#! /usr/local/bin/tcsh -f
echo "Test case: jnlcycle"
$gtm_tst/com/dbcreate.csh mumps 1
echo "MUPIP set -journal=enable,on,before -reg '*'"
$MUPIP set -journal=enable,on,before -reg "*"
sleep 2
$GTM  << EOF
f i=1:1:10 s ^a(i)=i
EOF
echo "rm -f mumps.mjl"
rm -f mumps.mjl
## backup command will cut the link
echo "MUPIP backup DEFAULT back.dat"
$MUPIP backup DEFAULT back.dat
echo "MUPIP journal -show=head -for mumps.mjl" #BYPASSOK 
$MUPIP journal -show=head -for mumps.mjl |& grep "Prev journal" #BYPASSOK
echo "MUPIP journal -recover -back -since=0 0:0:1  '*'"
$MUPIP journal -recover -back -since=\"0 0:0:1\" "*"
echo "End of test"
$gtm_tst/com/dbcheck.csh
