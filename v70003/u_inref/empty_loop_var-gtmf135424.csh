#!/usr/local/bin/tcsh -f
#################################################################
#
# Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.
# All rights reserved.
#
#	This source code contains the intellectual property
#	of its copyright holder(s), and is made available
#	under a license.  If you do not know the terms of
#	the license, please stop and do not read further.
#
#################################################################


# Make output the same under GT.M and YDB
setenv ydb_prompt 'GTM>'
setenv ydb_msgprefix "GTM"

echo "In NOUNDEF mode, access a FOR loop variable that doesn't exist"
echo "to ensure that FOR increments the empty string to 1 rather than"
echo "producing UNDEF error like it did in versions prior to v70003."
echo "This should print 5 and then break"

# Note: 'break:i-1' instead of 'quit:i=1' which is not allowed in a for loop.
# The break prevents an infinite loop due to the 'kill', where i always equals 1 and never reaches 9
echo 'view "noundef" for i=5:1:9 w i," " break:i=1  kill i' | $GTM
