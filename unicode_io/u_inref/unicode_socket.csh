#!/usr/local/bin/tcsh -f
$switch_chset UTF-8 
source $gtm_tst/com/portno_acquire.csh >>& portno.out
$GTM << EOF
set port=$portno
write "do ^unicodesocket",!
do ^unicodesocket
h
EOF
$gtm_tst/com/portno_release.csh
