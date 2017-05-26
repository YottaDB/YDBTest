#!/usr/local/bin/tcsh -f
#
# This subtest verifies the ] and ]] operators with the Chinese collation sequence
# Test Plan
#	This is a new test to test the ] and ]] operators. The test should do:
#	- Create the Chinese collation sequence
#	- Create an array of local variables that contain following values
#		- Chinese character strings (at least two that collates continuously)
#		- non-canonical numeric values
#		- canonical numeric values
#		- String that starts with numbers
#	- Use the ]] operator to compare each pair
#	- Apply the ] operator to each pair
#	- Verify that the result is as expected.

$switch_chset "UTF-8"
source $gtm_tst/com/cre_coll_sl.csh chinese 1

# ========= debug section ===========
echo "DEBUG INFORMATION"
echo $gtm_local_collate
env | $grep gtm_collate_1
echo "DEBUG INFORMATION"
# ======== end of debug section =====

# Test with ASCII subscript collation for local variables
$GTM << \EOF
if '$$set^%LCLCOL(0) write "Local collation cannot be changed",!
write "Current local collation="_$$get^%LCLCOL_"; ncol="_$$getncol^%LCLCOL_"; nct="_$$getnct^%LCLCOL,!
do ^operdata
quit
\EOF

# Retest the above with nct set to string mode
$GTM << \EOF
if '$$set^%LCLCOL(0,,1) write "Local collation cannot be changed",!
write "Current local collation="_$$get^%LCLCOL_"; ncol="_$$getncol^%LCLCOL_"; nct="_$$getnct^%LCLCOL,!
do ^operdata
quit
\EOF

# Test with CHINESE subscript collation for local variables
$GTM << \EOF
if '$$set^%LCLCOL(1) write "Local collation cannot be changed",!
write "Current local collation="_$$get^%LCLCOL_"; ncol="_$$getncol^%LCLCOL_"; nct="_$$getnct^%LCLCOL,!
do ^operdata
quit
\EOF

# Retest the above with nct set to string mode
$GTM << \EOF
if '$$set^%LCLCOL(1,,1) write "Local collation cannot be changed",!
write "Current local collation="_$$get^%LCLCOL_"; ncol="_$$getncol^%LCLCOL_"; nct="_$$getnct^%LCLCOL,!
do ^operdata
quit
\EOF
