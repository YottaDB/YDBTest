#!/usr/local/bin/tcsh
#
# D9G01-002590 GDE incorrectly reads the template parameter STDNULLCOLL
#

echo ""
echo "########################################################################################"
echo "                      Try saving LOCKSPACE in template                      "
echo "########################################################################################"
$GDE << GDE_EOF
show -template
template -segment -lock=1000
show -template
exit
GDE_EOF

echo ""
echo "########################################################################################"
echo "                      Try saving BLOCKSIZE and RECSIZE in template                      "
echo "########################################################################################"
$GDE << GDE_EOF
show -template
template -segment -block=8192
template -region -rec=8176
show -template
exit
GDE_EOF

echo ""
echo "########################################################################################"
echo "                      Try saving STDNULLCOLL in template                      "
echo "########################################################################################"
$GDE << GDE_EOF
show -template
template -region -stdnullcoll
show -template
exit
GDE_EOF

echo ""
echo "########################################################################################"
echo "                       Try reading STDNULLCOLL from saved template                      "
echo "########################################################################################"
$GDE << GDE_EOF
show -template
exit
GDE_EOF

