#These are the examples from the manual

set echoline = "echo =================================================================================="
###################################################
#FREAD
$echoline
echo "FREAD"
echo "one line" >>! text1.txt
echo "two lines" >>! text1.txt
cp text1.txt text2.txt
$convert_to_gtm_chset text1.txt
$convert_to_gtm_chset text2.txt
chmod -r text2.txt
$GTM << EOF
do ^fread("nonexist.txt")
do ^fread("text1.txt")
do ^fread("text2.txt")
halt
EOF

# correct permissions so that the file can be handled
chmod +r text2.txt


###################################################
#REPORT
$echoline
echo "REPORT"
$gtm_tst/com/dbcreate.csh . 1
$GTM << EOF
do ^report
EOF

cat temp.dat
$gtm_tst/com/dbcheck.csh
###################################################
# NULL device
$echoline
echo "NULL device"
$GTM << EOF
do ^null
halt
EOF
