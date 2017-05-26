#################################################################
#								#
#	Copyright 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# This script overrides the BEFORE_IMAGE or NOBEFORE_IMAGE journal file setting that the test was started with
# (specified as part of gtmtest.csh). This should be sourced in those tests/subtests that require BEFORE_IMAGE
# journaling for them to run properly. Such tests should have the following line at the beginning of instream.csh
# or <subtest>.csh driver script.
#
# source $gtm_tst/com/gtm_test_setbeforeimage.csh
#
# The preference is to have this in specific subtests. But if all subtests of a given test need to have this, it
# might be easy maintenance to place this in the top of the test's instream.csh
#
# Those tests that will run fine with either setting (NOBEFORE or BEFORE) should NOT source this script as it will
# otherwise cause them to run only with BEFORE_IMAGE which reduces the test/code coverage.
#
setenv tst_jnl_str "`echo $tst_jnl_str | sed 's/nobefore/before/'`"
setenv gtm_test_jnl_nobefore 0
#
# The randomly chosen value is changed, so lets log the modified tst_jnl_str in settings.csh
echo "# tst_jnl_str is modified by gtm_test_setbeforeimage.csh"	>> settings.csh
echo "setenv tst_jnl_str $tst_jnl_str"				>> settings.csh
echo "setenv gtm_test_jnl_nobefore 0"				>> settings.csh
# Since before image journaling cannot be set with MM access method, unconditionally set the access method to BG
source $gtm_tst/com/gtm_test_setbgaccess.csh
