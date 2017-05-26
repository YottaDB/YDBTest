#!/usr/local/bin/tcsh -f
#
# GTM-7077 MUPIP EXTRACT of large block
#
# Ask for a max size db block with GDE as dbcreate doesn't like it
$GDE change -segment DEFAULT -block=65024
$MUPIP create
$GTM <<GTM_EOF
for x=1:1:10000 set ^test(x)=\$justify("\*",100)	; populate with a bunch of stuff
GTM_EOF
$MUPIP extract -format=bin -select="^test" test.bin
$GTM <<GTM_EOF
kill ^test						; clean out the database
GTM_EOF
$MUPIP load -format=bin test.bin
$gtm_tst/com/dbcheck.csh	# didn't use dbcreate as it treats the warning about the big blocksize as an error
