#!/usr/local/bin/tcsh -f
$tst_awk -f $gtm_tst/$tst/inref/extract.awk -v "user=$USER" -v "host=$HOST:r:r:r" $1 | $tst_awk 'BEGIN{FS="\\"; OFS="\\"} {if (NF>3) {$4="##pid##"}; print}'
