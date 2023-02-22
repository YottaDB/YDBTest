#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
# Portions Copyright (c) Fidelity National			#
# Information Services, Inc. and/or its subsidiaries.		#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

setenv test_reorg "NON_REORG"
source $gtm_tst/$tst/u_inref/cre_coll_sl_com.csh

# Create a db and fill in some local variables to test local collation
source $gtm_tst/com/dbcreate.csh mumps 2 125 500 -col=1
$GTM << \aaa
d ^gblcol
\aaa
#

set teststatus=1

echo "Compare ZWR output"
diff col1.out $gtm_tst/$tst/outref/polgblcol.txt > /dev/null
if $status then
        echo "Local collation test FAILED even before MERGE "
	goto stoptest
else
        echo "Local collation test PASSED"
endif
echo "Compare reverse ZWR output"
$GTM << GTM_EOF
s output="rev1.out"
o output:newv use output
d ^REVZWR("^B")
d ^REVZWR("^A")
c output
d ^REVSORT(output)
GTM_EOF
diff rev1.out.rev $gtm_tst/$tst/outref/polgblcol.txt > /dev/null
if $status then
	echo "Reverse collation test FAILED even before MERGE "
	goto stoptest
else
	echo "Reverse collation test PASSED"
endif
#
echo "Compare ZWR output"
diff col2.out $gtm_tst/$tst/outref/polgblcol.txt > /dev/null
if $status then
        echo "Local collation test FAILED after first set of MERGE "
	goto stoptest
else
        echo "Local collation test PASSED"
endif
echo "Compare reverse ZWR output"
$GTM << GTM_EOF
s output="rev2.out"
o output:newv use output
d ^REVZWR("^B")
d ^REVZWR("^A")
c output
d ^REVSORT(output)
GTM_EOF
diff rev2.out.rev $gtm_tst/$tst/outref/polgblcol.txt > /dev/null
if $status then
	echo "Reverse collation test FAILED after first set of MERGE "
	goto stoptest
else
	echo "Reverse collation test PASSED"
endif
#
echo "Compare ZWR output"
diff col3.out $gtm_tst/$tst/outref/polgblcol.txt > /dev/null
if $status then
        echo "Local collation test FAILED after second set of MERGE "
	goto stoptest
else
        echo "Local collation test PASSED"
endif
echo "Compare reverse ZWR output"
$GTM << GTM_EOF
s output="rev3.out"
o output:newv use output
d ^REVZWR("^B")
d ^REVZWR("^A")
c output
d ^REVSORT(output)
GTM_EOF
diff rev3.out.rev $gtm_tst/$tst/outref/polgblcol.txt > /dev/null
if $status then
	echo "Reverse collation test FAILED after second set of MERGE "
	goto stoptest
else
	echo "Reverse collation test PASSED"
endif
#
echo "Compare ZSHOW ZWR output"
diff zshowgbl.out $gtm_tst/$tst/outref/zshowgbl.txt > /dev/null
if $status then
        echo "Local collation test FAILED in zshow or zwrite"
	goto stoptest
else
        echo "Local collation test PASSED"
endif
echo "Compare reverse ZSHOW ZWR output"
$GTM << GTM_EOF
s output="revzshowgbl.out"
o output:newv use output
d ^REVZWR("^B")
d ^REVZWR("^A")
c output
d ^REVSORT(output)
GTM_EOF
diff revzshowgbl.out.rev $gtm_tst/$tst/outref/polgblcol.txt > /dev/null
if $status then
	echo "Reverse collation test FAILED in zshow or zwrite"
	goto stoptest
else
	echo "Reverse collation test PASSED"
endif

set teststatus=0

stoptest:
$gtm_tst/com/dbcheck.csh -extr
exit $teststatus
