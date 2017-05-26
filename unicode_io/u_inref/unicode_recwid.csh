#!/usr/local/bin/tcsh -f
$switch_chset UTF-8 
$GTM << aaa
write "do ^unicoderecwid(""UTF-8"")",!
do ^unicoderecwid("UTF-8")
write "do ^unicoderecwid(""UTF-16"")",!
do ^unicoderecwid("UTF-16")
write "do ^unicoderecwid(""UTF-16LE"")",!
do ^unicoderecwid("UTF-16LE")
write "do ^unicoderecwid(""UTF-16BE"")",!
do ^unicoderecwid("UTF-16BE")
h
aaa
