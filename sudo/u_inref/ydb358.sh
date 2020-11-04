#!/bin/sh
#################################################################
# Copyright (c) 2020 YottaDB LLC and/or its subsidiaries.       #
# All rights reserved.                                          #
#                                                               #
#                                                               #
#       This source code contains the intellectual property     #
#       of its copyright holder(s), and is made available       #
#       under a license.  If you do not know the terms of       #
#       the license, please stop and do not read further.       #
#                                                               #
#################################################################

/Distrib/YottaDB/$1/$2/yottadb_r*/ydbinstall --installdir $3 --zlib --overwrite-existing --utf8 default --user $USER $4

if [ 0 != $? ]; then
        echo "ydbinstall returned a non-zero status: $?"
        exit $?
fi

exit 0
