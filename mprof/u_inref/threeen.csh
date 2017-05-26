#!/usr/local/bin/tcsh

# This script is a launcher for threeen.m program; it takes care of
# passing the input parameters properly. It is used invoked by
# D9L03002804 and D9L06002815 subtests.

if ($3 < 3) then
time $gtm_dist/mumps -run threeen <<EOF 
1 $1 $2 $3 $4 $5
EOF
else
$gtm_dist/mumps -run threeen <<EOF 
1 $1 $2 $3 $4 $5
EOF
endif
