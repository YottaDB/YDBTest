#!/bin/sh
#################################################################
#								#
# Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
gtm_verno=$1
tst_image=$2
install_dir=$3
install_opts=$4
echo "# Install YottaDB r1.38 as a base version"
/Distrib/YottaDB/${gtm_verno}/${tst_image}/yottadb_r*/ydbinstall --installdir ${install_dir} ${install_opts} --overwrite-existing r1.38 > install_r138.out
status=$?
if [ 0 != $status ]; then
	echo "ydbinstall returned a non-zero status: $status"
	exit $status
fi
grep -v "pkg-config" install_r138.out
echo ""
echo "# geteuid had been removed from YottaDB since YottaDB r1.24 (YDB#338) so no need to check for it anymore"
echo "# See more details at https://gitlab.com/YottaDB/DB/YDB/-/issues/338"
echo ""
echo "# Verify that geteuid doesn't exist"
ls ${install_dir}/geteuid
echo ""
echo "# Verify that ftok, semstat2 exist"
ls ${install_dir}/ftok ${install_dir}/semstat2
echo ""
echo "# Install YottaDB latest version as a new version with --overwrite-existing"
/Distrib/YottaDB/${gtm_verno}/${tst_image}/yottadb_r*/ydbinstall --installdir ${install_dir} --overwrite-existing ${install_opts} > install_latest.out
status=$?
if [ 0 != $status ]; then
	echo "ydbinstall returned a non-zero status: $status"
	exit $status
fi
grep -v "pkg-config" install_latest.out
echo ""
echo "# Verify that ftok, semstat2 are gone : This should be gone (before GT.M V7.0-002 got merged, this file would not be gone)."
ls ${install_dir}/ftok ${install_dir}/semstat2
echo ""
