#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# simple test for special characters, should be improved/ and small functionality tests should be added to other tests as well. This is yet incomplete -- Nergis Dincer
#setenv dollar "'"'a$b'"\"
   setenv first mumps
   setenv lar LAR
   if !($?test_replic) then
   	setenv full_path "$tst_working_dir/full-path-file"
   else
   	setenv full_path "not-fullpath-for-replic"
   endif
   setenv test_specific_gde $gtm_tst/$tst/u_inref/wow.gde
   $gtm_tst/com/dbcreate.csh  . 5
   echo  " "
   echo "ls -1 *.dat *.gld"
   ls -1 *.dat *.gld
   $GDE show -map

   if ($?test_replic) then
   echo "REMOTE"
   $sec_shell "$sec_getenv; $GDE show -map"
   endif

   $GTM << xyz
   do ^sfill("set",3,3)
   do ^sfill("ver",3,3)
   do ^sfill("kill",3,3)
xyz
   $gtm_tst/com/dbcheck.csh -extract





