#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Various tests checking out trigger interactions with R/O databases.
#
setenv gtm_test_sprgde_id "ID1"	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps 3
chmod 444 mumps.dat           # Make it R/O
#
echo
echo "Case 1 - MUPIP TRIGGER - Adding a trigger to a read-only database"
$MUPIP trigger -trig=$gtm_tst/$tst/inref/readonlyadd1.trg
#
echo
echo "Case 2 - MUPIP TRIGGER - Delete all triggers in a read-only database (first add a trigger to attempt to 'delete')"
chmod 644 mumps.dat           # Make R/W temporarily to add a trigger
$MUPIP trigger -trig=$gtm_tst/$tst/inref/readonlyadd1.trg
chmod 444 mumps.dat           # Now R/O again
$MUPIP trigger -trig=$gtm_tst/$tst/inref/readonlydall.trg << EOF
Y
EOF
#
echo
echo "Case 3 - MUPIP TRIGGER - Modifying a trigger in a read-only database"
$MUPIP trigger -trig=$gtm_tst/$tst/inref/readonlymod1.trg
#
echo
echo "Case 4 - MUPIP TRIGGER - Deleting a specific trigger in a read-only database"
$MUPIP trigger -trig=$gtm_tst/$tst/inref/readonlydel1.trg
#
echo
echo "Case 5 - MUPIP TRIGGER - multi-region - verify can add trigger to AREG if BREG is R/O"
chmod 644 mumps.dat
chmod 444 b.dat
$MUPIP trigger -trig=$gtm_tst/$tst/inref/readonlyadd2.trg
#
echo
echo "Case 6 - MUPIP TRIGGER - multi-region - verify we can modify trigger in AREG while DEFAULT region is R/O"
chmod 444 mumps.dat
$MUPIP trigger -trig=$gtm_tst/$tst/inref/readonlymod2.trg
#
echo
echo "Case 7 - MUPIP TRIGGER - multi-region - verify we can delete trigger in AREG with DEFAULT and BREG R/O"
$MUPIP trigger -trig=$gtm_tst/$tst/inref/readonlydel2.trg
#
echo
echo "Case 8 - MUPIP TRIGGER - multi-region - verify we can add trigger in AREG if with DEFAULT and BREG R/O"
$MUPIP trigger -trig=$gtm_tst/$tst/inref/readonlyadd2.trg
#
echo
echo "Case 9 - MUPIP TRIGGER - multi-region - verify we can delete all triggers if only BREG is R/O (no triggers there)"
chmod 644 mumps.dat
$MUPIP trigger -trig=$gtm_tst/$tst/inref/readonlydall.trg << EOF
Y
EOF

# Test cases for GTM-6901
echo '+^a -name=readonlyareg -command=s -xecute="set ^readwritetrg=^a"' >&! aonly.trg
echo '+^b -name=readwritebreg  -command=s -xecute="set ^readwritetrg=^b"' >&! bonly.trg
echo '+^c -name=readwritedef  -command=s -xecute="set ^readwritetrg=^c"' >&! conly.trg
cat aonly.trg bonly.trg conly.trg >&! trigabc.trg
cat bonly.trg conly.trg >&! trigbc.trg

echo "# Case GTM6901A - Trigger delete name* should work even if one region is read-only,"
echo "# as long as the region does not have a matching name* trigger"
chmod 644 b.dat
echo "# Install triggers in AREG, BREG and DEFAULT"
$MUPIP trigger -trig=trigabc.trg >&! casegtm6901a_trigadd.out
chmod 444 a.dat
echo "# Delete triggers with -readwrite*"
$gtm_exe/mumps -run %XCMD 'w $ztrigger("item","-readwrite*")'

echo "# Case GTM6901B - Trigger add/delete name* should not work if one of the regions that have a matching trigger is read-only"
echo "# Install triggers in AREG, BREG and DEFAULT - with AREG read-only"
$MUPIP trigger -trig=trigabc.trg
echo "# Install triggers in AREG, BREG and DEFAULT with all regions read-write"
chmod 644 a.dat
$MUPIP trigger -trig=trigabc.trg >&! casegtm6901b_trigadd.out
chmod 444 b.dat
echo "# Select name* should work if one of the regions that have a matching trigger is read-only"
$gtm_exe/mumps -run %XCMD 'w $ztrigger("select","read*")'
echo "# Delete triggers with -readwrite*"
$gtm_exe/mumps -run %XCMD 'w $ztrigger("item","-read*")'
chmod 644 b.dat

$gtm_tst/com/dbcheck.csh
echo "# Delete all triggers before attempting the next case"
$gtm_exe/mumps -run %XCMD 'w $ztrigger("item","-*")'
echo "# Case GTM6901C - If the only journaled region is read-only, a -* when no triggers exist should work even if TLGTRIG cannot be written"

