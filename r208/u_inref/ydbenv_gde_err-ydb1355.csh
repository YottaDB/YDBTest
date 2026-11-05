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

echo "#--------------------------------------------------------------------------------------------------#"
echo "# [YDB#1355] ydb_env_set reports GDE command errors instead of silently skipping the bad command    #"
echo "#--------------------------------------------------------------------------------------------------#"
echo

# GDE reports an error in a command (e.g. %GDE-E-KEYWRDBAD) on stdout, not stderr, and still creates or
# updates the global directory without the rejected change. When it reaches the end of its input without
# an EXIT command, as it does when reading gdedefaults, it also exits with a zero status. %YDBENV checked
# only GDE's stderr when creating an environment, and nothing at all when creating the YDBAIM, YDBJNLF and
# YDBOCTO regions in an existing environment (CreateRegion), so a bad command in a user's ./gdedefaults
# was silently skipped. With the fix, %YDBENV checks both stdout and stderr, as well as the exit status:
# - when creating an environment, it deletes the global directory GDE created and issues GLDCREATEERR
#   (exit status 238);
# - in CreateRegion, it restores the global directory as it was before running GDE and issues GDEERR
#   (exit status 236). CreateRegion now also uses ./gdedefaults, if it has commands for the region.
#
# ydb_env_set has to be SOURCED from a POSIX shell, so each stage runs it through the sh script
# ydbenv_gde_err-ydb1355.sh. Its output holds absolute path names, which do not belong in a reference
# file, so the stages assert against the output and name the file instead of displaying it.
#
# When it reports an error, ydb_env_set leaves its temporary directory (named in its "Error file is at"
# line) in place, with the GDE stdout and stderr files. The stages that expect an error check that
# directory and then remove it, as it is outside the subtest directory.

set setsh = "$gtm_tst/$tst/u_inref/ydbenv_gde_err-ydb1355.sh"
cp $gtm_tst/$tst/inref/ydb1355.m .
set gdedefaults = $gtm_dist/gdedefaults
set ydbdir = $cwd/ydbdir

echo '# Stage 1 : create an environment with a ./gdedefaults that has a command with a bad qualifier'
echo '# Command : sh ydbenv_gde_err-ydb1355.sh $cwd/stage1/ydbdir, in directory stage1 with a ./gdedefaults whose'
echo '#           DEFAULT section has "change -region default -null_subscripts=always -bogus_qualifier=1"'
echo '# Before the fix : exit status 0, and an environment whose DEFAULT region does not have null subscripts'
echo '# With the fix   : exit status 238 (GLDCREATEERR) naming %GDE-E-KEYWRDBAD, and no environment'
mkdir stage1
$tst_awk '/^! DEFAULT end/{print "change -region default -null_subscripts=always -bogus_qualifier=1"} {print}' $gdedefaults >&! stage1/gdedefaults
set stage1dir = $cwd/stage1/ydbdir
(cd stage1 && sh $setsh $stage1dir >&! ../stage1.out)
set act = `$tst_awk '/^Exit status = /{print $4}' stage1.out`
if ("$act" == "238") then
	echo "PASS : exit status 238, which is the U238 GLDCREATEERR error"
else
	echo "FAIL : expected exit status 238, got [$act] - see stage1.out"
endif
if (0 != `$grep -c -E 'YDBENV-F-GLDCREATEERR.*%GDE-E-KEYWRDBAD' stage1.out`) then
	echo "PASS : GLDCREATEERR names %GDE-E-KEYWRDBAD"
else
	echo "FAIL : GLDCREATEERR does not name %GDE-E-KEYWRDBAD - see stage1.out (stage1.outx if stage 8 passed)"
endif
set act = `find stage1/ydbdir -name '*.gld' | wc -l`
if ("$act" == "0") then
	echo "PASS : no global directory"
else
	echo "FAIL : expected no global directory, got $act :"
	find stage1/ydbdir -name '*.gld'
endif
set act = `find stage1/ydbdir -name '*.dat' | wc -l`
if ("$act" == "0") then
	echo "PASS : no database file"
else
	echo "FAIL : expected no database file, got $act - see [find stage1/ydbdir -name '*.dat']"
endif
set errdir = `$tst_awk '/^Error file is at /{sub("/err$","",$5); print $5}' stage1.out`
# tcsh does the `` substitutions of an if before evaluating its condition, so the grep is in a separate if
set act = 0
if ("$errdir" =~ */ydb_env_*) set act = `$grep -c '%GDE-E-KEYWRDBAD' $errdir/CreateEnv.out`
if (0 != $act) then
	echo "PASS : the GDE stdout file of ydb_env_set has %GDE-E-KEYWRDBAD"
