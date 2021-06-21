#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2021 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
echo '### Test GTM-1044 changes to $ZATRANSFORM ###'
echo "### These include the additions of 2 and -2 as ###"
echo "### valid values for the optional 3rd argument ###"
echo "### and the gtm_ac_xutil() function for use ###"
echo "### with external collations ###"
$echoline
echo "# Make sure the character set is M because the M code is supposed to throw a YDB-E-ZATRANSCOL in UTF-8 mode"
$switch_chset "M"
$echoline
echo "# Create shared library for all alternate collations"
source $gtm_tst/com/cre_coll_sl_all.csh
$echoline
echo "# Run gtm1044 test"
$ydb_dist/yottadb -run gtm1044
echo "# Switch the character set to UTF-8 and run the gtm1044 test again expecting a %YDB-E-ZATRANSCOL."
$switch_chset "UTF-8"
$ydb_dist/yottadb -run gtm1044
