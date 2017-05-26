#!/usr/local/bin/tcsh -f
$switch_chset UTF-8 
$GTM << aaa
write "do createFilesTruncate^eoftest",!
do createFilesTruncate^eoftest
h
aaa
setenv cur_dir `pwd`
cp $gtm_tst/com/ftruncate.c $cur_dir
$gt_cc_compiler -I$gtm_inc $cur_dir/ftruncate.c -o $cur_dir/ftruncate
# ftruncate all files now
# save the original files before truncation - will be helpful when debugging
foreach file ( `ls utf*.txt`)
	cp $file $file"_orig"
end
cp ascii.txt ascii.txt_orig
echo "Truncation Stats"
echo ""
# for truncation if we want one byte to truncate from the actual data we need to give it as two
# to account for line terminator 0a
ls -l utf8-1.txt|& $tst_awk '{print $5" "$NF}'
set filesize = `ls -l utf8-1.txt |&  $tst_awk '{print $5}'`
@ filesize = $filesize - 2
echo $cur_dir/ftruncate utf8-1.txt $filesize
$cur_dir/ftruncate utf8-1.txt $filesize
ls -l utf8-2.txt|& $tst_awk '{print $5" "$NF}'
set filesize = `ls -l utf8-2.txt |&  $tst_awk '{print $5}'`
@ filesize = $filesize - 3
echo $cur_dir/ftruncate  utf8-2.txt $filesize
$cur_dir/ftruncate  utf8-2.txt $filesize
ls -l utf8-3.txt|& $tst_awk '{print $5" "$NF}'
set filesize = `ls -l utf8-3.txt |&  $tst_awk '{print $5}'`
@ filesize = $filesize - 4
echo $cur_dir/ftruncate utf8-3.txt $filesize
$cur_dir/ftruncate utf8-3.txt $filesize
# utf-16 encoded data are represented as either a pair (2 bytes) or as 4 bytes
# so if we want to remove the  line terminator we have to substract two as they are
# represented as 000a or 0a00 based on endianess
ls -l utf16.txt|& $tst_awk '{print $5" "$NF}'
set filesize = `ls -l utf16.txt |&  $tst_awk '{print $5}'`
@ filesize = $filesize - 3
echo $cur_dir/ftruncate utf16.txt $filesize
$cur_dir/ftruncate utf16.txt $filesize
ls -l utf16_BE.txt|& $tst_awk '{print $5" "$NF}'
set filesize = `ls -l utf16_BE.txt |&  $tst_awk '{print $5}'`
@ filesize = $filesize - 3
echo $cur_dir/ftruncate utf16_BE.txt $filesize
$cur_dir/ftruncate utf16_BE.txt $filesize
ls -l utf16_LE.txt|& $tst_awk '{print $5" "$NF}'
set filesize = `ls -l utf16_LE.txt |&  $tst_awk '{print $5}'`
@ filesize = $filesize - 3
echo $cur_dir/ftruncate utf16_LE.txt $filesize
$cur_dir/ftruncate utf16_LE.txt $filesize
ls -l utf16-Surrogate.txt|& $tst_awk '{print $5" "$NF}'
set filesize = `ls -l utf16-Surrogate.txt |&  $tst_awk '{print $5}'`
@ filesize = $filesize - 4
echo $cur_dir/ftruncate utf16-Surrogate.txt $filesize
$cur_dir/ftruncate utf16-Surrogate.txt $filesize
#
$GTM << aaa
do readTruncates^eoftest
h
aaa
# save the truncated files and create fresh ones for the next test
foreach file ( `ls utf*.txt`)
	mv $file $file"_truncated"
end
#
$GTM << aaa
write "do createFilesEncoding^eoftest",!
do createFilesEncoding^eoftest
h
aaa
#
$GTM << aaa
do readBadEncoding^eoftest
h
aaa
#
echo "END OF TEST"
