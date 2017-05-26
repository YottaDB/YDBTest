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

#
# GTM-8111
# Verify that -EMBED_SOURCE qualifier allows $TEXT and ZPRINT to find source, even after we overwrite it.
#

unsetenv gtmcompile
\cp $gtm_tst/$tst/inref/src2.m ./

#
echo "# Verify NOEMBED_SOURCE (default) behaves as usual"
#
\cp $gtm_tst/$tst/inref/src.m ./
$gtm_exe/mumps src.m
$gtm_exe/mumps -run src
$gtm_exe/mumps -run text^gtm8111

\cp $gtm_tst/$tst/inref/src.m ./
$gtm_exe/mumps -noembed_source src.m
$gtm_exe/mumps -run src
# enter direct mode so information message (TXTSRCMAT) is displayed
$GTM << EOF
	do lnknwt^gtm8111
	write "### zprint begin",! zprint lab^src write "### zprint done",!
EOF

echo ""
echo ""
echo ""

#
echo "# Repeat with EMBED_SOURCE"
#
\cp $gtm_tst/$tst/inref/src.m ./
$gtm_exe/mumps -embed_source src.m
$gtm_exe/mumps -run src
$gtm_exe/mumps -run text^gtm8111

\cp $gtm_tst/$tst/inref/src.m ./
$gtm_exe/mumps -embed_source src.m
$gtm_exe/mumps -run src
$GTM << EOF
	do lnknwt^gtm8111
	write "### zprint begin",! zprint lab^src write "### zprint done",!
EOF