else
	echo "FAIL : the GDE stdout file [$errdir/CreateEnv.out] does not have %GDE-E-KEYWRDBAD"
endif
if ("$errdir" =~ */ydb_env_*) rm -rf $errdir
echo

echo '# Stage 2 : create an environment with a valid ./gdedefaults'
echo '# Command : sh ydbenv_gde_err-ydb1355.sh $cwd/ydbdir, in directory stage2 with a ./gdedefaults whose'
echo '#           DEFAULT section has "change -region default -null_subscripts=always"'
echo '# Expect : exit status 0, no error message, and a DEFAULT region with null subscripts'
mkdir stage2
$tst_awk '/^! DEFAULT end/{print "change -region default -null_subscripts=always"} {print}' $gdedefaults >&! stage2/gdedefaults
(cd stage2 && sh $setsh $ydbdir >&! ../stage2.out)
set act = `$tst_awk '/^Exit status = /{print $4}' stage2.out`
if ("$act" == "0") then
	echo "PASS : exit status 0"
else
	echo "FAIL : expected exit status 0, got [$act] - see stage2.out"
endif
set act = `$grep -c -E '%YDB(ENV)?-[EF]-' stage2.out`
if ("$act" == "0") then
	echo "PASS : no error message was reported"
else
	echo "FAIL : expected 0 error messages, got $act - see stage2.out"
endif
# The path of the global directory, $ydb_dir/$ydb_rel/g/yottadb.gld, depends on the YottaDB release, so take
# it from the $ydb_gbldir that ydb_env_set set. The database files of the environment are in the same directory.
set gld = `$tst_awk '/^ydb_gbldir = /{print $3}' stage2.out`
set gdir = $gld:h
if ("$gld" == "$ydbdir/$gld:h:h:t/g/yottadb.gld") then
	echo 'PASS : ydb_gbldir is $ydb_dir/$ydb_rel/g/yottadb.gld'
else
	echo 'FAIL : ydb_gbldir is ['"$gld"'], not $ydb_dir/$ydb_rel/g/yottadb.gld - see stage2.out'
endif
echo '# Command : $gtm_dist/mumps -run show^ydb1355 DEFAULT'
env ydb_gbldir=$gld $gtm_dist/mumps -run show^ydb1355 DEFAULT < /dev/null
echo

echo '# Stage 3 : source ydb_env_set again for the existing environment, which runs GDE to upgrade the global directory if needed'
echo '# Command : sh ydbenv_gde_err-ydb1355.sh $cwd/ydbdir, in directory stage2'
echo '# Expect : exit status 0 and no error message, i.e., no error is reported when GDE reports none'
(cd stage2 && sh $setsh $ydbdir >&! ../stage3.out)
set act = `$tst_awk '/^Exit status = /{print $4}' stage3.out`
if ("$act" == "0") then
	echo "PASS : exit status 0"
else
	echo "FAIL : expected exit status 0, got [$act] - see stage3.out"
endif
set act = `$grep -c -E '%YDB(ENV)?-[EF]-' stage3.out`
if ("$act" == "0") then
	echo "PASS : no error message was reported"
else
	echo "FAIL : expected 0 error messages, got $act - see stage3.out"
endif
echo

# The remaining stages remove the YDBOCTO region from the environment, so that sourcing ydb_env_set runs
# CreateRegion to create it. The GDE commands that remove it are generated from the "add -name" commands
# for the YDBOCTO region in $gtm_dist/gdedefaults, so that they track that file.
$tst_awk '/^add -name .* -region=ydbocto$/{print "delete -name", $3}' $gdedefaults >&! noocto.gde
echo "delete -region ydbocto" >>&! noocto.gde
echo "delete -segment ydbocto" >>&! noocto.gde

echo '# Stage 4 : CreateRegion of YDBOCTO when a name it adds already exists, using $ydb_dist/gdedefaults'
echo '# Command : remove the YDBOCTO region; map %ydbocto* to the YDBAIM region;'
echo '#           sh ydbenv_gde_err-ydb1355.sh $cwd/ydbdir, in directory stage4, which has no ./gdedefaults'
echo '# Before the fix : exit status 0, and a YDBOCTO region without the %ydbocto* name'
echo '# With the fix   : exit status 236 (GDEERR) naming %GDE-E-OBJDUP, and the global directory unchanged'
env ydb_gbldir=$gld $gtm_dist/mumps -run GDE < noocto.gde >&! stage4_noocto_gde.out
rm -f $gdir/%ydbocto.*
echo "add -name %ydbocto* -region=ydbaim" | env ydb_gbldir=$gld $gtm_dist/mumps -run GDE >&! stage4_addname_gde.out
cp $gld stage4_before.gld
mkdir stage4
(cd stage4 && sh $setsh $ydbdir >&! ../stage4.out)
set act = `$tst_awk '/^Exit status = /{print $4}' stage4.out`
if ("$act" == "236") then
	echo "PASS : exit status 236, which is the U236 GDEERR error"
