pinifini	; replacement for pini_pfini.csh
	set notjob=1
	goto doit
job	w "Start Time : ",$ZD($H,"DD-MON-YEAR 24:60:SS")," $JOB : "_$JOB,!
	kill notjob
doit	set max=20
	for count=0:1:max do
	. set cnt=$increment(^apinpfn)
	. if ^apinpfn=21 do ^sincetm("time1.txt")
	. if $r(4)>0 s ^bpinpfn(cnt)=$j
	. if $r(4)>0 s ^cpinpfn(cnt)=$j
	. if $r(4)>0 s ^dpinpfn(cnt)=$j
	. if $r(4)>0 s ^epinpfn(cnt)=$j
	. if ^apinpfn<10 do jobit
	. if $r(4)>0 s ^fpinpfn(cnt)=$j
	. if $r(4)>0 s ^gpinpfn(cnt)=$j
	. if $r(4)>0 s ^hpinpfn(cnt)=$j
	. if $r(4)>0 s ^ipinpfn(cnt)=$j
	. if ^apinpfn<30 do jobit
	if $data(notjob)=0 do
	. w "Finish Time : ",$ZD($H,"DD-MON-YEAR 24:60:SS")," $JOB : "_$JOB," cnt : "_cnt,!
	h
jobit   s out="pinifini_"_$increment(^pinijobcnt)
        s jobstr="job^pinifini:(out="""_out_"nc.mjo"":err="""_out_"nc.mje"")"
        job @jobstr
        q
