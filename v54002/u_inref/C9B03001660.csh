#!/usr/local/bin/tcsh -f

#
# Run test for C9B03-001660 - for loop with subscripted indirect control variable should tolerate
# assignment to an extrinsic function that changes (in the case of the test destroys) the array 
# which contains the control variable 
#
$gtm_dist/mumps -dir <<EOF
do ^C9B03001660
EOF
