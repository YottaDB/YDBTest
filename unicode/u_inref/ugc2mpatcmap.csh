#!/usr/local/bin/tcsh -f
setenv gtm_badchar "no"
$switch_chset UTF-8 
echo "unsetenv gtm_patnumeric"
unsetenv gtm_patnumeric 
$GTM << FIN 
d ^ugc2mpatcmap
h
FIN
echo "setenv gtm_patnumeric UTF-8"
setenv gtm_patnumeric UTF-8
$GTM << FIN 
d ^ugc2mpatcmap
h
FIN
