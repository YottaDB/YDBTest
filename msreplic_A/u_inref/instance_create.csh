#!/usr/local/bin/tcsh -f
#################################################################
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


## ## multisite_replic/instance_create			###3###Kishore
## We need to test the different valid and invalid alternatives for instance names (mupip replic -instance_create -name)
## and that the old file will be renamed properly.
## - no database is necessary
## - setenv gtm_repl_instance "mumps.repl"
## - unsetenv (deassign) gtm_repl_instname

echo "There would be lots of YDB-E- errors following. They are part of the test"
echo " "
setenv MUPIP "$gtm_exe/mupip"
setenv gtm_repl_instance "mumps.repl"
unsetenv gtm_repl_instname

## - mupip repl -instance_create
## 	--> We expect a REPLINSTNMUNDEF error, check that no instance file is created.
## - mupip repl -instance_create -name= 				# illegal name, empty string
## 	--> We expect a CLIERR error, since there is no value specified for -name.
## - setenv (define) gtm_repl_instname to "".			# illegal name, empty string
##   mupip repl -instance_create
## 	--> We expect a REPLINSTNMLEN error, check that no instance file is created.
##   unsetenv (deassign) gtm_repl_instname
## - mupip repl -instance_create -name=LONGNAME90123456	# illegal name - longer than 15 chars, exactly 16
## 	--> We expect a REPLINSTNMLEN error, check that no instance file is created.
## - setenv (define) gtm_repl_instname to LONGNAME90123456 # illegal name - longer than 15 chars, exactly 16
##   mupip repl -instance_create
## 	--> We expect a REPLINSTNMLEN error, check that no instance file is created.

echo "expect REPLINSTNMUNDEF error"
echo " "
$MUPIP replicate -instance_create
if (-e "mumps.repl") echo "TEST-E-ERROR mumps.repl is not expected here"
echo " "
echo "expect YDB-E-CLIERR error"
echo " "
$MUPIP replicate -instance_create -name=
if (-e "mumps.repl") echo "TEST-E-ERROR mumps.repl is not expected here"
echo " "
echo "expect 3 REPLINSTNMLEN errors"
echo " "
setenv gtm_repl_instname ""
$MUPIP replicate -instance_create
if (-e "mumps.repl") echo "TEST-E-ERROR mumps.repl is not expected here"
unsetenv gtm_repl_instname
$MUPIP replicate -instance_create -name=LONGNAME90123456
if (-e "mumps.repl") echo "TEST-E-ERROR mumps.repl is not expected here"
setenv gtm_repl_instname LONGNAME90123456
$MUPIP replicate -instance_create
if (-e "mumps.repl") echo "TEST-E-ERROR mumps.repl is not expected here"

##   unsetenv (deassign) gtm_repl_instname
## - setenv (define) gtm_repl_instname to SHOULDNOTBEUSEDITSLONGANYWAY	# illegal name - longer than 15 chars
##   mupip repl -instance_create -name=GOODNAME
## 	--> The file mumps.repl should be created, while gtm_repl_instname is pointing to a bad name, -name is
## 	    specified on the command line, so it should use GOODNAME
##   mupip replic -editinstance -show mumps.repl and verify the contents
## 	--> The instance name is expected to be GOODNAME.
## 	    For this command and all the following in this test, just grep the instancename from the -edit -show
## 	    output (and do forward the general output to a file)
## 	    mupip replic -editinstance -show mumps.repl |& tee instancefile_GOODNAME.out | grep INSTANCENAME (or whatever the
## 	    field is called in the final format)
## - setenv (define) gtm_repl_instname to B			# good name, this time only 1 char
##   mupip repl -instance_create
## 	--> The file mumps.repl should be re-created, and there should be a mumps.repl_<timestamp>
##   mupip replic -editinstance -show mumps.repl |& tee instancefile_B.out | grep ...
## 	--> The instance name is expected to be B.
## - Let's not worry about checking the renamed mumps.repl* from here on (since by now, we've tested the rename quite a
##   bit), so let's just check mumps.repl and not the renamed versions.

