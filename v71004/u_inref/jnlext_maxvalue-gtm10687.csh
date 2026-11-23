#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
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
GTM-10687 - Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.1-004_Release_Notes.html#GTM-DE1959410687)

GDE and MUPIP report a more appropriate maximum value for journal file extension. This does not change the way the extension logic works, only the value reported by the GDE VALTOOBIG or MUPIP JNLINVEXT messages. Previously the messages reported a maximum that had no relationship with the maximum size of a journal file. (GTM-10687)

CAT_EOF
echo

echo "# The maximum size of a journal file is the maximum journal AUTOSWITCHLIMIT, 8388607 blocks."
echo "# Before the fix : the maximum journal EXTENSION was 1073741823 (in the check and in the VALTOOBIG and JNLINVEXT"
echo "#                  messages), which is not the maximum AUTOSWITCHLIMIT."
echo "# With the fix   : the maximum journal EXTENSION is 8388607, the same as the maximum AUTOSWITCHLIMIT (Tests 5 and 6)."
echo

# Journaling is turned on by the test cases below so do not let the test framework turn journaling on.
setenv gtm_test_jnl NON_SETJNL
$gtm_tst/com/dbcreate.csh mumps >&! dbcreate.out

echo "# Test 1 : GDE accepts a journal EXTENSION of 8388607. Expect no error and [Extension : 8388607] from GDE SHOW."
echo "# Run [GDE change -region DEFAULT -journal=(nobefore_image,extension=8388607)]"
$GDE 'change -region DEFAULT -journal=(nobefore_image,extension=8388607)' >&! gde1.out
$grep -E -- '-[EWF]-' gde1.out
$GDE show -region DEFAULT >&! gdeshow1.out
$tst_awk '$1 == "DEFAULT" && $2 == "<based" {print "Extension : " $(NF-1)}' gdeshow1.out
echo

echo "# Test 2 : GDE rejects a journal EXTENSION of 8388608. Expect VALTOOBIG (maximum of 8388607) and OBJNOTCHG."
echo "# Run [GDE change -region DEFAULT -journal=(nobefore_image,extension=8388608)]"
$GDE 'change -region DEFAULT -journal=(nobefore_image,extension=8388608)' >&! gde2.out
$gtm_tst/com/check_error_exist.csh gde2.out GDE-I-VALTOOBIG GDE-E-OBJNOTCHG
echo

echo "# Test 3 : MUPIP SET -JOURNAL accepts an EXTENSION of 8388607."
echo "#          Expect no error and [Journal Extension 8388607] from DSE DUMP -FILEHEADER."
echo "# Run [mupip set -journal=enable,on,nobefore,alloc=3000,auto=1049575,extension=8388607 -region DEFAULT]"
$MUPIP set -journal=enable,on,nobefore,alloc=3000,auto=1049575,extension=8388607 -region DEFAULT >&! mupip3.out
$grep -E -- '-[EWF]-' mupip3.out
$DSE dump -fileheader >&! dse3.out
$tst_awk '/Journal Extension/ {print "Journal Extension " $NF}' dse3.out
echo

echo "# Test 4 : MUPIP SET -JOURNAL rejects an EXTENSION of 8388608. Expect JNLINVEXT (maximum of 8388607) and MUPCLIERR."
echo "# Run [mupip set -journal=enable,on,nobefore,alloc=3000,auto=1049575,extension=8388608 -region DEFAULT]"
$MUPIP set -journal=enable,on,nobefore,alloc=3000,auto=1049575,extension=8388608 -region DEFAULT >&! mupip4.out
$gtm_tst/com/check_error_exist.csh mupip4.out YDB-W-JNLINVEXT YDB-E-MUPCLIERR
echo "# Expect [Journal Extension 8388607] from DSE DUMP -FILEHEADER (that is, unchanged from Test 3)."
$DSE dump -fileheader >&! dse4.out
$tst_awk '/Journal Extension/ {print "Journal Extension " $NF}' dse4.out
echo

