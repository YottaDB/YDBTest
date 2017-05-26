#!/usr/local/bin/tcsh -f
# The sort function on z/OS does not user the -T option
# to set the temp dir used by sort.  It does however use
# the TMPDIR env var to change the temp dir used by sort.
#
# This script is only called on z/OS and is setup in
# $gtm_tst/com/set_specific.csh.
# 
# Currently only $gtm_tst/com/errors.csh uses "sort -T"
# so that is the only file that will call this one

# Save TMPDIR if set, it is a null string otherwise
set TMPDIR_save = `printenv "TMPDIR"`
# Set TMPDIR to the target location
setenv TMPDIR $1
shift

# do the sort
sort $*

# Reset TMPDIR to original value
if ("" != $TMPDIR_save) then
	setenv TMPDIR $TMPDIR_save
else
	unsetenv TMPDIR
endif


