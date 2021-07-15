#!/bin/sh
#################################################################
#								#
# Copyright (c) 2021 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

/Distrib/YottaDB/$1/$2/yottadb_r*/ydbinstall --installdir $3 --overwrite-existing --user $USER $4 > install.out
/Distrib/YottaDB/$1/$2/yottadb_r*/ydbinstall --installdir $3 --overwrite-existing --user $USER $4 --plugins-only $5 > plugins.out

if [ 0 != $? ]; then
        echo "ydbinstall returned a non-zero status: $?"
	cat install.out
	cat plugins.out
        exit $?
else
	echo "ydbinstall with options --plugins-only $5 was successful."
fi

exit 0
