#################################################################
#								#
# Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo '# Test that YDBEncrypt .sh scripts get installed with execute permissions in $ydb_dist/plugin/ydbcrypt'

foreach file ($ydb_dist/plugin/ydbcrypt/*.sh)
	echo -n "Testing $file:t has execute permissions : "
	if (-x $file) then
		echo "PASS"
	else
		echo "FAIL. ls -l $file output follows."
		ls -l $file
	endif
end

