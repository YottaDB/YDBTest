#!/usr/local/bin/tcsh -f
$switch_chset UTF-8 
$GTM << aaa
write "do ^basicUnicodeIO",!
do ^basicUnicodeIO
h
aaa
