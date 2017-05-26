main;
	kill
	do charcmp
	kill
	do strcmp
	quit
charcmp;
	set fail=""
	for i=1:1:$$FUNC^%HD("10FFFF") do  quit:fail'=""
	. set fail=""
	. set uchar1=$C(i-1)
	. set uchar2=$C(i)
	. if ((uchar1'="")&(uchar2'="")) do
	. . if $ascii(uchar2)<$ascii(uchar1) set fail="<"
	. . if $ascii(uchar2)'<$ascii(uchar1) set pass="'<"
	. . if $ascii(uchar2)>$ascii(uchar1) set pass=">"
	. . if $ascii(uchar2)'>$ascii(uchar1) set fail="'>"
	. . if uchar2]uchar1 set pass="]"		; if uchar2 follows uchar1?
	. . if uchar2']uchar1 set fail="']"
	. . ; 
	. . if uchar2=uchar1 set fail="="
	. . if uchar2'=uchar1 set pass="'="
	. . if uchar2[uchar1 set fail="["		; if uchar2 contains uchar1?
	. . if uchar2'[uchar1 set pass="'["	
	. . if i>59 do
	. . . if uchar2]]uchar1 set pass="]]"	; if uchar2 sorts after uchar1?
	. . . if uchar2']]uchar1 set fail="']]"
	. . if fail'="" write "Test Failed",!,"zwr=",! zwr
	if (i=$$FUNC^%HD("10FFFF")) write "charcmp^unicodeif Completed Successfully",!
	quit
strcmp;
	set failcnt=0
	for i=1:1:100 do  quit:failcnt'=0
	. do comparestr($$^ulongstr($r(1000)),$$^ulongstr($r(1000)))
	if failcnt=0 write "strcmp^unicodeif Completed Successfully",!
	quit
comparestr(ustr1,ustr2)
	if ((ustr1="")!(ustr2="")) quit
	if ustr1[ustr2 do
	. set result=$$contains(ustr1,ustr2)
	. if result'=1 write "Contains([) test fails:i=",i,!,"ustr1=",ustr1,":",!,"ustr2=",ustr2,":",!  set failcnt=failcnt+1
	if ustr1=ustr2 do
	. set result=$$equalstr(ustr1,ustr2)
	. if result'=1 write "Equality(=) test fails:i=",i,!,"ustr1=",ustr1,":",!,"ustr2=",ustr2,":",!  set failcnt=failcnt+1
	if ustr1'=ustr2 do
	. set result=$$equalstr(ustr1,ustr2)
	. if result=1 write "Not-Equality ('=)test fails:i=",i,!,"ustr1=",ustr1,":",!,"ustr2=",ustr2,":",!  set failcnt=failcnt+1
	if ustr2]]ustr1 do
	. set result=$$sortsafter(ustr2,ustr1)
	. if result'=1 write "Sorts after(]]) test fails:i=",i,!,"ustr2=",ustr2,": does not sort after ",!,"ustr1=",ustr1,":",!  set failcnt=failcnt+1
	if ustr2']]ustr1 do
	. set result=$$sortsafter(ustr2,ustr1)
	. if result=1 write "Does not Sort after(']]) test fails:i=",i,!,"ustr2=",ustr2,": sorts after ",!,"ustr1=",ustr1,":",!  set failcnt=failcnt+1
	quit

equalstr(ustr1,ustr2)
	new cnt,pass,len1,len2
	set len1=$length(ustr1)
	set len2=$length(ustr2)
	if len1'=len2 quit 0
	set pass=1
	for cnt=1:1:len1 do  quit:pass=0
	. if $extract(ustr1,cnt,cnt)'=$extract(ustr2,cnt,cnt) set pass=0
	quit pass

sortsafter(ustr2,ustr1)
	new cnt,pass,len1,len2
	set len1=$length(ustr1)
	set len2=$length(ustr2)
	if len2>len1 set len=len1
	else  set len=len2
	set done=0
	for cnt=1:1:len do  quit:done=1
	. set char1=$ascii(ustr1,cnt)
	. set char2=$ascii(ustr2,cnt)
	. if char1'=char2 do
	. . set done=1
	. . if char1>char2 set pass=0
	. . else  set pass=1
	if done=0  do
	. ; One of them is substring of another.
	. if len2>len1 set pass=1
	. else  set pass=0
	quit pass

contains(ustr1,ustr2)
	new len1,len2	
	set len1=$length(ustr1)
	set len2=$length(ustr2)
	if len2>len1 quit 0
	if $find(ustr1,ustr2) set pass=1
	else  set pass=0
	quit pass
