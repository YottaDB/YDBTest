#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2008-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018-2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#;;;Test the unix bahavior of the pipe device with both M and unicode tests
#;;;This work was done under the tr C9H05-002859
#;;;
# The following table shows the state conditions for timed reads for both the pipe and fifo
# devices.  It shows any modifications to the input variable X and Status Variables.
# There is coverage in the tests for each of these conditions for both the pipe and fifo devices.
# When a test is doing a timed read and no error or EOF condition will occur then the following
# form is used to wait for the data to be read into x.
# for  read x:0 quit:x'=""
# When data is read, x will not be null and the for loop will terminate.

# Operation		Result			$DEVICE		$ZA	$TEST		X	$ZEOF
#
# READ X:1	  Normal Termination		   0		 0	  1	    Data Read     0
# READ X:1       Timeout with no data read	   0		 0	  0	  empty string	  0
# READ X:1     Timeout with partial data read	   0		 0	  0       Partial data    0
# READ X:1		End of File     1,Device detected EOF	 9	  1       empty string    1
# READ X:0	  Normal Termination		   0		 0	  1	    Data Read	  0
# READ X:0	  No data available		   0		 0	  0	  empty string	  0
# READ X:0     Timeout with partial data read	   0		 0	  0	  Partial data	  0
# READ X:0		End of File	1,Device detected EOF	 9	  1	  empty string	  1
# READ X:N		Error		1,<error signature>	 9  indeterminate empty string	  0

$switch_chset M

# Create one-region gld and associated .dat file
$gtm_tst/com/dbcreate.csh mumps 1

# build the c routines for the tests
$gt_cc_compiler -o echoback -I$gtm_tst/$tst/inref -I$gtm_dist $gtm_tst/$tst/inref/echoback.c
rm -f echoback.o
$gt_cc_compiler -o strip_cr -I$gtm_tst/$tst/inref -I$gtm_dist $gtm_tst/$tst/inref/strip_cr.c
rm -f strip_cr.o
$gt_cc_compiler -o ntestin -I$gtm_tst/$tst/inref -I$gtm_dist $gtm_tst/$tst/inref/ntestin.c
rm -f ntestin.o

# The blockedwrite test must be first so gtm_non_blocked_write_retries will use the default value
$echoline
echo "**************************** blockedwrite ***********************"
$gtm_dist/mumps -run blockedwrite >& blockedwrite.out
$echoline
setenv pipecnt `$grep -c pipe blockedwrite.out`
if (0 < $pipecnt) then
    echo "ztrap taken for pipe full"
    echo "Total number of lines successfully written to pipe:"
endif

$grep -c "abc" blockedwrite.out

$echoline
echo "**************************** blockedfifo ****************************"
$echoline
$gtm_dist/mumps -run blockedfifo
$gtm_tst/com/wait_for_log.csh -log blkfiforead.mjo -message "10000" -duration 60
if (0 == $status) then
	wc -l blkfiforead.mjo | $tst_awk '{print "Number of lines read = " $1}'
	$tail -n 5 blkfiforead.mjo
	setenv fifocnt `$grep -c fifo blkfifowrite.mjo`
	if (0 < $fifocnt) then
		echo "ztrap taken for fifo full"
	endif
endif

# set gtm_non_blocked_write_retries to 300 so writes will not block for loops with read x:0 in them
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_non_blocked_write_retries gtm_non_blocked_write_retries 300

$echoline
echo "**************************** catback2 ****************************"
$echoline
$gtm_dist/mumps -run catback2
if (("osf1" != $gtm_test_osname) && ("os390" != $gtm_test_osname)) then
	$echoline
	echo "**************************** ioescape ****************************"
	$echoline
	setenv TERM xterm
	expect -f $gtm_tst/$tst/u_inref/ioescape.exp $gtm_dist
endif
$echoline
echo "**************************** alternate ****************************"
$echoline
# turn on journaling for alternate to test child closing of database and journaling files
source $gtm_tst/com/leftover_ipc_cleanup_if_needed.csh $0 # do rundown if needed before requiring standalone access
$gtm_dist/mupip set -journal=enable,on,nobefore -region "*"
$gtm_dist/mumps -run alternate
# turn off journaling
$gtm_dist/mupip set -file -nojournal mumps.dat
$echoline
echo "**************************** docat4 ******************************"
$echoline
$gtm_dist/mumps -run docat4
echo "Last 2 lines of out1:"
$tail -n 2 out1
echo "Last 2 lines of out2:"
$tail -n 2 out2
echo "Last 2 lines of out3:"
$tail -n 2 out3
echo "Last 2 lines of out4:"
$tail -n 2 out4
$echoline
echo "**************************** justread *****************************"
$echoline
$gtm_dist/mumps -run justread >& justread.out
echo "Expect the word "'"justread"'":"
$tail -n 1 justread.out | $tst_awk '{print $NF}'
$echoline
echo "**************************** readstar *****************************"
$echoline
$gtm_dist/mumps -run readstar
$echoline
echo "**************************** readpound ****************************"
$echoline
$gtm_dist/mumps -run readpound

