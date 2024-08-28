#!/bin/sh
#################################################################
# Copyright (c) 2022-2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "# Backing up ydb, gtm and ydbsh symlinks under /usr/local/bin (if any)"
cd /usr/local/bin
existing_ydb=`readlink ydb`
existing_gtm=`readlink gtm`
existing_ydbsh=`readlink ydbsh`
echo ""
echo ""

echo "# Backing up ydb_env_set, ydb_env_unset, and gtmprofile symlinks under /usr/local/etc (if any)"
cd /usr/local/etc
existing_ydb_env_set=`readlink ydb_env_set`
existing_ydb_env_unset=`readlink ydb_env_unset`
existing_gtmprofile=`readlink gtmprofile`
echo ""
echo ""

echo "# Installing YottaDB in install/dir1 without --linkexec and --linkenv options"
/Distrib/YottaDB/$1/$2/yottadb_r*/ydbinstall --installdir $3 --utf8 --user $USER $7 --nopkg-config --overwrite-existing
echo ""

cd /usr/local/bin
current_ydb=`readlink ydb`
current_gtm=`readlink gtm`
current_ydbsh=`readlink ydbsh`
default_gtm=`readlink -f gtm`
default_ydbsh=`readlink -f ydbsh`

echo "# Current ydb, gtm and ydbsh symlinks under /usr/local/bin point to install/dir1"
echo $current_ydb
echo $current_gtm
echo $default_gtm
echo $current_ydbsh
echo $default_ydbsh
echo ""
echo ""

cd /usr/local/etc
current_ydb_env_set=`readlink ydb_env_set`
current_ydb_env_unset=`readlink ydb_env_unset`
current_gtmprofile=`readlink gtmprofile`
default_gtmprofile=`readlink -f gtmprofile`

echo "# Current ydb_env_set, ydb_env_unset, and gtmprofile symlinks under /usr/local/etc point to install/dir1"
echo $current_ydb_env_set
echo $current_ydb_env_unset
echo $current_gtmprofile
echo $default_gtmprofile
echo ""
echo ""

echo "# Installing YottaDB in install/dir2 without --linkexec and --linkenv options"
/Distrib/YottaDB/$1/$2/yottadb_r*/ydbinstall --installdir $4 --utf8 --user $USER $7 --nopkg-config --overwrite-existing
echo ""

cd /usr/local/bin
current_ydb=`readlink ydb`
current_gtm=`readlink gtm`
current_ydbsh=`readlink ydbsh`

echo "# Current ydb, gtm and ydbsh symlinks under /usr/local/bin now point to install/dir2"
echo $current_ydb
echo $current_gtm
echo $current_ydbsh
echo ""
echo ""

cd /usr/local/etc
current_ydb_env_set=`readlink ydb_env_set`
current_ydb_env_unset=`readlink ydb_env_unset`
current_gtmprofile=`readlink gtmprofile`

echo "# Current ydb_env_set, ydb_env_unset, and gtmprofile symlinks under /usr/local/etc now point to install/dir2"
echo $current_ydb_env_set
echo $current_ydb_env_unset
echo $current_gtmprofile
echo ""
echo ""

#############################################################

echo "# Deleting current ydb, gtm and ydbsh symlinks to check that --linkexec creates symlinks if none exist"
cd /usr/local/bin
sudo rm gtm ydb ydbsh
echo ""
echo ""

echo "# Installing YottaDB in install/dir1 with --linkexec option"
/Distrib/YottaDB/$1/$2/yottadb_r*/ydbinstall --installdir $3 --linkexec --utf8 --user $USER $7 --nopkg-config --overwrite-existing
echo ""

cd /usr/local/bin
current_ydb=`readlink ydb`
current_gtm=`readlink gtm`
current_ydbsh=`readlink ydbsh`

echo "# ydb, gtm and ydbsh symlinks created under /usr/local/bin point to install/dir1"
echo $current_ydb
echo $current_gtm
echo $current_ydbsh
echo ""
echo ""

echo "# Installing YottaDB in install/dir2 with --linkexec option"
/Distrib/YottaDB/$1/$2/yottadb_r*/ydbinstall --installdir $4 --linkexec --utf8 --user $USER $7 --nopkg-config --overwrite-existing
echo ""

current_ydb=`readlink ydb`
current_gtm=`readlink gtm`
current_ydbsh=`readlink ydbsh`

