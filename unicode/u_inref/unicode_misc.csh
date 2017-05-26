#! /usr/local/bin/tcsh -f
setenv gtm_badchar "no"
$switch_chset UTF-8 
mkdir 我能吞下玻璃而不伤身体
mkdir 我能吞下玻璃而不伤身体\αβγδε
mkdir 我能吞下玻璃而不伤身体\①②③④⑤⑥⑦⑧
setenv UNICODE 我能吞下玻璃而不伤身体
source $gtm_tst/com/dbcreate.csh mumps 1 255 1000
$GTM << GTM_EOF
write "do ^unizsys",!
do ^unizsys
k
write "do ^unicodeif",!
do ^unicodeif
k
write "do ^unicodeIncrement",!
do ^unicodeIncrement
k
write "do ^unicodeQlengthName",!
do ^unicodeQlengthName
k
write "do ^unicodeQsubscript",!
do ^unicodeQsubscript
k
write "do ^unicodeReverse",!
do ^unicodeReverse
k
write "do ^unicodeZtrap",!
do ^unicodeZtrap
h
GTM_EOF
#
$gtm_exe/mumps -r unicodeArg "我能吞下玻璃而不伤身体" αβγδε "①②③④⑤⑥⑦⑧"
#
$gtm_tst/com/dbcheck.csh
