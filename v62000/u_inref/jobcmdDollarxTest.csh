#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Testing FLUSH by a middle process when starting a job cmd for various I/O devices.
# The middle process and the parent process should not add a newline at the end.

$gtm_tst/com/dbcreate.csh mumps 1

# In case of encryption, include key for devices.
if ("ENCRYPT" == "$test_encryption") then
	setenv gtmcrypt_key	key
	setenv gtmcrypt_iv	`$gtm_dist/mumps -run %XCMD 'write $$^%RANDSTR(16,,"AN")'`
else
	setenv gtmcrypt_config	/dev/null
	setenv gtmcrypt_key	""
	setenv gtmcrypt_iv	""
endif

cat >> $gtmcrypt_config <<EOF
files : {
        key : "$PWD/mumps_dat_key";
};
EOF

# Array declaration for various devices
set deviceArr =	("SD" "PRINCIPAL" "PIPE" "FIFO")
@ deviceCnt = $#deviceArr

set string = "The quick brown fox jumped over the lazy little dog."

@ i = 1
while ($i <= $deviceCnt)
	set device = $deviceArr[$i]

	if ($device == "PRINCIPAL") then
		$gtm_exe/mumps -run parent^jobcmdDollarxTest . $device "$string" > ${device}.encr
	else
		$gtm_exe/mumps -run parent^jobcmdDollarxTest ${device}.encr $device "$string" > /dev/null
	endif

	@ decrypt = 1

	# For FIFO the child decrypts the string so disabling invocation of decrypt label
	if ($device == "FIFO") then
		cp jobcmdDollarxTest.mjo ${device}.encr
		@ decrypt = 0
	endif

	# Testing Decryption
	$gtm_exe/mumps -run decrypt^jobcmdDollarxTest ${device}.encr $decrypt
	mv jobcmdDollarxTest.mjo ${device}.mjo
	@ i = $i + 1
end

$gtm_tst/com/dbcheck.csh
