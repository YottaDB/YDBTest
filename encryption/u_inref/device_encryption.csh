#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2014-2015 Fidelity National Information		#
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

#################################################################
# Driver script for the encryption/device_encryption test. It
# executes a wide variety of scenarios having to do with
# evaluation of encryption deviceparameters, operability of basic
# encryption / decryption operations, validity of the encryption
# state machine, and so on.
#################################################################

if ($?gtm_chset) then
	if ("UTF-8" == "$gtm_chset") then
		set is_utf8 = 1
	else
		set is_utf8 = 0
	endif
else
	set is_utf8 = 0
endif

setenv gtm_encrypt_notty "--no-permission-warning"
$gtm_tst_ver_gtmcrypt_dir/gen_sym_key.sh 0 mumps.key
$gtm_tst_ver_gtmcrypt_dir/gen_sym_key.sh 0 mumps1.key
$gtm_tst_ver_gtmcrypt_dir/gen_sym_key.sh 0 mumps2.key
unsetenv gtm_encrypt_notty

####################################################################################################################
# Test the following:
#  a. Deviceparameters are evaluated left-to-right, the last of the repeating / applicable ones taking precedence.
#  b. KEY sets both IKEY and OKEY.
#  c. IKEY specified after KEY does not affect OKEY.
#  d. OKEY specified after KEY does not affect IKEY.
#  e. Specifying an empty IV.
#  f. Specifying an IV shorter than 16 bytes.
#  g. Specifying an IV longer than 16 bytes.
#  h. Specifying an IV consisting of non-printable (control) characters.
####################################################################################################################
echo "Testing deviceparameter evaluation."

setenv gtmcrypt_config `pwd`/gtmcrypt.cfg
cat >&! $gtmcrypt_config <<EOF
files : {
        input : "mumps.key";
        output : "mumps1.key";
        both : "mumps2.key";
};
EOF

$gtm_exe/mumps -run devparameval

echo

####################################################################################################################
# Test correct behavior of encryption usage in conjunction with legitimate and illegitimate deviceparameters and
# various devices.
####################################################################################################################
setenv password "gtmrocks"
setenv string1 "The quick brown fox jumped over the lazy little dog."
setenv string2 "dog little lazy the over jumped fox brown quick the."
setenv string3 "${string1}${string2}"

#																			  Expected output for
#		Operation	Description						Encryption label	Decryption label	SD		PRINCIPAL	PIPE		FIFO
set operArr = (	"SIMPLE"	"Simple encryption/decryption"				"simpleEncrypt"		"simpleDecrypt"		"$string1"	"$string1"	"$string1"	"$string1"	\
		"NODESTROY"	"Encryption/decryption with NODESTROY"			"encryptNoDestroy"	"simpleDecrypt"		"$string3"	"$string3"	"$string2"	"$string2"	\
		"SEEK"		"Encryption/decryption with SEEK" 			"simpleSeek"		"simpleDecrypt"		"N/A"		"YDB>"		"YDB>"		"N/A"		\
		"SEEKNODESTROY"	"Encryption/decryption with SEEK and NODESTROY" 	"seekNoDestroy"		"simpleDecrypt"		"$string1"	"$string1 YDB>"	"YDB>"		"N/A"		\
		"APPEND"	"Encryption/decryption with simple APPEND" 		"simpleAppend"		"simpleDecrypt"		"$string1"	"$string3"	"$string2"	"$string2"	\
		"APNDNEWVER"	"Encryption/decryption with APPEND on NEWVERSION" 	"appendNewversion"	"simpleDecrypt"		"$string2"	"$string3"	"$string2"	"$string2"	\
		"APNDEMPTY"	"Encryption/decryption with APPEND on EMPTY device" 	"appendEmptyDevice"	"simpleDecrypt"		"$string1"	"$string1"	"$string1"	"$string1"	\
		"APNDNODESTROY"	"Encryption/decryption with APPEND and NODESTROY" 	"appendNoDestroy"	"simpleDecrypt"		"$string3"	"$string3"	"$string2"	"$string2"	\
		"REWINDTRUNC"	"Encryption/decryption with REWIND then TRUNCATE" 	"rewindTruncate"	"simpleDecrypt"		"$string2"	"$string2"	"$string3"	"$string3"	\
		"TRUNCREWIND"	"Encryption/decryption with TRUNCATE then REWIND" 	"truncateRewind"	"simpleDecrypt"		"$string3"	"$string1"	"$string3"	"$string3"	\
		"INCREMENTAL"	"Encryption/decryption with incremental reads/writes"	"incrementalEncrypt"	"incrementalDecrypt"	"$string1"	"$string1"	"$string1"	"$string1"	)
@ operCnt = $#operArr

set deviceArr =	("SD" "PRINCIPAL" "PIPE" "FIFO")
@ deviceCnt = $#deviceArr

