#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2014-2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

#################################################################
# Ensure that there are no memory leaks caused by the use of
# database and / or device encryption.
#################################################################

# MPROF and Unicode libraries allocate extra memory, so they are disabled.
unsetenv gtm_trace_gbl_name
if ($?gtm_chset) then
	if ("UTF-8" == "$gtm_chset") then
		$switch_chset M >&! disable_utf8.txt
	endif
endif

@ dbglvl = 0
# Use the following memory debugging flags (from gtmdbglvl.h); comment out as needed:
#	Regular assert checking, no special checks.
	@ dbglvl = $dbglvl + 1
#	Perform verification of allocated storage chain for each call.
	@ dbglvl = $dbglvl + 16
#	Perform simple verification of free storage chain for each call.
	@ dbglvl = $dbglvl + 32
#	Backfill unused storage (cause exceptions if released storage is used).
	@ dbglvl = $dbglvl + 64
#	Verify backfilled storage in GDL_AllocVerf while verifying each individual queue entry.
	@ dbglvl = $dbglvl + 128
#	Verify backfilled storage in GDL_FreeVerf while verifying each individual queue entry.
	@ dbglvl = $dbglvl + 256
#	Each piece of storage allocated is allocated in an element twice the desired size to
#	provide glorious amounts of backfill for overrun checking.
	@ dbglvl = $dbglvl + 512

setenv gtmdbglvl $dbglvl

$gtm_tst/com/dbcreate.csh mumps 10

cat >> $gtmcrypt_config <<EOF
files : {
        key1 : "a_dat_key";
	key2 : "key2.key";
	key3 : "c_dat_key";
	key4 : "key4.key";
	key5 : "e_dat_key";
	key6 : "key6.key";
	key7 : "g_dat_key";
	key8 : "key8.key";
	key9 : "i_dat_key";
	key10 : "key10.key";
};
EOF

cp $gtmcrypt_config gtmcrypt1.cfg

cat > gtmcrypt2.cfg <<EOF
files : {
        key1 : "b_dat_key";
	key2 : "key2.key";
	key3 : "d_dat_key";
	key4 : "key4.key";
	key5 : "f_dat_key";
	key6 : "key6.key";
	key7 : "h_dat_key";
	key8 : "key8.key";
	key9 : "j_dat_key";
	key10 : "key10.key";
};
EOF

cat > gtmcrypt3.cfg <<EOF
files : {
	key2 : "key10.key";
	key4 : "key8.key";
	key6 : "key6.key";
	key8 : "key4.key";
	key10 : "key2.key";
};
EOF

cat > gtmcrypt4.cfg <<EOF
files : {
	key12 : "key10.key";
	key14 : "key8.key";
	key16 : "key6.key";
	key18 : "key4.key";
	key20 : "key2.key";
	key22 : "a_dat_key";
};
EOF

cat > gtmcrypt5.cfg <<EOF
database : {
	keys: ( {
		dat : "z.dat";
		key : "a_dat_key";
	});
};
EOF

cat > gtmcrypt6.cfg <<EOF
database : {
	keys: ( {
		dat : "a.dat";
		key : "b_dat_key";
	}, {
		dat : "b.dat";
		key : "a_dat_key";
	} );
};
EOF

cat > gtmcrypt7.cfg <<EOF
database : {
	keys: ( {
		dat : "i.dat";
		key : "key2.key";
	}, {
		dat : "j.dat";
		key : "key4.key";
	} );
};
files : {
        key2 : "i_dat_key";
	key4 : "j_dat_key";
};
EOF


setenv gtm_encrypt_notty "--no-permission-warning"
$gtm_tst_ver_gtmcrypt_dir/gen_sym_key.sh 0 key2.key
$gtm_tst_ver_gtmcrypt_dir/gen_sym_key.sh 0 key4.key
$gtm_tst_ver_gtmcrypt_dir/gen_sym_key.sh 0 key6.key
$gtm_tst_ver_gtmcrypt_dir/gen_sym_key.sh 0 key8.key
$gtm_tst_ver_gtmcrypt_dir/gen_sym_key.sh 0 key10.key
unsetenv gtm_encrypt_notty

$gtm_dist/mumps -run memoryleak

cp gtmcrypt1.cfg gtmcrypt.cfg

$gtm_tst/com/dbcheck.csh
