#! /usr/local/bin/tcsh -f

if ($?test_replic == 1) then
	echo "This subtest is not applicable for replication"
	exit
endif

source $gtm_tst/com/dbcreate.csh mumps 4
$MUPIP set -region "*" $tst_jnl_str >& jnl.on
$GTM << EOF
s ^in4=0
l (^test1,^test2,^test3,^test4)
d ^mjnl
w "starting to switch journal files.",!
l -^test1
EOF

echo "starting to switch journal files."
$MUPIP set -region "*" $tst_jnl_str >>& jnl.on
sleep 5
$GTM << EOF
l -^test2
EOF
echo "starting to switch journal files."
$MUPIP set -region "*" $tst_jnl_str >>& jnl.on
sleep 5
$GTM << EOF
l -^test3
EOF
echo "starting to switch journal files."
$MUPIP set -region "*" $tst_jnl_str >>& jnl.on
sleep 5
$GTM << EOF
l -^test4
EOF
$GTM << EOF
f k=1:1:3000  q:^in4=16  h 1
i k=3000  w "Should we wait so long?",!
EOF
mkdir backup
mv *.dat backup
$MUPIP create
$MUPIP journal -recover -forward `echo *.mjl* | sed 's/ /,/g'` >>& rec_for.log
set stat1 = $status

grep "successful" rec_for.log
set stat2 = $status
if ($stat1 != 0 || $stat2 != 0) then
	echo "Multi_jnl_recover TEST FAILED" 
	cat  rec_for.log
	exit 1
endif
$GTM << EOF
w "d ^sverify",! d ^sverify
w "VERIFICATION PASSED",!
EOF
$gtm_tst/com/dbcheck.csh
