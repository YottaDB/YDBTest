#!/usr/local/bin/tcsh -f
echo "$gtm_exe/mumps -run mnset >&! mnset.out"
( $gtm_exe/mumps -run mnset >&! mnset.out )&
