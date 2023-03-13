#!/bin/sh
#################################################################
# Copyright (c) 2022-2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

FILE=/usr/share/pkgconfig/yottadb.pc
EXISTS=false
# If yottadb.pc already exists change value of EXISTS flag and
# get its current timestamp
if test -f "$FILE"; then
    EXISTS=true
    OLD_TIMESTAMP=`stat -c %y $FILE`
fi

/Distrib/YottaDB/$1/$2/yottadb_r*/ydbinstall --installdir $3 --nopkg-config --overwrite-existing --utf8 --user $USER $4

status=$?
if [ 0 != $status ]; then
    echo "ydbinstall returned a non-zero status: $status"
    exit $status
else
    # Test errors out if timestamp of yottadb.pc has changed, indicating
    # that the file has been updated with the --nopkg-config option
    if $EXISTS; then
	NEW_TIMESTAMP=`stat -c %y $FILE`
	if [ "$OLD_TIMESTAMP" != "$NEW_TIMESTAMP" ]; then
	    echo "Error: $FILE has been updated with --nopkg-config option"
	fi
    # Test errors out if yottadb.pc gets created with the --nopkg-config
    # option
    else
	if [ -f "$FILE" ]; then
	    echo "Error: $FILE has been created with the --nopkg-config option"
	fi
    fi
fi

exit 0
