#! /usr/local/bin/tcsh -f

#create a global directory with two regions -- DEFAULT, REGX

$gtm_tst/com/dbcreate.csh mumps 2

# Set some global variables - to fill some blocks

$GTM << GTM_EOF
do ^createdb
halt
GTM_EOF

# Test dse -page command

echo "TEST DSE - PAGE COMMAND"

# Write a couple of pagebreaks on the output device

$DSE << DSE_EOF

page
page

DSE_EOF

# Verify if the above operations have done any damage to the database
$gtm_tst/com/dbcheck.csh
