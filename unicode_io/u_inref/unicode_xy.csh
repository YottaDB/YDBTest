#!/usr/local/bin/tcsh -f
$switch_chset UTF-8 
$GTM << \aaa
set ulongstr31=$$^ulongstr(31*1024)
set ulongstr32=$$^ulongstr(32*1024)
set ulongstr33=$$^ulongstr(33*1024)
set ulongstr1024a=$$^ulongstr(1024*1024)
set ulongstr1024b=$$^ulongstr(1024*1024-20)
write "do ^unicodexy(""UTF-8"")",!
do ^unicodexy("UTF-8")
write "do ^unicodexy(""UTF-16"")",!
do ^unicodexy("UTF-16")
write "do ^unicodexy(""UTF-16LE"")",!
do ^unicodexy("UTF-16LE")
write "do ^unicodexy(""UTF-16BE"")",!
do ^unicodexy("UTF-16BE")
write "do ^unicodexy(""M"")",!
do ^unicodexy("M")
h
\aaa
