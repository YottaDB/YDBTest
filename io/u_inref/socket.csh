# SOCKET devices, LENGTH and WIDTH
source $gtm_tst/com/portno_acquire.csh >>& portno.out
$GTM << EOF
set port=$portno
do ^socket
halt
EOF

$GTM << EOF
set port=$portno
do ^destroysoc
halt
EOF
$gtm_tst/com/portno_release.csh
