fnlgstr;; This tests the functionality of various functions with
	;; with large string
	write "Create five strings of length: 32k,65k,130k,196k,and 1MB",!
	set str1="AAA"_$$^longstr(32765)
	set str2="BBB"_$$^longstr(65533)
	set str3="CCC"_$$^longstr(131069)
	set str4="DDD"_$$^longstr(196605)
	set str5="EEE"_$$^longstr(1048573)
	write "Now set local array with large local variable",!
	set lclarr(str1)=1
	set lclarr(str2)=2
	set lclarr(str3)=3
	set lclarr(str4)=4
	set lclarr(str5)=5
	write "================== $order() ==============================",!
	set x="" for  s x=$o(lclarr(x)) q:x=""  w $length(x)," ",$extract(x,1,3),!
	write "================== $zprevious() ==================================",!
	write "Output will be in the reverse order of $order() output",!
	set x="" for  s x=$zp(lclarr(x)) q:x=""  w $length(x)," ",$extract(x,1,3),!
	write "================ $NEXT() ==================================",!
	;; $next() is obsolete in favor of $order()
	set x="" for  s x=$n(lclarr(x)) q:x="-1"  w $length(x),!
	write "================== $query() ====================================",!
	set y="lclarr"
	set p=$q(@y) w $length(p)," ",$extract(p,9,11),!
	set q=$q(lclarr(str1)) if $length(q)>0 write $length(q)," ",$extract(q,9,11),! else  write $length(q),!
	set r=$q(lclarr(str2)) w $length(r)," ",$extract(r,9,11),!
	set t=$q(lclarr(str3)) w $length(t)," ",$extract(t,9,11),!
	set u=$q(lclarr(str4)) w $length(u)," ",$extract(u,9,11),!
	set v=$q(lclarr(str5)) w $length(v)," ",$extract(v,9,11),!
	write "======================= $extract() =========================",!
	set x=$e(str5,1048570,1048576) w x,!
	set x=$e(str5,32765,65540) w $length(x),!
	set str6=$$^longstr(1048576-3)
	set str7=$$^longstr(1048576-5)
	set $extract(str6,1,1048576)=str7
	write "length of str6 is: ",$length(str6),"(expected 1048571)",!
	write "======================= $piece()=================================",!
	set s1="" f i=1:1:32767 s s1=s1_"X"
	set s1=s1_"delim"
	f i=32773:1:65538 s s1=s1_"Y"
	set s1=s1_"delim"_"123456"
	write $length($p(s1,"delim")),!
	write $length($p(s1,"delim",1)),!
	q
