#!/usr/local/bin/tcsh -f
# get_fetch_resync.csh <log_file> 
# Reads fetch resync sequence number from the log 
grep "RLBKJNSEQ, Journal seqno of the instance after rollback is" $1 | $tst_awk '{print($10);}'

