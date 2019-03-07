#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2017 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.                                          #
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
$GDE << aaa
change -segment DEFAULT -block_size=1024
aaa
if ("ENCRYPT" == "$test_encryption" ) then
	$gtm_tst/com/create_key_file.csh >& create_key_file_dbload.out
	sed 's/mumps\.dat/back.dat/' $gtm_dbkeys > ${gtm_dbkeys}.bak
	$tst_awk -F '/' '/\.dat/ {print "dat "$NF; next} {print}' ${gtm_dbkeys}.bak > ${gtm_dbkeys}.both
	cat $gtm_dbkeys >> ${gtm_dbkeys}.both
	$gtm_dist/mumps -run CONVDBKEYS ${gtm_dbkeys}.both ${gtmcrypt_config}.both
	mv $gtmcrypt_config ${gtmcrypt_config}.orig
	sed "s|##GTM_TST##|$gtm_tst|" gtmtls.cfg >&! $gtmcrypt_config
	cat ${gtmcrypt_config}.both >>&! $gtmcrypt_config
endif
$MUPIP create
$MUPIP set -file -journal=enable,on,nobefore mumps.dat
$GTM <<bbb
w "Do fill1^myfill(""set"")",!
d fill1^myfill("set")
h
bbb
mv mumps.dat tmumps.dat
mv mumps.mjl tmumps.mjl
chmod 666 *.dat
chmod 666 *.mjl
