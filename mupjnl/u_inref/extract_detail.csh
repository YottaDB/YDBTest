#!/usr/local/bin/tcsh

$gtm_tst/com/dbcreate.csh .
if (-e mumps.mjl) then
	mv mumps.mjl mumps.mjl_save
endif
$MUPIP set -journal="enable,on,before" -reg "*"
$GTM << EOF
d ^jnlrecm
d ^jnlrecm
h
EOF
$gtm_exe/mumps -run jnlrecm
$MUPIP journal -extract -for -detail mumps.mjl
echo "Check that the offset + len matches the next offset (i.e. no records are omitted, and len is correct)"
$gtm_exe/mumps -run offset > offset.out
$grep ERROR offset.out
$tst_awk -f $gtm_tst/$tst/inref/extract.awk -v "detail=1" -v "user=$USER" -v "host=$HOST:r:r:r" mumps.mjf > mumps.list
$grep -vE "EPOCH|PBLK" mumps.list  | sed 's/^[^ ]* //g' > detail_extract.mjf
diff detail_extract.mjf $gtm_tst/$tst/outref/ >/dev/null
if ($status) then
	echo "TEST-E-DETAIL_EXTRACT check detail_extract.mjf $gtm_tst/$tst/outref/detail_extract.mjf"
endif
$gtm_tst/com/dbcheck.csh
