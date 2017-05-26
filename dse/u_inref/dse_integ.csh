#! /usr/local/bin/tcsh -f

#Test dse -integ command

echo "TEST DSE - INTEG COMMAND"

#create a global directory with two regions -- DEFAULT, REGX

$gtm_tst/com/dbcreate.csh mumps 2

# Set some global variables - to fill some blocks

$GTM << GTM_EOF
do ^createdb
halt
GTM_EOF

# integ on block zero
# save block 4, remove star record from it, then restore
# integ both before and after restoring

$DSE << DSE_EOF

integ -bl=0
save -bl=4
remove -bl=4 -re=24
integ
restore -bl=4 -ver=1
integ

DSE_EOF

# Verify if the above operations have done any damage to the database
$gtm_tst/com/dbcheck.csh
