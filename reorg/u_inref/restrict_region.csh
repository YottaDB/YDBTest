#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2012, 2013 Fidelity Information Services, Inc	#
#								#
# Copyright (c) 2023-2025 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
setenv test_reorg NON_REORG
if ((1 == $gtm_test_spanreg) || (3 == $gtm_test_spanreg)) then
	set colno = 0
	if ($?test_collation_no) then
		set colno = $test_collation_no
	endif
	setenv test_specific_gde $gtm_tst/$tst/inref/restrict_region_col${colno}.gde
endif
setenv gtm_test_spanreg 0	# We have already pointed a spanning gld to test_specific_gde
# Disable use of V6 DB mode using random V6 versions to create the DBs as that changes MUPIP REORG output
setenv gtm_test_use_V6_DBs 0

$gtm_tst/com/dbcreate.csh mumps 4

$GDE << EOF
change -name a* -region=AREG
change -name b* -region=DEFAULT
change -name c* -region=CREG
EOF

# We have regions areg, DEFAULT, and breg
$GTM << EOF
f i=1:1:10000 s ^b(i)=\$j(i,100)
f i=1:1:10000 s ^c(i)=\$j(i,100)
h
EOF

set verbose
$MUPIP reorg -region "*"
$MUPIP reorg -region AREG			# error expected
$MUPIP reorg -region Default			# Region Name in Mixed cases should be accepted
$MUPIP reorg -region CREG
unset verbose

$GTM << EOF
f i=1:1:10000 s ^a(i)=\$j(i,100)
h
EOF

set verbose
$MUPIP reorg -region "*"
$MUPIP reorg -region AREG
$MUPIP reorg -region DEFAULT
$MUPIP reorg -region CREG
$MUPIP reorg -region "AREG,DEFAULT"
$MUPIP reorg -region "AREG,CREG"
$MUPIP reorg -region "CREG,DEFAULT"

$MUPIP reorg -exclude="^a" -region AREG		# warning expected
$MUPIP reorg -exclude="^b" -region AREG
$MUPIP reorg -select="^a" -region AREG
$MUPIP reorg -select="^b" -region AREG		# warning expected

$MUPIP reorg "*"			# error expected
$MUPIP reorg asdf hjkl 			# error expected
unset verbose

$gtm_tst/com/dbcheck.csh
