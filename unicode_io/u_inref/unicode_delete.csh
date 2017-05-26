#!/usr/local/bin/tcsh -f
$switch_chset UTF-8 
$GTM << aaa
write "do ^unicodedelete(""UTF-8"")",!
do ^unicodedelete("UTF-8")
write "do ^unicodedelete(""UTF-16"")",!
do ^unicodedelete("UTF-16")
write "do ^unicodedelete(""UTF-16LE"")",!
do ^unicodedelete("UTF-16LE")
write "do ^unicodedelete(""UTF-16BE"")",!
do ^unicodedelete("UTF-16BE")
write "do ^unicodedelete(""M"")",!
do ^unicodedelete("M")
h
aaa
