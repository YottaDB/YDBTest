#!/usr/local/bin/tcsh -f
$switch_chset "UTF-8" >&! switch_chset.out
$gtm_tst/com/dbcreate.csh mumps
$GTM<<EOF
lock +faultylock("槥넾믰冣","楻漠ᥖ츻‎驞頼⎞嫓茴놣嫌唹ધ洼畭尬","----","AAAAABBBBBCCCCCDDDDDEEEEEAAAAABBBBBCCCCCDDDDDEEEEEAAAAABBBBBCCCCCDDDDDEEEEEAAAAABBBBBCCCCCDDDDDEEEEEAAAAABBBBBCCCCCDDDDDEEEEEAAAAABBBBBCCCCCDDDDDEEEEEAAAAABBBBBCCCCCDDDDDEEEEEAAAAABBBBBCCCCCDDDDDEEEEEAAAAABBBBBCCCCCDDDDDEEEEEAAAAABBBBBCCCCCDDDDDEEEEE1234567890","----")
EOF
$GTM<<EOF
lock +faultylock("槥넾믰冣","楻漠ᥖ츻‎驞頼⎞嫓茴놣嫌唹ધ洼畭尬","----","AAAAABBBBBCCCCCDDDDDEEEEEAAAAABBBBBCCCCCDDDDDEEEEEAAAAABBBBBCCCCCDDDDDEEEEEAAAAABBBBBCCCCCDDDDDEEEEEAAAAABBBBBCCCCCDDDDDEEEEEAAAAABBBBBCCCCCDDDDDEEEEEAAAAABBBBBCCCCCDDDDDEEEEEAAAAABBBBBCCCCCDDDDDEEEEEAAAAABBBBBCCCCCDDDDDEEEEEAAAAABBBBBCCCCCDDDDDEEEEE1234567890槥넾믰冣","----")
EOF
$GTM<<EOF
lock +oklock(4,"erer넾믰","nabermorukkeyifleryerindemi?!?!?","çekoslavakyalılaştıramadıklarımızdanmısınız","AHYONKARAHİSARLILAŞTIRAMMIZDAISINIZ槥넾믰")
lock +limitlock(5,100,"LLL","YYY","pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|12345")
lock +limitlockpassby1(5,100,"LLL","YYY","pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|pppp|123456")
EOF
$gtm_tst/com/dbcheck.csh mumps