# A value larger than the maximum of both builds (1073741823 before the fix) gets the maximum reported by either build
set toobig = 1073741824

echo "# Test 5 : GDE reports the same maximum for a journal EXTENSION as for a journal AUTOSWITCHLIMIT."
echo "#          Expect VALTOOBIG for both, and the two maximums in the VALTOOBIG messages to be the same."
echo "# Run [GDE change -region DEFAULT -journal=(nobefore_image,extension=$toobig)]"
$GDE "change -region DEFAULT -journal=(nobefore_image,extension=$toobig)" >&! gde5ext.out
$gtm_tst/com/check_error_exist.csh gde5ext.out GDE-I-VALTOOBIG GDE-E-OBJNOTCHG
echo "# Run [GDE change -region DEFAULT -journal=(nobefore_image,autoswitchlimit=$toobig)]"
$GDE "change -region DEFAULT -journal=(nobefore_image,autoswitchlimit=$toobig)" >&! gde5auto.out
$gtm_tst/com/check_error_exist.csh gde5auto.out GDE-I-VALTOOBIG GDE-E-OBJNOTCHG
# The VALTOOBIG message is "<value> is larger than the maximum of <maximum> for a <qualifier>"
set extmax = `$tst_awk '/VALTOOBIG/ {for (i = 1; i < NF; i++) if ($i == "of") print $(i + 1)}' gde5ext.out*`
set automax = `$tst_awk '/VALTOOBIG/ {for (i = 1; i < NF; i++) if ($i == "of") print $(i + 1)}' gde5auto.out*`
if (("$extmax" == "$automax") && ("" != "$extmax")) then
	echo "PASS : GDE maximum EXTENSION [$extmax] is the same as the GDE maximum AUTOSWITCHLIMIT [$automax]"
else
	echo "FAIL : GDE maximum EXTENSION [$extmax] is not the same as the GDE maximum AUTOSWITCHLIMIT [$automax]"
endif
echo

echo "# Test 6 : MUPIP SET -JOURNAL reports the same maximum for a journal EXTENSION as for a journal AUTOSWITCHLIMIT."
echo "#          Expect JNLINVEXT and JNLINVSWITCHLMT, and the two maximums in those messages to be the same."
echo "# Run [mupip set -journal=enable,on,nobefore,alloc=3000,auto=1049575,extension=$toobig -region DEFAULT]"
$MUPIP set -journal=enable,on,nobefore,alloc=3000,auto=1049575,extension=$toobig -region DEFAULT >&! mupip6ext.out
$gtm_tst/com/check_error_exist.csh mupip6ext.out YDB-W-JNLINVEXT YDB-E-MUPCLIERR
echo "# Run [mupip set -journal=enable,on,nobefore,alloc=3000,auto=$toobig -region DEFAULT]"
$MUPIP set -journal=enable,on,nobefore,alloc=3000,auto=$toobig -region DEFAULT >&! mupip6auto.out
$gtm_tst/com/check_error_exist.csh mupip6auto.out YDB-E-JNLINVSWITCHLMT YDB-E-MUPCLIERR
# The JNLINVEXT message ends with "maximum allowed size of <maximum>.  Journal file not created." and the
# JNLINVSWITCHLMT message ends with "allowed limits [<minimum>] and [<maximum>]"
set extmax = `$tst_awk '/JNLINVEXT/ {max = $(NF - 4); sub(/\.$/, "", max); print max}' mupip6ext.out*`
set automax = `$tst_awk '/JNLINVSWITCHLMT/ {gsub(/[][]/, "", $NF); print $NF}' mupip6auto.out*`
if (("$extmax" == "$automax") && ("" != "$extmax")) then
	echo "PASS : MUPIP maximum EXTENSION [$extmax] is the same as the MUPIP maximum AUTOSWITCHLIMIT [$automax]"
else
	echo "FAIL : MUPIP maximum EXTENSION [$extmax] is not the same as the MUPIP maximum AUTOSWITCHLIMIT [$automax]"
endif
echo

$gtm_tst/com/dbcheck.csh >&! dbcheck.out
