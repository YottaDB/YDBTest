#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2002, 2013 Fidelity Information Services, Inc	#
#								#
# Copyright (c) 2018-2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
#
echo ENTERING ONLINE5
#
#
setenv gtmgbldir online5.gld
setenv gtm_test_mupip_set_version "disable"
setenv gtm_test_use_V6_DBs 0	  	# Disable V6 DB mode due to differences in MUPIP BACKUP/RESTORE outputs
setenv gtm_test_disable_randomdbtn
if (("MM" == $acc_meth) && (0 == $gtm_platform_mmfile_ext)) then
	$gtm_tst/com/dbcreate.csh online5 1 125 700 1536 200 256
else
	$gtm_tst/com/dbcreate.csh online5 1 125 700 1536 100 256
endif
#
#
$GTM << pipeset
d fill3^myfill("set")
h
pipeset
$MUPIP backup -o -i -t=1 DEFAULT '"| $tst_gzip -c > online5pipe.inc.gz"'
if ($status != 0) then
	echo ERROR from backup to a pipe.
	exit 99
endif
#
#
$gtm_tst/com/dbcheck.csh
# from here on no dbcreates are done so disable dbcheck from regenerating the .sprgde file using -nosprgde
#
#
\rm -f online5.dat							# unzip, restore and verify
$MUPIP create
$tst_gunzip online5pipe.inc.gz
$MUPIP restore online5.dat online5pipe.inc
if ($status != 0) then
	echo ERROR from restore the unzipped backup file.
	exit 98
endif
$GTM << pipeverify1
d fill3^myfill("ver")
h
pipeverify1
#
$tst_gzip online5pipe.inc							# zip, restore and verify
\rm -f online5.dat
$MUPIP create
# the whole restore thorugh pipe has been re-directed to a file to avoid gzip-stdout error.
# Mupip restore is now larger itself and has larger memory requirements than it had in the past.
# If it was in some way "near the edge" in V4, it would be much closer to that edge now in terms of memory usage with temporary files and such.
# There is no functional change in restore that is explicitly breaking gzip, it is just that restore is now requiring a larger piece of the pie and potentially interferring with the shortcut gzip-to-stdout
# Hence the work around
($MUPIP restore online5.dat '"$tst_gzip -d -c online5pipe.inc.gz |"') >&! online5_restore.out
if ($status != 0) then
	echo ERROR from restore from pipe.
	exit 97
else
	$grep -E "restored|RESTORESUCCESS" online5_restore.out
endif
$GTM << pipeverify2
d fill3^myfill("ver")
h
pipeverify2
#
$gtm_tst/com/dbcheck.csh -noshut -nosprgde
echo LEAVING ONLINE5
