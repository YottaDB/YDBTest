	;;; conclu.m
	s version=$P($ZV," ",2)
	s image=$$FUNC^%UCASE($P($ZPARSE("$gtm_exe"),"/",5))
	s profver=$ZTRNLNM("profileversion")
	s numaccts=$ZTRNLNM("numaccts")
	s prevdev=$IO
	s ^hostn=$$^findhost(1)
	s outfile=^hostn_".dat"
	d profile^serverconf(^hostn,"v"_profver,numaccts,image)
	s x="^SYSLOG"
	f  s x=$q(@x) q:x=""  s y=@x  d
	. s item=$p(y,"|",3) 
	. if '$D(^run(item)) s ^run(item)=0
	. if '$D(^zzzavg(item)) s ^zzzavg(item)=0
	. if '$D(^zzzstddev(item)) s ^zzzstddev(item)=0
	. s ^run(item)=^run(item)+1
	. s value=$p(y,"|",5)-$p(y,"|",4)
	. if 0>value set value=value+86400	;it must have been a day change
	. s ^value(item,^run(item))=value
	. s varn="^totaln(item,version,image)"  i '$D(@varn) s @varn=0
	. s varx="^totalx(item,version,image)"  i '$D(@varx) s @varx=0
	. s varsq="^totalsq(item,version,image)"  i '$D(@varsq) s @varsq=0
	. s @varn=@varn+1
	. s @varx=@varx+value
	. s @varsq=@varsq+(value*value)
	. s ^zzzcomp=^zzzavg(item)+(2*^zzzstddev(item))
	. u prevdev
	. i ^zzzcomp<value  w item," FAILED  (time in secs) actual = ",value," > ",^zzzcomp," = max acceptable (ave = ",^zzzavg(item),"+(2*",^zzzstddev(item)," = std dev))",!
	. e  d
	. . w item," PASSED (time in secs) actual = ",value," <= ",^zzzcomp," = max acceptable (ave = ",^zzzavg(item),"+(2*",^zzzstddev(item)," = std dev))",! 
	. o outfile:append 
	. u outfile 
	. w version,",",image,",",item,",",value,! 
	.c outfile 
	.u prevdev
	d ^compute	; writes out the computed avg and stddev from the data 
	q
