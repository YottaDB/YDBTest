#!/usr/local/bin/tcsh
#################################################################
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
# This module is derived from FIS GT.M.
#################################################################

# test for conversion utility routines
# these are the tests in the manual
# for utf8 character set
#
$switch_chset "UTF-8"
$gtm_tst/com/dbcreate.csh .
# initialize the globals to various strings - all multi bytes
echo init
set cnt = 1
echo ""
echo "########################################## "$cnt" ########################################"
@ cnt = $cnt + 1
echo "Testing %G 1"
$GTM < $gtm_tst/mpt_extra/inref/gbl_utf8a.inp >&! gblinit.outx
#
# Filter out the %YDB-W-LITNONGRAPH, warnings
$tst_awk -f $gtm_tst/com/filter_litnongraph.awk gblinit.outx
echo ""
echo "########################################## "$cnt" ########################################"
@ cnt = $cnt + 1
echo "Testing %G 2"
$GTM < $gtm_tst/mpt_extra/inref/gbl_utf8b.inp

$GTM < $gtm_tst/mpt_extra/inref/gbl_utf8c.inp

echo ""
echo "########################################## "$cnt" ########################################"
@ cnt = $cnt + 1
echo "Testing %GC"
$GTM << EOF
do ^%GC

?
samplegbl
samplegblcp

write "zwriting samplegbl",!
zwrite ^samplegbl
write "zwriting samplegblcp, should be the same as above",!
zwrite ^samplegblcp
EOF
#
echo ""
echo "########################################## "$cnt" ########################################"
@ cnt = $cnt + 1
echo "Testing %GC"
$GTM < $gtm_tst/mpt_extra/inref/gbl_utf8d.inp
#
echo ""
echo "########################################## "$cnt" ########################################"
@ cnt = $cnt + 1
echo "Testing %GCE"
$GTM < $gtm_tst/mpt_extra/inref/gbl_utf8e.inp
#
echo ""
echo "########################################## "$cnt" ########################################"
@ cnt = $cnt + 1
echo "Testing %GO"
$GTM < $gtm_tst/mpt_extra/inref/gbl_utf8f.inp
#
# do an extract of the database with all the globals
$MUPIP extract orig.ext
$tail -n +3 orig.ext >&! orig1.ext
#
$GTM < $gtm_tst/mpt_extra/inref/gbl_utf8g.inp
#
# compare whether the global that got killed is restored by doing a mupip extract now and checking with the saved copy
$MUPIP extract gioutput_zwr.ext
$tail -n +3 gioutput_zwr.ext >&! gioutput_zwr1.ext
diff orig1.ext gioutput_zwr1.ext
#
$GTM < $gtm_tst/mpt_extra/inref/gbl_utf8h.inp
#
$MUPIP extract gioutput_go.ext
$tail -n +3 gioutput_go.ext >&! gioutput_go1.ext
diff orig1.ext gioutput_go1.ext
#
echo ""
echo "########################################## "$cnt" ########################################"
@ cnt = $cnt + 1
echo "Testing %GSE"
$GTM < $gtm_tst/mpt_extra/inref/gbl_utf8i.inp
#
$gtm_tst/com/dbcheck.csh
