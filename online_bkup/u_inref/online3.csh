#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2002, 2013 Fidelity Information Services, Inc	#
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
#
echo ENTERING ONLINE3  basic multiregion and wildcard mapping
#
setenv gtmgbldir online3.gld
# the output of this test relies on transaction numbers, so let's not do anything that might change the TN
setenv gtm_test_mupip_set_version "disable"
setenv gtm_test_use_V6_DBs 0	  	# Disable V6 DB mode due to differences in MUPIP BACKUP/RESTORE outputs
setenv gtm_test_disable_randomdbtn
$gtm_tst/com/dbcreate.csh online3 3
set core_found = 0
#
if ((1 == $gtm_test_spanreg) || (3 == $gtm_test_spanreg)) then
	# Since the number of transactions in a region/db is random,
	#i do not print information related to transactions/blocks
	set filterit = 'Transactions from|blocks saved|blocks restored'
else
	set filterit = 'NOTHINGTOFILTEROUT'
endif
#
$GTM << \jjjj                                                           # fill in data and back it up
d fill5^myfill("right")
s ^a="This should be in region AREG"
s ^b="This should be in region BREG"
s ^d="This should be in region DEFAULT"
h
\jjjj
$MUPIP backup -o -i -t=1 "*" online3a.inc,online3b.inc,online3d.inc >& mupip_backup_o_i.out
sort -f mupip_backup_o_i.out |& $grep -vE "$filterit"
#
#
$gtm_tst/com/dbcheck.csh
#
#
if ("os390" == "$gtm_test_osname") then
	if (-f gtmcore) then
		set core_found = 1
	endif
else
	if (-f core) then
		set core_found = 1
	endif
endif
if (1 == $core_found) then
	foreach file (*.dat)
		\mv $file $file.1
	end
else
	\rm -f online3*.dat
	\rm -f a.dat
	\rm -f b.dat
endif
$MUPIP create |& sort
$MUPIP restore online3.dat online3d.inc |& $grep -vE "$filterit"
$GTM << verifyc
zwr ^d
h
verifyc
$MUPIP restore a.dat online3a.inc |& $grep -vE "$filterit"
$GTM << verifya
zwr ^a
h
verifya
$MUPIP restore b.dat online3b.inc |& $grep -vE "$filterit"
$GTM << finalverify
zwr ^b
d fill5^myfill("ver")
h
finalverify
#
#
echo LEAVING ONLINE3
