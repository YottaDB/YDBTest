#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2003, 2015 Fidelity National Information	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
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
# Test the dse -cache command
# GT.M should be running concurrently on 8 databases
#

# Turn off statshare related env var as it affects test output and is not considered worth the trouble to maintain
# the reference file with SUSPEND/ALLOW macros for STATSHARE and NON_STATSHARE
source $gtm_tst/com/unset_ydb_env_var.csh ydb_statshare gtm_statshare

$gtm_tst/com/dbcreate.csh mumps 8 -rec=8000
#to test multiple global directories, copy the gld file
foreach no (0 1 2 3 4 5 6 7)
	cp mumps.gld mumpssec$no.gld
end

# Randomly set ydb_app_ensures_isolation env var to list of globals that need VIEW "NOISOLATION" set.
# If not set, tpntpupd.m (invoked later from dsecache.m below) will do the needed VIEW "NOISOLATION" call.
source $gtm_tst/com/tpntpupd_set_noisolation.csh

$GTM <<GTM_EOF
set ^secgldnm="mumpssec"	; will randomly pick one or the other global directory
set ^secgldno=8			; there are 8 copies of the gld
do start^dsecache	; start concurrent GTM updates while DSE commands are tested below
GTM_EOF

#
# Wait for all concurrent GTM updates to have referenced all regions as otherwise following DSE will give FTOK conflict.
# Note this needs to be done in a GTM invocation separate from the start^dsecache since waitchrg (invoked from waitbeg below)
#	relies on this process not having referenced the region in its refcnt calculations.
#
$GTM <<GTM_EOF
do waitbeg^dsecache	; wait for GTM updates to begin on all regions
GTM_EOF

#
# (1) Test CACHE VERIFY and CACHE RECOVER
#
echo ""
echo "--------- Testing CACHE VERIFY and CACHE RECOVER ---------"
echo ""
$DSE <<DSE_EOF >&! dse_cache_verify_recover.log
find -reg=CREG
cache -verify
find -reg=BREG
cache -verify
find -reg=AREG
cache -verify -all
cache -recover
cache -recover -all
cache -verify -all
quit
DSE_EOF

$tst_awk '{gsub("Time.*Region","Region"); print $0;}' dse_cache_verify_recover.log	# to make the output time-independent

#
# (2) Test CACHE SHOW with no arguments
#
echo ""
echo "--------- Testing CACHE SHOW with no arguments ---------"
echo ""
$DSE <<DSE_EOF >&! dse_cache_show_no_args.log
find -reg=AREG
cache -show
find -reg=CREG
cache -show -all
quit
DSE_EOF

$tst_awk '{gsub("0x[0-9A-F]*",""); print $0;}' dse_cache_show_no_args.log # to make the output independent of the actual shm layout

#
# (3) Test CACHE SHOW with arguments and CACHE CHANGE
#	Ensure size=1,2,4 works but size=8 does not work
#	Ensure a CACHE CHANGE works but doing a CACHE SHOW immediately after the CACHE CHANGE.
#	Ensure -ALL qualifier works and that -ALL does not change the current region for future commands.
#
echo ""
echo "--------- Testing CACHE SHOW and CACHE CHANGE ---------"
echo ""
$DSE <<DSE_EOF >&! dse_cache_change_show.log
find -reg=AREG
cache -show -offset=0 -size=4 -all
find -reg=AREG
cache -change -offset=0 -size=1 -value=12
cache -show -offset=0 -size=1
cache -change -offset=0 -size=1 -value=47
cache -show -offset=0 -size=1
cache -change -offset=0 -size=2 -value=1234
cache -show -offset=0 -size=2
cache -change -offset=0 -size=2 -value=4744
cache -show -offset=0 -size=2
cache -change -offset=0 -size=4 -value=12345678
cache -change -offset=0 -size=8 -value=12345678
find -reg=BREG
cache -change -offset=0 -size=4 -value=90abcdef
cache -show -offset=0 -size=4 -all
cache -show -offset=8 -size=8
find -reg=BREG
cache -change -offset=0 -size=4 -value=00000000
cache -change -offset=0 -size=1 -value=47
cache -change -offset=1 -size=1 -value=44
cache -change -offset=2 -size=1 -value=53
cache -change -offset=3 -size=1 -value=44
find -reg=AREG
cache -change -offset=0 -size=4 -value=00000000
cache -change -offset=0 -size=1 -value=47
cache -change -offset=1 -size=1 -value=44
cache -change -offset=2 -size=1 -value=53
cache -change -offset=3 -size=1 -value=44
find -reg=CREG
cache -show -offset=0 -size=4 -all
quit
DSE_EOF
#
# to take care of different in endianness, what we do is nullify all the expected values that can differ on different endian systems
#
$tst_awk '{gsub("1146307655 \\[0x44534447\\]",""); gsub("1146308420 \\[0x44534744\\]",""); gsub("1195660100 \\[0x47445344\\]",""); gsub("18244 \\[0x4744\\]",""); gsub("17479 \\[0x4447\\]",""); print $0;}' dse_cache_change_show.log
#
# Stop concurrent GTM updates
#
$GTM <<GTM_EOF
do stop^dsecache	; stop concurrent GTM updates
GTM_EOF

$gtm_tst/com/dbcheck.csh
