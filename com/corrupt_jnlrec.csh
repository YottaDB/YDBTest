#! /usr/local/bin/tcsh -f

#	Maximum 10 journal files can be passed argument. Pass name without ".mjl"
set totarg = $#
# 
# Following 3 lines So that journal extract does not find database and error out
\mkdir ./jnl_ext_temp
\mv *.dat ./jnl_ext_temp	
#
setenv cur_dir `pwd`
\cp $gtm_tst/com/corrupt_jnlrec.c $cur_dir
\cp $gtm_tst/com/ostype.h $cur_dir
$gt_cc_compiler $gt_cc_options_common $cur_dir/corrupt_jnlrec.c
if ($status) then
	echo "TEST-E-CC Error while trying to compile corrupt_jnlrec.c"
	exit 1
endif
$gt_cc_compiler $gt_ld_options_common -o $cur_dir/corrupt_jnlrec $cur_dir/corrupt_jnlrec.o
if ($status) then
	echo "TEST-E-LINK Error while trying to link corrupt_jnlrec.o"
	exit 1
endif
@ cnt = 1
while ($cnt <= $totarg)
	date
	set mjlfile = $1.mjl
	setenv jnlextfile $1.jnlext
	echo "$MUPIP journal -extract=$jnlextfile -detail -show=head -fence=none -forward -noverify -error=10 $mjlfile "
	$MUPIP journal -extract=$jnlextfile -detail -show=head -fence=none -forward -noverify -error=10 $mjlfile  >& $1.jnlhead
	if ($status == 0) then
		setenv end_of_data `$grep "End of Data" $1.jnlhead | $grep -v "Prev Recovery End of Data" | $tst_awk '{print $4}'`
		$GTM << aaa
			set endofdata=\$ztrnlnm("end_of_data")
			set jnlextfile=\$ztrnlnm("jnlextfile")
			do ^fsyncoff(jnlextfile,"recoff.txt",endofdata)
			halt
aaa
		setenv lastepochoffset `cat recoff.txt`
		setenv filesize `\ls -l $mjlfile | awk '{print $5}'`
		# now currupt journal file at random offset and random length after max(last epoch offset, last pblk offset)
		$cur_dir/corrupt_jnlrec $mjlfile $lastepochoffset $filesize 
		if ($status) then
			echo "TEST-E-RUN Error while running corrupt_jnlrec"
		endif
		\mv recoff.txt recoff{$cnt}.txt
	endif
	shift
	@ cnt = $cnt + 1
end
\mv ./jnl_ext_temp/*.dat .
\rm -rf ./jnl_ext_temp
