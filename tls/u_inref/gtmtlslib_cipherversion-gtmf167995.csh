#!/usr/local/bin/tcsh
#################################################################
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
#
cat << CAT_EOF | sed 's/^/# /;'
********************************************************************************************
GTM-F167995 - Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.1-002_Release_Notes.html#GTM-F167995)

	The GT.M TLS plugin library exposes an external call interface providing ciphersuite and version information. The four new functions are:

		getversion:            xc_long_t gtm_tls_get_version(O:xc_char_t*[2048])
		gettlslibsslversion:   xc_long_t gtm_tls_get_TLS_version(O:xc_char_t*[2048],I:xc_char_t*,O:xc_char_t*[2048])
		getdefaultciphers:     xc_long_t gtm_tls_get_defaultciphers(O:xc_char_t*[4096],I:xc_char_t*,O:xc_char_t*[2048])
		getciphers:            xc_long_t gtm_tls_get_ciphers(O:xc_char_t*[4096],I:xc_char_t*,I:xc_char_t*,I:xc_char_t*,I:xc_char_t*,O:xc_char_t*[2048])

	The following entry points provide the supported cipher suite information. Except where noted, the \$gtmcrypt_conf configuration file and gtmtls_passwd_<TLS_ID> are not required.

	getdefaultciphers

		1st parameter contains the default list of ciphers based on the 2nd parameter

		2nd parameter directs the interface to report the OpenSSL default cipher suite for TLSv1.2 ("tls1_2") or TLSv1.3 ("tls1_3")

		3rd parameter is an error string (allocated by the external call interface).

		The function returns negative as failure and positive for the number of colon delimited pieces in the return string.

	getciphers

		1st parameter contains the list of available ciphers based on the 2nd parameter

		2nd parameter directs the interface to report the OpenSSL default cipher suite for TLSv1.2 ("tls1_2") or TLSv1.3 ("tls1_3")

		3rd parameter directs the interface to report the cipher suite using the cipher suite defaults for "SOCKET" Device or "REPLICATION" server

		(optional) 4th parameter directs the interface to use the name TLS ID from the \$gtmcrypt_conf configuration file. Using the null string makes \$gtmcrypt_config optional. Using a TLS ID with certificates requires \$gtmtls_passwd_

		(optional) 5th parameter directs the interface to use the supplied cipher suite string when determining supported ciphers

		6th parameter is an error string (allocated by the external call interface)

		The function returns negative as failure and positive for the number of colon delimited pieces in the return string

	The following entry points provide version information.

	getversion

		1st parameter contains the GT.M TLS plugin version as a string.

		The function returns the GT.M TLS plugin version as a number.

	gettlslibversion

		1st parameter contains the OpenSSL string

		2nd parameter directs the function to report the "run-time" or "compile-time" OpenSSL version

		3rd parameter is an error string (allocated by the external call interface)

		The function returns the OpenSSL version number or negative on failure

	(GTM-F167995)

CAT_EOF
echo

# Test that both encryption and TLS information can reside in the same configuration file.

if ("$test_encryption" == "NON_ENCRYPT") then
	echo "This subtest requires encryption. Exiting.."
	exit 1
endif

setenv GTMXC_libgtmtls $gtm_dist/plugin/gtmtlsfuncs.tab
cp $gtm_tst/com/tls/gtmtls.cfg .
sed "s|##GTM_TST##|$gtm_tst|" gtmtls.cfg >&! gtmcrypt.cfg

$gtm_dist/mumps -r gtmf167995