if ("TRUE" == $gtm_test_unicode_support) then
# Large block containing GTM input redirection commands.  Not indenting.
$switch_chset UTF-8

$echoline
echo "**************************** utf3 *********************************"
$echoline
$gtm_dist/mumps -dir >& utf3.out <<here
set od="utf.in"
open od:newversion
use od
set a=10
for j=1:1:10 do ^u50
close od:timeout=1000
write "od \$ZCLOSE= ",\$ZCLOSE,!
if \$ZCLOSE halt
set sd="utf.in"
open sd
set t="p1"
open t:(comm="cat > temputf.out":OCHSET="UTF-16")::"pipe"
for m=1:1:10 use sd read x use t write x,!
close t:timeout=1000
write "t \$ZCLOSE= ",\$ZCLOSE,!
if \$ZCLOSE halt
close sd:timeout=1000
write "sd \$ZCLOSE= ",\$ZCLOSE,!
if \$ZCLOSE halt
set td="getinput"
open td:(comm="cat temputf.out":ICHSET="UTF-16")::"pipe"
set t2="p2"
open t2:(comm="cat > utf.out":writeonly)::"pipe"
for m=1:1:10 use td read x use t2 write x,!
close t2:timeout=1000
write "t2 \$ZCLOSE= ",\$ZCLOSE,!
halt
here
# if utf.out doesn't exist then we terminated the here doc early so exit now
if (! -e utf.out) exit 1
echo "diff between utf.in and utf.out:"
diff utf.in utf.out
$echoline
echo "**************************** tutf3 ********************************"
$echoline
echo "Expect last 5 lines with 50 utf8 characters per line and total number of characters in tutf3.out"
$gtm_dist/mumps -r tutf3 1 > tutf3.out
$tail -n 6 tutf3.out
wc -c tutf3.out | $tst_awk '{print "total bytes = " $1}'
$echoline
echo "**************************** tutf4 ********************************"
$echoline
echo "Expect last 5 lines with 50 utf8 characters per line and total number of characters in tutf4.out"
$gtm_dist/mumps -r tutf3 2 > tutf4.out
$tail -n 6 tutf4.out
wc -c tutf4.out | $tst_awk '{print "total bytes = " $1}'
$echoline
echo "**************************** tutf5 ********************************"
$echoline
echo "Expect last 6 lines with 35 utf8 characters on one line followed by 15 utf8 characters on next line and total number of characters in tutf5.out"
$gtm_dist/mumps -r tutf3 3 > tutf5.out
$tail -n 6 tutf5.out
wc -c tutf5.out | $tst_awk '{print "total bytes = " $1}'
$echoline
echo "**************************** tutf6 ********************************"
$echoline
echo "Expect last 6 lines with 35 utf8 characters per line and total number of characters in tutf6.out"
$gtm_dist/mumps -r tutf3 4> tutf6.out
$tail -n 6 tutf6.out
wc -c tutf6.out | $tst_awk '{print "total bytes = " $1}'
$echoline
echo "**************************** badinput2 ****************************"
$echoline
$gtm_dist/mumps -r badinput2

$echoline
echo "***** use read x:5 and pipe to the application strip_cr ******"
$echoline
echo "Write 50 UTF character per line"
$gtm_dist/mumps -r testutf1 1 > testutf1.out
$tail -n 3 testutf1.out
wc -c testutf1.out | $tst_awk '{print "total bytes = " $1}'
echo "Write 1000 UTF character per line"
$gtm_dist/mumps -r testutf1 2 > testutf2.out
$tail -n 3 testutf2.out
wc -c testutf2.out | $tst_awk '{print "total bytes = " $1}'
$echoline
echo "***** use read x:0 and pipe to the application strip_cr ******"
$echoline
echo "Write 50 UTF character per line"
$gtm_dist/mumps -r testutf2 1 > testutf3.out
$tail -n 3 testutf3.out
wc -c testutf3.out | $tst_awk '{print "total bytes = " $1}'
echo "Write 1000 UTF character per line"
$gtm_dist/mumps -r testutf2 2 > testutf4.out
$tail -n 3 testutf4.out
wc -c testutf4.out | $tst_awk '{print "total bytes = " $1}'
$echoline
echo "***** pipe to cat -u so do not timeout and use read x *****"
$echoline
echo "Write 50 UTF character per line"
$gtm_dist/mumps -r testutf3 1 > testutf5.out
$tail -n 3 testutf5.out
wc -c testutf5.out | $tst_awk '{print "total bytes = " $1}'
echo "Write 1000 UTF character per line"
$gtm_dist/mumps -r testutf3 2 > testutf6.out
$tail -n 3 testutf6.out
wc -c testutf6.out | $tst_awk '{print "total bytes = " $1}'
$echoline
echo "Write utf characters one at a time to pipe and read back one at a time to show newline not inserted by read"
$gtm_dist/mumps -run ^%XCMD 'set p="test" open p:(comm="cat -u")::"pipe" for i=997:1:1022 use p write $CHAR(i) read x#1 use $p write x'
$echoline
echo "**************************** utftimeout ****************************"
$echoline
$gtm_dist/mumps -run utftimeout 0
$gtm_dist/mumps -run utftimeout 1

