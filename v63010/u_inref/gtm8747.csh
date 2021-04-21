#!/usr/local/bin/tcsh
#################################################################
#                                                               #
# Copyright (c) 2021 YottaDB LLC and/or its subsidiaries.       #
# All rights reserved.                                          #
#                                                               #
#       This source code contains the intellectual property     #
#       of its copyright holder(s), and is made available       #
#       under a license.  If you do not know the terms of       #
#       the license, please stop and do not read further.       #
#                                                               #
#################################################################

$echoline
echo "# Creating database"
$gtm_tst/com/dbcreate.csh mumps

$echoline
echo "# Starting journaling"
$MUPIP set -journal="enable,file=jnl.mjl" -file mumps.dat

$echoline
echo "# Set 500 global variables"
$gtm_exe/yottadb -run %XCMD 'for i=1:1:500 set ^a(i)=i*i'

$echoline
echo "# Stop journaling"
$MUPIP set -journal=disable -file mumps.dat

$echoline
echo "# Restarting journaling to make a second journal file"
$MUPIP set -journal="enable,file=jnl2.mjl" -file mumps.dat

$echoline
echo "# Set 500 global variables"
$gtm_exe/yottadb -run %XCMD 'for i=501:1:1000 set ^a(i)=i*i'

$echoline
echo "# Stop journaling"
$MUPIP set -journal=disable -file mumps.dat

$echoline
echo "# Extract the first journal file before corrupting/deleting the database for comparisons"
$MUPIP journal -extract -forward jnl.mjl
mv jnl.mjf jnl_before.mjf

$echoline
echo "# Attempt a MUPIP JOURNAL -EXTRACT -CORRUPTDB on *. This should not work."
$MUPIP journal -extract -forward -corruptdb *

$echoline
echo "# Make the database unreadable"
chmod -r mumps.dat

$echoline
echo "# Extract the first journal file via a MUPIP JOURNAL -EXTRACT -CORRUPTDB"
$MUPIP journal -extract -forward -corruptdb jnl.mjl
mv jnl.mjf jnl_unreadable.mjf

$echoline
echo "# Make the database readable and corrupt"
chmod +r mumps.dat
$DSE change -file -corrupt_file=TRUE

$echoline
echo "# Extract the first journal file via a MUPIP JOURNAL -EXTRACT -CORRUPTDB"
$MUPIP journal -extract -forward -corruptdb jnl.mjl
mv jnl.mjf jnl_corrupt.mjf

$echoline
echo "# Delete the database file"
rm mumps.dat

$echoline
echo "# Extract the first journal file via a MUPIP JOURNAL -EXTRACT -CORRUPTDB"
$MUPIP journal -extract -forward -corruptdb jnl.mjl
mv jnl.mjf jnl_deleted.mjf

$echoline
echo "# Attempt MUPIP JOURNAL -EXTRACT -CORRUPTDB where -fences is set to NONE and ALWAYS. These should not work."
$MUPIP journal -extract -forward -corruptdb -fences=NONE jnl.mjl
$MUPIP journal -extract -forward -corruptdb -fences=ALWAYS jnl.mjl

$echoline
echo "# Attempt MUPIP JOURNAL -EXTRACT -CORRUPTDB where -broken is set. This should not work."
$MUPIP journal -extract -forward -corruptdb -broken="broken.txt" jnl.mjl

$echoline
echo "# Attempt MUPIP JOURNAL -EXTRACT -CORRUPTDB where -lost is set. This should not work."
$MUPIP journal -extract -forward -corruptdb -lost="jnl.lost" jnl.mjl

$echoline
echo "# Compare the various extract files with diff. There should be no output from these diff commands."
echo "# All files besides jnl_before.mjf are compared with jnl_before.mjf. There is no need to compare all possible combinations"
echo "# because comparing all files to jnl_before (extract from the database with no errors) with diff will find any differences"
echo "# between the various extract files."
$echoline
echo "# jnl_before.mjf vs jnl_unreadable.mjf"
$echoline
echo "# jnl_before.mjf vs jnl_corrupt.mjf"
diff jnl_before.mjf jnl_corrupt.mjf
$echoline
echo "# jnl_before.mjf vs jnl_deleted.mjf"
diff jnl_before.mjf jnl_deleted.mjf

$echoline
echo "# Create shared library for alternate collation # 1 (reverse collation)"
source $gtm_tst/com/cre_coll_sl_reverse.csh 1

$echoline
echo "# Create a new database file"
$gtm_tst/com/dbcreate.csh mumps

$echoline
echo "# Restart journaling with a new file"
$MUPIP set -journal="enable,file=jnl_collation.mjl" -file mumps.dat

$echoline
echo "# Set some global variables using alternate collation #1"
$ydb_dist/mumps -run ^%XCMD 'set ^x=0  kill ^x  set x=$$set^%GBLDEF("^x",0,1) for i=1:1:500 set ^x(i)=i*i*i'

$echoline
echo "# Stop journaling"
$MUPIP set -journal=disable -file mumps.dat

$echoline
echo "# Unset alternate collation"
source $gtm_tst/com/unset_ydb_env_var.csh ydb_collate_1 gtm_collate_1
source $gtm_tst/com/unset_ydb_env_var.csh ydb_local_collate gtm_local_collate

$echoline
echo "# Extract the journal file via a MUPIP JOURNAL -EXTRACT -CORRUPTDB"
$MUPIP journal -extract -forward -corruptdb jnl_collation.mjl
mv jnl_collation.mjf jnl_collation_corruptdb.mjf

$echoline
echo "# Extract the journal file via a regular MUPIP JOURNAL -EXTRACT"
$MUPIP journal -extract -forward jnl_collation.mjl

$echoline
echo "# Extract 2 comma separated journal files from different databases via a MUPIP JOURNAL -EXTRACT -CORRUPTDB"
$MUPIP journal -extract -forward -corruptdb jnl.mjl,jnl_collation.mjl

$echoline
echo "# Extract 2 comma separated journal files from the same database via a MUPIP JOURNAL -EXTRACT -CORRUPTDB"
echo "# [0x00000000000041F4] [0x0000000000004000]"
$MUPIP journal -extract -forward -corruptdb jnl.mjl,jnl2.mjl
