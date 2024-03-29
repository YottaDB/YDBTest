#!/bin/sh
#################################################################
# Copyright (c) 2019-2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# attempts to install yottadb to the testing directory from a different directory (/tmp in this case)
cd /tmp
/Distrib/YottaDB/$1/$2/yottadb_r*/ydbinstall --installdir $3 --overwrite-existing $4

status=$?
if [ 0 != $status ]; then
	echo "ydbinstall returned a non-zero status: $status"
	exit $status
fi

exit 0
