#!/usr/local/bin/tcsh -f
#
# Check the newcompilation errors added for alias processing
#

$gtm_dist/mumps -run ^comperrs
$gtm_dist/mumps -run ^comperrs2

# Test that $zahandle of a non-existant index gives error and not explosion
$gtm_dist/mumps -dir << EOF
w \$zahandle(x(2)),!
EOF
