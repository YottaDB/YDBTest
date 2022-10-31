#!/bin/sh
#################################################################
# Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.       #
# All rights reserved.                                          #
#                                                               #
#                                                               #
#       This source code contains the intellectual property     #
#       of its copyright holder(s), and is made available       #
#       under a license.  If you do not know the terms of       #
#       the license, please stop and do not read further.       #
#                                                               #
#################################################################

echo "# Testing ydbinstall/ydbinstall.sh as root with --dry-run option"
/Distrib/YottaDB/$1/$2/yottadb_r*/ydbinstall --installdir $3 --overwrite-existing --utf8 default --dry-run $4

status=$?
if [ 0 != $status ]; then
    echo "ydbinstall returned a non-zero status: $status"
    exit $status
fi

echo ""
echo "# Testing ydbinstall/ydbinstall.sh as root"
/Distrib/YottaDB/$1/$2/yottadb_r*/ydbinstall --installdir $3 --overwrite-existing --utf8 default $4

status=$?
if [ 0 != $status ]; then
    echo "ydbinstall returned a non-zero status: $status"
    exit $status
fi

echo ""
if id ydbtest_non_root >/dev/null 2>&1; then
        echo "Non root user already exists."
else
    echo "Non root user does not exist. Creating user."
    useradd --no-log-init --no-create-home -d `pwd` ydbtest_non_root > useradd.log 2>&1
fi
echo ""
echo "# Testing ydbinstall/ydbinstall.sh as non root user with --dry-run option"
sudo --preserve-env=ASAN_OPTIONS su ydbtest_non_root > nru_dr.log 2>&1 <<EOF
/Distrib/YottaDB/$1/$2/yottadb_r*/ydbinstall --installdir $3 --overwrite-existing --utf8 default --dry-run $4

status=$?
if [ 0 != $status ]; then
    echo "ydbinstall returned a non-zero status: $status"
    exit $status
fi
exit
EOF
head -3 nru_dr.log

echo ""
echo "# Testing ydbinstall/ydbinstall.sh as non root user"
sudo --preserve-env=ASAN_OPTIONS su ydbtest_non_root > nru.log 2>&1 <<EOF
/Distrib/YottaDB/$1/$2/yottadb_r*/ydbinstall --installdir $3 --overwrite-existing --utf8 default $4

status=$?
if [ 0 != $status ]; then
    echo "ydbinstall returned a non-zero status: $status"
    exit $status
fi
exit
EOF
head -2 nru.log

userdel ydbtest_non_root > userdel.log 2>&1
