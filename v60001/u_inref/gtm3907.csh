#!/usr/local/bin/tcsh -f
#
# Test side effect expressions with $gtm_side_effects 1 (or 2)
#
$gtm_tst/com/dbcreate.csh mumps 1
setenv gtm_side_effects 2		# turn on compiler warnings
$gtm_dist/mumps -run gtm3907		# first a basic test
setenv gtm_side_effects 1		# turn off warnings - they would be overwhelming
unsetenv gtmdbglvl			# just too heavyweight for regular use with big compiles
$gtm_dist/mumps -run opevalord		# now random cases of non-Boolean binary operators
if ($status == 1) then
    echo "Run of opevalord.m or opevalordtst.m failed"
endif
$gtm_dist/mumps -run funcevalord	# now random cases of multi-argument functions
if ($status == 1) then
    echo "Run of funcevalord.m or fncevlordtst.m failed"
endif
$gtm_tst/com/dbcheck.csh
