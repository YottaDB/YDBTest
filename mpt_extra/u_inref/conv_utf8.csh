#!/usr/local/bin/tcsh
# test for conversion utility routines
# these are the tests in the manual
# for utf8 characters
#
# Test the entire range of ascii,control and punctuation characters,i.e 1-255 limit
# For LCASE UCASE functions check some special casing characters and their behavior
# execute an awk file that will generate a M routine containing such special chars.

# The whole section gets to run only if gtm_chset=UTF-8
$switch_chset "UTF-8"
$tst_awk -f $gtm_tst/com/convert.awk $gtm_tst/com/special_casing.txt
#
$GTM << \GTMEND
do ^caseconv
write "Test the interactive label INT of LCASE and UCASE",!
do INT^%LCASE
!"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~
do INT^%UCASE
!"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~
do INT^%LCASE
ľāťīň 'ō ľāťīň Ľāťīň 'Ō Ľāťīň ĽĀŤĪŇ 'Ō ĽĀŤĪŇ
do INT^%UCASE
ľāťīň 'ō ľāťīň Ľāťīň 'Ō Ľāťīň ĽĀŤĪŇ 'Ō ĽĀŤĪŇ
do INT^%LCASE
Chinese Should Not Change 北齊書  周書  南史  北史  隋書
do INT^%UCASE
Chinese Should Not Change 北齊書  周書  南史  北史  隋書
do INT^%LCASE
Ok some Tamil with JUICY comBIning chars எ ன ̇க̇ கு மா ற̇ ற ம̇ இ ல̇ ைல
do INT^%UCASE
Ok some Tamil with juicy comBIning chars எ ன ̇க̇ கு மா ற̇ ற ம̇ இ ல̇ ைல
halt
\GTMEND
#
