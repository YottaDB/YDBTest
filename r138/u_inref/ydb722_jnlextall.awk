#!/usr/local/bin/tcsh -f
#################################################################
#                                                               #
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.       #
# All rights reserved.                                          #
#                                                               #
#       This source code contains the intellectual property     #
#       of its copyright holder(s), and is made available       #
#       under a license.  If you do not know the terms of       #
#       the license, please stop and do not read further.       #
#                                                               #
#################################################################

# This is a helper awk script used by r138/u_inref/ydb722_jnlextall.csh
# This filters out just the key parts of the detailed journal extract records so they can be included in the ydb722 subtest reference file

BEGIN	{}
($1 ~ /SET/) || ($1 ~ /ZTRIG/) || ($1 ~ /KILL/)	{ printf "%-8s seqno=%d updnum=%d nodeflags=%-2d value=%s\n",$1,$7,$10,$11,$12; }
$1 ~ /LGTRIG/	{ printf "%-8s seqno=%d updnum=%d              value=%s\n",$1,$7,$10,$11; }
$1 ~ /NULL/	{ printf "%-8s seqno=%d          salvaged=%d\n",$1,$7,$10; }
$1 ~ /ZTWORM/	{ printf "%-8s seqno=%d updnum=%d              value=%s\n",$1,$7,$10,$11; }
$1 ~ /TCOM/	{ printf "%-8s seqno=%d\n",$1,$7; }
END	{}
