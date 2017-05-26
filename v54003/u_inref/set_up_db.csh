#!/usr/local/bin/tcsh

# This script creates the database files for two regions and sets the flush timeouts for both of them,
# as passed in corresponding parameters from C9K11003340.csh.

set flush_timeout1 = $1
set flush_timeout2 = $2

# dbcheck is later done in C9K11003340.csh
$gtm_tst/com/dbcreate.csh mumps 2 >& "dbcreate.outx"

$gtm_dist/dse >& "dse.outx" << EOF
        find -region=DEFAULT
        change -fileheader -flush_time=$flush_timeout1
        find -region=AREG
        change -fileheader -flush_time=$flush_timeout2
        quit
EOF
