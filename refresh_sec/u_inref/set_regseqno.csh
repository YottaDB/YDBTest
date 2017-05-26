#!/usr/local/bin/tcsh -f
#
#
foreach x (mumps a)
	# Determine latest generation journal file of this region
	set jnlfile=`ls -1t $x.mjl_* | $head -n 1`
	setenv end_regseqno `$MUPIP journal -show=header -forward $jnlfile |& $tst_awk '/End Region/ {print $6}' |& sed 's/\[\(.*\)\]/\1/g'`
	if ("mumps" == $x) then
		setenv region_name DEFAULT
	else
		setenv region_name $x"reg"
	endif
	echo $end_regseqno
	$DSE << DSE_EOF
find -reg=$region_name
change -file -REG_SEQNO=$end_regseqno
dump -file
DSE_EOF

	if (1 == $test_replic_suppl_type) then
		$DSE << DSE_EOF
find -reg=$region_name
change -file -STRM_NUM=1 -STRM_REG_SEQNO=$end_regseqno
dump -file
DSE_EOF

	endif

	if (2 == $test_replic_suppl_type) then
		$DSE << DSE_EOF
find -reg=$region_name
change -file -STRM_NUM=0 -STRM_REG_SEQNO=$end_regseqno
dump -file
DSE_EOF

	endif
end
