dollarzdate	; exhaustive $zdate() test
	; set hourlog to  FRI, JUL 04 2008 01:19:18 PM (instead of $H) to keep the reference file simple.
	new (act)
	If '$data(act) new act set act="write ! zshow ""isv"""
	new $estack,$etrap
	set $ecode="",$etrap="goto error",zl=$zlevel
	set h=61181
	set hfull="61181,47958"
	write "Print $zdate with all possible format specifiers",!
	write "*** SECTION 1 ***",!
	write "Simple checks without month and day codes",!
	write !,"----- Only day format specification elements -----",!
	for i=h,hfull do
	. write "Testing the value ",i,!
	. write "$ZDATE()         : ",$ZDATE(i),!
	. write "2 digit year     : ",$zdate(i,"YY"),!
	. write "4 digit year     : ",$zdate(i,"YEAR"),!
	. write "numeral month    : ",$zdate(i,"MM"),!
	. write "3 lettered month : ",$zdate(i,"MON"),!
	. write "digit day        : ",$zdate(i,"DD"),!
	. write "3 lettered day   : ",$zdate(i,"DAY"),!
	. write "DD-MON-YEAR      : ",$zdate(i,"DD-MON-YEAR"),!
	. write "MM/DD/YY         : ",$zdate(i,"MM/DD/YY"),!
	. write "DAY, MON DD YEAR : ",$zdate(i,"DAY, MON DD YEAR"),!
	write !,"----- day-time format specification elements -----",!
	for i=hfull do
	. write "Testing the value ",i,!
	. write "Hour in 24   : ",$zdate(i,"24"),!
	. write "Hour in 12   : ",$zdate(i,"12"),!
	. write "Minute       : ",$zdate(i,"60"),!
	. write "Second       : ",$zdate(i,"SS"),!
	. write "AM/PM        : ",$zdate(i,"AM"),!
	. write "24:60:SS     : ",$zdate(i,"24:60:SS"),!
	. write "Some format  : ",$zdate(i,"+12:60:SS AM"),!
	. write "Funny format : ",$zdate(i,"* MON DD, YY. DAY ; 12:60:SS AM *"),!
	;
	set germanmonths="Januar,Februar,März,April,Mai,Juni,Juli,August,September,Oktober,November,Dezember"
	set frenchdays="Dimanche,Lundi,Mardi,Mercredi,Jeudi,Vendredi,Samedi"
	for round=1:1:3 do
	. if (1=round) do
	. . write !,"*** SECTION 2 ***",!
	. . write "Essentially the same commands as above. But with month codes",!
	. . set monthcodes=germanmonths
	. . set daycodes=""
	. if (2=round) do
	. . write !,"*** SECTION 3 ***",!
	. . write "Essentially the same commands as above. But with day codes",!
	. . set monthcodes=""
	. . set daycodes=frenchdays
	. if (3=round) do
	. . write !,"*** SECTION 4 ***",!
	. . write "Essentially the same commands as above. But with both month and day codes",!
	. . set monthcodes=germanmonths
	. . set daycodes=frenchdays
	. write "monthcodes : ",monthcodes,!
	. write "daycodes   : ",daycodes,!
	. write !,"----- Only day format specification elements -----",!
	. for i=h,hfull do
	. . write "Testing the value ",i,!
	. . write "2 digit year     : ",$zdate(i,"YY",monthcodes,daycodes),!
	. . write "4 digit year     : ",$zdate(i,"YEAR",monthcodes,daycodes),!
	. . write "numeral month    : ",$zdate(i,"MM",monthcodes,daycodes),!
	. . write "Month            : ",$zdate(i,"MON",monthcodes,daycodes),!
	. . write "digit day        : ",$zdate(i,"DD",monthcodes,daycodes),!
	. . write "day of the week  : ",$zdate(i,"DAY",monthcodes,daycodes),!
	. . write "DD-MON-YEAR      : ",$zdate(i,"DD-MON-YEAR",monthcodes,daycodes),!
	. . write "MM/DD/YY         : ",$zdate(i,"MM/DD/YY",monthcodes,daycodes),!
	. . write "DAY, MON DD YEAR : ",$zdate(i,"DAY, MON DD YEAR",monthcodes,daycodes),!
	. write !,"----- day-time format specification elements -----",!
	. for i=hfull do
	. . write "Testing the value ",i,!
	. . write "Hour in 24   : ",$zdate(i,"24",monthcodes,daycodes),!
	. . write "Hour in 12   : ",$zdate(i,"12",monthcodes,daycodes),!
	. . write "Minute       : ",$zdate(i,"60",monthcodes,daycodes),!
	. . write "Second       : ",$zdate(i,"SS",monthcodes,daycodes),!
	. . write "AM/PM        : ",$zdate(i,"AM",monthcodes,daycodes),!
	. . write "24:60:SS     : ",$zdate(i,"24:60:SS",monthcodes,daycodes),!
	. . write "Some fomat   : ",$zdate(i,"+12:60:SS AM",monthcodes,daycodes),!
	. . write "Funny format : ",$zdate(i,"* MON DD, YY. DAY ; 12:60:SS AM *",monthcodes,daycodes),!
	set d=-366
	for y=1840:1 do   quit:y'=+r!("DEC 31"'=$extract(r,8,13))!(1000000=y)
	. set d=d+365
	. if y#4=0 set d=d+1			;leap years
	. if (y)#100=0,((y)#400) set d=d-1	; but not centuries, except leap centuries
	. if 1000000'=y set r=$zdate(d,"YYYYYY MON DD")
	if 1000000'=y write !,"Bad date: ",r
	set expect="ZDATEBADDATE",context(0)=d
	set x=$zdate(d) if $increment(cnt) xecute act
	set context(0)=10000000000000000000000000000000
	set x=$zdate("10000000000000000000000000000000,0") if $increment(cnt) xecute act
	set context(0)=-3,x=-365
	for y=x+(28-$zdate(x,"DD")):1 if $zdate(y,"MM") quit
	set context(0)=-1
	set x=$zdate("-366,86399") if $increment(cnt) xecute act
	set expect="ZDATEBADTIME"
	set x=$zdate("0,-1") if $increment(cnt) xecute act
	set context(0)=86400
	set x=$zdate("0,86400") if $increment(cnt) xecute act
	quit
zdateunicode	; unicode version
	write !,"*** SECTION 5 ***",!
	write "Test $ZDate with UNICODE values for daycodes",!
	set i="61181,47968"
	set daycodes="ஞாயிறு, திங்கள், செவ்வாய், புதன், வியாழன்,  வெள்ளி,  சனி"
	set monthcodes=""
	write "DAY, MON DD YEAR : ",$zdate(i,"DAY, MON DD YEAR",monthcodes,daycodes),!
	write "Funny format : ",$zdate(i,"* MON DD, YY. DAY ; 12:60:SS AM *",monthcodes,daycodes),!
	quit
error	for lev=$stack:-1:0 set loc=$stack(lev,"PLACE") quit:loc[("^"_$text(+0))
	set next=zl_":"_$p(loc,"+")_"+"_($piece(loc,"+",2)+1)_"^"_$piece(loc,"^",2)
	set status=$zstatus,stat="\"_$piece($piece(status,"-",3),",")
	if status'[$get(expect)!(""=$get(expect)),$increment(cnt) write !,$stack(lev,"MCODE") xecute act
	for qecxti=0:1 quit:""=$get(context(qecxti))  if status'[context(qectxi),$incr(cnt) write !,$stack(lev,"MCODE") xecute act
	set $ecode=""
	zgoto @next
