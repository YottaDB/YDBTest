#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2011-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Disable implicit mprof testing to prevent failures due to extra memory footprint;
# see <mprof_gtm_trace_glb_name_disabled> for more detail
unsetenv gtm_trace_gbl_name
setenv gtm_poollimit 0 # Setting gtm_poollimit will cause some triggers to be reissued. Not desirable in this test.
#
# Also disable $gtm_boolean and $gtm_side_effects. This test uses gtmpcat which has some sensitivities to
# a lack of boolean-shortcutting so avoid explicit (by user) or implicit (by test randomization) setting
# of either of these flags (gtm_side_effects forces gtm_boolean).
#
setenv gtm_boolean 0	                # gtmpcat has a non-boolean dependency
setenv gtm_side_effects 0     	        # gtmpcat has a non-side-effect dependency
#
# Avoid gtmpcat setup for z/OS and Tru64
#
if (("OSF1" != $HOSTOS) && ("OS/390" != $HOSTOS)) then
  #
  # Setup for running gtmpcat
  #
  setenv gtmpcatinvoke "$cms_tools/gtmpcat.sh --memorydump "
  setenv gtmpcatfldbldinvoke "$cms_tools/gtmpcatfldbld.csh $gtm_verno"
  #
  # Since not always run with a production release, always regenerate the
  # initialization file.
  #
  $gtmpcatfldbldinvoke >& gtmpcatfldbld-log.txt
else
  setenv gtmpcatinvoke "notrun"
  setenv gtmpcatfldbldinvoke "notrun"
endif
$gtm_tst/com/dbcreate.csh .
#
# Need $gtmdbglvl set so gtmpcat can include the memory dump
#
setenv gtmdbglvl 1
#
# Test #1 - Verify operation with object files
#
echo
echo "############# Test 1 ##############################"
echo "Testing unlink with normal (linked in) object files"
cat > tulnk1.m << EOF
start(tstnum)
	Set \$ETrap="Goto Error^tulnk1"
        Set ^tstnum=tstnum
	Write " In tulnk1",!
	Do ^tulnk2
	Quit
;
Error
	If (\$ZStatus+0)=150373978 Do     ; If ZLINKFILE error, just print it and halt
	. Write \$ZStatus,!
	. Halt
	Write "FAIL - failure encountered",!
	ZShow "*"
	Halt
EOF
cat > tulnk2.m << EOF
	Write " In tulnk2",!
	Do ^tulnk3
	Quit
EOF
cat > tulnk3.m << EOF
	Write " In tulnk3",!
	Do ^tulnk4
	Quit
EOF
cat > tulnk4.m << EOF
	Write " In tulnk4",!
	Do ^tulnk5
	Quit
EOF
cat > tulnk5.m << EOF
	Write " In tulnk5",!
	Do ^tulnk6
	Quit
EOF
cat > tulnk6.m << EOF
	Write " In tulnk6 - Gathering info then doing zgoto",!
	; To effectively test storage reduction, use as much storage as we are going to in our stats gathering.
	; Run both before and after stats gathering, then delete them and gather real stats.
	Do
	. New i  ; used in bypassed verify routine. Now allocated (and popped) before we do the real runs
	. Do before^tulnkverf("dryrun")
	. Do after^tulnkverf("dryrun")
	Kill before,after
	Do before^tulnkverf("realrun")
	ZGoto 0:^allgone
	Write "zgoto failed",!
	ZShow "*"
	Quit
