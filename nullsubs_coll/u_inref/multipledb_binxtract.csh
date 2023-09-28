#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2004, 2013 Fidelity Information Services, Inc	#
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
# check mupip binary extract on multiple databases with different nullcollation. Should error out!
#
# create multiple databases.
# the output of this test relies on dse dump -file output, therefore let's not change the block version:
setenv gtm_test_mupip_set_version "disable"
setenv gtm_test_use_V6_DBs 0	  	# Disable V6 DB mode due to differences in DSE DUMP -FILEHEADER output
# because this test enables stdnullcoll in one region and not in the other and there are only two regions, we cannot
# enable random spanning regions testing in this easily.  So disable it.
setenv gtm_test_spanreg 0
$gtm_tst/com/dbcreate.csh mumps 2 200
# change collating order for the two databases.
$DSE << dse_eof
find -reg=DEFAULT
change -fileheader -stdnullcoll=FALSE
find -reg=AREG
change -fileheader -stdnullcoll=TRUE -null_subscripts=ALWAYS
dump -fileheader
find -region=DEFAULT
change -fileheader -null_subscripts=ALWAYS
dump -fileheader
exit
dse_eof
$GTM << gtm_eof
do two^varfill
write "both globals should collate differently",!
zwrite ^aforavariable,^iamdefault
halt
gtm_eof
$MUPIP extract -format=bin extr.bin
if ($status) then
        echo "PASS! extract did fail as expected"
else
        echo "TEST-E-ERROR extract din't fail for differently collating databases"
	exit 3
endif
$GTM << gtm_eof
kill ^aforavariable,^iamdefault
halt
gtm_eof
# change to same collating order
$DSE << dse_eof
find -region=DEFAULT
change -fileheader -stdnullcoll=TRUE
dump -fileheader
exit
dse_eof
# zwrite is added to ensure all globals are intact
$GTM << gtm_eof
do two^varfill
write "both globals should collate same",!
zwrite ^aforavariable,^iamdefault
halt
gtm_eof
$MUPIP extract -format=bin extr.bin >&ext.out
if ($status) then
        echo "TEST-E-ERROR extract failed even after same collating order"
else
	echo ""
        echo "PASS! extract successfull after change of collation"
endif
#
$gtm_tst/com/dbcheck.csh
#
