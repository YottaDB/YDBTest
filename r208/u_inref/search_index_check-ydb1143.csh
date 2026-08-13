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
# Reads the search index size and slot count of each region named on the command line and CHECKS them
# against the values the caller says it expects. Arguments are triples : region, expected size,
# expected slot count.
#
# The point of checking rather than merely printing is that a reference file records whatever happened.
# A stage that only displays two numbers passes as long as those numbers do not change, so a wrong
# value baked into a reference file goes on matching itself forever. Naming the expectation in the
# subtest turns a wrong value into the word WRONG, which no one skims past, and it states in the
# subtest itself what the stage believes the product should do.
#
# A separate script rather than an alias in the caller because tcsh cannot carry a "while" in an alias.
# DSE prints both fields on ONE line, so a single grep gets the pair; the spacing is squeezed out so
# the reference file does not depend on column positions.

while ($#argv > 0)
	set reg = "$argv[1]"
	set expsize = "$argv[2]"
	set expslots = "$argv[3]"
	shift
	shift
	shift
	set line = `( echo "find -region=$reg" ; echo "dump -fileheader" ) | $ydb_dist/dse |& grep -i "Search Index Size" | sed 's/  */ /g; s/^ //'`
	# "Search Index Size <bytes> Search Index Slots <count>" : the two numbers are words 4 and 8
	set actsize = "$line[4]"
	set actslots = "$line[8]"
	if (("$actsize" == "$expsize") && ("$actslots" == "$expslots")) then
		echo "$reg : Search Index Size $actsize Search Index Slots $actslots : as expected"
	else
		echo "$reg : Search Index Size $actsize Search Index Slots $actslots : WRONG, expected size $expsize slots $expslots"
	endif
end
