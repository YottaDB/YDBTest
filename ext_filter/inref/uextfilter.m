	; External filter, simplistic echo back filter
	s $ztrap="g err"
	s TSTART="08"
	s TCOMMIT="09"
	s EOT="99"
	s log="log.extout"
	s EOL=$C(10)
	open log:(newversion:ochset="UTF-8")
	u $p:(nowrap)
	f  d
	. u $p
	. r extrRec
	. s rectype=$p(extrRec,"\",1)
	. i rectype'=EOT d
	.. i rectype'=TSTART set filtrOut=extrRec_EOL
	.. e  d
	... s filtrOut=extrRec_EOL
	... f  r extrRec s filtrOut=filtrOut_extrRec_EOL q:$e(extrRec,1,2)=TCOMMIT
	.. ; s $x=0 is needed so every write starts at beginning of record position
	.. ; don't write more than "width" characters in one output operation to avoid "chopping" of output 
	.. ; and/or eol in the middle of output stream
	.. f  s $x=0 w $e(filtrOut,1,32767) q:$l(filtrOut)'>32767  s filtrOut=$e(filtrOut,32768,$l(filtrOut))
	. u log
	. w "Received: ",EOL,$s(rectype'=TSTART:extrRec_EOL,1:filtrOut)
	. i rectype'=EOT w "Sent: ",EOL,filtrOut
	. e  w "EOT received, halting..." h
	q

err
	u log
	w !!!,"**** ERROR ENCOUNTERED ****",!!!
	zshow "*"
	h