# In the following loop we ensure that neither of the three strings we operate on in the subsequent tests contains a newline
# character (0xa) when encrypted with the chosen key and IV.
set xcmd = 'for  read line quit:$zeof  for i=1:1:$length(line," ") set p=$piece(line," ",i) if (p="a")!(p="0a") zhalt 1'
while (1)
	setenv iv `$gtm_exe/mumps -run %XCMD 'write $$^%RANDSTR(16,,"AN")'`
	echo $iv > iv.txt

	source $gtm_tst/$tst/u_inref/set_encryption_algorithm.csh

	echo $string1 | openssl enc -$algorithm -nosalt -e -K $keyHex -iv $ivHex | od -tx1 | $gtm_exe/mumps -run %XCMD "$xcmd"
	if ($status) continue
	echo $string2 | openssl enc -$algorithm -nosalt -e -K $keyHex -iv $ivHex | od -tx1 | $gtm_exe/mumps -run %XCMD "$xcmd"
	if ($status) continue
	echo $string3 | openssl enc -$algorithm -nosalt -e -K $keyHex -iv $ivHex | od -tx1 | $gtm_exe/mumps -run %XCMD "$xcmd"
	if ($status) continue
	break
end

$gtm_tst/com/dbcreate.csh mumps 1
echo
setenv GTMXC_gpgagent $gtm_exe/plugin/gpgagent.tab
set key = "key"
cat >>&! $gtmcrypt_config <<EOF
files : {
        $key : "mumps.key";
};
EOF

# Since we are passing ciphertext for storage in files, we cannot support UTF.
if ($is_utf8) then
	$switch_chset M >&! disable_utf8.txt
endif

@ i = 1
while ($i < $operCnt)
	set operation = $operArr[$i]
	@ i = $i + 1
	set operationDesc = "$operArr[$i]"
	@ i = $i + 1
	set encrLabel = $operArr[$i]
	@ i = $i + 1
	set decrLabel = $operArr[$i]

	echo "############# ${operationDesc} #############"

	@ j = 1
	while ($j <= $deviceCnt)
		set device = $deviceArr[$j]
		echo "# $j. ${operation}:${device}"

		set encrFile = ${operation}-${device}.encr
		set decrFile = ${operation}-${device}.decr

		# Redirect output of encryption to a file for all devices except SD.
		if ($device == "SD") then
			set encrOutFile = /dev/null
		else
			set encrOutFile = $encrFile
		endif

		# Initialize the expected output from various devices as per the operation performed.
		@ expIndex = $i + $j
		set expected = "$operArr[$expIndex]"

		# Test encryption stage.
		$gtm_exe/mumps -run $encrLabel^deviceopers $encrFile $key $iv $device cat > $encrOutFile
		if ($device == "FIFO") then
			mv $encrFile $encrFile.bak
			mv encrypt.mjo $encrFile >&! /dev/null
		endif

		# If encryption succeeds, proceed to decryption.
		if (-e $encrFile) then
			# Verify encryted result with openssl for all devices.
			set result = `openssl enc -$algorithm -nosalt -d -K $keyHex -iv $ivHex -in $encrFile`
			if ("$result" != "$expected") then
				echo "TEST-E-FAIL, Test $operation (encryption) on $device failed; expected '$expected' but found '$result'"
			endif

			# Test decryption stage.
			cat $encrFile | $gtm_exe/mumps -run $decrLabel^deviceopers $encrFile $key $iv $device "cat $encrFile" > $decrFile
			if ($device == "FIFO") then
				mv $decrFile $decrFile.bak
				mv decrypt.mjo $decrFile
			endif

			# Verify decrypted result with openssl for all devices.
			set result = `cat $decrFile`
			if ("$result" != "$expected") then
				echo "TEST-E-FAIL, Test $operation (decryption) on $device failed; expected '$expected' but found '$result'"
			endif
			if (("TRUNCREWIND" == $operation) && ("PRINCIPAL" == $device)) cat Truncerror.outx
		endif
		@ j = $j + 1
	end
	@ i = $i + 5
end

echo
$gtm_tst/com/dbcheck.csh
echo

if ($is_utf8) then
	$switch_chset UTF-8 >&! enable_utf8.txt
endif

###################################################################
echo "Testing simple FOLLOW."
set file = t6a.txt
touch $file
($gtm_exe/mumps -run fill^deviceopers $file $key $iv >&! fill-a.out &) >&! /dev/null
$gtm_exe/mumps -run follow^deviceopers $file $key $iv
echo

echo "Testing FOLLOW with bursts of WRITEs."
set file = t6b.txt
touch $file
($gtm_exe/mumps -run hangFill^deviceopers $file $key $iv >&! fill-b.out &) >&! /dev/null
$gtm_exe/mumps -run follow^deviceopers $file $key $iv
echo

