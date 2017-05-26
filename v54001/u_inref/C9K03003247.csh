#!/usr/local/bin/tcsh -f

# Test that with encryption, MUPIP CREATE does NOT issue "libgcrypt" warnings in syslog.

set syslog_before = `date +"%b %e %H:%M:%S"`

$gtm_tst/com/dbcreate.csh mumps 1
$GTM << EOF 
for i=1:1:100  Set ^a(i)=\$J(i,100)
halt
EOF

set syslog_after = `date +"%b %e %H:%M:%S"`
$echoline
echo "Test if libgcrypt warnings are seen in syslog"
$echoline
echo ""
echo ""
$gtm_tst/com/getoper.csh "$syslog_before" "$syslog_after" syslog1.txt

set count = `$grep "Libgcrypt warning" syslog1.txt | wc -l`
if ($count) then
	echo "TEST-E-FAILED : Libgcrypt warning seen in syslog"
else
	echo "TEST-I-PASSED : Libgcrypt warning NOT seen in syslog as expected"
endif
$gtm_tst/com/dbcheck.csh
