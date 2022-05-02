#!/bin/sh
#################################################################
#								#
# Copyright (c) 2021-2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

if [ "yes" = $6 ] ; then
	/Distrib/YottaDB/$1/$2/yottadb_r*/ydbinstall --installdir $3 --overwrite-existing --user $USER $4 > install.out
	/Distrib/YottaDB/$1/$2/yottadb_r*/ydbinstall --installdir $3 --overwrite-existing --user $USER $4 --plugins-only $5 > plugins.out 2>&1
else
	/Distrib/YottaDB/$1/$2/yottadb_r*/ydbinstall --installdir $3 --overwrite-existing --user $USER $4 $5 > install.out 2>&1
fi

status=$?
if [ 0 != $status ]; then
	echo "ydbinstall returned a non-zero status: $status"
	echo "# install.out contents follow"
	cat install.out
	if [ "yes" = $6 ] ; then
		echo "# plugins.out contents follow"
		cat plugins.out
	fi
	exit $status
fi
if [ "yes" = $6 ] ; then
	echo "ydbinstall with options --plugins-only $5 was successful."
else
	echo "ydbinstall with options $5 was successful."
fi

exit 0
