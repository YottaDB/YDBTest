operdata; this M routine populates data for the test_opers.csh subtest
	; 	It also sets the max to the maximum index
	set tempc="啊不二卡"
	set tempa="AZay"
	set tempn="019"
	set endc=$length(tempc)
	set enda=$length(tempa)
	set endn=$length(tempn)
	set counter=1
	for i=1:1:endc set a($e(tempc,i,i))=""
	for i=1:1:enda set a($e(tempa,i,i))=""
	for i=1:1:endn  do
	. set a($e(tempn,i,i))=""
	. set a($e(tempn,i,i)_$e(tempc,i*3-2,i*3))=""
	. set a($e(tempn,i,i)_$e(tempa,i,i))=""
	set a("00.10")=""
	set a("010.10")=""
	set a("10E2")=""
	zwrite a
	set counter=1 set i="" for  set i=$order(a(i)) quit:i=""  set b(counter)=i,counter=counter+1  ;write "a(",i,")=",a(i),!
	set max=counter-1
	;
	; Check ]] and ] operators
	;
	set errcnt=0
	for i=1:1:max   do
	. for j=1:1:max  do
	. . if i'>j  set expect=0
	. . else     set expect=1
	. . set actual=b(i)]]b(j)
	. . if expect'=actual do
	. . . set errcnt=errcnt+1
	. . . write "]] operator check failed : """,b(i),"""]]""",b(j),"""=",actual,":Expected=",expect,!
	. . if b(i)]b(j)'=actual do
	. . . write "]] and ] operator result differ : """,b(i),"""]""",b(j),"""=",b(i)]b(j)," : """,b(i),"""]]""",b(j),"""=",actual,!
	write "]] and ] operator verification PASS"
	quit
	;
