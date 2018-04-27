#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2014-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# We do not want autorelink-enabled directories that have been randomly assigned by the test system because we are explicitly
# testing the autorelink functionality, as opposed to the rest of the test system which may be testing it implicitly.
source $gtm_tst/com/gtm_test_disable_autorelink.csh

set save_gtmroutines = "$gtmroutines"

$gtm_tst/com/dbcreate.csh mumps
echo

cat > y.m <<EOF
	write "version 1",!
EOF

$gtm_dist/mumps y.m

echo "# Relative pathname to ZLINK."
$gtm_dist/mumps -run %XCMD 'set $zroutines=".*(.)" zlink "y.o" do ^y'
echo

echo "# Absolute pathname to ZLINK."
$gtm_dist/mumps -run %XCMD 'set $zroutines=".*(.)" zlink "$PWD/y.o" do ^y'
echo

echo "# Invalid ZLINK argument."
$gtm_dist/mumps -run %XCMD 'zlink "y^1" do ^y'
echo

echo "# Non-existent non-autorelink directories with argumentless MUPIP RCTLDUMP."
setenv gtmroutines "a b $save_gtmroutines"
$gtm_dist/mupip rctldump
echo

echo "# Non-existent autorelink directories with argumentless MUPIP RCTLDUMP."
setenv gtmroutines "a* b* $save_gtmroutines"
$gtm_dist/mupip rctldump
echo

echo "# Non-existent directory as an argument to MUPIP RCTLDUMP."
setenv gtmroutines "$save_gtmroutines"
$gtm_dist/mupip rctldump a
echo

echo "# Non-existent directories as arguments to MUPIP RCTLDUMP."
$gtm_dist/mupip rctldump a b
echo

echo "# Existing directories as arguments to MUPIP RCTLDUMP."
mkdir a b
$gtm_dist/mupip rctldump a b
echo

echo "# Existing directories with relinkctl stuff as arguments to MUPIP RCTLDUMP."
$gtm_dist/mumps -run %XCMD 'set $zroutines="a* b*" zsystem "$gtm_dist/mupip rctldump a b"'
echo

echo "# Existing directory with relinkctl stuff as an argument to MUPIP RCTLDUMP."
$gtm_dist/mumps -run %XCMD 'set $zroutines="a*" zsystem "$gtm_dist/mupip rctldump a"'
echo

echo "# Existing directory with relinkctl stuff as an argument (including a . path modifier) to MUPIP RCTLDUMP."
$gtm_dist/mumps -run %XCMD 'set $zroutines="a*" zsystem "$gtm_dist/mupip rctldump ./a"'
echo

echo "# Existing directory with relinkctl stuff as an argument (including a .. path modifier) to MUPIP RCTLDUMP."
set cur_dir = `pwd`
set cur_dir = ${cur_dir:t}
$gtm_dist/mumps -run %XCMD 'set $zroutines="a*" zsystem "$gtm_dist/mupip rctldump ../'$cur_dir'/a"'
echo

echo "# Existing directory with relinkctl stuff as an argument (as an absolute path) to MUPIP RCTLDUMP."
set cur_dir = `pwd`
$gtm_dist/mumps -run %XCMD 'set $zroutines="a*" zsystem "$gtm_dist/mupip rctldump '$cur_dir'/a"'
echo

echo 'Recursive relink of the invoked routine not in $gtmroutines (with no autorelink directories).'
cat > rtn1.m <<eof
rtn1
 view "link":"recursive"
 set \$zroutines="dir"
 do ^rtn2
 quit
cb
 quit
eof

cat > rtn2.m <<eof
rtn2
 do cb^rtn1
 quit
eof

mkdir dir
mv rtn2.m dir

setenv gtmroutines "."
$gtm_dist/mumps -run rtn1
echo