echo "Testing FOLLOW with random-length READs and WRITEs."
set file = t6c.txt
touch $file
set str = "the quick brown fox jumped over the lazy dog"
($gtm_exe/mumps -run randomFill^deviceopers $file $key $iv "$str" >&! fill-c.out &) >&! /dev/null
$gtm_exe/mumps -run randomFollow^deviceopers $file $key $iv "$str" > output.txt
set out = `cat output.txt`
if ("$out" !~ "$str") then
	echo "TEST-E-FAIL, Assembled output does not match the expected string. See output.txt for details."
endif
echo
###################################################################
echo "Testing heredocs and stream redirection."

set file = t7.txt

$gtm_exe/mumps -run principalDecryptEncrypt^deviceopers $key $iv 1 0 > t7.mout1 <<EOF
The quick brown fox jumped over the lazy little dog.
dog little lazy the over jumped fox brown quick the.
EOF

cat << EOF >&! $file
The quick brown fox jumped over the lazy little dog.
dog little lazy the over jumped fox brown quick the.
EOF

openssl enc -$algorithm -nosalt -e -K $keyHex -iv $ivHex -in $file -out t7.openssl1
diff t7.mout1 t7.openssl1 >&! t7.diff1
if ($status) then
	echo "TEST-E-FAIL, Test case 7: Encrypted data is not consistent with OpenSSL (t7.mout1 vs. t7.openssl1)."
endif

$gtm_exe/mumps -run principalDecryptEncrypt^deviceopers $key $iv 0 1 < t7.openssl1 > t7.mout2

openssl enc -$algorithm -nosalt -d -K $keyHex -iv $ivHex -in t7.mout1 -out t7.openssl2
diff t7.mout2 t7.openssl2 >&! t7.diff2
if ($status) then
	echo "TEST-E-FAIL, Test case 7: Decrypted data is not consistent with OpenSSL (t7.mout2 vs. t7.openssl2)."
endif

# Since $principal cannot be OPENed with chset="M" programmatically, we temporarily disable UTF-8.
if ($is_utf8) then
	$switch_chset M >&! disable_utf8.txt
endif

cat t7.openssl1 | $gtm_exe/mumps -run principalDecryptEncrypt^deviceopers $key $iv 1 1 > t7.mout3
diff t7.mout3 t7.openssl1 >&! t7.diff3
if ($status) then
	echo "TEST-E-FAIL, Test case 7: Reencrypted data is not consistent with original (OpenSSL) data (t7.mout3 vs. t7.openssl1)."
endif

if ($is_utf8) then
	$switch_chset UTF-8 >&! enable_utf8.txt
endif
echo
###################################################################
echo "Testing pipe encryption / decryption for stdout / stderr."

# Build an executable that reads input and writes it to both output and error channels.
$gt_cc_compiler -o pipeErrTest -I$gtm_tst/$tst/inref -I$gtm_dist $gtm_tst/$tst/inref/pipeErrTest.c

# Pass plaintext to OpenSSL, have it encrypted, and decrypt the ciphertext that comes back.
set cmd = "openssl enc -$algorithm -nosalt -e -K $keyHex -iv $ivHex | ./pipeErrTest"
$gtm_exe/mumps -run pipeEncryptDecryptErrTest^deviceopers $key $iv 0 1 "$cmd"

# Feed ciphertext to OpenSSL, have it decrypted, and read the plain text that comes back.
set cmd = "openssl enc -$algorithm -nosalt -d -K $keyHex -iv $ivHex | ./pipeErrTest"
$gtm_exe/mumps -run pipeEncryptDecryptErrTest^deviceopers $key $iv 1 0 "$cmd"

# Encrypt plain text and decrypt what comes back.
set cmd = "./pipeErrTest"
$gtm_exe/mumps -run pipeEncryptDecryptErrTest^deviceopers $key $iv 1 1 "$cmd"
echo

####################################################################################################################
# Induce various encryption / decryption state changes and validate GT.M's responses.
####################################################################################################################
echo "Testing encryption state switches."

set key1 = one
set key2 = two
set iv1 = `$gtm_exe/mumps -run %XCMD 'write $$^%RANDSTR(16,,"AN")'`
set iv2 = `$gtm_exe/mumps -run %XCMD 'write $$^%RANDSTR(16,,"AN")'`
set keyFile1 = mumps1.key
set keyFile2 = mumps2.key

cat > gtmcrypt.cfg <<EOF
files : {
        $key1 : "$keyFile1";
        $key2 : "$keyFile2";
};
EOF

echo "hello world" > input.txt

$gtm_exe/mumps -run encryptionstate encryptstate1.txt $key1 $iv1 $key2 $iv2
$gtm_exe/mumps -run iormuse input.txt output.txt $key1 $iv1 $key2 $iv2

echo
