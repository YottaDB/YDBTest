#! /usr/local/bin/tcsh
#################################################################
#								#
#	Copyright 2004, 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# this is the script to test long routine names and labels - up to 31 characters.
$gtm_tst/com/dbcreate.csh mumps
echo "###########################################################################################"
echo "test that the correct labels/routines are invoked"
$GTM << gtm_end
do ^routsmoke
gtm_end
echo "###########################################################################################"
echo "test all acceptable lengths of label and routine names"
$GTM << aaa
do ^labtest
aaa
#
echo "###########################################################################################"
echo "zlink a routine over and over to test that literals set in the prev incarnations are still valid"
$GTM << bbb
do ^litlab
bbb
#
echo "###########################################################################################"
echo "relinks"
cp $gtm_tst/$tst/inref/lnkrtn* .
cp $gtm_tst/$tst/inref/errcont.m .
cp $gtm_tst/$tst/inref/relinks.m .
mv lnkrtn.x lnkrtn.m
mv lnkrtn0.x lnkrtn0.m
mv lnkrtn1.x lnkrtn1.m
mv lnkrtn2.x lnkrtn2.m
$GTM << end_relinks
do ^relinks
end_relinks
#
echo "###########################################################################################"
echo "test stp_move"
cp -f $gtm_tst/$tst/inref/test1.m .
cp -f $gtm_tst/$tst/inref/test2.m .
$GTM << ccc
do ^testmain
ccc
#
echo "###########################################################################################"
setenv MUMPS "$gtm_exe/mumps"
cp $gtm_tst/$tst/inref/x234567890123456789012345678901a.m .
set echo
echo "routine name is more than 31 characters"
$MUMPS -run x234567890123456789012345678901a
$MUMPS -run x234567890123456789012345678901
ls x234567890123456789012345678901*.o
$MUMPS x234567890123456789012345678901a.m
ls x234567890123456789012345678901*.o
$GTM << eof
set cmd="do ^x234567890123456789012345678901"
write cmd,!
xecute cmd
halt
eof
$GTM << eof
set cmd="do ^x234567890123456789012345678901a"
write cmd,!
xecute cmd
halt
eof
\rm -f x234567890123456789012345678901.o
$GTM << eof
set cmd="do ^x234567890123456789012345678901a"
write cmd,!
xecute cmd
set cmd="zlink ""x234567890123456789012345678901a"""
write cmd,!
xecute cmd
set cmd="do ^x234567890123456789012345678901a"
write cmd,!
xecute cmd
halt
eof
$GTM << eof
set cmd="do ^x234567890123456789012345678901a"
write cmd,!
xecute cmd
halt
eof

unset echo
#
echo "###########################################################################################"
echo "label names are more than 31 characters"
set echo
$MUMPS -run x234567890123456789012345678901a^toolong
$MUMPS -run x234567890123456789012345678901b^toolong
$MUMPS -run x234567890123456789012345678901c^toolong
unset echo
#
echo "###########################################################################################"
$gtm_tst/com/dbcheck.csh
