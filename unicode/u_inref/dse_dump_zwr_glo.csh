#!/usr/local/bin/tcsh -f
#
# This tools dumps all the data blocks of the GVT in the dumpfile specified.
# Sample Usage:
# $gtm_tst/$tst/u_inref/dse_dump_zwr_glo.csh -format [ZWR|GLO] -outfile <outputfile> -dumpfile <dumpfile> -ochset  <ochset>
#
# Note the 1-1 correspondence between opt_array and opt_name_array. Any additions/deletions  must be done in both arrays.
set opt_array      = ("\-format" "\-outfile" "\-dumpfile" "\-ochset" )
set opt_name_array = (  "format"   "outfile"   "dumpfile"   "ochset" )
source $gtm_tst/com/getargs.csh $argv
#
source $gtm_tst/com/get_blks_to_upgrade.csh "" "default"
# dump all the blocks available in the database
$DSE dump -block=1 -count=$calculated >&! fulldump_$ochset
# grab just the Level 0 blocks and that DOES NOT include leaf of the directory tree
set datablk=`$tst_awk -f $gtm_tst/com/datablock.awk fulldump_$ochset`
foreach blk ( $datablk )
$DSE << dse_eof >&! $outfile
open -file=temp.out -ochset="$ochset"
dump -block=$blk -$format
close
dse_eof
#
cat temp.out >>&! tmpdumpfile
end
# remove all the extra comments present in the dump output so that it can be loaded without any errors
$tst_awk '{if ((NR<=2)||($0 !~ /^;/)) print $0}' tmpdumpfile >&! $dumpfile ; rm -f tmpdumpfile
# check the format of the dumpfile to be of the format as specified by ochset
# do a roundtrip to utf-8 and back to the type specified in ochset
if ( "UTF-16" == $ochset || "UTF-16LE" == $ochset || "UTF-16BE" == $ochset ) then
	set ochset=`echo $ochset|tr '[A-Z]' '[a-z]'`
	iconv -f $ochset -t utf-8 $dumpfile >&! iconv_$dumpfile.out
	iconv -f utf-8 -t $ochset iconv_$dumpfile.out >&! tocompare_$dumpfile.out
	# now do a diff 
	if ( "utf-16" == $ochset) then
		# if the ochset is just 16, iconv will append BOM to the files, whereas dse dump will not.
		set filelen=`wc -l tocompare_$dumpfile.out | $tst_awk '{print $1}'`
		@ filelen = $filelen - 1
		$tail -n +$filelen tocompare_$dumpfile.out >&! tmp_tocompare_$dumpfile.out
		$tail -n +$filelen $dumpfile >&! tmp_$dumpfile
		\diff tmp_tocompare_$dumpfile.out tmp_$dumpfile >&! format_$dumpfile.diff
		set diffstat = $status
	else
		\diff tocompare_$dumpfile.out $dumpfile >&! format_$dumpfile.diff
		set diffstat = $status
	endif
	if ( $diffstat ) then
		echo "TEST-E-ERROR OCHSET format incorrect for $dumpfile as $format"
		cat format_$dumpfile.diff
	endif
endif
# check the dump output
set tmpch=`echo $ochset|sed 's/-//'`
$gtm_tst/$tst/u_inref/test_gde_dump_output.csh -savedir bak_$ochset"_"$format -input $dumpfile -format $format -outfile test_gde_dump_${tmpch}_$format.out
#
