#!/usr/local/bin/tcsh -f
setenv gtm_badchar "no"
$switch_chset UTF-8 
#
$GTM << aaa >&! unicodeCommentsLiterals_with_warn.outx
write "do ^unicodeCommentsLiterals",!
do ^unicodeCommentsLiterals
h
aaa
#
$tst_awk -f $gtm_tst/com/filter_litnongraph.awk unicodeCommentsLiterals_with_warn.outx
