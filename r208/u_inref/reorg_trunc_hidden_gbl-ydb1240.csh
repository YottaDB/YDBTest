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

echo "#------------------------------------------------------------------------------------------------#"
echo "# [#1240] MUPIP REORG -TRUNCATE should process globals in .dat files that are hidden by the .gld #"
echo "#------------------------------------------------------------------------------------------------#"
echo

# MUPIP REORG -TRUNCATE is not supported with the MM access method so force BG
source $gtm_tst/com/gtm_test_setbgaccess.csh
# Disable V6 DB mode and the > 4g db block testing scheme as both change MUPIP REORG -TRUNCATE behavior/output
setenv gtm_test_use_V6_DBs 0
setenv ydb_test_4g_db_blks 0
# This subtest builds its own multi-region glds around a single-region database so disable spanning region
# randomization
setenv gtm_test_spanreg 0
# Do not let the test system run its own concurrent reorg processes; this subtest checks specific reorg output
setenv test_reorg NON_REORG

$gtm_tst/com/dbcreate.csh mumps 1 64 500 4096

set orig_gbldir = "$gtmgbldir"

echo "# Run [inita^ydb1240] : grow ^x, create ^a at the very end of the file, then kill both"
$ydb_dist/yottadb -run inita^ydb1240
echo "# Create 2reg.gld : a copy of the original gld plus the names a, b and c mapped to a new region AREG."
echo "# Region DEFAULT's database file still holds those globals' blocks (right now the killed ^a's leftover"
echo "# root block, at the very end of the file) but 2reg.gld no longer maps the names to DEFAULT: they are"
echo "# hidden globals (see YDB#1240)"
# Copying the original gld (rather than generating a fresh one with GDE) keeps whatever settings dbcreate.csh
# put on region DEFAULT. The names b and c are mapped now, in one go with a, so the later stages need no
# further gld surgery; they are harmless to the earlier stages (^b/^c do not exist yet).
cp "$orig_gbldir" 2reg.gld
setenv gtmgbldir 2reg.gld
cat > 2reg.gde << gde_eof
add -name a -region=AREG
add -name b -region=AREG
add -name c -region=AREG
add -region AREG -dynamic=ASEG
add -segment ASEG -file=areg.dat
exit
gde_eof
$GDE_SAFE @2reg.gde >&! gde_2reg.out
if (0 != $status) then
	echo "FAIL: GDE could not create 2reg.gld"
	echo "# ----- gde_2reg.out -----"
	cat gde_2reg.out
endif
# The AREG database file has to exist even though nothing is ever stored in it: the REORGs below bind the
# global names they encounter through the gld, which opens the region a name maps to.
$MUPIP create -reg=AREG >&! mupcreate_areg.out
if (0 != $status) then
	echo "FAIL: could not create the AREG database file"
	echo "# ----- mupcreate_areg.out -----"
	cat mupcreate_areg.out
endif

echo
echo "# Stage A : the YDB#1240 issue scenario (a killed global hidden by the gld)"
echo "#"
echo "# First run [mupip reorg -truncate -select=x -reg DEFAULT] : with an explicit -SELECT the reorg"
echo "# deliberately does NOT process hidden globals (the user decides the exact set of globals to work on)."
echo "# ^a's leftover root block therefore stays at the end of the file and pins it, since a single busy"
echo "# block in the last local bitmap rules out any meaningful truncation (usually a MUTRUNCALREADY message)."
echo "# The truncate tail sweep cannot help here either: a killed global's root block is empty, so the"
echo "# sweep's scan has no key to determine a global name from (only the directory tree still knows the"
echo "# name, and with -SELECT the reorg deliberately does not consult it beyond the selected names)."
$MUPIP reorg -truncate -select=x -reg DEFAULT >&! truncate_selectx.out
echo -n "Hidden global ^a processed by the -select reorg : "
grep -c "^Global: a (region DEFAULT)" truncate_selectx.out
# The usual outcome is a MUTRUNCALREADY message (^a's blocks sit in the last local bitmap, so no truncation is
# possible at all). If the last file extension happened to push the file end just past a local bitmap boundary,
# the reorg can instead trim that boundary sliver and print a [Truncated region] line; that is still "the file
# stayed pinned by hidden ^a", so treat a post-truncate total above 1024 blocks the same as MUTRUNCALREADY
# (the file was grown to over 1024 blocks and ^a is what keeps it there; compare the truncate down to 1024
# blocks or less that the no-select reorg below achieves).
set untrunc = "NO"
grep -q "MUTRUNCALREADY" truncate_selectx.out
if (0 == $status) then
	set untrunc = "YES"