rm *.o dir/*.o

echo 'Recursive relink of the invoked routine not in $gtmroutines (with an autorelink directory).'
# When making a directory autorelink-enabled, one must be able to autorelink routines as needed. So, if the current $ZROUTINEs does not contain the
# entries needed to locate the routine needing to be autorelinked, the autorelink cannot happen, thus causing the ZLINK error.
setenv gtmroutines ".*"
$gtm_dist/mumps -run rtn1
echo

echo "Implicit relink of a statically linked routine whose source has not changed but object has (due to different compilation options)."
cat > rtn.csh <<eof
#!/usr/local/bin/tcsh -f
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_boolean gtm_boolean 1
cp -p rtn.o rtn.o.orig
$gtm_dist/mumps rtn.m
$gtm_dist/mumps -direct << GTM_EOF
zrupdate "rtn.o"
GTM_EOF
eof

chmod 755 rtn.csh

cat > rtn.m <<eof
rtn
 set \$zroutines=".*(.)"
 view "LINK":"RECURSIVE"
 write 0&(\$incr(x)),!
 zwrite
 if +\$incr(cnt)<2 zsystem "rtn.csh" do ^rtn
 quit
eof

setenv gtmroutines "$save_gtmroutines"

# These environment variables are modified in the following test, so we want to start with a "vanilla" state.
unsetenv gtm_side_effects
source $gtm_tst/com/unset_ydb_env_var.csh ydb_boolean gtm_boolean

# Because rtn itself is linked from a non-autorelink-enabled directory, no relink will follow the ZRUPDATE.
$gtm_dist/mumps -run rtn
mv rtn.o rtn.o.1
mv rtn.o.orig rtn.o.orig.1
echo

echo "Implicit relink of an autorelinked routine whose source has not changed but object has (due to different compilation options)."
setenv gtmroutines ".* $save_gtmroutines"
# This time rtn is linked from an autorelink-enabled directory, so ZRUPDATE should cause a relink with $ydb_boolean/$gtm_boolean.
$gtm_dist/mumps -run rtn
mv rtn.o rtn.o.2
mv rtn.o.orig rtn.o.orig.2
echo

echo "Multiple arguments to ZRUPDATE:"
mkdir someDir
touch someRtn.o someDir/someRtn.o

# All valid and existing files.
echo ' a. ZRUPDATE "someRtn.o","someDir/someRtn.o"'
$gtm_dist/mumps -run %XCMD 'zrupdate "someRtn.o","someDir/someRtn.o" zshow "A"'
echo

# All valid and some existing files.
echo ' b. ZRUPDATE "otherRtn.o","someDir/someRtn.o","someDir/otherRtn.o","someRtn.o"'
$gtm_dist/mumps -run %XCMD 'zrupdate "otherRtn.o","someDir/someRtn.o","someDir/otherRtn.o","someRtn.o" zshow "A"'
echo

# All valid and no existing files.
echo ' c. ZRUPDATE "otherRtn.o","someDir/otherRtn.o"'
$gtm_dist/mumps -run %XCMD 'zrupdate "otherRtn.o","someDir/otherRtn.o" zshow "A"'
echo

# Duplicate valid files.
echo ' d. ZRUPDATE "someRtn.o","someDir/someRtn.o","someRtn.o","someDir/someRtn.o"'
$gtm_dist/mumps -run %XCMD 'zrupdate "someRtn.o","someDir/someRtn.o","someRtn.o","someDir/someRtn.o" zshow "A"'
echo

# Some invalid and some valid and existing files.
echo ' e. ZRUPDATE "someRtn.o","someRtn.m","someDir/otherRtn.o","someDir/%someRtn.o"'
$gtm_dist/mumps -run %XCMD 'zrupdate "someRtn.o","someRtn.m","someDir/otherRtn.o","someDir/%someRtn.o" zshow "A"'
echo

# Some invalid and some invalid and non-existent files.
echo ' f. ZRUPDATE "someRtn.m","someDir/otherRtn.o","someDir/%someRtn.o"'
$gtm_dist/mumps -run %XCMD 'zrupdate "someRtn.m","someDir/otherRtn.o","someDir/%someRtn.o" zshow "A"'
echo

# Valid patterns with wildcards.
echo ' g. ZRUPDATE "*some*.o","some*/*"'
$gtm_dist/mumps -run %XCMD 'zrupdate "*some*.o","some*/*" zshow "A"'
echo

