#!/usr/local/bin/tcsh -f
$switch_chset UTF-8 
$GTM << aaa
write "do ^simpleUnicodeIO(""UTF-8"")",!
do ^simpleUnicodeIO("UTF-8")
h
aaa
#
$GTM << aaa
write "do ^simpleUnicodeIO(""UTF-16"")",!
do ^simpleUnicodeIO("UTF-16")
h
aaa
#
$GTM << aaa
write "do ^simpleUnicodeIO(""UTF-16LE"")",!
do ^simpleUnicodeIO("UTF-16LE")
h
aaa
#
$GTM << aaa
write "do ^simpleUnicodeIO(""UTF-16BE"")",!
do ^simpleUnicodeIO("UTF-16BE")
h
aaa
#
$GTM << aaa
write "do ^simpleUnicodeIO(""M"")",!
do ^simpleUnicodeIO("M")
h
aaa
#
$GTM << aaa
write "do ^simpleUnicodeIO("""")",!
do ^simpleUnicodeIO("")
h
aaa
#
#
