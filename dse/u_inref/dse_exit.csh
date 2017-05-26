#! /usr/local/bin/tcsh -f

#create a global directory with two regions -- DEFAULT, REGX

$gtm_tst/com/dbcreate.csh mumps 2

# Set some global variables - to fill some blocks

$GTM << GTM_EOF
do ^createdb
halt
GTM_EOF

# Test dse -exit command

echo "TEST DSE - EXIT COMMAND"

$DSE << DSE_EOF

exit

DSE_EOF

# Verify if the above operations have done any damage to the database
$gtm_tst/com/dbcheck.csh
