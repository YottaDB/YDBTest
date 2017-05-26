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

############################################################################
# Verify that the UTF-specific $gtm_dist path can be used with encryption. #
############################################################################

$switch_chset UTF-8 >&! enable_utf8.txt

cat > gtmcrypt.cfg <<EOF
database: {
	keys: ( {
		dat: "mumps.dat";
		key: "mumps.key";
	} );
};
files : {
        key: "mumps.key";
};
EOF

setenv gtm_encrypt_notty "--no-permission-warning"
$gtm_tst_ver_gtmcrypt_dir/gen_sym_key.sh 0 mumps.key
unsetenv gtm_encrypt_notty

$GDE change -seg DEFAULT -encr
$MUPIP create

$DSE dump -f >&! dse.log
set encryption = `$tst_awk '/encrypt/ {print $4}' dse.log`
if ("$encryption" != "TRUE") then
	echo "TEST-E-FAIL, Database is not encrypted. See dse.log for details."
endif

$gtm_exe/mumps -run %XCMD 'set ^a=1'
set a = `$gtm_exe/mumps -run %XCMD 'write ^a set $x=0'`
if ("$a" != "1") then
	echo "TEST-E-FAIL, Global ^a contains '$a' instead of '1'."
endif

$gtm_exe/mumps -run %XCMD 'set x="x.encr" open x:key="key 123" use x write "привет, мир!" set $x=0 close x'
$gtm_exe/mumps -run %XCMD 'set x="x.plain" open x use x write "привет, мир!" set $x=0 close x'
diff x.plain x.encr >&! x.plain-encr.diff
if (! $status) then
	echo "TEST-E-FAIL, File x.encr is not encrypted. Compare it with x.plain."
	exit 1
endif
$gtm_exe/mumps -run %XCMD 'set x="x.encr" open x:key="key 123" use x read line:30 set t=$test use $p write $select(t=0:"Timed out",1:line) set $x=0' > x.decr
diff x.plain x.decr >&! x.plain-decr.diff
if ($status) then
	echo "TEST-E-FAIL, Result of decrypting x.encr (stored in x.decr) is different from x.plain."
endif

$gtm_tst/com/dbcheck.csh