else
	echo "FAIL : expected exit status 236, got [$act] - see stage4.out"
endif
if (0 != `$grep -c -E 'YDBENV-F-GDEERR.*%GDE-E-OBJDUP.* when creating region YDBOCTO' stage4.out`) then
	echo "PASS : GDEERR names %GDE-E-OBJDUP when creating region YDBOCTO"
else
	echo "FAIL : GDEERR does not name %GDE-E-OBJDUP when creating region YDBOCTO - see stage4.out (stage4.outx if stage 8 passed)"
endif
cmp -s $gld stage4_before.gld
if (0 == $status) then
	echo "PASS : the global directory is unchanged"
else
	echo "FAIL : the global directory changed - compare $gld with stage4_before.gld"
endif
set errdir = `$tst_awk '/^Error file is at /{sub("/err$","",$5); print $5}' stage4.out`
# tcsh does the `` substitutions of an if before evaluating its condition, so the grep is in a separate if
set act = 0
if ("$errdir" =~ */ydb_env_*) set act = `$grep -c '%GDE-E-OBJDUP' $errdir/GDE_YDBOCTO.out`
if (0 != $act) then
	echo "PASS : the GDE stdout file of ydb_env_set has %GDE-E-OBJDUP"
else
	echo "FAIL : the GDE stdout file [$errdir/GDE_YDBOCTO.out] does not have %GDE-E-OBJDUP"
endif
if ("$errdir" =~ */ydb_env_*) rm -rf $errdir
echo '# Command : $gtm_dist/mumps -run show^ydb1355 YDBOCTO'
env ydb_gbldir=$gld $gtm_dist/mumps -run show^ydb1355 YDBOCTO < /dev/null
echo

echo '# Stage 5 : CreateRegion of YDBOCTO with a ./gdedefaults whose YDBOCTO section has a command with a bad qualifier'
echo '# Command : remove the %ydbocto* name; sh ydbenv_gde_err-ydb1355.sh $cwd/ydbdir, in directory stage5'
echo '#           with a ./gdedefaults whose YDBOCTO section has "change -region ydbocto -bogus_qualifier=1"'
echo '# Before the fix : exit status 0, and a YDBOCTO region created from $ydb_dist/gdedefaults, as ./gdedefaults was not used'
echo '# With the fix   : exit status 236 (GDEERR) naming %GDE-E-KEYWRDBAD, and the global directory unchanged'
echo "delete -name %ydbocto*" | env ydb_gbldir=$gld $gtm_dist/mumps -run GDE >&! stage5_delname_gde.out
cp $gld stage5_before.gld
mkdir stage5
$tst_awk '/^! YDBOCTO end/{print "change -region ydbocto -bogus_qualifier=1"} {print}' $gdedefaults >&! stage5/gdedefaults
(cd stage5 && sh $setsh $ydbdir >&! ../stage5.out)
set act = `$tst_awk '/^Exit status = /{print $4}' stage5.out`
if ("$act" == "236") then
	echo "PASS : exit status 236, which is the U236 GDEERR error"
else
	echo "FAIL : expected exit status 236, got [$act] - see stage5.out"
endif
if (0 != `$grep -c -E 'YDBENV-F-GDEERR.*%GDE-E-KEYWRDBAD.* when creating region YDBOCTO' stage5.out`) then
	echo "PASS : GDEERR names %GDE-E-KEYWRDBAD when creating region YDBOCTO"
else
	echo "FAIL : GDEERR does not name %GDE-E-KEYWRDBAD when creating region YDBOCTO - see stage5.out (stage5.outx if stage 8 passed)"
endif
cmp -s $gld stage5_before.gld
if (0 == $status) then
	echo "PASS : the global directory is unchanged"
else
	echo "FAIL : the global directory changed - compare $gld with stage5_before.gld"
endif
set act = `find $ydbdir -name '%ydbocto.*' | wc -l`
if ("$act" == "0") then
	echo "PASS : no YDBOCTO database or journal file"
else
	echo "FAIL : expected no YDBOCTO database or journal file, got $act :"
	find $ydbdir -name '%ydbocto.*'
endif
set errdir = `$tst_awk '/^Error file is at /{sub("/err$","",$5); print $5}' stage5.out`
if ("$errdir" =~ */ydb_env_*) rm -rf $errdir
echo '# Command : $gtm_dist/mumps -run show^ydb1355 YDBOCTO'
env ydb_gbldir=$gld $gtm_dist/mumps -run show^ydb1355 YDBOCTO < /dev/null
echo

