#!/usr/local/bin/tcsh
#
# D9G01-002587 Errors during MUPIP LOAD with a fillfactor of less than 100%
#
# mupip load below will have an additional line about renaming journal file if journaling is enabled
# So filter out GTM-I-FILERENAME from the load output, to keep the reference file consistent
$gtm_tst/com/dbcreate.csh mumps 1 255 950 1024
mv mumps.dat mumpsbak.dat

# --------- (a) Test VIEW and $VIEW commands with FILL_FACTOR keyword ------------

cp mumpsbak.dat mumps.dat
$GTM << GTM_EOF
	do viewfillfactor^d002587
	quit
GTM_EOF
$gtm_tst/com/dbcheck.csh

# --------- (b) Test new RSVDBYTE2HIGH message both from GT.M and MUPIP LOAD -------------------

cp mumpsbak.dat mumps.dat
echo ""
echo "###### GT.M with RESERVED_BYTES=0. Should NOT issue RSVDBYTE2HIGH error ###### "
$GTM << GTM_EOF
	do fillfactor^d002587
	do rsvdbyte2high^d002587
	quit
GTM_EOF
$gtm_tst/com/dbcheck.csh
$MUPIP extract data1.glo
echo "data1.glo"
$tail -n +3 data1.glo

cp mumpsbak.dat mumps.dat
$DSE << DSE_EOF
	change -file -reserved_bytes=128
DSE_EOF
echo ""
echo "###### GT.M with RESERVED_BYTES=128. Should issue RSVDBYTE2HIGH error ###### "
$GTM << GTM_EOF
	do rsvdbyte2high^d002587 ; test RSVDBYTE2HIGH error on empty GVT codepath
GTM_EOF

$GTM << GTM_EOF
	do fillfactor^d002587
	do rsvdbyte2high^d002587 ; test RSVDBYTE2HIGH error on non-empty GVT codepath
	quit
GTM_EOF
$gtm_tst/com/dbcheck.csh
$MUPIP extract data2.glo
echo "data2.glo"
$tail -n +3 data2.glo

echo ""
echo "###### MUPIP LOAD with RESERVED_BYTES=128. Should issue RSVDBYTE2HIGH error ###### "
cp mumpsbak.dat mumps.dat
$DSE << DSE_EOF
	change -file -reserved_bytes=128
DSE_EOF
$MUPIP load data1.glo -fill=60 >&! load_expect_RSVDBYTE2HIGH.outx # should issue RSVDBYTE2HIGH error
$tail -n +3 load_expect_RSVDBYTE2HIGH.outx | $grep -v GTM-I-FILERENAME
$gtm_tst/com/dbcheck.csh
$MUPIP extract data3.glo

echo ""
echo "###### MUPIP LOAD with RESERVED_BYTES=0 and FILLFACTOR=30. Should NOT issue RSVDBYTE2HIGH error ###### "
cp mumpsbak.dat mumps.dat
$MUPIP load data1.glo -fill=30 >&! load_not_expect_RSVDBYTE2HIGH.out # should NOT issue RSVDBYTE2HIGH error
$tail -n +3 load_not_expect_RSVDBYTE2HIGH.out | $grep -v GTM-I-FILERENAME
$gtm_tst/com/dbcheck.csh
$MUPIP extract data4.glo

# RSVDBYTE2HIGH error from an index block
cp mumpsbak.dat mumps.dat
echo ""
$DSE << DSE_EOF
	change -file -reserved_bytes=768
DSE_EOF
$GTM << GTM_EOF
	do rsvdbyte2highINDEX^d002587
GTM_EOF

# --------- (c) Test block split does not result in an empty right block ------------

cp mumpsbak.dat mumps.dat
$GTM << GTM_EOF
	do emptyrightblock^d002587
	quit
GTM_EOF
$gtm_tst/com/dbcheck.csh

$MUPIP extract data5.glo

echo ""
echo "###### MUPIP LOAD with FILLFACTOR=60 ######"
cp mumpsbak.dat mumps.dat
$MUPIP load data5.glo -fill=60 >&! load_fill_60.out
$tail -n +3 load_fill_60.out | $grep -v GTM-I-FILERENAME
$gtm_tst/com/dbcheck.csh
$MUPIP extract data6.glo
echo "data6.glo"
$tail -n +3 data6.glo

# --------- (d) Test copy_extra_record logic in gvcst_put.c ------------

cp mumpsbak.dat mumps.dat
$GTM << GTM_EOF
	do copyextrarecord^d002587
	quit
GTM_EOF
$gtm_tst/com/dbcheck.csh

$MUPIP extract data7.glo

cp mumpsbak.dat mumps.dat
$GTM << GTM_EOF
	do data2^d002587
	quit
GTM_EOF
$gtm_tst/com/dbcheck.csh
$MUPIP extract data_2.glo

cp mumpsbak.dat mumps.dat
$GTM << GTM_EOF
	do data1^d002587
	quit
GTM_EOF
$gtm_tst/com/dbcheck.csh
$MUPIP extract data_1.glo

cp mumpsbak.dat mumps.dat
echo ""
echo "###### MUPIP LOAD of DATA2 with FILLFACTOR=60 ######"
$MUPIP load data_2.glo -fill=60 >&! load_fill_60_data2.out
$tail -n +3 load_fill_60_data2.out | $grep -v GTM-I-FILERENAME
$gtm_tst/com/dbcheck.csh
echo ""
echo "###### MUPIP LOAD of DATA1 with FILLFACTOR=30 ######"
$MUPIP load data_1.glo -fill=30 |& $tail -n +3 
$gtm_tst/com/dbcheck.csh

$MUPIP extract data8.glo
echo "data8.glo"
$tail -n +3 data8.glo

# --------- (e) Test left split logic in gvcst_put.c where left block need not satisfy reserved_bytes setting ------------
cp mumpsbak.dat mumps.dat
$GTM << GTM_EOF
	do leftsplitLEFTBLOCKpart1^d002587
	quit
GTM_EOF
$DSE << DSE_EOF
	change -file -reserved_bytes=512
DSE_EOF
$GTM << GTM_EOF
	do leftsplitLEFTBLOCKpart2^d002587
	quit
GTM_EOF
$gtm_tst/com/dbcheck.csh

# --------- (f) Test left split logic in gvcst_put.c where right block need not satisfy reserved_bytes setting ------------
cp mumpsbak.dat mumps.dat
$GTM << GTM_EOF
	do leftsplitRIGHTBLOCKpart1^d002587
	quit
GTM_EOF
$DSE << DSE_EOF
	change -file -reserved_bytes=512
DSE_EOF
$GTM << GTM_EOF
	do leftsplitRIGHTBLOCKpart2^d002587
	quit
GTM_EOF
$gtm_tst/com/dbcheck.csh

# --------- (g) Test right split logic in gvcst_put.c where left block need not satisfy reserved_bytes setting ------------
cp mumpsbak.dat mumps.dat
$GTM << GTM_EOF
	do rightsplitLEFTBLOCKpart1^d002587
	quit
GTM_EOF
$DSE << DSE_EOF
	change -file -reserved_bytes=512
DSE_EOF
$GTM << GTM_EOF
	do rightsplitLEFTBLOCKpart2^d002587
	quit
GTM_EOF
$gtm_tst/com/dbcheck.csh

