#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2019 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# Tests that ydbinstall will give and error and exit without doing anything when sourced

echo '# Tests that ydbinstall will give and error and exit without doing anything when sourced'
# setup of the image environment
mkdir install # the install destination
cd install
# we have to make this folder before hand otherwise the installer will throw out errors
# this happens only when this script is invoked by the test system
# it works fine without permission issues when run as root in an interactive terminal
mkdir gtmsecshrdir
chmod -R 755 .

cp $gtm_tst/$tst/u_inref/sourceInstall.sh ..
sudo sh ../sourceInstall.sh $gtm_verno $tst_image `pwd`


if (`ls -1 | wc -l` != 1) then
	echo "ydbinstall created files in the install directory when it shouldn't have"
	echo "Only thing in there should be the empty folder gtmsecshrdir/"
	echo "Files found"
	ls -1
endif