EOF
cat > allgone.m << EOF
	Write "Everything is gone - verify cleanup",!
	Do after^tulnkverf("realrun")
	Set error=0
	If before("stor")<after("stor") Set error=1 Write "FAIL - storage increased",!
	If (after("level")>2)!(after("level")'<before("level")) Set error=1 Write "FAIL - level not correct",!
	If (after("rtns",0)>2)!(after("rtns",0)'<before("rtns",0)) Set error=1 Write "FAIL - loaded routines not as expected",!
	ZShow:(error) "*"
	Write "Exiting allgone",!
	Quit
EOF
set pcatawk=$gtm_tst/$tst/inref/unlnkpcat.awk # BYPASSOK
cat > tulnkverf.m << EOF
;
; Gather stats before we do the ZGOTO unlink
;
before(type)
	New x
	Set x=\$Stack(1,"PLACE") ; Prime the pump before generate stats
	Do state(.before)
	Do invokepcat("before",type)
	Quit

;
; Gather stats after we do the ZGOTO unlink
;
after(type)
	Do state(.after)
	Do invokepcat("after",type)
	Quit

;
; Gather M type stats (stack, storage level, routine list)
;
state(when)
	New i,rtn
	Set when("stor")=\$ZUsedstor
	Set when("level")=\$Stack(-1)
	For i=1:1:when("level") Set when("stack",i)=\$Stack(i,"PLACE")
	Set rtn=""
	For i=1:1 Set rtn=\$View("RTNNEXT",rtn) Quit:(""=rtn)  Set when("rtns",\$Increment(when("rtns",0)))=rtn
	Quit

;
; On platforms other than z/OS or Tru64, use gtmpcat to gather additional stats on the running routine. Gtmpcat
; is not supported at all on z/OS and with ladebug broken, doesn't work well on Tru64 either (but perhaps one
; day will work better using dbx).
;
invokepcat(when,type)
	New fname,host
	Set host=\$ZPiece(\$ZVersion," ",3)
	Do:(("OS390"'=host)&("OSF1"'=host))
	. Set fname="gtmpcatOutput-test"_^tstnum_"-"_when_".txt"
	. ZSystem "${gtmpcatinvoke}"_"-output "_fname_" "_\$Job_" >> gtmpcat_run.log"
	. Open fname:(Readonly:Exception="Write ""FAIL - gtmpcat failed - see gtmpcat_run.log"",! ZShow ""*"" Halt")
	. Close fname
	. Kill *pcatwhen
	. If "before"=when Set *pcatwhen=pcatbefore
	. Else  Set *pcatwhen=pcatafter
	. Do CommandToPipe("$tst_awk -f $pcatawk "_fname,.pcatwhen)
	. Do:(1'=pcatwhen(0))
	. . Write "FAIL - unlnkpcat.awk failed",! ; BYPASSOK
	. . ZShow "*"
	. . Halt
	. Do:(("after"=when)&("realrun"=type)) verifypcat(pcatbefore(1),pcatafter(1),\$Select(1=^tstnum:0,1:1))
	Quit
;
; Routine to execute a command in a pipe and return the executed lines in an array
;
CommandToPipe(cmd,results)
	New pipecnt,pipe,saveIO
	Kill results
	Set pipe="CmdPipe"
	Set saveIO=\$IO
	Open pipe:(Shell="/bin/sh":Command=cmd)::"PIPE"
	Use pipe
	Set pipecnt=1
	For  Read results(pipecnt) Quit:\$ZEOF  Set pipecnt=pipecnt+1
	Close pipe
	Set results(0)=pipecnt-1
	Kill results(pipecnt)
	Use saveIO
	Quit
;
; Verify the gtmpcat stats are such that after stats show a reduction of resources. Also
; verify that the shared library was released (if requested).
;
verifypcat(before,after,expectlib)
	New i
	Do:(7'=\$ZLength(before," "))!(7'=\$Zlength(after," "))
	. Write "FAIL - input strings not of expected composition",!
	. ZShow "*"
	. Halt
	For i=1:1:6 Do
	. ;
	. ; Bypass check for field 2 (shared storage size) if not expecting a shared library
	. ;
	. Quit:('expectlib&(i=2))
	. ;
	. ; Bypass check for fields 5/6 (storage pieces and bytes) if Linux x86 because the program
	. ; storage used by this model is all mmap() storage allocated by gtm_text_alloc() which is
	. ; not reported by gtmpcat.
	. ;
	. Quit:(("x86"=\$ZPiece(\$ZVersion," ",4))&((5=i)!(6=i)))
	. If \$ZPiece(before," ",i)'>\$ZPiece(after," ",i) Do
	. . Write "FAIL - count for field ",i," not reduced after ZGOTO",!
	. . ZShow "*"
	. . Halt
	If (\$ZPiece(before," ",7)'=expectlib)!\$ZPiece(after," ",7) Do
	. Write "FAIL - detected shared library where none should be found",!
	. ZShow "*"
	. Halt
	Write "gtmpcat output verified",!
EOF
$gtm_dist/mumps -run %XCMD 'Do start^tulnk1(1)'
$echoline
#
# If this is Linux x86, branch around test 2 which requires shared libraries
#
if ("HOST_LINUX_IX86" == "$gtm_test_os_machtype") then
    goto bypasstest2
endif
#
###################################################################
#
# Test #2 - Verify operation with shared libraries
#
echo
echo "############# Test 2 ##############################"
echo "Testing unlink with modules in shared libraries"
#
# Need to make a slight adjustment to tulnk6 to reset $ZRoutines so it picks up allgone from there
#
\rm -f tulnk6.m >& /dev/null
cat > tulnk6.m << EOF
	Write " In tulnk6 - Gathering info then doing zgoto",!
	; To effectively test storage reduction, use as much storage as we are going to in our stats gathering.
	; Run both before and after stats gathering, then delete them and gather real stats.
	Do before^tulnkverf("dryrun")
	Do after^tulnkverf("dryrun")
	Kill before,after
	Do before^tulnkverf("realrun")
	Set \$ZRoutines="gtmunlnklib2$gt_ld_shl_suffix"
	ZGoto 0:^allgone
	Write "zgoto failed",!
	ZShow "*"
	Quit
EOF
$gtm_dist/mumps tulnk6.m
$gt_ld_m_shl_linker ${gt_ld_option_output} gtmunlnklib1$gt_ld_shl_suffix tulnk1.o tulnk2.o tulnk3.o tulnk4.o tulnk5.o tulnk6.o tulnkverf.o ${gt_ld_m_shl_options} >>& tstunlink_gtmunlnklib1map.txt
$gt_ld_m_shl_linker ${gt_ld_option_output} gtmunlnklib2$gt_ld_shl_suffix allgone.o tulnkverf.o ${gt_ld_m_shl_options} >>& tstunlink_gtmunlnklib2map.txt
\mkdir oldtulnk
\mv tulnk*.m tulnk*.o allgone.* oldtulnk   # Get rid of both M source and object files so we know we are resolving from the shared lib(s)
cat > tulnk0.m << EOF
start(tstnum)
	; Set \$ZRoutines several times which to verify it does not re-dlopen() the libraries like it used to
	Set \$ZRoutines="gtmunlnklib1$gt_ld_shl_suffix"
	Set \$ZRoutines="gtmunlnklib1$gt_ld_shl_suffix"
	Set \$ZRoutines="gtmunlnklib1$gt_ld_shl_suffix"
	Set \$ZRoutines="gtmunlnklib1$gt_ld_shl_suffix"
	Set \$ZRoutines="gtmunlnklib1$gt_ld_shl_suffix"
	Set \$ZRoutines="gtmunlnklib1$gt_ld_shl_suffix"
	Set \$ZRoutines="gtmunlnklib1$gt_ld_shl_suffix"
	Do start^tulnk1(tstnum)
	Quit
EOF
$gtm_dist/mumps -run %XCMD 'Do start^tulnk0(2)'
$echoline
bypasstest2:
#
###################################################################
#
# Test #3 - verify get error before zgoto if unable to effect transfer to target entryref
#
echo
echo "############# Test 3 ##############################"
echo "Testing error path - expect ZLINKFILE error for missing allgone routine but should still have full stack"
#
# Modify tulnk6.m so it doesn't have access to allgone (no zroutines change). Note some care is taken here to do
# the right thing depending on whether this is Linux x86 (no shared libs) or an SHBIN platform..
#
\rm -f tulnk6.m >& /dev/null
cat > tulnk6.m << EOF
	Write " In tulnk6 - Gathering info then doing zgoto - expect error",!
	ZGoto 0:^allgone
	Write "zgoto failed",!
	ZShow "*"
	Quit
EOF
if ("HOST_LINUX_IX86" != "$gtm_test_os_machtype") then
    \rm gtmunlnklib1$gt_ld_shl_suffix
    \rm gtmunlnklib2$gt_ld_shl_suffix
    \cp oldtulnk/*.o .
    $gtm_dist/mumps tulnk6.m
    $gt_ld_m_shl_linker ${gt_ld_option_output} gtmunlnklib1$gt_ld_shl_suffix tulnk1.o tulnk2.o tulnk3.o tulnk4.o tulnk5.o tulnk6.o tulnkverf.o ${gt_ld_m_shl_options} >>& tstunlink_gtmunlnklib1map.txt
    \rm -f tulnk*.m tulnk*.o >& /dev/null
    set zroutines="gtmunlnklib1${gt_ld_shl_suffix}"
else
    set zroutines="$gtmroutines"
endif
\rm -f tulnk6.o allgone.* tulnk0.* >& /dev/null
cat > tulnk0.m << EOF
start(tstnum)
	Set \$ZRoutines="$zroutines"
	Do start^tulnk1(tstnum)
	Quit
EOF
$gtm_dist/mumps -run %XCMD 'Do start^tulnk0(3)'
$echoline
#
###################################################################
#
# Test #4 - verify get error attempting to do unlink with a callin on the stack
#
echo
echo "############# Test 4 ##############################"
echo "Testing error path - expect ZGOCALLOUTIN when stack has a call-in on it"
#
setenv GTMCI simpleci.tab
cat >> $GTMCI << EOF
simpleci:  void ^simpleci()
EOF
#
if ( "os390" == $gtm_test_osname ) then
	# Save the normal LIBPATH and append the desired paths for call ins to work
	set old_libpath=${LIBPATH}
	setenv LIBPATH ${tst_working_dir}:${gtm_exe}:.:${LIBPATH}
	# Apparently on z/OS the the sidedeck must be specified for the call out DLL
	setenv tst_ld_sidedeck "-L$gtm_dist $tst_ld_gtmshr"
else
	setenv tst_ld_sidedeck ""
endif
$gt_cc_compiler $gt_cc_options_common $gtm_tst/$tst/inref/driveci.c -I$gtm_dist
$gt_ld_linker $gt_ld_option_output driveci $gt_ld_options_common driveci.o $gt_ld_sysrtns $ci_ldpath$gtm_dist -L$gtm_dist $tst_ld_gtmshr $gt_ld_syslibs $tst_ld_sidedeck >& link.map
if( $status != 0 ) then
    cat link.map
endif
rm -f  link.map
#
driveci
unsetenv $GTMCI
$echoline
if ( "os390" == $gtm_test_osname ) then
	# Restore the normal LIBPATH
	setenv LIBPATH $old_libpath
endif
unsetenv tst_ld_sidedeck
#
###################################################################
#
# Test #5 - Generate 200 random routines (they just have a QUIT in them),
#           plus a "main" routine. The main routine has a ZBREAK command
#           for each generated routine plus the code to do an unlink-all.
#           This verifies we don't have issues with the find_rtn_hdr() rtn
#           that the clearing of the zbreak performs.
#
echo
echo "############# Test 5 ##############################"
echo "Test unlink with many routines with ZBREAKs in them"
$gtm_dist/mumps -run genrtns
#
if ("HOST_HP-UX_PA_RISC" != "$gtm_test_os_machtype") then
    ###################################################################
    #
    # Test #6 - Add some triggers to the database. Drive the triggers once
    #           so they are loaded when we do the unlink. Then drive the
    #	    triggers again to make sure they work. To make sure we aren't
    #	    driving the triggers that got released, create and zlink in a
    #	    couple routines the same size as the triggers before driving
    #	    the triggers. Bypass test on HPUX-HPPA
    echo
    echo "############# Test 6 ##############################"
    echo "Test unlink with active triggers"
    $gtm_dist/mupip trigger -trig=$gtm_tst/$tst/inref/unlinktrg.trg
    $gtm_dist/mumps -run unlinktrg
endif
#
# The test generates randomly named .m files. File names like awk.m that matches a valid framework m routine would cause troubles. Move them away
$gtm_tst/com/backup_dbjnl.csh randmroutines '*.m *.o' mv
$gtm_tst/com/dbcheck.csh