echo "# Enable journaling only for AREG"
$MUPIP set $tst_jnl_str -reg AREG >&! casegtm6901c_jnlon.out
chmod 444 a.dat
echo "# Delete all triggers with -*"
$gtm_exe/mumps -run %XCMD 'w $ztrigger("item","-*")'
echo "# Check journal extract - do not expect TLGRIG in AREG, as it is read-only"
$gtm_tst/$tst/u_inref/jnl_extract_detailed.csh
chmod 644 a.dat

echo "# Case GTM6901D - If the only journaled region is read-write, a -* should write A TLGTRIG jnl record in that region even if no triggers exist there"
echo "# Install triggers in BREG and DEFAULT"
$MUPIP trigger -trig=trigbc.trg >&! casegtm6901d_trigadd.out
echo "# Delete all triggers with -*"
$gtm_exe/mumps -run %XCMD 'w $ztrigger("item","-*")'
echo "# Check journal extract - expect TLGTRIG in AREG"
$gtm_tst/$tst/u_inref/jnl_extract_detailed.csh

echo "# Case GTM6901E - If the only journaled region is read-only, a -name* should work fine as long as a matching trigger does not exist in AREG"
echo "# Install triggers in AREG, BREG and DEFAULT"
$MUPIP trigger -trig=trigabc.trg >&! casegtm6901e_trigadd.out
chmod 444 a.dat
echo "# Delete -readwrite* triggers, which matches triggers in BREG and DEFAULT"
$gtm_exe/mumps -run %XCMD 'w $ztrigger("item","-readwrite*")'
echo "# Check journal extract - Do not expect new TLGTRIG in AREG"
$gtm_tst/$tst/u_inref/jnl_extract_detailed.csh
chmod 644 a.dat

