#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2009-2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#

$gtm_tst/com/dbcreate.csh mumps 3

# Before we start anything, lets do a quick test for GTM-7701.
setenv gtm_passwd	# Set gtm_passwd to empty string forcing GT.M startup to load the encryption plugin and ask for password
# nullify the LD_LIBRARY_PATH and LIBPATH so that the dlopen of the encryption plugin will fail on at least a few platforms
set save_ld_library_path = $LD_LIBRARY_PATH
set save_libpath = $LIBPATH
if ($?gtm_chset) then
	set save_utf8 = $gtm_chset
	set save_gtmroutines = "$gtmroutines"
	setenv gtmroutines "$gtmroutines:s/utf8//"
	unsetenv gtm_chset # Force GT.M into non-unicode mode as we want to explicitly test CRYPTDLNOOPEN2.
endif
setenv LD_LIBRARY_PATH
setenv LIBPATH
echo "foobar" | $gtm_dist/mumps -direct	>&! emptypassphrase.out
if ($?save_utf8) then
	setenv gtm_chset $save_utf8 # Now that CRYPTDLNOOPEN2 testing is complete, bring back unicode for the reset of the test.
	setenv gtmroutines "$save_gtmroutines"
endif
# If there is a CRYPTDLNOOPEN2, filter it. Anything else will be caught by the test system
$gtm_tst/com/check_error_exist.csh emptypassphrase.out CRYPTDLNOOPEN2 >&! capturerror.outx
# Bring back sanity
setenv LD_LIBRARY_PATH $save_ld_library_path
setenv LIBPATH $save_libpath

# OK, now that we have a working encrypted database we can verify that maskpass and GT.M mask the same way.

# Get GT.M to prompt for password and set obfuscated one in the enviroment.
setenv gtm_passwd
echo "My kingdom for a horse!" > ob_key.txt

source $gtm_tst/com/unset_ydb_env_var.csh ydb_obfuscation_key gtm_obfuscation_key
echo "Try something simple (with userid and inode)"
set newpasswd="banana"
set maskpass=`echo $newpasswd|$gtm_exe/plugin/gtmcrypt/maskpass |cut -d":" -f 2`
echo $maskpass > maskpasstry1a.txt
$GTM << EOF > gtmtry1a.txt
$newpasswd
w \$ztrnlnm("gtm_passwd")
EOF

if (1 == `$grep -c $maskpass gtmtry1a.txt`) then
	echo PASS
else
	echo FAIL
endif

source $gtm_tst/com/set_ydb_env_var_random.csh ydb_obfuscation_key gtm_obfuscation_key "ob_key.txt"
echo "Try something simple (with gtm_obfuscation key)"
set newpasswd="banana"
set maskpass=`echo $newpasswd|$gtm_exe/plugin/gtmcrypt/maskpass |cut -d":" -f 2`
echo $maskpass > maskpasstry1b.txt
$GTM << EOF > gtmtry1b.txt
$newpasswd
w \$ztrnlnm("gtm_passwd")
EOF

if (1 == `$grep -c $maskpass gtmtry1b.txt`) then
	echo PASS
else
	echo FAIL
endif

source $gtm_tst/com/unset_ydb_env_var.csh ydb_obfuscation_key gtm_obfuscation_key
echo "Try something simple with spaces (with userid and inode)"
set newpasswd="the rain in spain falls mainly on the plain."
set maskpass=`echo $newpasswd|$gtm_exe/plugin/gtmcrypt/maskpass |cut -d":" -f 2`
echo $maskpass > maskpasstry2a.txt
$GTM << EOF > gtmtry2a.txt
$newpasswd
w \$ztrnlnm("gtm_passwd")
EOF

if (1 == `$grep -c $maskpass gtmtry2a.txt`) then
	echo PASS
else
	echo FAIL
endif

source $gtm_tst/com/set_ydb_env_var_random.csh ydb_obfuscation_key gtm_obfuscation_key "ob_key.txt"
echo "Try something simple with spaces (with gtm_obfuscation key)"
set newpasswd="the rain in spain falls mainly on the plain."
set maskpass=`echo $newpasswd|$gtm_exe/plugin/gtmcrypt/maskpass |cut -d":" -f 2`
echo $maskpass > maskpasstry2b.txt
$GTM << EOF > gtmtry2b.txt
$newpasswd
w \$ztrnlnm("gtm_passwd")
EOF

if (1 == `$grep -c $maskpass gtmtry2b.txt`) then
	echo PASS
else
	echo FAIL
endif

source $gtm_tst/com/unset_ydb_env_var.csh ydb_obfuscation_key gtm_obfuscation_key
echo "Try something simple but longer (with userid and inode)"
set newpasswd="1234567890qwertyuiopasdfghjklzxcvbnm"
set maskpass=`echo $newpasswd|$gtm_exe/plugin/gtmcrypt/maskpass |cut -d":" -f 2`
echo $maskpass > maskpasstry3a.txt
$GTM << EOF > gtmtry3a.txt
$newpasswd
w \$ztrnlnm("gtm_passwd")
EOF