echo '# Stage 6 : CreateRegion of YDBOCTO with a ./gdedefaults whose YDBOCTO section gives a key size of 500'
echo '# Command : sh ydbenv_gde_err-ydb1355.sh $cwd/ydbdir, in directory stage6 with a ./gdedefaults whose'
echo '#           YDBOCTO section has -key_size=500 in place of -key_size=1019'
echo '# Before the fix : a YDBOCTO region with a key size of 1019, from $ydb_dist/gdedefaults'
echo '# With the fix   : exit status 0, no error message, and a YDBOCTO region with a key size of 500'
mkdir stage6
$tst_awk '/^! YDBOCTO begin/{inocto=1} /^! YDBOCTO end/{inocto=0} {if (inocto) sub("-key_size=1019","-key_size=500"); print}' $gdedefaults >&! stage6/gdedefaults
(cd stage6 && sh $setsh $ydbdir >&! ../stage6.out)
set act = `$tst_awk '/^Exit status = /{print $4}' stage6.out`
if ("$act" == "0") then
	echo "PASS : exit status 0"
else
	echo "FAIL : expected exit status 0, got [$act] - see stage6.out"
endif
set act = `$grep -c -E '%YDB(ENV)?-[EF]-' stage6.out`
if ("$act" == "0") then
	echo "PASS : no error message was reported"
else
	echo "FAIL : expected 0 error messages, got $act - see stage6.out"
endif
if (-e $gdir/%ydbocto.dat) then
	echo "PASS : the YDBOCTO database file exists"
else
	echo "FAIL : the YDBOCTO database file $gdir/%ydbocto.dat does not exist"
endif
echo '# Command : $gtm_dist/mumps -run show^ydb1355 YDBOCTO'
env ydb_gbldir=$gld $gtm_dist/mumps -run show^ydb1355 YDBOCTO < /dev/null
echo

echo '# Stage 7 : CreateRegion of YDBOCTO with a ./gdedefaults that has no "! <region> begin" and "! <region> end" lines'
echo '# Command : remove the YDBOCTO region; sh ydbenv_gde_err-ydb1355.sh $cwd/ydbdir, in directory stage7 with'
echo '#           a ./gdedefaults that is $ydb_dist/gdedefaults without its comment lines'
echo '# Expect : exit status 0, no error message, and a YDBOCTO region created from $ydb_dist/gdedefaults (key size 1019)'
env ydb_gbldir=$gld $gtm_dist/mumps -run GDE < noocto.gde >&! stage7_noocto_gde.out
rm -f $gdir/%ydbocto.*
mkdir stage7
$grep -v '^!' $gdedefaults >&! stage7/gdedefaults
(cd stage7 && sh $setsh $ydbdir >&! ../stage7.out)
set act = `$tst_awk '/^Exit status = /{print $4}' stage7.out`
if ("$act" == "0") then
	echo "PASS : exit status 0"
else
	echo "FAIL : expected exit status 0, got [$act] - see stage7.out"
endif
set act = `$grep -c -E '%YDB(ENV)?-[EF]-' stage7.out`
if ("$act" == "0") then
	echo "PASS : no error message was reported"
else
	echo "FAIL : expected 0 error messages, got $act - see stage7.out"
endif
echo '# Command : $gtm_dist/mumps -run show^ydb1355 YDBOCTO'
env ydb_gbldir=$gld $gtm_dist/mumps -run show^ydb1355 YDBOCTO < /dev/null
echo

echo "# Stage 8 : declare the errors stages 1, 4 and 5 provoked, so the framework error scan expects them"
echo '# Command : $gtm_tst/com/check_error_exist.csh stage<N>.out <GLDCREATEERR|GDEERR> SETECODE'
# Without this, com/errors.csh finds the GLDCREATEERR or GDEERR that the stages asked for, plus the SETECODE
# in the $ZSTATUS line the %YDBENV error trap writes beside it, and fails the subtest on errors it was written
# to produce. The output of check_error_exist.csh quotes the lines it matched, which carry absolute path names
# and the error text being declared, so it goes to a .logx file, which errors.csh does not scan.
foreach stage (stage1 stage4 stage5)
	set err = GDEERR
	if ("stage1" == "$stage") set err = GLDCREATEERR
	$gtm_tst/com/check_error_exist.csh $stage.out $err SETECODE >&! $stage-check_error.logx
	set act = $status
	if ("$act" == "0") then
		echo "PASS : $err and SETECODE in $stage.out are now declared expected"
	else
		echo "FAIL : check_error_exist.csh returned $act for $stage.out - see $stage-check_error.logx"
	endif
end

echo
echo "# Done"