$echoline
echo "**************************** ureadstderr *****************************"
$echoline
$gtm_dist/mumps -run ureadstderr
$echoline
# End of UTF-8 section
endif

$switch_chset M
unsetenv LC_CTYPE

echo
echo "Write M characters one at a time to pipe and read back one at a time to show newline not inserted by read"
$gtm_dist/mumps -run ^%XCMD 'set p="test" open p:(comm="cat -u")::"pipe" for i=97:1:122 use p write $CHAR(i) read x#1 use $p write x'
echo
$echoline
echo "**************************** jread2 *******************************"
$echoline
$gtm_dist/mumps -run jread2 |& $tail -n 10
$echoline
echo "**************************** newread2 *****************************"
$echoline
$gtm_dist/mumps -run newread2 > newread2.out
$grep  " 999" newread2.out
$grep  " 1000" newread2.out
$echoline
echo "**************************** badlabel^badhandler ******************"
$echoline
$gtm_dist/mumps -direct << xxx
do BADLABEL^badhandler
halt
xxx
$echoline
echo "**************************** badcommand^badhandler ******************"
$echoline
$gtm_dist/mumps -direct << xxx
do BADCOMMAND^badhandler
halt
xxx
$echoline
echo "*********************** justbadlabel^badhandler entryref *********"
$echoline
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_ztrap_form gtm_ztrap_form entryref
$gtm_dist/mumps -direct << xxx
do JUSTBADLABEL^badhandler
halt
xxx
$echoline
echo "**************************** justgoodlabel^badhandler entryref *********"
$echoline
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_ztrap_form gtm_ztrap_form entryref
$gtm_dist/mumps -direct << xxx
do JUSTGOODLABEL^badhandler
halt
xxx
$echoline
echo "************************ badcommand^badhandler adaptive ***********"
$echoline
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_ztrap_form gtm_ztrap_form adaptive
$gtm_dist/mumps -direct << xxx
do BADCOMMAND^badhandler
halt
xxx
$echoline
echo "**************************** ex1 **********************************"
$echoline
$gtm_dist/mumps -run ex1
$echoline
echo "**************************** ex2 **********************************"
$echoline
$gtm_dist/mumps -run ex2
$echoline
echo "**************************** ex3 **********************************"
$echoline
$gtm_dist/mumps -run ex3
$echoline
echo "**************************** ex4 **********************************"
$echoline
$gtm_dist/mumps -run ex4
$echoline
echo "**************************** ex5 **********************************"
$echoline
$gtm_dist/mumps -run ex5
$echoline
echo "**************************** eofread **********************************"
$echoline
$gtm_dist/mumps -run eofread
$echoline
echo "**************************** writetrap ****************************"
$echoline
$gtm_dist/mumps -run writetrap
$echoline
echo "**************************** exnull ****************************"
$echoline
$gtm_dist/mumps -run exnull
$echoline
echo "************ test DEVICEWRITEONLY for pipe and file*******************"
$echoline
$gtm_dist/mumps -dir <<EOF |& $grep DEVICEWRITEONLY
write "Testing DEVICEWRITEONLY for file",!
set f="devwrite.txt"
open f:WRITEONLY
use f
read x
use \$p
write "Testing DEVICEWRITEONLY for pipe",!
set p="pipe"
open p:(comm="cat":WRITEONLY)::"pipe"
use p
read x
EOF
$echoline
echo "**************************** mtom ****************************"
$echoline
echo "Look in mtom.log and mtom2.log for ps -ef output" #BYPASSOK
$gtm_dist/mumps -run mtom
$echoline
echo "**************************** fexception ****************************"
$echoline
$gtm_dist/mumps -run fexception
$echoline
echo "**************************** mupipread ****************************"
$echoline
$gtm_dist/mumps -run mupipread
$echoline
echo "**************************** fix ****************************"
$echoline
$gtm_dist/mumps -run fix
$echoline
echo "**************************** badinput ****************************"
$echoline
$gtm_dist/mumps -run badinput
$echoline
echo "**************************** independent ****************************"
$echoline
# path to csh on OS/390 is /bin/tcsh
if ( $HOSTOS == "OS/390" ) then
	set shells="/usr/local/bin/tcsh /bin/sh /bin/tcsh"
