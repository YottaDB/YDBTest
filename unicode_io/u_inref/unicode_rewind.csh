#!/usr/local/bin/tcsh -f
$switch_chset UTF-8 
$GTM << \aaa
set ulongstr9=$$^ulongstr(9)
set ulongstr15=$$^ulongstr(15)
set ulongstr32=$$^ulongstr(32*1024)
set ulongstr64=$$^ulongstr(64*1024)
set ulongstr128=$$^ulongstr(128*1024)
set ulongstr1024=$$^ulongstr(1024*1024)
write "do ^unicoderewind(""UTF-8"")",!
do ^unicoderewind("UTF-8")
write "do ^unicoderewind(""UTF-16"")",!
do ^unicoderewind("UTF-16")
write "do ^unicoderewind(""UTF-16LE"")",!
do ^unicoderewind("UTF-16LE")
write "do ^unicoderewind(""UTF-16BE"")",!
do ^unicoderewind("UTF-16BE")
write "do ^unicoderewind(""M"")",!
do ^unicoderewind("M")
h
\aaa
