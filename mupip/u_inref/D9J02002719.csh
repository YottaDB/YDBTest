#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2010, 2013 Fidelity Information Services, Inc	#
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
setenv gtm_test_use_V6_DBs 0	# Disable V6 DB mode due to differences in MUPIP INTEG output
#
#########################################
# D9J02002719.csh  test for mupip integ #
#########################################
#
#
echo MUPIP D9J02002719
#

# disable random 4-byte collation header in DT leaf block since this test output is sensitive to DT leaf block layout
setenv gtm_dirtree_collhdr_always 1

# Create DB. Using an allocation of 300 blocks because file extensions in MM mode are not supported on HPPA.
setenv gtmgbldir "integ.gld"
$gtm_tst/com/dbcreate.csh integ -allocation=300

#
# Only one level-1 GVT block and it has only one * record, then there is not enough information at the
# index level for fast to infer the DBINVGBL error. In that case, it is ok that it not report the error.

# Fill with test data
$GTM << EOF
set ^a="a"
halt
EOF

# Create an invalid mixing of global names
# mupip integ fast : no error detected
# Restore damaged blocks
$DSE << EOF
save -block=2
map -block=20
restore -block=20 -version=1 -from=2
change -level=1
add -record=1 -key="^a1" -pointer=4
remove -record=2
change -level=0
save
restore -block=2 -from=20 -version=1
spawn "$MUPIP integ -fast -reg '*'"
restore -block=2 -from=2 -version=1
remove -block=20 -version=1
EOF

#
# Testing with a duplicated pointer in the directory tree.  DBBDBALLOC error is reported by
# mupip integ fast.
# Fill with test data
$GTM << EOF
set ^b="a"
halt
EOF

# Create a duplicated pointer in the directory tree.
# mupip integ fast : error detected
# Restore damaged blocks

# The integ is expected to error.  Set whitebox test to prevent the assert in bml_busy.c:33.
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 33

if ("LITTLE_ENDIAN" == $gtm_endian) then
	set offset="17"
else
	set offset="1A"
endif

$DSE << EOF
save -block=2
overwrite -offset=$offset -data=\6
spawn "$MUPIP integ -fast -reg '*'"
restore -block=2 -version=1
EOF

unsetenv gtm_white_box_test_case_enable
unsetenv gtm_white_box_test_case_number

#
# GVT block has more than one index record, so we have a non-* record.  The DBKEYORD or DBINVGBL error should
# be reported.

# Fill with more test data
$GTM << EOF
for i=1:1:1000 set ^a(\$justify(i,50))=\$justify(i,160)
halt
EOF

# Create a duplicated pointer in the directory tree.  Integ is expected to report the error.
$DSE << EOF
save -block=4
overwrite -block=4 -offset=14 -data="b"
spawn "$MUPIP integ -fast -reg '*'"
restore -block=4 -version=1
EOF

$gtm_tst/com/dbcheck.csh

#
##########################
# END of D9J02002719.csh #
##########################
