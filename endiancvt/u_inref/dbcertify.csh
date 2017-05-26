#!/usr/local/bin/tcsh -f

## This routine does the necessary steps to dbcertify mumps.dat 
## The requirement in the test was only for mumps.dat and so the tool is not generic (not to complicate things)
## USAGE: dbcertify.csh
## No arguments necessary. It runs only for mumps.dat

cp $gtm_tst/$tst/inref/yes.txt .
if (-e $tst_general_dir/run_cre_coll_sl_reverse.txt) then
        # The above file signals switch_gtm_version.csh to recomplile libreverse shared library
        # The recompiling is required everytime we switch between 32 and 64 bit GTM.
        # In this special case, though there is a version switch below,
        # the commands $DBCERTIFY and $MUPIPV5 that follows are actually 64bit GTM tools and they will require 64bit library.
        # Hence do not create 32bit libreverse shared library
        mv $tst_general_dir/run_cre_coll_sl_reverse.txt $tst_general_dir/run_cre_coll_sl_reverse.txt.bak
endif
$sv4
if (-e $tst_general_dir/run_cre_coll_sl_reverse.txt.bak) then
        mv $tst_general_dir/run_cre_coll_sl_reverse.txt.bak $tst_general_dir/run_cre_coll_sl_reverse.txt
endif
$DSE change -file -reserved_bytes=8
$DBCERTIFY scan DEFAULT -outfile=dbcertify_scan.scan >&! dbcertify_scan.out
echo ""
echo "# dbcertify certify..."
$DBCERTIFY certify dbcertify_scan.scan < yes.txt >&! dbcertify_certify.out
if ( $status) then
        echo "TEST-E-ERROR. certify failed"
else
        grep "DBCDBCERTIFIED" dbcertify_certify.out
endif
echo ""
echo "# mupip upgrade..."
$MUPIPV5 upgrade mumps.dat < yes.txt >&! mupip_upgrade.out
if ( $status) then
        echo "TEST-E-ERROR. mupip upgrade failed"
else
        grep "MUPGRDSUCC" mupip_upgrade.out
endif
# switch back to V5
$sv5
echo ""
echo "# convert the gld to V5 format"
$GDE exit
