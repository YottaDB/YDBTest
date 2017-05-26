#!/usr/local/bin/tcsh -f
#
echo "Get dump before change"
$gtm_tst/$tst/u_inref/dse_dump_uprproc.csh
echo "Now change update process related fields"
$DSE << DSE_EOF
change -file -AVG_BLKS_READ=10
change -file -PRE_READ_TRIGGER_FACTOR=40
change -file -UPD_RESERVED_AREA=45
change -file -UPD_WRITER_TRIGGER_FACTOR=60
quit
DSE_EOF
echo "Get dump after change"
$gtm_tst/$tst/u_inref/dse_dump_uprproc.csh
