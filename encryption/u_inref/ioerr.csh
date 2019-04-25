#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2014-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018-2019 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

#################################################################
# Ensure that GT.M encrypts error messages, as appropriate,
# depending on where the standard output and error of a process
# are currently redirected to.
#################################################################

# Prepare the test environment: symmetric key, configuration file, key and IV, encryption algorithm, and so on.
setenv gtm_encrypt_notty "--no-permission-warning"
$gtm_tst_ver_gtmcrypt_dir/gen_sym_key.sh 0 mumps.key
unsetenv gtm_encrypt_notty

setenv gtmcrypt_config `pwd`/gtmcrypt.cfg
cat >&! $gtmcrypt_config <<EOF
files : {
        key : "mumps.key";
};
EOF

set string = "Hello, world!"

setenv iv `$gtm_dist/mumps -run %XCMD 'write $$^%RANDSTR(16,,"AN")'`
echo $iv > iv.txt
setenv password "ydbrocks"
setenv gtm_passwd `echo $password | $gtm_dist/plugin/gtmcrypt/maskpass | cut -f3 -d' '`

cat > gtmPrompt.outx <<EOF

YDB>
EOF

cat > gtmErrorPrompt.outx <<EOF
%YDB-E-DIVZERO, Attempt to divide by zero
		At M source location principalError+4^ioerr

YDB>
EOF

cat > gtmStringPrompt.outx <<EOF
Hello, world!

YDB>
EOF

cat > gtmStringPromptCompact.outx <<EOF
Hello, world!
YDB>
EOF

cat > gtmStringErrorPrompt.outx <<EOF
Hello, world!
%YDB-E-DIVZERO, Attempt to divide by zero
		At M source location principalWriteError+8^ioerr

YDB>
EOF

source $gtm_tst/$tst/u_inref/set_encryption_algorithm.csh

#########################################################################################################################################
# Writes to a file, with newline or not, followed by the termination of the process.
$gtm_exe/mumps -run fileFlush^ioerr filenoflush.out key $iv 0 $string
set result = `openssl enc -$algorithm -nosalt -d -K $keyHex -iv $ivHex -in filenoflush.out`
if ("$result" != "$string") then
	echo "TEST-E-FAIL, Decrypted filenoflush.out with OpenSSL as '$result' instead of '$string'."
endif

$gtm_exe/mumps -run fileFlush^ioerr fileflush.out key $iv 1 $string
set result = `openssl enc -$algorithm -nosalt -d -K $keyHex -iv $ivHex -in fileflush.out`
if ("$result" != "$string") then
	echo "TEST-E-FAIL, Decrypted fileflush.out with OpenSSL as '$result' instead of '$string'."
endif
#########################################################################################################################################
# Generation of an error with no prior writes to $principal, with various output redirections.
echo "# We expect the DIVZERO error to show up below:"
$gtm_exe/mumps -run principalError^ioerr key $iv > principal1-1-out.out
openssl enc -$algorithm -nosalt -d -K $keyHex -iv $ivHex -in principal1-1-out.out -out principal1-1-out.openssl
diff gtmPrompt.outx principal1-1-out.openssl > principal1-1-out.diff
if ($status) then
	echo "TEST-E-FAIL, Unexpected result of decrypting principal1-1-out.out. See principal1-1-out.diff for details."
endif

($gtm_exe/mumps -run principalError^ioerr key $iv > principal1-2-out.out) >&! principal1-2-err.out
$gtm_tst/com/check_error_exist.csh principal1-2-err.out DIVZERO
if (! $status) mv principal1-2-err.outx principal1-2.outx
openssl enc -$algorithm -nosalt -d -K $keyHex -iv $ivHex -in principal1-2-out.out -out principal1-2-out.openssl
diff gtmPrompt.outx principal1-2-out.openssl > principal1-2-out.diff
if ($status) then
	echo "TEST-E-FAIL, Unexpected result of decrypting principal1-2-out.out. See principal1-2-out.diff for details."
endif

$gtm_exe/mumps -run principalError^ioerr key $iv >&! principal1-3-out+err.out
openssl enc -$algorithm -nosalt -d -K $keyHex -iv $ivHex -in principal1-3-out+err.out -out principal1-3-out+err.openssl
diff gtmErrorPrompt.outx principal1-3-out+err.openssl > principal1-3-out+err.diff
if ($status) then
	echo "TEST-E-FAIL, Unexpected result of decrypting principal1-3-out+err.out. See principal1-3-out+err.diff for details."
endif
#########################################################################################################################################
# Generation of an error with a prior write (no newline) to $principal, with various output redirections.
echo "# We expect the DIVZERO error to show up below:"
$gtm_exe/mumps -run principalWriteError^ioerr key $iv 0 $string > principal2-1-out.out
openssl enc -$algorithm -nosalt -d -K $keyHex -iv $ivHex -in principal2-1-out.out -out principal2-1-out.openssl
diff gtmStringPromptCompact.outx principal2-1-out.openssl > principal2-1-out.diff
if ($status) then
	echo "TEST-E-FAIL, Unexpected result of decrypting principal2-1-out.out. See principal2-1-out.diff for details."
endif

