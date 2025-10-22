#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2015-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2025 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

if (2 > $gtm_test_eotf_keys) then
	echo "ONLINE_EOTF-I-MULTIPlE_KEYS : gtm_test_eotf_keys ($gtm_test_eotf_keys) is less than 2. Cannot proceed"
	exit 0
endif

echo "`date` : online reorg encrypt begins"
echo "PID : $$"
touch EOTF.RUNNING

# Get the region-database mapping
$GDE show -map | & $tst_awk '{if (/REG = /) {regname = $NF} ; if (/FILE = /) { dbmap[regname]=$NF}} END {for (r in dbmap){print r,dbmap[r]}}' >&! reg_db.map

# Get the database-multiple-encryption-keys mapping
$tst_awk -F '[/"]' '{if (/dat:/) {dat = $(NF-1)};if (dat == "") next; if (/key:/) {map[dat] = map[dat]" "$(NF-1)}} END {for (i in map) print i " : " map[i]}' gtmcrypt.cfg >& gtmcrypt_cfg.map

set region_list = `$tst_awk '{print $1}' reg_db.map`
foreach region ($region_list)
	set dbname = `$tst_awk '/^'$region'/ {print $2}' reg_db.map`
	eval 'set '$region' = '$dbname''
	set keys = `$tst_awk -F : '/^'$dbname'/ {print $2}' gtmcrypt_cfg.map`
	eval 'set keys_'$region' = ('$keys')'
end

echo "# The below environment variables control the rest of the script"
echo "gtm_test_eotf_keys = $gtm_test_eotf_keys"
set |& $grep -E "keys_|region_list"

@ cnt = 0
while (1)
	date
	@ keycnt = $cnt % $gtm_test_eotf_keys + 1
	echo "# keycnt : $keycnt"
	foreach region ($region_list)
		if (-f "EOTF.END") then
			set eotfend
			break
		endif
		source $gtm_tst/com/random_mutex_type.csh
		echo "# `date` : Region : $region"
		eval 'set key = $keys_'$region'['$keycnt']'
		alias do '$MUPIP reorg -encrypt='$key' -region '$region''
		alias do
		do
		sleep 5
		alias done '$MUPIP set -encryptioncomplete -region '$region''
		alias done
		done
		echo ""
	end
	if ($?eotfend) then
		break
	endif
	@ cnt = $cnt + 1
	@ sleeptime = $cnt % 30
	sleep $sleeptime
end
rm -f EOTF.RUNNING
echo "`date` : online reorg encrypt done"
