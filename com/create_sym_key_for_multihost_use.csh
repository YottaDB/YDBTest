#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2015-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# This is a script to be *sourced* on the *local* box when running multihost tests that ship databases across. To ensure that the
# remote side can decrypt a database create on the local side, we distribute the same symmetric key to both hosts, which is then
# discovered by the dbcreate.csh script.
setenv gtm_encrypt_notty "--no-permission-warning"
date >>&! $tst_general_dir/use_this_key.out
set key_name = ${tst_org_host:ar}_sym_key_from_${tst_org_host:ar}.asc
$gtm_tst_ver_gtmcrypt_dir/gen_sym_key.sh 0 $tst_general_dir/$key_name		>>& $tst_general_dir/use_this_key.out
setenv gtm_use_same_sym_key $tst_general_dir/$key_name
set i = 2
while ($i <= $gtm_test_eotf_keys)
	set altkey = ${key_name}_$i
	$gtm_tst_ver_gtmcrypt_dir/gen_sym_key.sh 0 $tst_general_dir/$altkey	>>&! $tst_general_dir/use_this_key.out
	@ i++
end
unsetenv gtm_encrypt_notty
