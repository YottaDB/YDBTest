#!/usr/local/bin/tcsh -f
$switch_chset UTF-8 
$GTM << aaa
write "do ^varstr(""UTF-8"")",!
do ^varstr("UTF-8")
write "do ^varstr(""UTF-16"")",!
do ^varstr("UTF-16")
write "do ^varstr(""UTF-16LE"")",!
do ^varstr("UTF-16LE")
write "do ^varstr(""UTF-16BE"")",!
do ^varstr("UTF-16BE")
h
aaa
