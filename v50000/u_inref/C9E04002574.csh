#!/usr/local/bin/tcsh
#
# C9E04-002574 cert_blk (database block certification) does not error out for a lot of cases
#

$gtm_tst/com/dbcreate.csh mumps 1 255 1000 1024
mv mumps.dat mumpsbak.dat

# --------- (a) DBMAXNRSUBS -------------------

cp mumpsbak.dat mumps.dat
$GTM << GTM_EOF
	do dbmaxnrsubs^c002574
	quit
GTM_EOF

$DSE << DSE_EOF >>&! dse_dbmaxnrsubs.log	# redirect dump -bl output due to endianness issues with reference files 
	find -bl=3
	add  -bl=3 -rec=2 -key="^a(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32)" -data=2
	dump -bl=3
	quit
DSE_EOF

$DSE << DSE_EOF
	integ -bl=3
DSE_EOF

cp mumps.dat dbmaxnrsubs.dat

# --------- (b) DBKEYORD -------------------

cp mumpsbak.dat mumps.dat

$GTM << GTM_EOF
	do dbkeyord^c002574
	quit
GTM_EOF

$DSE << DSE_EOF >>&! dse_dbkeyord.log	# redirect dump -bl output due to endianness issues with reference files 
	find -bl=3
	add  -bl=3 -rec=2 -key="^a" -data=2
	dump -bl=3
	quit
DSE_EOF

$DSE << DSE_EOF
	integ -bl=3
DSE_EOF

cp mumps.dat dbkeyord.dat

# --------- (c) DBINVGBL and DBDIRTSUBSC -------------------

cp mumpsbak.dat mumps.dat

$GTM << GTM_EOF
	do dbinvgbldbdirtsubsc^c002574
	quit
GTM_EOF

$DSE << DSE_EOF >>&! dse_dbinvgbldbdirtsubsc.log	# redirect dump -bl output due to endianness issues with reference files 
	find -bl=3
	add  -bl=3 -rec=2 -key="^a(1)" -data=2
	add  -bl=3 -rec=3 -key="^abcd" -data=3
	dump -bl=3
DSE_EOF

$DSE << DSE_EOF
	integ -bl=3
DSE_EOF

$DSE << DSE_EOF >>&! dse_dbinvgbldbdirtsubsc.log	# redirect dump -bl output due to endianness issues with reference files 
	remove -bl=3 -rec=3
	remove -bl=3 -rec=2
	add    -bl=3 -rec=2 -key="^abcd(20)" -data=4
	dump   -bl=3
DSE_EOF

$DSE << DSE_EOF
	integ -bl=3
DSE_EOF

$DSE << DSE_EOF >>&! dse_dbinvgbldbdirtsubsc.log	# redirect dump -bl output due to endianness issues with reference files 
	remove -bl=3 -rec=2
	add    -bl=3 -rec=2 -key="^b(100)" -data=5
	dump   -bl=3
DSE_EOF

$DSE << DSE_EOF
	integ -bl=3
DSE_EOF

cp mumps.dat dbginvgbl.dat

# --------- (d) DBBDBALLOC -------------------

cp mumpsbak.dat mumps.dat

$GTM << GTM_EOF
	do dbbdballoc^c002574
	quit
GTM_EOF

$DSE << DSE_EOF >>&! dse_dbbdballoc.log	# redirect dump -bl output due to endianness issues with reference files 
	find -bl=4
	add  -bl=4 -rec=2 -key="^a(5)" -pointer=3
	dump -bl=4
	quit
DSE_EOF

$DSE << DSE_EOF
	integ -bl=4
DSE_EOF

cp mumps.dat dbbdballoc.dat

echo ""
echo "--> End of test"
cp mumpsbak.dat mumps.dat
$gtm_tst/com/dbcheck.csh
