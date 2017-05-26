#!/usr/local/bin/tcsh -f
#
# C9J04003115 [Narayanan] Compiling EBCDIC M program in ASCII land causes SIG-11 & stack smash errors
#
# Compiling this produces unreadable output so redirect output to a file.
# Objective is to test that there are no dump files from this action.
# The test framework anyway does for us so no other special checks needed in this test.

$GTM << GTM_EOF >& error.out
	do ^c003115
GTM_EOF
