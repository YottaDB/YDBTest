#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2014-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
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

# Test trigger loads bypass region-specific max-rec-size or max-key-size values

$gtm_tst/com/dbcreate.csh mumps -key_size=8 -record_size=5

cat > trig.trg << CAT_EOF
+^a -commands=SET -xecute="do A^sym01234"
+^a -commands=SET -xecute="do A^sym0123456789012345678" -name=a123456789
CAT_EOF

# Trigger load should work fine now even though the key-size and record-size values are normally too small to hold the desired triggers
$MUPIP trigger -noprompt -trigg=trig.trg

# Test that DSE ADD -REC honors new max-rec-size convention (only value part, key not included)

# this should error out since strlen(data)=12 > max-rec-size=11
$DSE change -fi -rec=11
$DSE << DSE_EOF
add -bl=3 -data="123456789012" -key="^#t(""z"")" -rec=16
DSE_EOF

# this should pass since strlen(data)=11 == max-rec-size=11
$DSE << DSE_EOF
add -bl=3 -data="12345678901" -key="^#t(""z"")" -rec=16
DSE_EOF

# Dump ^#t key values. But filter out Off Size and Cmpc values since they can change depending on M or UTF-8
#	Rec:7  Blk 3  Off 75  Size C  Cmpc A  Key ^#t("a",1,"CHSET")
#
$DSE dump -block=3 >&! dse_dump_bl3.out
$tst_awk '/Rec:.*#t/ {print $1, $10, $11}' dse_dump_bl3.out

$gtm_tst/com/dbcheck.csh
