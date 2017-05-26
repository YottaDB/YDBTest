#!/usr/local/bin/tcsh -f
#
# $1 = REGION
# $2 = SEQNO
# $3 = OUTPUT_FILE
#
# Operation :
# To set the req_seqno and resync_seqno of arbitrary regions
# Sets reg_seqno and resync_seqno of region REGION ($1) to be SEQNO ($2) and
# does a dse dump of that region into OUTPUT_FILE ($3)
#

# Region seqno:
$DSE << DSE_EOF >>&! $3
find -reg=$1
change -file -REG_SEQNO=$2
dump -file
DSE_EOF

set OUTPUT_FILE = "$3"
set outputfile_base = $OUTPUT_FILE:r
set outputfile_ext = $OUTPUT_FILE:e
set outputfiler1 = ${outputfile_base}_r_1.$outputfile_ext
set outputfiler2 = ${outputfile_base}_r_2.$outputfile_ext
set outputfilej1 = ${outputfile_base}_j_1.$outputfile_ext
set outputfilej2 = ${outputfile_base}_j_2.$outputfile_ext
echo "#Resync seqno:"
$MUPIP replic -editinstance -show -detail $gtm_repl_instance >& $outputfiler1
$grep "Resync Sequence Number" $outputfiler1
$MUPIP replic -editinstance -change -offset=0x00000410 -size=8 $gtm_repl_instance -value=$2 |& cat
$MUPIP replic -editinstance -show -detail $gtm_repl_instance >& $outputfiler2
$grep "Resync Sequence Number" $outputfiler2

echo "#Journal seqno:"
$MUPIP replic -editinstance -show -detail $gtm_repl_instance >& $outputfilej1

set jsn_offset = "0x00000090"	# for both 64-bit and 32-bit platforms, the offset of this field is the same

$tst_awk '/Journal Sequence Number/ { if(offset==$1) {$1=""} ; print}' offset=$jsn_offset $outputfilej1
$MUPIP replic -editinstance -change -offset=$jsn_offset -size=8 $gtm_repl_instance -value=$2 >&! change_offset.out
$tst_awk '{if ("["offset"]" == $3) { $1=$2=$3=""} ; print}' offset=$jsn_offset change_offset.out
$MUPIP replic -editinstance -show -detail $gtm_repl_instance >& $outputfilej2
$tst_awk '/Journal Sequence Number/ {$1="" ; print}' $outputfilej2
