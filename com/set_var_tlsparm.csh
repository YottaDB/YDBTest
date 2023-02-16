#################################################################
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# This is a helper script that sets the variable "tlsparm" and "tls_reneg_parm" as appropriate for use by caller scripts.
#
# $1 - target instance name (for example "$gtm_test_cur_pri_name" or "$gtm_test_cur_sec_name").

set instname = $1

set tlsparm = ""
set tls_reneg_parm = ""
set ver = $gtm_exe:h:t
if (("TRUE" == $gtm_test_tls) && (`expr $ver ">" "V60003"`)) then
	if (`eval echo '$?gtmtls_passwd_'${instname}`) then
		if ("$HOST:r:r:r:r" != "$tst_org_host:r:r:r:r" || "$remote_ver" != "$tst_ver") then
			# Reset the password, since
			# (a) The test could be a multi-host test and we need to set the password on the remote machine based
			#     on the remote side's password parameters (inode of the mumps executable).
			# (b) The source and receiver are run with different versions both of which support TLS (like
			#     v61000 vs v990).
			set passwd = `echo ydbrocks | $gtm_exe/plugin/gtmcrypt/maskpass | cut -f3 -d ' '`
			setenv gtmtls_passwd_${instname} $passwd
		endif
		set passwd = `eval echo '$gtmtls_passwd_'${instname}`
		echo "Using SSL/TLS obfuscated password: $passwd"
		set tlsparm = "-tlsid=$instname"
		if ($?gtm_test_plaintext_fallback) then
			set tlsparm = "$tlsparm -plaintext"
		endif
		if ($?gtm_test_tls_renegotiate) then
			set tls_reneg_parm = "-renegotiate_interval=$gtm_test_tls_renegotiate"
		endif
	endif
endif

