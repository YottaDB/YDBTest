#!/usr/local/bin/tcsh

echo "In process B for write to critical section-----------------"
$DSE <<QQQ >&! fix_endianb.txt
crit
change -fileheader -location=1000 -value=22 -size=2 -nocrit
exit
QQQ

awk '{print}' fix_endianb.txt | sed 's/Old Value = 0 \[0x00\]/Old Value = XX [0xXX]/g' | sed 's/Old Value = 34 \[0x22\]/Old Value = XX [0xXX]/g'

echo "leaving process B-----------------------------"
