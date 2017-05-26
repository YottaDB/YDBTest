#!/usr/local/bin/tcsh -f
$switch_chset UTF-8 
$GTM << aaa
write "do ^unicodelength(""UTF-8"")",!
do ^unicodelength("UTF-8")
write "do ^unicodelength(""UTF-16"")",!
do ^unicodelength("UTF-16")
write "do ^unicodelength(""UTF-16LE"")",!
do ^unicodelength("UTF-16LE")
write "do ^unicodelength(""UTF-16BE"")",!
do ^unicodelength("UTF-16BE")
write "do ^unicodelength(""M"")",!
do ^unicodelength("M")
h
aaa
