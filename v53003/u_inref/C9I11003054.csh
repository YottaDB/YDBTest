#!/usr/local/bin/tcsh -f

#
# C9I09003054 - When MM is selected GDE and/or mupip need to set default to NOBEFORE image journaling and raise errors
#		for MM with BEFORE image journaling.
#
echo "C9I09003054 subtest begins..."
###############################
# GDE tests for initializing MM
###############################
$echoline
echo "Test 1"
# Trigger MMNOBEFORIMG error in GDE
$GDE << EOF
change -region DEFAULT -journal=before_image
change -segment DEFAULT -access_method=MM
exit
EOF
if("ENCRYPT" == $test_encryption) then
        $gtm_tst/com/create_key_file.csh >& create_key_file_dbload.out
endif
$MUPIP create
\rm -rf mumps.* >& /dev/null
#
$echoline
echo "Test 2"
# Trigger MMNOBEFORIMG error in GDE and then correct it
$GDE << EOF
change -region DEFAULT -journal=before_image
change -segment DEFAULT -access_method=MM
change -region DEFAULT -journal=nobefore_image
change -segment DEFAULT -access_method=MM
exit
EOF
$MUPIP create
\rm -rf mumps.* >& /dev/null
#
$echoline
echo "Test 3"
# Trigger MMNOBEFORIMG error in GDE with alternate sequence and then correct it
$GDE << EOF
change -segment DEFAULT -access_method=MM
change -region DEFAULT -journal=before_image
change -region DEFAULT -journal=nobefore_image
exit
EOF
$MUPIP create
\rm -rf mumps.* >& /dev/null
#
$echoline
#
###############################
# mupip tests for initializing MM
###############################
# Trigger MMBEFOREJNL error
echo "Test 101"
$GDE exit
$MUPIP create
$MUPIP set -file mumps.dat -access_method=MM
$MUPIP set -journal=enable,on,before -region "*"
\rm -rf mumps.* >& /dev/null
#
$echoline
echo "Test 102"
# Trigger MMBEFOREJNL error and then fix it
$GDE exit
$MUPIP create
$MUPIP set -file mumps.dat -access_method=MM
$MUPIP set -journal=enable,on,before -region "*"
$MUPIP set -journal=enable,on,nobefore -region "*"
\rm -rf mumps.* >& /dev/null
#
$echoline
echo "Test 103"
# Turn on default replication for MM -- should be NOBEFORE
$GDE exit
$MUPIP create
$MUPIP set -file mumps.dat -access_method=MM
$MUPIP set -file mumps.dat -replication=on
\rm -rf mumps.* >& /dev/null
#
$echoline
echo "Test 104"
# Turn on default replication for MM
$GDE exit
$MUPIP create
$MUPIP set -file mumps.dat -access_method=MM
$MUPIP set -file mumps.dat -journal=enable,on,nobefore
$MUPIP set -file mumps.dat -replication=on
\rm -rf mumps.* >& /dev/null
#
$echoline
echo "Test 105"
# Trigger "MM access method cannot be set with BEFORE image journaling" error
$GDE exit
$MUPIP create
$MUPIP set -file mumps.dat -journal=enable,on,before
$MUPIP set -file mumps.dat -access_method=MM
\rm -rf mumps.* >& /dev/null
#
$echoline
echo "Test 106"
# Trigger MM and BEFORE error and change to NOBEFORE (still using BG at end)
$GDE exit
$MUPIP create
$MUPIP set -file mumps.dat -journal=enable,on,before
$MUPIP set -file mumps.dat -access_method=MM
$MUPIP set -file mumps.dat -journal=enable,on,nobefore
\rm -rf mumps.* >& /dev/null
#
$echoline
echo "Test 107"
# Trigger MM and BEFORE error and change to NOBEFORE and MM
$GDE exit
$MUPIP create
$MUPIP set -file mumps.dat -journal=enable,on,before
$MUPIP set -file mumps.dat -access_method=MM
$MUPIP set -file mumps.dat -journal=enable,on,nobefore
$MUPIP set -file mumps.dat -access_method=MM
\rm -rf mumps.* >& /dev/null
#
$echoline
echo "Test 108"
# Try MM first then trigger MMBEFOREJNL error
$GDE exit
$MUPIP create
$MUPIP set -file mumps.dat -access_method=MM
$MUPIP set -file mumps.dat -journal=enable,on,before
\rm -rf mumps.* >& /dev/null
#
$echoline
echo "Test 109"
# Try MM first then trigger MMBEFOREJNL error then correct it
$GDE exit
$MUPIP create
$MUPIP set -file mumps.dat -access_method=MM
$MUPIP set -file mumps.dat -journal=enable,on,before
$MUPIP set -file mumps.dat -journal=enable,on,nobefore
\rm -rf mumps.* >& /dev/null
$echoline
echo "End of subtest C9I09003054"
