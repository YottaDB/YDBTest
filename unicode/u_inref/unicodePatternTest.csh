#!/usr/local/bin/tcsh -f
$switch_chset UTF-8 
unsetenv gtm_patnumeric 
$GTM << FIN 
d ^unicodePatternTest
h
FIN
setenv gtm_patnumeric UTF-8
$GTM << FIN 
d ^unicodePatternTest
h
FIN

