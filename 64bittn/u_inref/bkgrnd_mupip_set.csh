#!/usr/local/bin/tcsh -f
#
# the script is called from bkgrndset m-routine & controlled from there
#
# alternate between V4 & V6 versions of database
#
$MUPIP set -version=V4 -file mumps.dat
# sleep for some random seconds (below 20)
set v4rand=`$gtm_exe/mumps -run rand 20`
sleep `expr $v4rand + 1`
#
$MUPIP set -version=V6 -file mumps.dat
# sleep for some random seconds (below 20)
set v5rand=`$gtm_exe/mumps -run rand 20`
sleep `expr $v5rand + 1`
#
