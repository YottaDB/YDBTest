#!/usr/local/bin/tcsh -f
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
echo ""
echo "------------------------------------------------------------"
echo '# Set $ZROUTINES to $ydb_dist/utf8/libyottadbutil.so if ydb_chset=UTF-8 and ydb_routines is not set'

source $gtm_tst/$tst/u_inref/setinstalloptions.csh	# sets the variable "installoptions" (e.g. "--force-install" if needed)
echo "# Creating 3 YDB installations, M, UTF-8, UTF-8 with no sharedlibs"
$sudostr /Distrib/YottaDB/$gtm_verno/$tst_image/yottadb_r*/ydbinstall --installdir $PWD/YDBM $installoptions
$sudostr /Distrib/YottaDB/$gtm_verno/$tst_image/yottadb_r*/ydbinstall --utf8 default --installdir $PWD/YDBUTF8 $installoptions
$sudostr /Distrib/YottaDB/$gtm_verno/$tst_image/yottadb_r*/ydbinstall --utf8 default --keep-obj --installdir $PWD/YDBUTF8NOSO $installoptions
# YottaDB has these by default now; remove them to test the corner case that they don't exist
$sudostr rm $PWD/YDBUTF8NOSO/libyottadbutil.so $PWD/YDBUTF8NOSO/utf8/libyottadbutil.so

$switch_chset "M"
unsetenv gtmroutines
unsetenv ydb_routines
unsetenv gtm_dist
unsetenv ydb_dist

echo ""
echo "# ydb_chset/gtm_chset='M' but install does not have UTF-8 folder"
setenv ydb_dist $PWD/YDBM
$ydb_dist/yottadb -dir << EOF
WRITE \$ZROUTINES
EOF

echo ""
echo "# ydb_chset/gtm_chset='M' and install has UTF-8 folder"
setenv ydb_dist $PWD/YDBUTF8
$ydb_dist/yottadb -dir << EOF
WRITE \$ZROUTINES
EOF

$switch_chset "UTF-8"
unsetenv gtmroutines
unsetenv ydb_routines
unsetenv gtm_dist
unsetenv ydb_dist

echo ""
echo "# ydb_chset/gtm_chset='UTF-8' but install does not have UTF-8 folder"
setenv ydb_dist $PWD/YDBM
$ydb_dist/yottadb -dir << EOF
WRITE \$ZROUTINES
EOF

echo ""
echo "# ydb_chset/gtm_chset='UTF-8' and install has UTF-8 folder"
setenv ydb_dist $PWD/YDBUTF8
$ydb_dist/yottadb -dir << EOF
WRITE \$ZROUTINES
EOF

echo ""
echo "# ydb_chset/gtm_chset='UTF-8' and install has UTF-8 folder, but only .o files not libyottadbutil.so"
setenv ydb_dist $PWD/YDBUTF8NOSO
$ydb_dist/yottadb -dir << EOF
WRITE \$ZROUTINES
EOF

# clean up the install directory since the files are owned by root and can't be gzipped by the test system
$sudostr rm -rf $PWD/YDBM
$sudostr rm -rf $PWD/YDBUTF8
$sudostr rm -rf $PWD/YDBUTF8NOSO
