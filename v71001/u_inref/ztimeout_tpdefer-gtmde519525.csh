#!/usr/local/bin/tcsh -f
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

cat << CAT_EOF | sed 's/^/# /;'
********************************************************************************************
GTM-DE519525 - Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.1-001_Release_Notes.html#GTM-DE519525):

GT.M defers \$ZTIMEOUT when its expiry happens during a TP transaction. \$ZMAXTPTIME may interrupt a transaction, as optionally may MUPIP INTRPT initiated \$ZINTERRUPT processing, but \$ZTIMEOUT acts after a TROLLBACK or master TCOMMIT. Previously, GT.M allowed a \$ZTIMEOUT expiry within a TP transaction. (GTM-DE519525)

CAT_EOF
echo

setenv ydb_msgprefix "GTM"
setenv ydb_prompt "GTM>"

$gtm_tst/com/dbcreate.csh mumps >&! dbcreate.out

echo '# Create test routine gtmde519525.m from pre-existing similar test routine v71001/inref/gtmde513980.m'
cp $gtm_tst/v71001/inref/gtmde513980.m gtmde519525.m
echo '# Revised copied test routine gtmde519525.m to use $ztimeout instead of $zmaxtptime'
sed -i 's/zmaxtptime/ztimeout/' gtmde519525.m
echo '# Set gtm_tpnotacidtime to a value higher than the hang time of 15 seconds, i.e. 30 seconds, to avoid a TPNOTACID message in the test routine'
setenv gtm_tpnotacidtime 30
echo
echo '# Run the gtmde519525 routine to set $ZTIMEOUT to 2 seconds, do a trestart until execution reaches the final retry,'
echo '# and then, hang for 15 seconds. Expect a message with $HOROLOG and $TRESTART information both BEFORE and AFTER'
echo '# the hang. Prior to v71001, the transaction would not complete and a GTM-W-ZTIMEOUT message would be issued.'
$gtm_dist/mumps -r gtmde519525

$gtm_tst/com/dbcheck.csh >&! dbcheck.out