else
	grep -q "Truncated region: DEFAULT" truncate_selectx.out
	if (0 == $status) then
		set toblks = `grep "Truncated region: DEFAULT" truncate_selectx.out | $tst_awk '{split($0, a, "[][]"); print a[4] + 0;}'`
		if ($toblks > 1024) set untrunc = "YES"
	endif
endif
if ("YES" == "$untrunc") then
	echo "Hidden ^a still pins the file after the -select reorg : YES"
else
	echo "Hidden ^a still pins the file after the -select reorg : NO"
	echo "# ----- truncate_selectx.out -----"
	cat truncate_selectx.out
endif
echo
echo "# Now run [mupip reorg -truncate -reg DEFAULT] : without -SELECT the reorg processes every global in"
echo "# region DEFAULT's directory tree, hidden ones included (the YDB#1240 fix), so ^a's root block moves"
echo "# to the front and the truncate works. A build without the fix reports this instead:"
echo "#	%YDB-I-MUTRUNCALREADY, Region DEFAULT: no further truncation possible"
$MUPIP reorg -truncate -reg DEFAULT >&! truncate_hidden_a.out
echo -n "Hidden global ^a processed by the no-select reorg : "
grep -c "^Global: a (region DEFAULT)" truncate_hidden_a.out
grep -q "Truncated region: DEFAULT" truncate_hidden_a.out
if (0 != $status) then
	echo "FAIL: the no-select reorg -truncate did not truncate region DEFAULT"
	echo "# ----- truncate_hidden_a.out -----"
	cat truncate_hidden_a.out
else
	$tst_awk -f $gtm_tst/r208/inref/trunc_bounds-ydb1240.awk truncate_hidden_a.out
endif

echo
echo "# Stage B : a hidden global WITH data"
echo "#"
echo "# Run [initb^ydb1240] (through the original gld) : regrow ^x, create ^b at the end of the file, then"
echo "# kill only ^x. With 2reg.gld the name [b] maps to AREG, so ^b (data and all) is a hidden global in"
echo "# region DEFAULT"
setenv gtmgbldir "$orig_gbldir"
$ydb_dist/yottadb -run initb^ydb1240
setenv gtmgbldir 2reg.gld
echo "# Run [mupip reorg -truncate -reg DEFAULT] : the hidden ^b's blocks must move down for the truncate"
$MUPIP reorg -truncate -reg DEFAULT >&! truncate_hidden_b.out
echo -n "Hidden global ^b processed by the no-select reorg : "
grep -c "^Global: b (region DEFAULT)" truncate_hidden_b.out
grep -q "Truncated region: DEFAULT" truncate_hidden_b.out
if (0 != $status) then
	echo "FAIL: the no-select reorg -truncate did not truncate region DEFAULT"
	echo "# ----- truncate_hidden_b.out -----"
	cat truncate_hidden_b.out
else
	$tst_awk -f $gtm_tst/r208/inref/trunc_bounds-ydb1240.awk truncate_hidden_b.out
endif
echo "# Run [verifyb^ydb1240] (through the original gld) : ^b's contents must have survived the block moves"
setenv gtmgbldir "$orig_gbldir"
$ydb_dist/yottadb -run verifyb^ydb1240

