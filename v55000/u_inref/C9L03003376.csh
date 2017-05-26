#!/usr/local/bin/tcsh -f

#
# ZMessage 1 was being taken as a "success" return code eventually causing an
# assert failure in op_unwind() in a debug build.
#

$gtm_dist/mumps -run C9L03003376
