#!/usr/local/bin/tcsh -f
#
echo "Current Time:`date +%H:%M:%S`" >>&! last_processed_tr.out
echo "FOR DEBUG INFO" >>&! last_processed_tr.out
echo `$grep "Last Seqno processed by update process" RCVR_$1.log | $tst_awk '{print $NF}'` >>&! last_processed_tr.out
set sec_seqno =  `$grep "Last Seqno processed by update process" RCVR_$1.log | $tst_awk '{print $NF}'`
echo $sec_seqno