else
	set ksh_path=`which ksh`
	set shells="/usr/local/bin/tcsh /bin/sh /bin/csh $ksh_path"
endif
# save the shell paths for reference in case of some error
echo $shells > independent_shells

foreach shellpath ($shells)
	set shell=$shellpath:t
	echo "Shell = $shell"
	$gtm_dist/mumps -run independent "$shellpath"
	set ntestin_pid=`$head -n 1 ntestin.pid`
	$gtm_tst/com/is_proc_alive.csh $ntestin_pid
	if (0 == $status) then
		echo "ntestin still running"
	endif
	# clean up ntestin and any shell executing it (such as csh)
	setenv pids `tr '\012' " " < ntestin.pid `
	foreach pid ($pids)
		# allow up to 30 sec for pid to be removed
		set cnt=0
		while ( 30 > $cnt )
			(kill -HUP $pid >& /dev/null) # BYPASSOK kill -HUP
			$gtm_tst/com/is_proc_alive.csh $pid
			if (1 == $status) then
				break
			endif
			sleep 1
			@ cnt++
		end
		if (30 == $cnt) then
			echo "pid\: $pid is still alive - error"
		endif
	end
end
$echoline
echo "**************************** fifozeof ****************************"
$echoline
$gtm_dist/mumps -run fifozeof
$gtm_tst/com/wait_for_log.csh -log fiforead.mjo -message "device" -duration 10
if (0 == $status) then
	cat fiforead.mjo
endif
$echoline
echo "**************************** fifovar ****************************"
$echoline
$gtm_dist/mumps -run fifovar
$gtm_tst/com/wait_for_log.csh -log fifovarread.mjo -message "DEVICEWRITE" -duration 120
if (0 == $status) then
	cat fifovarread.mjo
	#we don't want the accumulated error output
	mv fifovarread.mjo fifovarread_mjo.dontcheck
endif
$echoline
echo "**************************** fbadinput ****************************"
$echoline
$gtm_dist/mumps -run fbadinput
$echoline
echo "**************************** dollarx ****************************"
$echoline
$gtm_dist/mumps -run dollarx
$echoline
echo "**************************** dollarxy fixed ****************************"
$echoline
$gtm_dist/mumps -run dollarxy
$echoline
echo "**************************** gtmaspipedriver ****************************"
$echoline
$gtm_dist/mumps -run gtmaspipedriver
$tst_gzip_quiet gtmaspipeproc2.outx

if ("TRUE" == $gtm_test_unicode_support) then
	# now do it in utf-8 mode
	$switch_chset UTF-8
	$echoline
	echo "**************************** dollarx in utf-8 mode ****************************"
	$echoline
	$gtm_dist/mumps -run dollarx
	$echoline
	echo "**************************** dollarxy fixed in utf-8 mode ****************************"
	$echoline
	$gtm_dist/mumps -run dollarxy
	$switch_chset M
	unsetenv LC_CTYPE

	$echoline
	echo "**************************** shortutf ***********************"
	$echoline
	# make sure in M mode for creation of this file
	$gtm_dist/mumps -run ^%XCMD 'write $CHAR(239),$CHAR(187),$CHAR(191),"^",!' > uout_with_bom
	# verify output
	echo uout_with_bom:
        $gtm_dist/mumps -run ^%XCMD 'set in="uout_with_bom" open in for  use in read *x  quit:$zeof  use $p write x," "'
	echo "^" > uout_without_bom
	$convert_to_gtm_chset uout_without_bom
	echo uout_without_bom:
        $gtm_dist/mumps -run ^%XCMD 'set in="uout_without_bom" open in for  use in read *x  quit:$zeof  use $p write x," "'
	# make sure in UTF-8 mode for execution
	$switch_chset UTF-8
	$gtm_dist/mumps -run shortutf

	$echoline
	echo "**************************** utffifo ***********************"
	$echoline
	$gtm_dist/mumps -run utffifo
	$echoline
	echo "**************************** fbadinput2 ***********************"
	$echoline
	$gtm_dist/mumps -run fbadinput2
	$switch_chset M
	unsetenv LC_CTYPE
endif
$gtm_tst/com/dbcheck.csh
