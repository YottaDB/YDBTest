#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2002, 2013 Fidelity Information Services, Inc	#
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
# settings for polish collation - Since com/cre_coll_sl.cshalways sets $gtm_local_collate and we
# want the local collation set to '1', do the polish_rev first, and then the polish library so we
# end up with gtm_local_collate set appropriately.
#
source $gtm_tst/com/cre_coll_sl.csh com/col_polish_rev.c 2
source $gtm_tst/com/cre_coll_sl.csh com/col_polish.c 1

# create a db with polish collation, and fill it
setenv gtm_test_sprgde_id "ID1"	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh "mumps" 2 125 500 -col=1
$GTM << GTM_EOF
set ^prefix="^"
d in2^mixfill("set",15)
d in2^numfill("set",1,2)
h
GTM_EOF
$gtm_tst/com/dbcheck.csh -extr
unsetenv test_replic
#
$gtm_tst/$tst/u_inref/check_polm.csh
echo "$MUPIP extract extr.bin -format=bin"
$MUPIP extract -format=bin extr.bin >&! mupip_extract_bin.out
if ($status) then
	echo "Extract failed"
	exit 1
endif
$grep -v '(region' mupip_extract_bin.out

# create a db with def collation and load it from the previous extract
setenv gtm_test_sprgde_id "ID2"	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh "mumps" 2 125 500 -col=2
echo "$MUPIP load -format=bin extr.bin"
$MUPIP load -format=bin extr.bin >&! mu_load_bin.out
if ($status) then
	echo "Load failed"
	exit 1
endif
$grep "LOAD TOTAL" mu_load_bin.out
$gtm_tst/$tst/u_inref/check_rev_polm.csh
$gtm_tst/com/dbcheck.csh
