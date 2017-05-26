badconv	; External filter, simplistic echo back filter, except that it outputs wrong values
	; see "deadbeef" below
	; The test input consists of one mini-transaction followed by a TSTART, 2 transactions, and a TCOMMIT for a
	; total of 5 lines
	; Based on the ramdom number below it will prepend deadbeef to the beginning of line 0-4
	s $ztrap="g err"
	s TSTART="08"
	s TCOMMIT="09"
	s EOT="99"
	s log="log.extout"
	s rnd=$RANDOM(5)
	i $zv["VMS" s EOL=$C(13)_$C(10)
	e  s EOL=$C(10)
	open log:newversion
	u $p:(nowrap)
	f  d
	. s line=0
	. u $p
	. r extrRec
	. s rectype=$p(extrRec,"\",1)
	. i rectype'=EOT d
	.. i rectype'=TSTART s filtrOut=extrRec_EOL
	.. e  d
	... s line=2
	... s filtrIn=extrRec_EOL
	... if rnd=1 s filtrOut="deadbeef"_extrRec_EOL
	... else  s filtrOut=extrRec_EOL
	... f  r extrRec q:$e(extrRec,1,2)=TCOMMIT  do
	.... s filtrIn=filtrIn_extrRec_EOL
	.... if line=rnd s filtrOut=filtrOut_"deadbeef"_extrRec_EOL
	.... else  s filtrOut=filtrOut_extrRec_EOL
	.... set line=line+1
	... s filtrIn=filtrIn_extrRec_EOL
	... if line=rnd s filtrOut=filtrOut_"deadbeef"_extrRec_EOL
	... else  s filtrOut=filtrOut_extrRec_EOL
	.. ; corrupt the output string
	.. if (rnd=0)&(line=0) set filtrOut="deadbeef"_filtrOut
	.. ; s $x=0 is needed so every write starts at beginning of record position
	.. ; don't write more than "width" characters in one output operation to avoid "chopping" of output 
	.. ; and/or eol in the middle of output stream
	.. f  s $x=0 w $e(filtrOut,1,32767) q:$l(filtrOut)'>32767  s filtrOut=$e(filtrOut,32768,$l(filtrOut))
	. u log
	. w "Received: ",EOL,$s(rectype'=TSTART:extrRec_EOL,1:filtrIn)
	. i rectype'=EOT w "Sent: ",EOL,filtrOut
	. e  w "EOT received, halting..." h
	q

err
	u log
	w !!!,"**** ERROR ENCOUNTERED ****",!!!
	zshow "*"
	h
