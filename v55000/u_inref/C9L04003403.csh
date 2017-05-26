#!/usr/local/bin/tcsh -f

#
# If large number (exceeding 64) indirect frames generated for a given counted frame,
# this overflows the array in zshow_stack.c potentially causing crashes.
#

$gtm_dist/mumps -run C9L04003403
