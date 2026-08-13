#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Reads the SIDX and SISL segment characteristics out of GDE SHOW and CHECKS them against the two
# values the caller says it expects. Arguments are the expected SIDX and the expected SISL, spelled
# as GDE displays them, so AUTO and OFF are written here the way a reader sees them.
#
# Same reasoning as search_index_check-ydb1143.csh : displaying a value only proves it has not changed
# since the reference file was made, while naming the expected value proves the product agrees with
# what the subtest claims. GDE squeezes its output into columns, so the spaces are removed before
# comparing and the reference does not depend on column positions.

set expsidx = "$argv[1]"
set expsisl = "$argv[2]"
# The value can be separated from its keyword by padding, "SISL=            OFF", so the match has to
# span the spaces rather than stop at the first one.
echo "show -segment" | $ydb_dist/mumps -run GDE >& gdecheck.out
set actsidx = `grep -o "SIDX= *[A-Za-z0-9]*" gdecheck.out | head -1 | sed 's/SIDX= *//'`
set actsisl = `grep -o "SISL= *[A-Za-z0-9]*" gdecheck.out | head -1 | sed 's/SISL= *//'`
if (("$actsidx" == "$expsidx") && ("$actsisl" == "$expsisl")) then
	echo "SIDX=$actsidx SISL=$actsisl : as expected"
else
	echo "SIDX=$actsidx SISL=$actsisl : WRONG, expected SIDX=$expsidx SISL=$expsisl"
endif