echo "# Case GTM6901F - If the only journaled region is read-write, a -name* should write a TLGTRIG jnl record even if it does not have a matching trigger in that region"
echo "# Install triggers in AREG, BREG and DEFAULT"
$MUPIP trigger -trig=trigabc.trg >&! casegtm6901f_trigadd.out
echo "# Delete all triggers with -readwrite*"
$gtm_exe/mumps -run %XCMD 'w $ztrigger("item","-readwrite*")'
echo "# Check journal extract - expect TLGTRIG in AREG"
$gtm_tst/$tst/u_inref/jnl_extract_detailed.csh
$gtm_tst/com/dbcheck.csh
#
echo
echo 'Cases 10-18 - $ZTRIGGER("FILE")'
$gtm_tst/com/backup_dbjnl.csh muptrigbkup
setenv gtm_test_sprgde_id "ID2"	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps 3
chmod 444 mumps.dat           # Make it R/O
$GTM << EOF
Write "Case 10 - \$ZTrigger(FILE) - Adding a trigger to a read-only database",!
Write \$ZTrigger("FILE","$gtm_tst/$tst/inref/readonlyadd1.trg"),!!
Write "Case 11 - \$ZTrigger(FILE) - Delete all triggers in a read-only database (first add a trigger to attempt to 'delete')",!
EOF
chmod 644 mumps.dat
$GTM << EOF
Write \$ZTrigger("FILE","$gtm_tst/$tst/inref/readonlyadd1.trg"),!
EOF
chmod 444 mumps.dat
$GTM << EOF
Write \$ZTrigger("FILE","$gtm_tst/$tst/inref/readonlydall.trg"),!!
Write "Case 12 - \$ZTrigger(FILE) - Modifying a trigger in a read-only database",!
Write \$ZTrigger("FILE","$gtm_tst/$tst/inref/readonlymod1.trg"),!!
Write "Case 13 - \$ZTrigger(FILE) - Deleting a specific trigger in a read-only database",!
Write \$ZTrigger("FILE","$gtm_tst/$tst/inref/readonlydel1.trg"),!!
Write "Case 14 - \$ZTrigger(FILE) - multi-region - verify can add trigger to AREG if BREG is R/O",!
EOF
chmod 644 mumps.dat
chmod 444 b.dat
$GTM << EOF
Write \$ZTrigger("FILE","$gtm_tst/$tst/inref/readonlyadd2.trg"),!!
Write "Case 15 - \$ZTrigger(FILE) - multi-region - verify we can modify trigger in AREG while DEFAULT region is R/O",!
EOF
chmod 444 mumps.dat
cp a.dat abak.dat
$GTM << EOF
Write \$ZTrigger("FILE","$gtm_tst/$tst/inref/readonlymod2.trg"),!!
Write "Case 16 - \$ZTrigger(FILE) - multi-region - verify we can delete trigger in AREG with DEFAULT and BREG R/O",!
Write \$ZTrigger("FILE","$gtm_tst/$tst/inref/readonlydel2.trg"),!!
Write "Case 17 - \$ZTrigger(FILE) - multi-region - verify we can also delete trigger in AREG if only BREG is R/O",!
EOF
chmod 644 mumps.dat
chmod 644 b.dat
cp abak.dat a.dat
$GTM << EOF
Write \$ZTrigger("FILE","$gtm_tst/$tst/inref/readonlydel2.trg"),!!
Write "Case 18 - \$ZTrigger(FILE) - multi-region - verify we can delete all trigges if only BREF is R/O (no triggers there)",!
Write \$ZTrigger("FILE","$gtm_tst/$tst/inref/readonlydall.trg"),!!
EOF
$gtm_tst/com/dbcheck.csh
#
echo
echo 'Cases 10-27 - $ZTrigger("ITEM")'
$gtm_tst/com/backup_dbjnl.csh ztrigfbkup
setenv gtm_test_sprgde_id "ID3"	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps 3
chmod 444 mumps.dat           # Make it R/O
$GTM << EOF
Write "Case 19 - \$ZTrigger(ITEM) - Adding a trigger to a read-only database",!
Write \$ZTrigger("ITEM","+^C -name=addedtrig -command=S,ZTR -xecute=""Set ^XX=3"""),!!
Write "Case 20 - \$ZTrigger(ITEM) - Delete all triggers in a read-only database (first add a trigger to attempt to 'delete')",!
EOF
chmod 644 mumps.dat
$GTM << EOF
Write \$ZTrigger("ITEM","+^C -name=addedtrig -command=S,ZTR -xecute=""Set ^XX=3"""),!
EOF
chmod 444 mumps.dat
$GTM << EOF
Write \$ZTrigger("ITEM","-*"),!!
Write "Case 21 - \$ZTrigger(ITEM) - Modifying a trigger in a read-only database",!
Write \$ZTrigger("ITEM","+^C -name=moddedtrig -command=S,ZTR -xecute=""Set ^XX=3"""),!!
Write "Case 22 - \$ZTrigger(ITEM) - Deleting a specific trigger in a read-only database",!
Write \$ZTrigger("ITEM","-^C -name=addedtrig -command=S,ZTR -xecute=""Set ^XX=3"""),!!
Write "Case 23 - \$ZTrigger(ITEM) - multi-region - verify can add trigger to AREG if BREG is R/O",!
EOF
chmod 644 mumps.dat
chmod 444 b.dat
$GTM << EOF
Write \$ZTrigger("ITEM","+^A -name=addedtrig2 -command=S,ZTR -xecute=""Set ^XX=1"""),!!
Write "Case 24 - \$ZTrigger(ITEM) - multi-region - verify we can modify trigger in AREG while DEFAULT region is R/O",!
EOF
chmod 444 mumps.dat
cp a.dat abak.dat
$GTM << EOF
Write \$ZTrigger("ITEM","+^A -name=addedtrig2 -command=S,ZTR -options=NOC -xecute=""Set ^XX=1"""),!!
Write "Case 25 - \$ZTrigger(ITEM) - multi-region - verify we can delete trigger in AREG with DEFAULT and BREG R/O",!
Write \$ZTrigger("ITEM","-^A -name=addedtrig2 -command=S,ZTR -options=NOC -xecute=""Set ^XX=1"""),!!
Write "Case 26 - \$ZTrigger(ITEM) - multi-region - verify we can also delete trigger in AREG if only BREG is R/O",!
EOF
chmod 644 mumps.dat
cp abak.dat a.dat
$GTM << EOF
Write \$ZTrigger("ITEM","-^A -name=addedtrig2 -command=S,ZTR -options=NOC -xecute=""Set ^XX=1"""),!!
Write "Case 27 - \$ZTrigger(FILE) - multi-region - verify we can delete all trigges if only BREF is R/O (no triggers there)",!
Write \$ZTrigger("ITEM","-*"),!!
EOF
#
echo
echo "Case 28-29 - ZTRIGGER command (adding 1 trigger back in)"
$MUPIP trigger -trig=$gtm_tst/$tst/inref/readonlyadd1.trg
chmod 444 mumps.dat
$GTM << EOF
Write "Case 28 - Drive trigger for non-existant global in a read-only database",!
ZTRIGGER ^donotexist
Write !
Write "Case 29 - Drive trigger for existing global in a read-only database",!
ZTRIGGER ^C
EOF
#
chmod 644 mumps.dat
chmod 644 b.dat
$gtm_tst/com/dbcheck.csh
