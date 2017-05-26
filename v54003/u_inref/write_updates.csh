#!/usr/local/bin/tcsh

# This script executes a MUMPS program that saves its own JOB ID in a file, sets two globals,
# and writes a special predefined string, as expected by C9K11003340.csh.

$gtm_dist/mumps -direct << EOF
	zsy "echo '"_\$job_"' > pid.outx"
        set ^a=1
        set ^z=1
        hang 123
        quit
EOF