echo
echo "# Stage C : hidden-global blocks that only the truncate tail sweep can move"
echo "#"
echo "# Run [initc^ydb1240] (through the original gld) : regrow ^x, create ^c at the end of the file, then"
echo "# kill only ^x (same shape as stage B, with ^c hidden by 2reg.gld)"
$ydb_dist/yottadb -run initc^ydb1240
setenv gtmgbldir 2reg.gld
echo "# Run [mupip reorg -truncate -select=x -reg DEFAULT] : the explicit -SELECT keeps the reorg phase off"
echo "# the hidden ^c, but ^c's blocks hold live data (unlike stage A's killed ^a) and sit past the truncate"
echo "# point, so the tail sweep's scan finds them and determines the name [c] from their keys. Since that"
echo "# name is in region DEFAULT's own directory tree the sweep moves the blocks, no matter that the gld"
echo "# maps the name to AREG (the tail sweep part of the YDB#1240 fix; it used to skip such names)"
$MUPIP reorg -truncate -select=x -reg DEFAULT >&! truncate_sweep_c.out
echo -n "Hidden global ^c processed by the reorg phase : "
grep -c "^Global: c (region DEFAULT)" truncate_sweep_c.out
grep -q "Truncate tail sweep of Global: c (region DEFAULT)" truncate_sweep_c.out
if (0 == $status) then
	echo "Tail sweep moved the hidden ^c : YES"
else
	echo "Tail sweep moved the hidden ^c : NO"
	echo "# ----- truncate_sweep_c.out -----"
	cat truncate_sweep_c.out
endif
grep -q "Truncated region: DEFAULT" truncate_sweep_c.out
if (0 != $status) then
	echo "FAIL: the -select reorg -truncate did not truncate region DEFAULT despite the sweep"
	echo "# ----- truncate_sweep_c.out -----"
	cat truncate_sweep_c.out
else
	$tst_awk -f $gtm_tst/r208/inref/trunc_bounds-ydb1240.awk truncate_sweep_c.out
endif
echo "# Run [verifyc^ydb1240] (through the original gld) : ^c's contents must have survived the sweep's moves"
setenv gtmgbldir "$orig_gbldir"
$ydb_dist/yottadb -run verifyc^ydb1240

echo
echo "# Stage D : a region ALL of whose globals are hidden"
echo "#"
echo "# Create 3reg.gld : a copy of 2reg.gld plus the name x also mapped to AREG; every name in region"
echo "# DEFAULT's directory tree (a, b, c and x) is now hidden"
cp 2reg.gld 3reg.gld
setenv gtmgbldir 3reg.gld
cat > 3reg.gde << gde_eof
add -name x -region=AREG
exit
gde_eof
$GDE_SAFE @3reg.gde >&! gde_3reg.out
if (0 != $status) then
	echo "FAIL: GDE could not create 3reg.gld"
	echo "# ----- gde_3reg.out -----"
	cat gde_3reg.out
endif
echo "# Run [initx^ydb1240] (through the original gld) : regrow and kill ^x so a truncate has work to do"
setenv gtmgbldir "$orig_gbldir"
$ydb_dist/yottadb -run initx^ydb1240
setenv gtmgbldir 3reg.gld
echo "# Run [mupip reorg -truncate -reg DEFAULT] : a build without the YDB#1240 fix selects nothing here"
echo "# (every name is hidden) and errors out with a NOSELECT message; expect all four hidden globals"
echo "# processed and the file truncated instead"
$MUPIP reorg -truncate -reg DEFAULT >&! truncate_all_hidden.out
echo -n "NOSELECT errors : "
grep -c "NOSELECT" truncate_all_hidden.out
echo -n "Hidden globals processed : "
grep -c "^Global: . (region DEFAULT)" truncate_all_hidden.out
grep -q "Truncated region: DEFAULT" truncate_all_hidden.out
if (0 != $status) then
	echo "FAIL: the all-hidden reorg -truncate did not truncate region DEFAULT"
	echo "# ----- truncate_all_hidden.out -----"
	cat truncate_all_hidden.out
else
	$tst_awk -f $gtm_tst/r208/inref/trunc_bounds-ydb1240.awk truncate_all_hidden.out
endif

