#!/usr/local/bin/tcsh -f
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
# $1, $2, $3 etc. space separated list of instance names that we want merged into INST1's $gtmcrypt_config

head -n -3 $gtmcrypt_config > $gtmcrypt_config.merged
foreach inst ($*)
	echo "        }," >> $gtmcrypt_config.merged
	$MSR RUN $inst "cat $gtmcrypt_config" | sed '0,/keys:/d' | head -n -3 >> $gtmcrypt_config.merged
end
tail -n 3 $gtmcrypt_config >> $gtmcrypt_config.merged
mv $gtmcrypt_config $gtmcrypt_config.orig
mv $gtmcrypt_config.merged $gtmcrypt_config

