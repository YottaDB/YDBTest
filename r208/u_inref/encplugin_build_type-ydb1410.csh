#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "#----------------------------------------------------------------------------------------------------#"
echo "# [YDB#1410] The encryption and TLS plugin is a debug build (with asserts) only for a Debug build of #"
echo "# YottaDB                                                                                            #"
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo "# The plugin Makefile builds a debug plugin for a Debug build of YottaDB and a production plugin, which"
echo "# has no asserts, otherwise. A file of the plugin that has asserts references the C library function"
echo "# __assert_fail(), which nm -D lists. So with a Debug build of YottaDB each file below has to reference"
echo "# __assert_fail(), and with a Release build none of them may."
echo "#"
echo "# Before the fix : make built a debug plugin unless image=PRO was specified, so this subtest failed with"
echo "#                  a Release build of YottaDB, with a FAIL line for each file below"
echo "# With the fix   : expect a PASS line for each file with a Debug and with a Release build of YottaDB"
echo

echo '# Command : nm -D $gtm_dist/plugin/<file> | grep -c __assert_fail, for each of the 5 files below'
foreach file (libgtmtls.so libgtmcryptutil.so libgtmcrypt_gcrypt_AES256CFB.so libgtmcrypt_openssl_AES256CFB.so gtmcrypt/maskpass)
	if (! -e $gtm_dist/plugin/$file) then
		echo "FAIL : $file does not exist in the plugin directory"
		continue
	endif
	set count = `nm -D $gtm_dist/plugin/$file | grep -c __assert_fail`
	if (("dbg" == "$tst_image") && (0 != $count)) then
		echo "PASS : $file matches the build type of YottaDB"
	else if (("dbg" != "$tst_image") && (0 == $count)) then
		echo "PASS : $file matches the build type of YottaDB"
	else
		echo "FAIL : $file has $count references to __assert_fail with a $tst_image build of YottaDB"
	endif
end
