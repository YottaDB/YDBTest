#!/usr/local/bin/tcsh

echo "Seize critical section for process A-----------------------------"

$DSE <<EOF >&! fix_endiana.txt
change -fileheader -location=1000 -value=55 -size=1
crit -seize
crit
spawn $gtm_tst/$tst/u_inref/dse_critb_fhead.csh 
crit -rel
change -fileheader -location=1000 -value=66 -size=1
exit
EOF

awk '{print}' fix_endiana.txt | sed 's/Old Value = 85 \[0x0055\]/Old Value = XX [0xXXXX]/g' | sed 's/Old Value = 21760 \[0x5500\]/Old Value = XX [0xXXXX]/g' | sed 's/Old Value = 34 \[0x22\]/Old Value = XX [0xXX]/g' | sed 's/Old Value = 0 \[0x00\]/Old Value = XX [0xXX]/g'

echo "Leaving critical section for process A------------------------"
