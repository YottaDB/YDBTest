#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2024-2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# If run in MSR context:
#     $1, $2, $3 etc. space separated list of instance names that we want merged into INST1's $gtmcrypt_config
# If run outside of MSR context:
#     $1, $2, $3 etc. space separated list of database file paths that we want merged into the existing $gtmcrypt_config

head -n -3 $gtmcrypt_config > $gtmcrypt_config.merged
foreach inst ($*)
	echo "        }," >> $gtmcrypt_config.merged
	if ($?MSR) then
		$MSR RUN $inst "cat $gtmcrypt_config" | sed '0,/keys:/d' | head -n -3 >> $gtmcrypt_config.merged
	else
		# Add missing 'dat_key' entries for the given instance to $gtmcrypt_config by appending similar entries from the existing $gtmcrypt_config, but:
		# 1. With the instance name swapped to $inst
		# 2. Only when the 'dat_key' entry shares a name with the database file in $inst, e.g. "mumps_dat_key" for "../mumps.dat"
		set dbname = `basename $inst | cut -f 1 -d '.'`
		cat $gtmcrypt_config | sed '0,/keys:/d' | head -n -3 | awk -v dbname=$dbname 'BEGIN {RS=","} $0 ~ dbname { printf "%s", $0 }' | sed 's/}$/},/g' | sed 's|^\([[:space:]]*dat: \).*|\1"'${inst}'";|g' >> $gtmcrypt_config.merged
	endif
end
tail -n 3 $gtmcrypt_config >> $gtmcrypt_config.merged
mv $gtmcrypt_config $gtmcrypt_config.orig
mv $gtmcrypt_config.merged $gtmcrypt_config