echo
echo "# Stage E : -EXCLUDE and hidden globals"
echo "#"
echo "# The -EXCLUDE list is built through the gld too ([gv_select]): a name that does not exist anywhere"
echo "# per the gld produces an EMPTY exclude list (a NOEXCLUDE message), so excluding a hidden global by"
echo "# name only works if the name also exists somewhere per the gld. Once the exclude list is non-empty,"
echo "# the exclusion check itself is name-based and applies to hidden globals like any other. Both"
echo "# behaviors are pre-existing -EXCLUDE semantics; this stage pins them down for hidden globals."
echo
echo "# Run [mupip reorg -truncate -exclude=b -reg DEFAULT] : the gld (3reg.gld) maps [b] to region AREG"
echo "# where no ^b exists, so expect a NOEXCLUDE message and the hidden ^b processed anyway"
$MUPIP reorg -truncate -exclude=b -reg DEFAULT >&! truncate_exclude_hidden.out
echo -n "NOEXCLUDE messages : "
grep -c "NOEXCLUDE" truncate_exclude_hidden.out
echo -n "Hidden global ^b processed despite -exclude=b : "
grep -c "^Global: b (region DEFAULT)" truncate_exclude_hidden.out
echo -n "EXCLUDEREORG messages : "
grep -c "EXCLUDEREORG" truncate_exclude_hidden.out
echo
echo "# Run [initbareg^ydb1240] (through 3reg.gld) : create ^b in region AREG, so the name [b] now exists"
echo "# per the gld and -EXCLUDE=b builds a non-empty exclude list"
$ydb_dist/yottadb -run initbareg^ydb1240
echo "# Rerun [mupip reorg -truncate -exclude=b -reg DEFAULT] : the exclusion check is name-based, so the"
echo "# hidden ^b in region DEFAULT is now excluded (an EXCLUDEREORG message) and the reorg ends with a"
echo "# REORGINC warning, the standard outcome whenever a selected global is excluded"
$MUPIP reorg -truncate -exclude=b -reg DEFAULT >&! truncate_exclude_visible.out
# This reorg is EXPECTED to produce the EXCLUDEREORG and REORGINC warnings. Verify they are present (the
# matched messages become part of the reference file) and filter exactly them out of the .out file, so the
# test framework's error scan (com/errors.csh) still catches any OTHER error/warning that shows up in it.
$gtm_tst/com/check_error_exist.csh truncate_exclude_visible.out EXCLUDEREORG REORGINC

echo
echo "# Stage F : a plain reorg (no -TRUNCATE) processes hidden globals too"
echo "#"
echo "# Run [mupip reorg -reg DEFAULT] : all four names in region DEFAULT's directory tree are hidden by"
echo "# 3reg.gld, so a build that invokes the hidden global selection only for -TRUNCATE selects nothing"
echo "# here (a NOSELECT error); expect all four processed instead, exactly as with -TRUNCATE in stage D"
$MUPIP reorg -reg DEFAULT >&! plain_reorg_hidden.out
echo -n "NOSELECT errors : "
grep -c "NOSELECT" plain_reorg_hidden.out
echo -n "Hidden globals processed : "
grep -c "^Global: . (region DEFAULT)" plain_reorg_hidden.out
echo "# Run [verifyb^ydb1240] and [verifyc^ydb1240] (through the original gld) : ^b and ^c must have"
echo "# survived the plain reorg intact"
setenv gtmgbldir "$orig_gbldir"
$ydb_dist/yottadb -run verifyb^ydb1240
$ydb_dist/yottadb -run verifyc^ydb1240
echo
echo "# Run [mupip reorg] (no -REGION at all, still through 3reg.gld) : the gld-visible ^b in region AREG"
echo "# and the hidden ^b in region DEFAULT are different globals with the same name; expect BOTH processed,"
echo "# each in its own region"
setenv gtmgbldir 3reg.gld
$MUPIP reorg >&! plain_reorg_all.out
echo -n "^b processed in region AREG (gld-visible) : "
grep -c "^Global: b (region AREG)" plain_reorg_all.out
echo -n "^b processed in region DEFAULT (hidden) : "
grep -c "^Global: b (region DEFAULT)" plain_reorg_all.out

setenv gtmgbldir "$orig_gbldir"
$gtm_tst/com/dbcheck.csh
