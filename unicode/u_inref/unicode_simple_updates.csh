#!/usr/local/bin/tcsh
#
$switch_chset UTF-8 
source $gtm_tst/com/dbcreate.csh uniupdates 1 255 1000
$DSE << DSE_EOF
change -file -null_subs=always
DSE_EOF
#
$GTM << aaa
write "do ^unicodeLocalUpdates",!
do ^unicodeLocalUpdates
h
aaa
#
$GTM << aaa
write "do ^unicodeGlobalUpdates",!
do ^unicodeGlobalUpdates
h
aaa
#
$gtm_tst/com/dbcheck.csh