if (1 == `$grep -c $maskpass gtmtry3a.txt`) then
	echo PASS
else
	echo FAIL
endif

source $gtm_tst/com/set_ydb_env_var_random.csh ydb_obfuscation_key gtm_obfuscation_key "ob_key.txt"
echo "Try something simple but longer (with gtm_obfuscation key)"
set newpasswd="1234567890qwertyuiopasdfghjklzxcvbnm"
set maskpass=`echo $newpasswd|$gtm_exe/plugin/gtmcrypt/maskpass |cut -d":" -f 2`
echo $maskpass > maskpasstry3b.txt
$GTM << EOF > gtmtry3b.txt
$newpasswd
w \$ztrnlnm("gtm_passwd")
EOF

if (1 == `$grep -c $maskpass gtmtry3b.txt`) then
	echo PASS
else
	echo FAIL
endif

source $gtm_tst/com/unset_ydb_env_var.csh ydb_obfuscation_key gtm_obfuscation_key
echo "Try something else (with userid and inode)"
set newpasswd="fsdkfjsafjsd;ajfdsjfajl;sjad"
set maskpass=`echo $newpasswd|$gtm_exe/plugin/gtmcrypt/maskpass |cut -d":" -f 2`
echo $maskpass > maskpasstry4a.txt
$GTM << EOF > gtmtry4a.txt
$newpasswd
w \$ztrnlnm("gtm_passwd")
EOF

if (1 == `$grep -c $maskpass gtmtry4a.txt`) then
	echo PASS
else
	echo FAIL
endif

source $gtm_tst/com/set_ydb_env_var_random.csh ydb_obfuscation_key gtm_obfuscation_key "ob_key.txt"
echo "Try something else (with gtm_obfuscation key)"
set newpasswd="fsdkfjsafjsd;ajfdsjfajl;sjad"
set maskpass=`echo $newpasswd|$gtm_exe/plugin/gtmcrypt/maskpass |cut -d":" -f 2`
echo $maskpass > maskpasstry4b.txt
$GTM << EOF > gtmtry4b.txt
$newpasswd
w \$ztrnlnm("gtm_passwd")
EOF

if (1 == `$grep -c $maskpass gtmtry4b.txt`) then
	echo PASS
else
	echo FAIL
endif

source $gtm_tst/com/unset_ydb_env_var.csh ydb_obfuscation_key gtm_obfuscation_key
echo "Try something else with spaces (with userid and inode)"
set newpasswd="123456 7890-= asdfg hjkl;' zxcvb nm,./"
set maskpass=`echo $newpasswd|$gtm_exe/plugin/gtmcrypt/maskpass |cut -d":" -f 2`
echo $maskpass > maskpasstry5a.txt
$GTM << EOF > gtmtry5a.txt
$newpasswd
w \$ztrnlnm("gtm_passwd")
EOF

if (1 == `$grep -c $maskpass gtmtry5a.txt`) then
	echo PASS
else
	echo FAIL
endif

source $gtm_tst/com/set_ydb_env_var_random.csh ydb_obfuscation_key gtm_obfuscation_key "ob_key.txt"
echo "Try something else with spaces (with gtm_obfuscation key)"
set newpasswd="123456 7890-= asdfg hjkl;' zxcvb nm,./"
set maskpass=`echo $newpasswd|$gtm_exe/plugin/gtmcrypt/maskpass |cut -d":" -f 2`
echo $maskpass > maskpasstry5b.txt
$GTM << EOF > gtmtry5b.txt
$newpasswd
w \$ztrnlnm("gtm_passwd")
EOF

if (1 == `$grep -c $maskpass gtmtry5b.txt`) then
	echo PASS
else
	echo FAIL
endif

source $gtm_tst/com/unset_ydb_env_var.csh ydb_obfuscation_key gtm_obfuscation_key
echo "Try all blanks (with userid and inode)"
set newpasswd="                                                                         "
set maskpass=`echo "$newpasswd"|$gtm_exe/plugin/gtmcrypt/maskpass |cut -d":" -f 2`
echo $maskpass > maskpasstry6a.txt
$GTM << EOF > gtmtry6a.txt
$newpasswd
w \$ztrnlnm("gtm_passwd")
EOF

if (1 == `$grep -c $maskpass gtmtry6a.txt`) then
	echo PASS
else
	echo FAIL
endif

source $gtm_tst/com/set_ydb_env_var_random.csh ydb_obfuscation_key gtm_obfuscation_key "ob_key.txt"
echo "Try all blanks (with gtm_obfuscation key)"
set newpasswd="                                                                         "
set maskpass=`echo "$newpasswd"|$gtm_exe/plugin/gtmcrypt/maskpass |cut -d":" -f 2`
echo $maskpass > maskpasstry6b.txt
$GTM << EOF > gtmtry6b.txt
$newpasswd
w \$ztrnlnm("gtm_passwd")
EOF

if (1 == `$grep -c $maskpass gtmtry6b.txt`) then
	echo PASS
