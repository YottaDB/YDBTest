#!/usr/local/bin/tcsh -f
setenv gtm_badchar "no"
$switch_chset UTF-8 
unsetenv gtm_patnumeric 
$GTM << FIN 
d ^unicodeZwritePattern
h
FIN
setenv gtm_patnumeric UTF-8
$GTM << FIN 
d ^unicodeZwritePattern
h
FIN
