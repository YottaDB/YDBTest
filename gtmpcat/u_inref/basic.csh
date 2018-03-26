#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Drive basic gtmpcat test - run test against all available versions >= V51000.
# Set $gtmpcat_test_versions to a blank delimited list of verisons to test if less than full run desired.
#
echo "Begin gtmpcat/basic test"
#
# Set/reset configuration flags. Some of these settings may be unnecessary as we mostly do our own
# database setups but leave them in as indicators of the environment we want.
#
set keepcores = 0
if ($?gtmpcat_keep_cores) set keepcores = 1
setenv gtm_boolean 0	                # gtmpcat has a non-boolean dependency
setenv gtm_side_effects 0     	        # gtmpcat has a non-sideeffect dependency
setenv test_encryption NON_ENCRYPT    	# encryption gets in the way of what we are testing
unsetenv gtm_trace_gbl_name             # Undo random MProfiling setting - we do our own selection
setenv gtm_test_tls 0			# No encryption to bog things down - at least for now
unsetenv gtm_custom_errors		# Otherwise version test runs with defines the custom error file - even if doesn't have one
setenv gtm_test_dynamic_literals "NODYNAMIC_LITERALS" # No dynamic literals to slow things down
setenv gtm_test_embed_source "NOEMBED_SOURCE" # No imbedding of source
setenv acc_meth "BG"   			# We control our own MM/BG distribution by version
setenv gtm_test_tls FALSE		# No TLS to slow things down
setenv gtm_test_fake_enospc 0		# Don't slow test down with auto-freezes
unsetenv gtmcompile	    		# In case it snuck through somehow - causes problems for gengtmtypedefs.csh
set pushdsilent = 1			# Make pushd/popd silent
#
# Setup port used for socket creation and the replication port
#
source $gtm_tst/com/portno_acquire.csh >> socketportno.out
setenv socketportno $portno
source $gtm_tst/com/portno_acquire.csh >> replportno.out
setenv replportno $portno
#
# Core file setup. For HPUX-IA64 and Solaris, execute appropriate coreadm commands so core files behave properly
#
source $gtm_tst/com/set_gtm_machtype.csh
if (("sunos" == "$gtm_test_osname") || (("hp-ux" == "$gtm_test_osname") && ("ia64" == "$gtm_test_machtype"))) then
    coreadm -pcore.%p
endif
set errors = 0
#
# By adding gtmtest.csh option -env "work_dir=$HOME/<work>/<workdir>", contents of work directories can be driven
# with this test. There are 4 pieces to this test which can live either in $cms_tools or can live in a workdirectory.
# If $work_dir is defined, see if it contains any of gtmpcat.m, gtmpcatfldbld.m, gtmpcatfldbld.csh, or gtmpcat_field_def.txt. If
# so, use those versions rather than the ones in $cms_tools.
#
setenv fldblddir "$tst_working_dir/gtmpcatfldbld"
mkdir $fldblddir
pushd $fldblddir
#
set pcatfbcsh = "$cms_tools/gtmpcatfldbld.csh"
set pcatm = "$cms_tools/gtmpcat/gtmpcat.m"
set pcatfbm = "$cms_tools/gtmpcat/gtmpcatfldbld.m"
set pcatfdt = "$cms_tools/gtmpcat/gtmpcat_field_def.txt"
if ($?work_dir) then
    if (-e $work_dir) then
	if (-e $work_dir/tools/cms_tools/gtmpcatfldbld.csh) set pcatfbcsh = "$work_dir/tools/cms_tools/gtmpcatfldbld.csh"
	if (-e $work_dir/tools/cms_tools/gtmpcat/gtmpcat.m) set pcatm = "$work_dir/tools/cms_tools/gtmpcat/gtmpcat.m"
	if (-e $work_dir/tools/cms_tools/gtmpcat/gtmpcatfldbld.m) set pcatfbm = "$work_dir/tools/cms_tools/gtmpcat/gtmpcatfldbld.m"
	if (-e $work_dir/tools/cms_tools/gtmpcat/gtmpcat_field_def.txt) set pcatfdt = "$work_dir/tools/cms_tools/gtmpcat/gtmpcat_field_def.txt"
    endif
