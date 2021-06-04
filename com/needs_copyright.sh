#!/bin/sh

#################################################################
#								#
# Copyright (c) 2020-2021 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Determines whether a file should need a copyright by its name
# Returns 0 if it needs a copyright and 1 otherwise.
# Returns 2 if an error occurs.
set -eu

if ! [ $# = 1 ]; then
	echo "usage: $0 <filename>"
	exit 2
fi

file="$1"

# Don't require deleted files to have a copyright
if ! [ -e "$file" ]; then
       exit 1
fi

skipextensions="txt out dat key crt cfg inp zwr"	# List of extensions that cannot have copyrights.
if echo "$skipextensions" | grep -q -w "$(echo "$file" | awk -F . '{print $NF}')"; then
	exit 1
fi

# Below is a list of specific files that do not have a copyright so ignore them
# The files below are planned to be public domain and so should not have copyright on them so that people can copy and paste.
skiplist="COPYING call_ins/inref/_ydbaccess.m call_ins/inref/_ydbreturn.m call_ins/inref/ydbaccess.ci call_ins/inref/ydbaccess_ci.c call_ins/inref/ydbaccess_cip.c call_ins/inref/ydbreturn.ci call_ins/inref/ydbreturn_ci.c"
skiplist="$skiplist socket/inref/VPRJREQ.m" # This file was obtained from the public domain so do not have a copyright for it.
for skipfile in $skiplist; do
	if [ $file = $skipfile ]; then
		exit 1
	fi
done
