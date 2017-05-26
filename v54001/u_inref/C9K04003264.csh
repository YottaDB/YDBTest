#!/usr/local/bin/tcsh -f
# C9K04-003264 - Check $QLENGTH() and $QSUBSCRIPT() handling of $[Z]CHAR() representations of non-graphic characters
echo Starting C9K04003264
$gtm_exe/mumps -run C9K04003264
echo Ending C9K04003264