else
	echo FAIL
endif

source $gtm_tst/com/unset_ydb_env_var.csh ydb_obfuscation_key gtm_obfuscation_key
unset newpasswd

# Test that GT.M encryption works with longer passwords
#
# Since we don't meddle with the GNUPGHOME created for the all the tests in general, setup a new GNUPGHOME
# just for this test. Instead of creating one (which hurts when the entropy is too low), copy the existing
# one and set GNUPGHOME appropriately.
setenv GNUPGHOME_OLD $GNUPGHOME
setenv GNUPGHOME `pwd`/.gnupg
cp -r $GNUPGHOME_OLD $GNUPGHOME
cp $gtm_pubkey .
setenv gtm_pubkey `pwd`/pubkey.asc

echo "Test 1: Set a random password of length 50"
$gpg -a --gen-random 0 50 >&! random_50.out
setenv newpasswd `$grep -v "gpg:" random_50.out`
setenv oldpasswd $gtm_test_gpghome_passwd
unsetenv gtm_passwd
$gtm_tst/com/reset_gpg_agent.csh
expect -f $gtm_test/$tst_src/encryption/u_inref/change_pass.exp $newpasswd $oldpasswd $gtm_test_gpghome_uid $gpg >& expect1.out
setenv gtm_passwd `echo $newpasswd|$gtm_exe/plugin/gtmcrypt/maskpass |cut -d":" -f 2`
$gtm_tst/com/reset_gpg_agent.csh
rm *.dat
$MUPIP create
$gtm_tst/com/reset_gpg_agent.csh
$GTM << EOF
s ^XXX="ENCRPTED"
EOF

source $gtm_tst/com/set_ydb_env_var_random.csh ydb_obfuscation_key gtm_obfuscation_key `pwd`/"ob_key.txt"
setenv gtm_passwd `echo $newpasswd|$gtm_exe/plugin/gtmcrypt/maskpass |cut -d":" -f 2`
$gtm_tst/com/reset_gpg_agent.csh RESET
$GTM << EOF
s ^YYY="ENCRPTED"
EOF

echo "Test 2: Much longer password"
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_obfuscation_key gtm_obfuscation_key
setenv oldpasswd $newpasswd
# Using gpg --gen-random for that purpose is not ideal because it creates Base64-encrypted "armored" ASCII of length longer
# than requested; furthermore, it refuses to work with passwords exceeding 496 bytes (see <CRYPTKEYFETCHFAILED_long_password>
# for more details). So, we just use simple %RANDSTR to generate what we want. It must be noted, though, that the password
# length used to be up to 375, but newer GPGs refuse to work with that.
setenv pass_len 80

$gtm_dist/mumps -run %XCMD 'do ^%RANDSTR('$pass_len')' > random_80.out
setenv newpasswd `cat random_80.out`
unsetenv gtm_passwd
$gtm_tst/com/reset_gpg_agent.csh
expect -f $gtm_test/$tst_src/encryption/u_inref/change_pass.exp $newpasswd $oldpasswd $gtm_test_gpghome_uid $gpg >& expect2.out
setenv gtm_passwd `echo $newpasswd|$gtm_exe/plugin/gtmcrypt/maskpass |cut -d":" -f 2`
$gtm_tst/com/backup_dbjnl.csh "bak2" "*.dat" mv
$gtm_tst/com/reset_gpg_agent.csh
$MUPIP create
$gtm_tst/com/reset_gpg_agent.csh
$GTM << EOF
s ^XXX="ENCRPTED"
EOF

source $gtm_tst/com/set_ydb_env_var_random.csh ydb_obfuscation_key gtm_obfuscation_key `pwd`/"ob_key.txt"
setenv gtm_passwd `echo $newpasswd|$gtm_exe/plugin/gtmcrypt/maskpass |cut -d":" -f 2`
$gtm_tst/com/reset_gpg_agent.csh
$GTM << EOF
s ^YYY="ENCRPTED"
EOF

source $gtm_tst/com/set_ydb_env_var_random.csh ydb_obfuscation_key gtm_obfuscation_key
echo "Test 3: Revert back the changes"
setenv oldpasswd $newpasswd
setenv newpasswd $USER
unsetenv gtm_passwd
$gtm_tst/com/reset_gpg_agent.csh
expect -f $gtm_test/$tst_src/encryption/u_inref/change_pass.exp $newpasswd $oldpasswd $gtm_test_gpghome_uid $gpg >& expect3.out
setenv gtm_passwd `echo $newpasswd|$gtm_exe/plugin/gtmcrypt/maskpass |cut -d":" -f 2`
$gtm_tst/com/backup_dbjnl.csh "bak3" "*.dat" mv
$gtm_tst/com/reset_gpg_agent.csh
$MUPIP create
$gtm_tst/com/reset_gpg_agent.csh
$GTM << EOF
s ^XXX="ENCRPTED"
EOF
$gtm_tst/com/reset_gpg_agent.csh
$gtm_tst/com/dbcheck.csh
$gtm_tst/com/reset_gpg_agent.csh
