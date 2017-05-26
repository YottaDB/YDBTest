#! /usr/local/bin/tcsh -f
echo "C9C11002171 subtest begins"
echo "exception for  sequential file where no file exists"
$GTM <<aa
d ^opexrm
aa
echo "----------------------------------------------------"
echo "exception for sequential file where no directory exists"
$GTM <<aa
d ^opnodir
aa
echo "----------------------------------------------------"
echo "exception for fifo where permission is denied"
$GTM <<aa
d ^opexff
aa
echo "End of C9C11002171 subtest"