echo "# Current ydb, gtm and ydbsh symlinks under /usr/local/bin now point to install/dir2"
echo $current_ydb
echo $current_gtm
echo $current_ydbsh
echo ""
echo ""

echo "# Installing YottaDB in install/dir1 with --nolinkexec option"
/Distrib/YottaDB/$1/$2/yottadb_r*/ydbinstall --installdir $3 --nolinkexec --utf8 --user $USER $7 --nopkg-config --overwrite-existing
echo ""

current_ydb=`readlink ydb`
current_gtm=`readlink gtm`
current_ydbsh=`readlink ydbsh`

echo "# Current ydb, gtm and ydbsh symlinks under /usr/local/bin still point to install/dir2"
echo $current_ydb
echo $current_gtm
echo $current_ydbsh
echo ""
echo ""

#############################################################################

echo "# Deleting current ydb_env_set, ydb_env_unset, and gtmprofile symlinks to check that --linkenv creates symlinks if none exist"
cd /usr/local/etc
sudo rm ydb_env_set ydb_env_unset gtmprofile
echo ""
echo ""

echo "# Installing YottaDB in install/dir2 with --linkenv option"
/Distrib/YottaDB/$1/$2/yottadb_r*/ydbinstall --installdir $4 --linkenv --utf8 --user $USER $7 --nopkg-config --overwrite-existing
echo ""

current_ydb_env_set=`readlink ydb_env_set`
current_ydb_env_unset=`readlink ydb_env_unset`
current_gtmprofile=`readlink gtmprofile`

echo "# ydb_env_set, ydb_env_unset, and gtmprofile symlinks created under /usr/local/etc point to install/dir2"
echo $current_ydb_env_set
echo $current_ydb_env_unset
echo $current_gtmprofile
echo ""
echo ""

echo "# Installing YottaDB in install/dir1 with --linkenv option"
/Distrib/YottaDB/$1/$2/yottadb_r*/ydbinstall --installdir $3 --linkenv --utf8 --user $USER $7 --nopkg-config --overwrite-existing
echo ""

current_ydb_env_set=`readlink ydb_env_set`
current_ydb_env_unset=`readlink ydb_env_unset`
current_gtmprofile=`readlink gtmprofile`

echo "# Current ydb_env_set, ydb_env_unset, and gtmprofile symlinks under /usr/local/etc now point to install/dir1"
echo $current_ydb_env_set
echo $current_ydb_env_unset
echo $current_gtmprofile
echo ""
echo ""

echo "# Installing YottaDB in install/dir2 with --nolinkenv option"
/Distrib/YottaDB/$1/$2/yottadb_r*/ydbinstall --installdir $4 --nolinkenv --utf8 --user $USER $7 --nopkg-config --overwrite-existing
echo ""

current_ydb_env_set=`readlink ydb_env_set`
current_ydb_env_unset=`readlink ydb_env_unset`
current_gtmprofile=`readlink gtmprofile`

echo "# Current ydb_env_set, ydb_env_unset, and gtmprofile symlinks under /usr/local/etc still point to install/dir1"
echo $current_ydb_env_set
echo $current_ydb_env_unset
echo $current_gtmprofile
echo ""
echo ""

#############################################################################

echo "# Installing YottaDB in install/dir1 with --linkexec tmpbin/"
/Distrib/YottaDB/$1/$2/yottadb_r*/ydbinstall --installdir $3 --linkexec $5 --utf8 --user $USER $7 --nopkg-config --overwrite-existing
echo ""

cd $5
current_ydb=`readlink ydb`
current_gtm=`readlink gtm`
current_ydbsh=`readlink ydbsh`

echo "# Current ydb, gtm and ydbsh symlinks under tmpbin/ point to install/dir1"
echo $current_ydb
echo $current_gtm
echo $current_ydbsh
echo ""
echo ""

echo "# Installing YottaDB in install/dir2 with --linkexec tmpbin/"
/Distrib/YottaDB/$1/$2/yottadb_r*/ydbinstall --installdir $4 --linkexec $5 --utf8 --user $USER $7 --nopkg-config --overwrite-existing
echo ""

cd $5
current_ydb=`readlink ydb`
current_gtm=`readlink gtm`
current_ydbsh=`readlink ydbsh`

echo "# Current ydb, gtm and ydbsh symlinks under tmpbin/ now point to install/dir2"
echo $current_ydb
echo $current_gtm
echo $current_ydbsh
echo ""
echo ""