endif
ln -s $pcatfbcsh ./gtmpcatfldbld.csh
ln -s $pcatm ./gtmpcat.m
ln -s $pcatfbm ./gtmpcatfldbld.m
ln -s $pcatfdt ./gtmpcat_field_def.txt
#
# Build the field initialization files needed by gtmpcat. First step, determine a version list we are testing.
#
set testver = "$gtm_verno"  # save so we restore this version to run gtmpcat
#
# If $?gtmpcat_test_versions is set, use that set of
#
if ($?gtmpcat_test_versions) then
    set pcatvers = "$gtmpcat_test_versions"
else
    set pcatvers = `$gtm_tst/$tst/u_inref/findvers.csh`
endif
gtmpcatfldbld.csh $pcatvers >& fldbld.log.txt     # use .txt extention to prevent log file from being appended to test log
popd
#
# Check if any errors encountered while generating initialization files and copy to output file if so.
#
echo "Any errors from gtmpcatfldbld are shown here"
$grep -E 'GTMPCATFLDBLD-[EF]-|GTMPCAT-[EF]-' $fldblddir/fldbld.log.txt
$echoline
echo "Any errors during running of makedmp.csh on each requested version are shown here"
#
# Loop through each version generating core file, processing it and creating output report file.
#
foreach pcatver ($pcatvers)
    #
    # Switch to the version to test
    #
    source $gtm_tst/com/switch_gtm_version.csh $pcatver $tst_image
    #
    # record the directory so we can pass it to gtmpcat
    #
    set gtm_dist_dmp = "$gtm_dist"
    #
    # This will (re)create as many as 9 core files (but also clears old version text files)
    #
    $gtm_tst/$tst/u_inref/makedmp.csh >& makedmp-${pcatver}.log.txt
    #
    # Switch back to our production version
    #
    source $gtm_tst/com/switch_gtm_version.csh $testver $tst_image >& /dev/null
    setenv gtmroutines "$gtmroutines $fldblddir"
    #
    # Run gtmpcat on the generated core file for mumps (id is saved in mumps.coreid). If this version is also the test-submit version,
    # enable MProfiling.
    #
    set mumpscorename = `cat mumps.coreid`
    if ("$mumpscorename" == "") then
	echo "TEST-E-MISSCORE Core is missing for mumps process - cannot continue"
	goto errorexit
    endif
    echo "Processing $mumpscorename as a mumps core" > gtmpcat-${pcatver}.log.txt
    echo >> gtmpcat-${pcatver}.log.txt
    set mprofoption = ""
    if (! $?gtmpcat_nomprof && ("$pcatver" == "$testver")) then
	#
	# Need to create a db we can use to hold M-Profiling info (existing test DBs are largely replicated thus not good to use).
	#
	setenv gtmgbldir "gtmpcat.gld"
	$gtm_dist/mumps -run ^GDE << EOF >& mprofdb.create.txt