($gtm_exe/mumps -run principalWriteError^ioerr key $iv 0 $string > principal2-2-out.out) >&! principal2-2-err.out
$gtm_tst/com/check_error_exist.csh principal2-2-err.out DIVZERO
if (! $status) mv principal2-2-err.outx principal2-2.outx
openssl enc -$algorithm -nosalt -d -K $keyHex -iv $ivHex -in principal2-2-out.out -out principal2-2-out.openssl
diff gtmStringPromptCompact.outx principal2-2-out.openssl > principal2-2-out.diff
if ($status) then
	echo "TEST-E-FAIL, Unexpected result of decrypting principal2-2-out.out. See principal2-2-out.diff for details."
endif

$gtm_exe/mumps -run principalWriteError^ioerr key $iv 0 $string >&! principal2-3-out+err.out
openssl enc -$algorithm -nosalt -d -K $keyHex -iv $ivHex -in principal2-3-out+err.out -out principal2-3-out+err.openssl
diff gtmStringErrorPrompt.outx principal2-3-out+err.openssl > principal2-3-out+err.diff
if ($status) then
	echo "TEST-E-FAIL, Unexpected result of decrypting principal2-3-out+err.out. See principal2-3-out+err.diff for details."
endif
#########################################################################################################################################
# Generation of an error with a prior write (with a newline) to $principal, with various output redirections.
echo "# We expect the DIVZERO error to show up below:"
$gtm_exe/mumps -run principalWriteError^ioerr key $iv 1 $string > principal3-1-out.out
openssl enc -$algorithm -nosalt -d -K $keyHex -iv $ivHex -in principal3-1-out.out -out principal3-1-out.openssl
diff gtmStringPrompt.outx principal3-1-out.openssl > principal3-1-out.diff
if ($status) then
	echo "TEST-E-FAIL, Unexpected result of decrypting principal3-1-out.out. See principal3-1-out.diff for details."
endif

($gtm_exe/mumps -run principalWriteError^ioerr key $iv 1 $string > principal3-2-out.out) >&! principal3-2-err.out
$gtm_tst/com/check_error_exist.csh principal3-2-err.out DIVZERO
if (! $status) mv principal3-2-err.outx principal3-2.outx
openssl enc -$algorithm -nosalt -d -K $keyHex -iv $ivHex -in principal3-2-out.out -out principal3-2-out.openssl
diff gtmStringPrompt.outx principal3-2-out.openssl > principal3-2-out.diff
if ($status) then
	echo "TEST-E-FAIL, Unexpected result of decrypting principal3-2-out.out. See principal3-2-out.diff for details."
endif

$gtm_exe/mumps -run principalWriteError^ioerr key $iv 1 $string >&! principal3-3-out+err.out
openssl enc -$algorithm -nosalt -d -K $keyHex -iv $ivHex -in principal3-3-out+err.out -out principal3-3-out+err.openssl
diff gtmStringErrorPrompt.outx principal3-3-out+err.openssl > principal3-3-out+err.diff
if ($status) then
	echo "TEST-E-FAIL, Unexpected result of decrypting principal3-3-out+err.out. See principal3-3-out+err.diff for details."
endif
#########################################################################################################################################
# Generation of an error with no prior writes to a file, with various output redirections.
$gtm_exe/mumps -run fileWriteError^ioerr file1-1-out.out key $iv 0 $string >&! file1-1-err.out
$gtm_tst/com/check_error_exist.csh file1-1-err.out DIVZERO NOTPRINCIO
openssl enc -$algorithm -nosalt -d -K $keyHex -iv $ivHex -in file1-1-out.out -out file1-1-out.openssl
@ size = `wc -c file1-1-out.openssl | cut -c -1`
if ($size != 0) then
	echo "TEST-E-FAIL, Unexpected result of decrypting file1-1-out.out. Expected nothing but got something (see file1-1-out.openssl)."
endif

$gtm_exe/mumps -run fileWriteError^ioerr file1-2-out+err.out key $iv 0 $string >>&! file1-2-out+err.out
$gtm_tst/com/check_error_exist.csh file1-2-out+err.out DIVZERO NOTPRINCIO
#########################################################################################################################################
# Generation of an error with a prior write to a file, with various output redirections.
$gtm_exe/mumps -run fileWriteError^ioerr file2-1-out.out key $iv 1 $string >&! file2-1-err.out
$gtm_tst/com/check_error_exist.csh file2-1-err.out DIVZERO NOTPRINCIO
set result = `openssl enc -$algorithm -nosalt -d -K $keyHex -iv $ivHex -in file2-1-out.out | tee file2-1-out.openssl`
if ("$result" != "$string") then
	echo "TEST-E-FAIL, Decrypted file2-1-out.out with OpenSSL as '$result' instead of '$string'."
endif

$gtm_exe/mumps -run fileWriteError^ioerr file2-2-out+err.out key $iv 1 $string >>&! file2-2-out+err.out
openssl enc -$algorithm -nosalt -d -K $keyHex -iv $ivHex -in file2-2-out+err.out -out file2-2-out+err.openssl
$gtm_tst/com/check_error_exist.csh file2-2-out+err.out DIVZERO NOTPRINCIO
