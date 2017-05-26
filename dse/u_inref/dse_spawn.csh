#! /usr/local/bin/tcsh -f

#create a global directory with two regions -- DEFAULT, REGX

$gtm_tst/com/dbcreate.csh mumps 2

# Set some global variables - to fill some blocks

$GTM << GTM_EOF
do ^createdb
halt
GTM_EOF

# Test dse -spawn command 

echo "TEST DSE - SPAWN COMMAND"

# Spawn a shell and execute some echo commands

$DSE spawn << DSE_EOF1

echo "Hi! I am the spawned shell speaking"

$DSE spawn << DSE_EOF2
echo "Hi! I am the shell spawned by the shell spawned by the ... oh! forget it"
exit
DSE_EOF2

echo "now the parent here..."
exit

DSE_EOF1

# Verify if the above operations have done any damage to the database
$gtm_tst/com/dbcheck.csh
