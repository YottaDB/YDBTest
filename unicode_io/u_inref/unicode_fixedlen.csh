#!/usr/local/bin/tcsh -f
$switch_chset UTF-8 
$GTM << aaa
write "do ^unicodefixedlen(""UTF-8"")",!
do ^unicodefixedlen("UTF-8")
write "do ^unicodefixedlen(""UTF-16"")",!
do ^unicodefixedlen("UTF-16")
write "do ^unicodefixedlen(""UTF-16LE"")",!
do ^unicodefixedlen("UTF-16LE")
write "do ^unicodefixedlen(""UTF-16BE"")",!
do ^unicodefixedlen("UTF-16BE")
write "do ^unicodefixedlen(""M"")",!
do ^unicodefixedlen("M")
h
aaa
