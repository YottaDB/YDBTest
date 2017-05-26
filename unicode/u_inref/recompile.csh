#################################################################
#								#
#	Copyright 2006, 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
###############################################################################################
$echoline
cat << EOF
If an m routine is compiled with \$ZCHSET set to one setting, but executed when \$ZCHSET is set to another setting, GT.M
will error out. So we need to remove the object and compile it again.
EOF
###############################################################################################
$echoline
set echo; setenv gtm_chset "M"; unset echo
cp $gtm_tst/com/utfpattern.m .
$gtm_exe/mumps utfpattern.m
echo "#--> Check that the utfpattern.o (version 1) exists and note its sum (checksum or other information to see if it changes later on)."
ls -l utfpattern*.o >& ls1.out
set cnt = `wc ls1.out | $tst_awk '{print $1}'`
if (1 != "$cnt") then
	echo "TEST-E-ERROR The object file did not get created"
endif
cp -p utfpattern.o utfpattern_ver1.o
set sum1 = `sum utfpattern.o | $tst_awk '{print $1}'`

###############################################################################################
$echoline
$gtm_exe/mumps -run utfpattern >>! out2.out
echo "#--> Check that the utfpattern.o created above (version 1) was used."
$gtm_tst/com/wait_for_log.csh -log out2.out -duration 0 -grep -message "M in effect"
ls -l utfpattern*.o >& ls2.out
set sum2 = `sum utfpattern.o | $tst_awk '{print $1}'`
if ($sum2 != $sum1) then
	echo "TEST-E-ERROR sum2 ($sum2) vs sum1 ($sum1)"
endif

###############################################################################################
$echoline
$GTM << EOF >>! out3.out
do ^utfpattern
halt
EOF
echo "#--> Check that the utfpattern.o created above (version 1) was used."
$gtm_tst/com/wait_for_log.csh -log out3.out -duration 0 -grep -message "M in effect"
ls -l utfpattern*.o >& ls3.out
set sum3 = `sum utfpattern.o | $tst_awk '{print $1}'`
if ($sum3 != $sum1) then
	echo "TEST-E-ERROR sum3 ($sum3) vs sum1 ($sum1)"
endif

###############################################################################################
$echoline
set echo; setenv gtm_chset "UTF-8"; unset echo
$gtm_exe/mumps -run utfpattern >&! out4.out
echo "#  --> Check that utfpattern.o does not get regenerated automatically but instead error out with INVOBJ"
$gtm_tst/com/check_error_exist.csh out4.out "GTM-E-INVOBJFILE" "GTM-I-TEXT"
set sum4 = `sum utfpattern.o | $tst_awk '{print $1}'`
if ($sum4 != $sum1) then
	echo "TEST-E-ERROR sum4 ($sum4) vs sum1 ($sum1) should have been equal as the object recompilation attempt failed"
endif
rm utfpattern.o
$gtm_exe/mumps -run utfpattern >! out44.out
$gtm_tst/com/wait_for_log.csh -log out44.out -duration 0 -grep -message "UTF-8 in effect"
ls -l utfpattern*.o >& ls4.out
set sum44 = `sum utfpattern.o | $tst_awk '{print $1}'`
if ($sum44 == $sum1) then
	echo "TEST-E-ERROR sum44 ($sum44) vs sum1 ($sum1)"
endif
cp -p utfpattern.o utfpattern_ver2.o

###############################################################################################
$echoline
set echo; setenv gtm_chset "M"; unset echo
$gtm_exe/mumps -run utfpattern >&! out5.out
echo "#  --> Check that utfpattern.o does not get regenerated automatically but instead error out with INVOBJ"
$gtm_tst/com/check_error_exist.csh out5.out "GTM-E-INVOBJFILE" "GTM-I-TEXT"
set sum5 = `sum utfpattern.o | $tst_awk '{print $1}'`
if ($sum5 != $sum44) then
	echo "TEST-E-ERROR sum5 ($sum5) vs sum44 ($sum44) should have been equal as the object recompilation attempt failed"
endif
rm utfpattern.o
$gtm_exe/mumps -run utfpattern >! out55.out
$gtm_tst/com/wait_for_log.csh -log out55.out -duration 0 -grep -message "M in effect"
ls -l utfpattern*.o >& ls5.out
set sum55 = `sum utfpattern.o | $tst_awk '{print $1}'`
if ($sum55 == $sum5) then
	echo "TEST-E-ERROR sum55 ($sum55) vs sum5 ($sum5)"
endif
cp -p utfpattern.o utfpattern_ver1a.o

###############################################################################################
$echoline
set echo; setenv gtm_chset "UTF-8"; unset echo
$GTM << EOF >&! out6.out
do ^utfpattern
halt
EOF
echo "#  --> Check that utfpattern.o does not get regenerated automatically but instead error out with INVOBJ"
$gtm_tst/com/check_error_exist.csh out6.out "GTM-E-INVOBJFILE" "GTM-I-TEXT"
set sum6 = `sum utfpattern.o | $tst_awk '{print $1}'`
if ($sum6 != $sum55) then
	echo "TEST-E-ERROR sum6 ($sum6) vs sum55 ($sum55) should have been equal as the object recompilation attempt failed"
endif
rm utfpattern.o
$gtm_exe/mumps -run utfpattern >! out66.out
$gtm_tst/com/wait_for_log.csh -log out66.out -duration 0 -grep -message "UTF-8 in effect"
ls -l utfpattern*.o >& ls6.out
set sum66 = `sum utfpattern.o | $tst_awk '{print $1}'`
if ($sum66 == $sum6) then
	echo "TEST-E-ERROR sum66 ($sum66) vs sum6 ($sum6)"
endif
cp -p utfpattern.o utfpattern_ver2a.o

###############################################################################################
$echoline
set echo; setenv gtm_chset "M"; unset echo
$GTM << EOF >&! out7.out
do ^utfpattern
halt
EOF
echo "#  --> Check that utfpattern.o does not get regenerated automatically but instead error out with INVOBJ"
$gtm_tst/com/check_error_exist.csh out7.out "GTM-E-INVOBJFILE" "GTM-I-TEXT"
set sum7 = `sum utfpattern.o | $tst_awk '{print $1}'`
if ($sum7 != $sum66) then
	echo "TEST-E-ERROR sum7 ($sum7) vs sum66 ($sum66) should have been equal as the object recompilation attempt failed"
endif
rm utfpattern.o
$gtm_exe/mumps -run utfpattern >! out77.out
$gtm_tst/com/wait_for_log.csh -log out77.out -duration 0 -grep -message "M in effect"
ls -l utfpattern*.o >& ls7.out
set sum77 = `sum utfpattern.o | $tst_awk '{print $1}'`
if ($sum77 == $sum7) then
	echo "TEST-E-ERROR sum77 ($sum77) vs sum7 ($sum7)"
endif

###############################################################################################
# this section is not applicable as from M to UTF-8 they are all fresh objs and no recompilation of old one
#$echoline
#echo "#make the object file non-writable"
##chmod -w utfpattern.o
#ls -l utfpattern*.o >& ls7a.out
#set echo; setenv gtm_chset "UTF-8"; unset echo
#$gtm_exe/mumps -run utfpattern >& out8.out
#echo "#--> We expect a ZLINKFILE and OBJFILERR with a permission denied error since recompilation will fail since the object file is not writable."
#ls -l utfpattern*.o >& ls8.out
#$gtm_tst/com/check_error_exist.csh out8.out ENO13 ZLINKFILE ZLNOOBJECT OBJFILERR

###############################################################################################
set | $grep -E "^sum" > sums.txt
$echoline

