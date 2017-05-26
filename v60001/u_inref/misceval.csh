#!/usr/local/bin/tcsh -f
$gtm_tst/com/dbcreate.csh mumps 1
#
# Run 1
setenv gtm_side_effects 0
setenv gtm_boolean 0
$gtm_dist/mumps -run misceval
mv misceval.o misceval.o.1
# Run 2
setenv gtm_side_effects 0
setenv gtm_boolean 1
$gtm_dist/mumps -run misceval
mv misceval.o misceval.o.2
# Run 3
setenv gtm_side_effects 1
setenv gtm_boolean 0
$gtm_dist/mumps -run misceval
mv misceval.o misceval.o.3
# Run 4
setenv gtm_side_effects 1
setenv gtm_boolean 1
$gtm_dist/mumps -run misceval
mv misceval.o misceval.o.4
#
echo ""
$gtm_tst/com/dbcheck.csh
