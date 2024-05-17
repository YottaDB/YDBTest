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

echo '# Check left-to-right evaluation within $SELECT() when using FULL_BOOLEAN compilation'
echo '# This will print 0 on success or 1 if the side effect ($increment) is evaluated before it should be.'

# Note: it is necessary to `xecute` the code string to be sure FULL_BOOLEAN has been applied
set code = 'view "FULL_BOOLEAN" xecute "set x=0 w (x=1)\!$select($increment(x)=0:0,1:0)"'
echo "GTM>$code:q"
echo "$code:q" | $GTM
