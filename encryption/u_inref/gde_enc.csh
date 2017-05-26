#!/usr/local/bin/tcsh -f
#
# Test to check GDE command for setting encryption status
#
echo "***************BEGIN THE GDE TEST*******************"

echo "#Create new gld file verify the ENCR flag value is OFF and turn it to ON#"
$GDE show | $grep ENCR
$GDE change -s DEFAULT -encr
$GDE show | $grep ENCR

echo "#Update the gld by adding a new region and grep for ENCR flag to verify the default value is OFF#"
$GDE << GDE_EOF
add -name a* -region=NEWREG
add -region NEWREG -d=NEWSEG
add -segment NEWSEG -file=newfile.dat
GDE_EOF

$GDE show | $grep ENCR

echo "#Add another region and turn on encryption for this region#"
$GDE << GDE_EOF
add -name b* -region=BREG
add -region BREG -d=BSEG
add -segment BSEG -file=Bfile.dat
GDE_EOF

$GDE change -s BSEG -encr
$GDE show | $grep ENCR

echo "#Trying to change the encryption flag for region#"
$GDE change -r NEWREG -encr
echo "#Enable encryption for previously added region#"
$GDE change -s NEWSEG -encr
$GDE show | $grep ENCR

echo "#Add one more region and disable the encryption for a previous region whose encryption status was ON#"
$GDE << GDE_EOF
add -name c* -region=CREG
add -region CREG -d=CSEG
add -segment CSEG -file=Cfile.dat
change -s BSEG -noencr
GDE_EOF
$GDE show | $grep ENCR

$gtm_tst/com/create_key_file.csh >& create_ke_file_dbload.out
$MUPIP create
echo "****************END GDE TEST**************************"