change -segment DEFAULT -file=gtmpcat.dat
exit
EOF
	$gtm_dist/mupip create >& mprofdb.create.txt
	set mprofoption = "-p"
    endif
    $gtm_dist/mumps -run gtmpcat -lrmdtvo $gtm_dist_dmp gtmpcatList.mumps.${pcatver}.txt --lvdetail --lkdetail --msdetail $mprofoption $mumpscorename >>& gtmpcat-${pcatver}.log.txt
    if (-e gtmpcat-DEBUG.zshowdump.txt) mv gtmpcat-DEBUG.zshowdump.txt gtmpcatList.mumps.${pcatver}-DEBUG.zshowdump.txt
    #
    # Drive the interactive script (-cmdscript) against the main mumps core as well to validate that method of execution. If the
    # version being run doesn't have a GTMDefinedTypesInit.m file, create one and remove it after. Note - not used for Solaris
    # versions prior to V54000 because scantypedefs.m doesn't correctly support the early Solaris versions (deprecated options).
    #
    if (("sunos" != "$gtm_test_osname") || (`expr "V54000" \<= $pcatver`)) then
	echo >> gtmpcat-${pcatver}.log.txt
	echo "Re-Processing $mumpscorename with interactive routine IAERtest" >>& gtmpcat-${pcatver}.log.txt
	set deftypesdir = $gtm_dist_dmp
	if (! -e ${gtm_dist_dmp}/GTMDefinedTypesInit.m) then
	    echo "(Building GTMDefinedTypesInit.m for this version as it is not present in $gtm_dist_dmp" >> gtmpcat-${pcatver}.log.txt
	    $cms_tools/builddefinedtypes/gengtmdeftypes.csh $pcatver $tst_image >>& gtmpcat-${pcatver}.log.txt
	    set deftypesdir = "."
	endif
	$gtm_dist/mumps -run gtmpcat -dvgs $gtm_dist_dmp $deftypesdir ^IAERtest $mumpscorename >>& gtmpcat-${pcatver}.log.txt
	if (-e gtmpcatIAER-DEBUGTRC.zshowdump.txt) mv gtmpcatIAER-DEBUGTRC.zshowdump.txt gtmpcatIAER-${pcatver}-DEBUGTRC.zshowdump.txt
	if (-e gtmpcat-DEBUG.zshowdump.txt) mv gtmpcat-DEBUG.zshowdump.txt gtmpcatIAER-${pcatver}-DEBUG.zshowdump.txt
	rm -f GTMDefinedTypesInit.* >& /dev/null		# If we created it (src and/or object), remove it
    endif
    #
    # We also have a mumps core in the 2ndary directory. Process it too
    #
    set mumpscorename2ndary = `cat mumps2ndary.coreid`
    $gtm_dist/mumps -run gtmpcat -lrmdvto $gtm_dist_dmp gtmpcatList.2ndrymumps.${pcatver}.txt --lvdetail --lkdetail --msdetail $mprofoption repl2ndary/$mumpscorename2ndary >& gtmpcat-2ndrymumps-${pcatver}.log.txt
    if (-e gtmpcat-DEBUG.zshowdump.txt) mv gtmpcat-DEBUG.zshowdump.txt gtmpcatList.2ndrymumps.${pcatver}-DEBUG.zshowdump.txt
    #
    # Dispose of core files. We either (1) rename it so doesn't cause test failure or (2) delete it. Choice
    # depends on setting of keepcores setting. A full test run keeping cores can consume > 16GB and take
    # half way to forever to gzip..
    #
    if ($keepcores) then
	mv ${mumpscorename} gtmpcat-mumpsdmp-primary.${pcatver}.${mumpscorename}
	mv repl2ndary/${mumpscorename2ndary} gtmpcat-mumpsdmp-secondary.${pcatver}.${mumpscorename2ndary}
    else
	rm -f ${mumpscorename} >& /dev/null
	rm -f repl2ndary/${mumpscorename2ndary} >& /dev/null
    endif
    #
    # The remaining core files are from mupip (primary source, secondary src, secondary updproc, secondary receiver, helper procs [2 each read/write])
    #
    setenv updproccore ""
    set corelist = `find . -name "core*" -print | $tst_awk '{gsub(/\.\//,""); if ($1 != coreid) flist = flist " " $1} END {print flist}' coreid=$mumpscorename`
    if ($#corelist < 8) then           # Should be 8 cores left from 4 helpers, 2 source servers, 1 receiver and 1 update process
	echo "Insufficient cores generated for ${pcatver} - processing what we have"
    endif
    foreach corename ($corelist)
	set base = ${corename:t}
	if ("$base" == "$corename") then
	    set dir = "primary"
	else
	    set dir = "secondary"
	endif
	echo >> gtmpcat-${pcatver}.log.txt
	echo "Processing $corename as a mupip core" >> gtmpcat-${pcatver}.log.txt
	echo >> gtmpcat-${pcatver}.log.txt
	$gtm_dist/mumps -run gtmpcat -lrmvdo $gtm_dist_dmp gtmpcatList.mupip-${dir}.${pcatver}.${base}.txt --mupip $corename >>& gtmpcat-${pcatver}.log.txt
	if (-e gtmpcat-DEBUG.zshowdump.txt) mv gtmpcat-DEBUG.zshowdump.txt gtmpcatList.mupip-${dir}.${pcatver}.${base}-DEBUG.zshowdump.txt
	$grep "updproc_actions" gtmpcatList.mupip-${dir}.${pcatver}.${base}.txt >& /dev/null
	if (0 == $status) setenv updproccore "$base"         # Make sure we know which core is the update process so we can run interactive mode on it
	if ("${corename}" != "repl2ndary/$updproccore") then # Don't remove/rename update process core till run interactive mode on it
	    if ($keepcores) then
		mv ${corename} gtmpcat-mupipdmp-${dir}.${pcatver}.${base}
	    else
		rm -f ${corename} >& /dev/null
	    endif
	endif
    end
    #
    # Make sure we found an updproc core file - if not something bad happened so stop right here
    #
    if ("" == "${updproccore}") then
	echo "TEST-E-MISSUPDCORE Update process core report not found - may have errored out or core may be missing - saving repl2ndry as missupdcore.${pcatver}"
	mv repl2ndary missupdcore.${pcatver}
	goto errorexit
    endif
    #
    # Run interactive mode on the updproc core to verify those commands work correctly
    #
    $gtm_dist/mumps -run gtmpcat -irvcd $gtm_dist_dmp $gtm_tst/$tst/inref/makedmp_cmds.txt --mupip repl2ndary/${updproccore} >& gtmpcatIntList.mupip-${dir}.${pcatver}.${updproccore}.txt
    if (-e gtmpcat-DEBUG.zshowdump.txt) mv gtmpcat-DEBUG.zshowdump.txt gtmpcatIntList.mupip-${dir}.${pcatver}.${base}-DEBUG.zshowdump.txt
    if ($keepcores) then
	mv repl2ndary/${updproccore} gtmpcat-mupipdmp-secondary.${pcatver}.${updproccore}
    else
	rm -f repl2ndary/${updproccore} >& /dev/null
    endif
    #
    # Rename the replication logs so they aren't pulled into the test log (we expext GTM-F-KILLBYSIG* errors in logs along with cores).
    # If the files don't exist due to other errors, don't add to the carnage.
    #
    mv repl.src.log repl.src.log-${pcatver}.txt >& /dev/null
    set loglist = `ls -1 repl2ndary/repl*log* repl2ndary/repl*.txt`
    foreach logname ($loglist)
	set newlogname = `echo $logname | sed "s/log/log\-$pcatver/" | sed "s,repl2ndary,$tst_working_dir,"`
	mv $logname ${newlogname}.txt >& /dev/null
    end
    #
    # Rename the mupip rundown log which is separated from the makedmp log because the makedmp log is scanned and lots of
    # irrelevant errors occur there (DBRDONLY, CRYPTINIT, etc). File should exist but check anyway.
    #
    if (-e mupip_rundown_log.txt) mv mupip_rundown_log.txt mupip_rundown_${pcatver}.txt
    #
    # Scan the makedmp logs for spurious GT.M errors. There should be exactly one error (KILLBYSIG*) in each log.
    #
    set errcnt = `$grep -Ec "GTM-[EF]-" makedmp-${pcatver}.log.txt`
    if ($errcnt > 1) then
	echo "Extraneous errors in makedmp run for ${pcatver}:"
	$grep -E "GTM-[WEF]-" makedmp-${pcatver}.log.txt | $grep -v "killed by a signal 4"
	echo
    endif
end
errorexit:
#
# Look for gtmpcat errors and/or error files
#
$echoline
echo "Any errors in gtmpcat on mumps or mupip processes are shown here"
$grep -E 'GTMPCAT-[WEF]-' gtmpcat-V*.log.txt
$grep -E 'GTM-[WEF]-' gtmpcat-V*.log.txt
$grep -E 'GTMPCAT-[WEF]-' gtmpcatIntList*.txt
/bin/ls -l | $grep gtmpcat-fail
$echoline
#
# If the test was run with all versions (i.e. $gtmpcat_test_versions was not set), Perform analysis of memory usage by the
# makedmp.m routine using the gtmpcat report for the mumps versions. Drive routine ^memanal to do the analysis.
#
$grep "Total                              " gtmpcatList.mumps.*.txt > memuse.log
if (! $?gtmpcat_test_versions) then
    $gtm_dist/mumps -run ^memanal
else
    echo 'No memory usage analysis done due to presence of $gtmpcat_test_versions'
endif
#
# Before we skidaddle, if there's still a YDB_FATAL_ERROR file, remove it as it will cause the test to fail. The jobexam file created
# is just as good as it was created one (M) line of code before makedmp.m suicided.
#
rm -f YDB_FATAL_ERROR.* >& /dev/null
rm -f repl2ndary/YDB_FATAL_ERROR.* >& /dev/null
#
# Release both ports acquired. Needs $portno to be correct and match portno.out.
#
cp replportno.out portno.out
source $gtm_tst/com/portno_release.csh     # release repl portno
setenv portno $socketportno
cp socketportno.out portno.out
source $gtm_tst/com/portno_release.csh     # release socket portno
#
echo "End gtmpcat/basic test"
