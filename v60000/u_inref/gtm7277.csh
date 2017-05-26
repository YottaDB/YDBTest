#!/usr/local/bin/tcsh -f
#
# Generate boolean expressions, test with gtm_boolean=0 and 1
#
$gtm_tst/com/dbcreate.csh .

#
# Make sure $gtmdbglvl is off for compiles (takes WAY too long - over 5hrs on snail) but can be on for runs
#
if ($?gtmdbglvl) then
	set gtmdbglvlsave = "$gtmdbglvl"
endif

# Generator always runs no-bool
unsetenv gtm_side_effects		# might otherwise subvert the intention of this test
unsetenv gtm_boolean
$gtm_dist/mumps -run boolgen
if ($status == 1) then
    echo "Run of boolgen.m failed"
    exit 1
endif
# First run is normal shortcutting - no boolean
echo "Compiling btest.m with gtm_boolean=0"
if ($?gtmdbglvlsave) unsetenv gtmdbglvl
$gtm_dist/mumps btest.m
if ($status != 0) then
    echo "Compile of normal boolean btest.m failed"
    exit 1
endif
echo "Running btest.m with gtm_boolean=0"
if ($?gtmdbglvlsave) then
	setenv gtmdbglvl "$gtmdbglvlsave"
endif
$gtm_dist/mumps -run btest > btest_output_bool0.txt
if ($status != 0) then
    echo "Run of normal boolean btest.m failed"
    exit 1
endif
mv btest.o btest-nonbool.o   # Allows comparison of bool-0 object file with bool-1
# Compile with boolean now
echo "Compiling btest.m with gtm_boolean=1"
setenv gtm_boolean 1
if ($?gtmdbglvlsave) unsetenv gtmdbglvl
$gtm_dist/mumps btest.m
if ($status != 0) then
    echo "Compile of full boolean btest.m failed"
    exit 1
endif
echo "Running btest.m with gtm_boolean=1"
if ($?gtmdbglvlsave) then
	setenv gtmdbglvl "$gtmdbglvlsave"
endif
$gtm_dist/mumps -run btest > btest_output_bool1.txt
if ($status != 0) then
    echo "Run of full boolean btest.m failed"
    exit 1
endif
unsetenv gtm_boolean
# Compare output files in detail to isolate broken expressions if any
$gtm_dist/mumps -run boolcomp
# Quick double check of database coherency.
$gtm_tst/com/dbcheck.csh
