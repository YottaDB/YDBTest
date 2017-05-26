#!/usr/local/bin/tcsh -f

$gtm_tst/com/dbcreate.csh mumps 4 # creates a database with max key size = 64

echo
$echoline
echo "Increase the maximum key size in AREG, BREG and CREG"
$echoline
echo
# Increase the database key size
$DSE << EOF
find -reg=AREG
change -file -key=255
find -reg=BREG
change -file -key=255
find -reg=CREG
change -file -key=255
EOF
echo

# At this point the database file header has a max key size that is greater than the max key size value in the global directory.
# The view "NOISOLATION" done in each of the tests below will allocate memory for gv_target based on the key size value present
# in global directory. However, the first time the database is opened as part of each database operation tested below, it should 
# recognize the difference in key size between the global directory AND the database file header and reallocate the gv_target 
# accordingly. Prior to V5.4-003, this did NOT happen and caused GTMASSERT.

$gtm_exe/mumps -run %XCMD 'do setupLargeKeys^C9L03003393'

# Various tests follow
foreach label (testWrite testDollarGet testKill testDollarOrder testDollarZPrevious testDollarData testSet)
	$gtm_exe/mumps -run $label^C9L03003393
end
echo
$gtm_tst/com/dbcheck.csh
