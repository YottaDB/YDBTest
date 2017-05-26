#!/usr/local/bin/tcsh -f
# Verify that special indices used by spanning nodes are properly displayed (#SPAN1)
# Verify that sn can be found with "find -key"

$GDE change -region DEFAULT -null_subscripts=always -stdnull -rec=4000
$gtm_exe/mupip create

$GTM <<EOF
set ^nsgbl="BEGIN"_\$JUSTIFY(" ",3000)_"END"
set ^nsgbl(1)="BEGIN"_\$JUSTIFY(" ",3500)_"END"
set ^nsgbl("erdeniz")="BEGIN"_\$JUSTIFY(" ",3500)_"END"
EOF

echo "#SPAN1 tag exists for global ^ngbl?"
set blockno=`$gtm_exe/dse find -key="^nsgbl" | & $tst_awk '{if ($1=="Key") {print $5}}' | tr -d "\."`
$gtm_exe/dse dump -block=$blockno | & $grep -c "\#SPAN1"
echo "#SPAN1 tag exists for global ^ngbl(1)?"
set blockno=`$gtm_exe/dse find -key="^nsgbl(1)" | & $tst_awk '{if ($1=="Key") {print $5}}' | tr -d "\."`
$gtm_exe/dse dump -block=$blockno | & $grep -c "\#SPAN1"
echo '#SPAN1 tag exists for global ^ngbl("erdeniz")?'
set blockno=`$gtm_exe/dse find -key='^nsgbl("""erdeniz""")' | & $tst_awk '{if ($1=="Key") {print $5}}' | tr -d "\."`
$gtm_exe/dse dump -block=$blockno | & $grep -c "\#SPAN1"
