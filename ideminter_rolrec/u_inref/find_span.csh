#!/usr/local/bin/tcsh
# given since/before times or seqno and max_seqno), find the span (in secs or seqnos) or the recover/rollback command
# if there is an argument $1, that means it was idempotent, hence do a diff od r2-r1 instead of maxseqno-r2
set tmpvar = 0
set span = $tmpvar
ls RECOVER* >& /dev/null
@ rec = 1 - $status
if ($rec) then
	set t1 = `cat since_time${logno}.txt`
	set t2 = `cat before_time${logno}.txt`
	set tmpvar = `echo $t1 $t2 | $tst_awk '{print $2 - $1}'`
	echo "TEST-I-find_span.csh : span was determined to be $tmpvar using since_time${logno}.txt and before_time${logno}.txt (" `cat since_time${logno}.txt` `cat before_time${logno}.txt` ")" >>! find_span.out
	mv since_time${logno}.txt since_time${logno}.txt_`date +%H_%M_%S`
	mv before_time${logno}.txt before_time${logno}.txt_`date +%H_%M_%S`
else
	set r1 = `cat  seqno${logno}.txt`
	set r2file = max_seqno.txt
	# for IDEMPOTENT, use the previous resync seqno (except for the first one, which should use max_seqno)
	if (("IDEMP" == "$1") && ("1_1" != $logno)) set r2file = `ls -rt seqno* | $tail -n 2 | $head -n 1`
	set r2 = `cat $r2file`
	set tmpvar = `echo $r1 $r2 |  $tst_awk '{print $2 - $1}'`
	if ((0 == $r1) || (0 == $r2)) set tmpvar = 0
	echo "TEST-I-find_span.csh : using seqno${logno}.txt and $r2file (" `cat seqno${logno}.txt` and `cat $r2file` ") span was found to be $tmpvar" >>! find_span.out
	mv seqno${logno}.txt seqno${logno}.txt_`date +%H_%M_%S`
endif
if (0 > $tmpvar) then
	set tmpvar = 0
endif
set span = $tmpvar
