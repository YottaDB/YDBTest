#! /usr/local/bin/tcsh -f

#create a global directory with two regions -- DEFAULT, REGX

$gtm_tst/com/dbcreate.csh mumps 2

# Set some global variables - to fill some blocks

$GTM << GTM_EOF
do ^createdb
halt
GTM_EOF

# Test the open, close commands of dse

echo "TEST DSE - OPEN/CLOSE COMMAND"

# Empty open - just to make sure that no file is currently open
# Create a file using open
# List the currently open file
# Close it
# Verify if indeed the file was created

$DSE << DSE_EOF

open
open -file=foo.glo
open
close

DSE_EOF

# If OPEN fails, it is not part of dse_open's mistake, it is a system error.
# How do I deal with a system error??

if (-f foo.glo) then
	echo "OPEN succeeded in creating a file"
else
	echo "OPEN failed to create a file due to a system error"
	exit 1
endif

# Check some error cases
# Try opening a file which is already open.
# Try opening a file when another is open.
# Try closing the same file twice

$DSE << DSE_EOF
open -file=foo.glo
open -file=foo.glo
open -file=foo2.glo
close
close

DSE_EOF

# Verify if the above operations have done any damage to the database
$gtm_tst/com/dbcheck.csh