# Invalid patterns with wildcards.
echo ' h. ZRUPDATE "other*","*/*.m"'
$gtm_dist/mumps -run %XCMD 'zrupdate "other*","*/*.m" zshow "A"'
echo

echo 'Static link of a routine from a directory following a starred directory in $zroutines.'
setenv gtmroutines "$save_gtmroutines"
mkdir dir1 dir2
touch dir2/abcd.m
# Although the starred directory is preceded by a non-starred one, no relinkctl records should be
# created for the latter.
$gtm_dist/mumps -run %XCMD 'set $zroutines="dir1* dir2" do ^abcd zshow "a"'
echo

echo "Check the concurrent versions of the same routine in rtnobj shared memory."

mkdir objXDS srcBKH srcSJA
echo 'rtnWEH(x) set (text,x)="rtnWEH 1" quit:$quit x quit' > srcBKH/rtnWEH.m
echo 'rtnWEH(x) set (text,x)="rtnWEH 2" quit:$quit x quit' > srcSJA/rtnWEH.m

# Refer to the M script for details.
$gtm_dist/mumps -run procA^numver

echo "Process B has compiled and linked a different version of routine and recompiled the original:"
cat rctldump-1.log
echo

echo "Process A has executed the originally linked version of the routine:"
cat rctldump-2.log
echo

echo "Process C has executed the currently available routine:"
cat rctldump-3.log
echo

echo "Process A has also executed the currently available routine:"
cat rctldump-4.log
echo

echo 'Duplicate entries in $gtmroutines.'
mkdir dirA dirB
cp y.m dirA
setenv gtmroutines "dirA* dirB dirA* $save_gtmroutines"
$gtm_dist/mumps -run %XCMD 'do ^y zshow "A"'
echo
$gtm_dist/mumps -run %XCMD 'zrupdate "dirA/y.o" zshow "A"'
echo

echo 'Duplicate entries in $zroutines.'
setenv gtmroutines "$save_gtmroutines"
$gtm_dist/mumps -run %XCMD 'set $zroutines="dirA* dirB dirA*" do ^y zshow "A"'
echo
$gtm_dist/mumps -run %XCMD 'set $zroutines="dirA* dirB dirA*" zrupdate "dirA/y.o" zshow "A"'
echo

echo 'Environment variables in $zroutines.'
setenv cur_dir	`pwd`
setenv A_dir	"dirA"
setenv A_char	"A"
$gtm_dist/mumps -run %XCMD 'set $zroutines="$cur_dir*" zshow "A"'
echo
$gtm_dist/mumps -run %XCMD 'set $zroutines="$cur_dir/$A_dir*" zshow "A"'
echo
$gtm_dist/mumps -run %XCMD 'set $zroutines="$cur_dir/dir$A_char*" zshow "A"'
echo

echo 'NORECURSIVE overrides autorelink for routines on M-stack.'
setenv gtmroutines ".*"
cat > x.m <<eof
 quit:(\$zlevel>1)
 write "\$zlevel = ",\$zlevel," : Entering : Version 0",!
 set \$zroutines=".*"
 zsystem "cp x1.m x.m"
 zcompile "x.m"
 zrupdate "x.o"
 do ^x
 quit
eof
cat > x1.m <<eof
 write "\$zlevel = ",\$zlevel," : Entering : Version 1",!
 quit
eof
$gtm_dist/mumps -run x
echo

setenv gtmroutines "$save_gtmroutines"

$gtm_tst/com/dbcheck.csh
