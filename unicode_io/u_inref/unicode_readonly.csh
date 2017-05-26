#!/usr/local/bin/tcsh -f
$switch_chset UTF-8 
$GTM << aaa
write "do ^unicodereadonly(""UTF-8"")",!
do ^unicodereadonly("UTF-8")
write "do ^unicodereadonly(""UTF-16"")",!
do ^unicodereadonly("UTF-16")
write "do ^unicodereadonly(""UTF-16LE"")",!
do ^unicodereadonly("UTF-16LE")
write "do ^unicodereadonly(""UTF-16BE"")",!
do ^unicodereadonly("UTF-16BE")
write "do ^unicodereadonly(""M"")",!
do ^unicodereadonly("M")
h
aaa
