#!/usr/local/bin/tcsh -f
$switch_chset UTF-8 
$GTM << aaa
write "do ^unicodefiletest(""UTF-8"")",!
do ^unicodefiletest("UTF-8")
write "do ^unicodefiletest(""UTF-16"")",!
do ^unicodefiletest("UTF-16")
write "do ^unicodefiletest(""UTF-16LE"")",!
do ^unicodefiletest("UTF-16LE")
write "do ^unicodefiletest(""UTF-16BE"")",!
do ^unicodefiletest("UTF-16BE")
write "do ^unicodefiletest(""M"")",!
do ^unicodefiletest("M")
h
aaa
