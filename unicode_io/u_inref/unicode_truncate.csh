#!/usr/local/bin/tcsh -f
$switch_chset UTF-8 
$GTM << \aaa
set s32k=$$^ulongstr(32768)
set s1mb=$$^ulongstr(1048576)
write "do ^unicodetruncate(""UTF-8"")",!
do ^unicodetruncate("UTF-8")
write "do ^unicodetruncate(""UTF-16"")",!
do ^unicodetruncate("UTF-16")
write "do ^unicodetruncate(""UTF-16LE"")",!
do ^unicodetruncate("UTF-16LE")
write "do ^unicodetruncate(""UTF-16BE"")",!
do ^unicodetruncate("UTF-16BE")
write "do ^unicodetruncate(""M"")",!
do ^unicodetruncate("M")
write "Test for unicode TRUNCATE with different line terminators",!
do ^truncatelineterm
h
\aaa
echo "unicode_truncate test ends"
