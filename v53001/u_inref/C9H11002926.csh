#!/usr/local/bin/tcsh -f

# C9H11-002926: Don't allow relink of routine currently on the GTM stack.
# This issue was raised because insufficient checking was being done to verify
# that a module being relinked was not in fact on the stack. If the module that is
# on the stack is not using the most current routine header (because the module
# had been replaced one or more times but there existed references to the earlier
# versions) the code prior to this fix did not detect that because it was only
# checking the most current version of the routine header. This test triggers the
# failing case that the fix cures by relinking modules that are on the stack
# repeatedly until it fails.

# The test references some M files directly so copy them from the inref diretory.
cp $gtm_tst/$tst/inref/zlinktst*.m .

$gtm_exe/mumps -run C9H11002926