unsetenv gtm_repl_instname
setenv gtm_repl_instname SHOULDNOTBEUSEDITSLONGANYWAY
$MUPIP replicate -instance_create -name=GOODNAME
if ( ! -e "mumps.repl") echo "TEST-E-ERROR mumps.repl is expected but missing"
echo " "
echo "expect instance name to be GOODNAME"
echo " "
$MUPIP replicate -editinstance -show mumps.repl |& tee instancefile_GOODNAME.out | $grep "HDR Instance Name"
setenv gtm_repl_instname B
$MUPIP replicate -instance_create
echo " "
echo "expect mumps.repl_<timestamp>"
echo " "
ls mumps.repl_*
echo " "
echo "The next 8 outputs should be 'Instance Name <name>'"
echo "The instance names should be B , C , 1 , 2 , ABC4E6G890 , TESTINSTANCEA45 , INTE_RES/+TING. , INTE_RES/+TING."
echo " "
$MUPIP replicate -editinstance -show mumps.repl |& tee instancefile_B.out | $grep "HDR Instance Name"

## - mupip repl -instance_create -name=C				# good name, this time only 1 char
##   mupip replic -editinstance -show mumps.repl |& tee instancefile_C.out | grep ...
## 	--> The instance name is expected to be C.
## - setenv (define) gtm_repl_instname to 1			# good name, this time only 1 char, and only a number
##   mupip repl -instance_create
##   mupip replic -editinstance -show mumps.repl |& tee instancefile_1.out | grep ...
## 	--> The instance name is expected to be 1.
## - mupip repl -instance_create -name=2				# good name, this time only 1 char, and only a number
##   mupip replic -editinstance -show mumps.repl |& tee instancefile_2.out | grep ...
## 	--> The instance name is expected to be 2.
## - mupip repl -instance_create -name=ABC4E6G890			# good name, a combination of letters and numbers
##   mupip replic -editinstance -show mumps.repl |& tee instancefile_ABC4E6G890.out | grep ...
## 	--> The instance name is expected to be ABC4E6G890.
## - setenv (define) gtm_repl_instname to TESTINSTANCEA45		# good name, exactly 15 chars
##   mupip repl -instance_create
##   mupip replic -editinstance -show mumps.repl |& tee instancefile_TESTINSTANCEA45.out | grep ...
## 	--> The instance name is expected to be TESTINSTANCEA45.
## - mupip repl -instance_create -name=INTE_RES/+TING.		# weird name, but should work, exactly 15 chars, note
##   								# the dot at the end, it is part of the name
##   mupip replic -editinstance -show mumps.repl |& tee instancefile_INTERESTING.out | grep ...
## 	--> The instance name is expected to be INTE_RES/+TING.
## - setenv (define) gtm_repl_instname to XNTE_RES/+TING.		# weird name, but should work, exactly 15 chars, note
##   								# the dot at the end, it is part of the name
##   mupip repl -instance_create
##   mupip replic -editinstance -show mumps.repl | tee instancefile_XNTERESTING.out | grep ...
## 	--> The instance name is expected to be XNTE_RES/+TING.
##   unsetenv (deassign) gtm_repl_instname
##

$MUPIP replicate -instance_create -name=C
$MUPIP replicate -editinstance -show mumps.repl |& tee instancefile_C.out | $grep "HDR Instance Name"
setenv gtm_repl_instname 1
$MUPIP replicate -instance_create
$MUPIP replicate -editinstance -show mumps.repl |& tee instancefile_1.out | $grep "HDR Instance Name"
$MUPIP replicate -instance_create -name=2
$MUPIP replicate -editinstance -show mumps.repl |& tee instancefile_2.out | $grep "HDR Instance Name"
$MUPIP replicate -instance_create -name=ABC4E6G890
$MUPIP replicate -editinstance -show mumps.repl |& tee instancefile_ABC4E6G890.out | $grep "HDR Instance Name"
setenv gtm_repl_instname TESTINSTANCEA45
$MUPIP replicate -instance_create
$MUPIP replicate -editinstance -show mumps.repl |& tee instancefile_TESTINSTANCEA45.out | $grep "HDR Instance Name"
$MUPIP replicate -instance_create -name=INTE_RES/+TING.
$MUPIP replicate -editinstance -show mumps.repl |& tee instancefile_INTERESTING.out | $grep "HDR Instance Name"
setenv gtm_repl_instname INTE_RES/+TING.
$MUPIP replicate -instance_create
$MUPIP replicate -editinstance -show mumps.repl |& tee instancefile_XINTERESTING.out | $grep "HDR Instance Name"
unsetenv gtm_repl_instname
