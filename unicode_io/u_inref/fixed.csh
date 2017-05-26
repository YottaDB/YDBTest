#!/usr/local/bin/tcsh -f
$switch_chset UTF-8 
$GTM << aaa
write "do ^fixed(""UTF-8"")",!
do ^fixed("UTF-8")
write "do ^fixed(""UTF-16"")",!
do ^fixed("UTF-16")
write "do ^fixed(""UTF-16LE"")",!
do ^fixed("UTF-16LE")
write "do ^fixed(""UTF-16BE"")",!
do ^fixed("UTF-16BE")
h
aaa
