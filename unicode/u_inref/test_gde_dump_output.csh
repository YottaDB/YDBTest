#!/usr/local/bin/tcsh -f
#
# This tool comapres the data present in the dumpfile(dse) with the actual database content
# Sample usage:
# $gtm_tst/$tst/u_inref/test_gde_dump_output.csh -savedir <bakdir> -input <datafile> -format [glo|zwr]
#
# Note the 1-1 correspondence between opt_array and opt_name_array. Any additions/deletions  must be done in both arrays.
set opt_array      = ("\-savedir" "\-input" "\-format"  "\-outfile")
set opt_name_array = ("savedir" "input"   "format" "outfile")
source $gtm_tst/com/getargs.csh $argv
#
$MUPIP extract tmp_orig.out >&! $outfile
if !( -d ./$savedir ) then
	mkdir $savedir
	cp mumps.dat ./$savedir
endif
\rm mumps.dat
$gtm_tst/com/dbcreate.csh . -bl=512 >>&! $outfile
if ("GLO" == $format) set format="GO"
$MUPIP load -format=$format $input >>&! $outfile
$MUPIP extract tmp_$input"_"$format.out >>&! $outfile
set filelen=`wc -l tmp_${input}_$format.out | $tst_awk '{print $1}'`
@ filelen = $filelen - 1
$tail -n +$filelen tmp_${input}_$format.out >&! ${input}_$format.out
$tail -n +$filelen tmp_orig.out >&! orig.out
#
\diff orig.out $input"_"$format.out >&! $input.diff
if ($status) then
	echo "TEST-E-ERROR with DSE DUMP for $input in $format. Check the files in ./$savedir"
	cp tmp_orig.out orig.out tmp_${input}_$format.out ${input}_$format.out ./$savedir
else
	echo "TEST-I-PASS dse dump for encoding `echo $input | sed 's/\(.*\)_\(.*\)/\1/'` in $format passed"
endif
rm tmp_orig.out
$gtm_tst/com/dbcheck.csh >>&! $outfile
cp ./$savedir/mumps.dat .
#
