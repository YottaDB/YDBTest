#!/usr/local/bin/tcsh -f
#################################################################
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

echo "# Test that ZWRITE of lvn with 1MiB subscript works fine"
echo "# Before YDB@5e955190, this used to assert fail in sr_port/lvzwr_out.c"
echo "# Run [yottadb -run zwr1MibSubs]. This would create a file [zwr.txt] with the ZWRITE output"
$gtm_dist/mumps -run zwr1MibSubs
echo "# The file [zwr.txt] would have 33 lines, the first 32 lines being 32767 bytes long and the last line being 42 bytes long"
echo "# Extract first 42 columns of ALL lines to confirm ZWRITE command worked fine"
cut -b 1-42 zwr.txt