echo "# Installing YottaDB in install/dir1 with --linkenv tmpetc/"
/Distrib/YottaDB/$1/$2/yottadb_r*/ydbinstall --installdir $3 --linkenv $6 --utf8 --user $USER $7 --nopkg-config --overwrite-existing
echo ""

cd $6
current_ydb_env_set=`readlink ydb_env_set`
current_ydb_env_unset=`readlink ydb_env_unset`
current_gtmprofile=`readlink gtmprofile`

echo "# Current ydb_env_set, ydb_env_unset, and gtmprofile symlinks under tmpetc/ point to install/dir1"
echo $current_ydb_env_set
echo $current_ydb_env_unset
echo $current_gtmprofile
echo ""
echo ""

echo "# Installing YottaDB in install/dir2 with --linkenv tmpetc/"
/Distrib/YottaDB/$1/$2/yottadb_r*/ydbinstall --installdir $4 --linkenv $6 --utf8 --user $USER $7 --nopkg-config --overwrite-existing
echo ""

cd $6
current_ydb_env_set=`readlink ydb_env_set`
current_ydb_env_unset=`readlink ydb_env_unset`
current_gtmprofile=`readlink gtmprofile`

echo "# Current ydb_env_set, ydb_env_unset, and gtmprofile symlinks under tmpetc/ now point to install/dir2"
echo $current_ydb_env_set
echo $current_ydb_env_unset
echo $current_gtmprofile
echo ""
echo ""

############################################################

echo "# Installing YottaDB in install/dir1 with --copyexec option"
/Distrib/YottaDB/$1/$2/yottadb_r*/ydbinstall --installdir $3 --copyexec --utf8 --user $USER $7 --nopkg-config --overwrite-existing
echo ""

cd /usr/local/bin
ls ydb
readlink gtm
ls ydbsh
readlink ydbsh
echo ""
echo ""

echo "# Installing YottaDB in install/dir2 with --copyenv option"
/Distrib/YottaDB/$1/$2/yottadb_r*/ydbinstall --installdir $4 --copyenv --utf8 --user $USER $7 --nopkg-config --overwrite-existing
echo ""

cd /usr/local/etc
ls ydb_env_set
ls ydb_env_unset
readlink gtmprofile
echo ""
echo ""

echo "# Installing YottaDB in install/dir1 with --copyexec tmpbin/"
/Distrib/YottaDB/$1/$2/yottadb_r*/ydbinstall --installdir $3 --copyexec $5 --utf8 --user $USER $7 --nopkg-config --overwrite-existing
echo ""

cd $5
ls ydb
readlink gtm
ls ydbsh
readlink ydbsh
echo ""
echo ""

echo "# Installing YottaDB in install/dir2 with --copyenv tmpetc/"
/Distrib/YottaDB/$1/$2/yottadb_r*/ydbinstall --installdir $4 --copyenv $6 --utf8 --user $USER $7 --nopkg-config --overwrite-existing
echo ""

cd $6
ls ydb_env_set
ls ydb_env_unset
readlink gtmprofile
echo ""
echo ""

########################################################

cd /usr/local/bin
echo "# Restoring ydb, gtm and ydbsh symlinks under /usr/local/bin to their original state"
sudo rm gtm ydb ydbsh
if [ "$existing_ydb" != "" ]; then
    sudo ln -s $existing_ydb ydb
fi
if [ "$existing_gtm" != "" ]; then
    sudo ln -s $existing_gtm gtm
fi
if [ "$existing_ydbsh" != "" ]; then
    sudo ln -s $existing_ydbsh ydbsh
fi
echo ""
echo ""

cd /usr/local/etc
echo "# Restoring ydb_env_set, ydb_env_unset, and gtmprofile symlinks under /usr/local/etc to their original state"
sudo rm ydb_env_set ydb_env_unset gtmprofile
if [ "$existing_ydb_env_set" != "" ]; then
    sudo ln -s $existing_ydb_env_set ydb_env_set
fi
if [ "$existing_ydb_env_unset" != "" ]; then
    sudo ln -s $existing_ydb_env_unset ydb_env_unset
fi
if [ "$existing_gtmprofile" != "" ]; then
    sudo ln -s $existing_gtmprofile gtmprofile
fi
echo ""
echo ""
