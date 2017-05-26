atomic	;	
	write "Long Name test for atomic indirection",!
	do atmcset("set",0,"^")
	do atmcset("ver",0,"^")
	do atmcset("set",1,"^")
	do atmcset("ver",1,"^")
	do atmcset("set",2,"^")
	do atmcset("ver",2,"^")
	do atmcset("set",0,"")
	do atmcset("ver",0,"")
	do atmcset("set",2,"")
	do atmcset("ver",2,"")
	do atmcset("set",4,"")
	do atmcset("ver",4,"")
	
	;direct set and with % as first character
	set @"xyz4567890123456789012345678901"=1
	set @"^xyz4567890123456789012345678901"=1
	set @"^%xyz567890123456789012345678901(1,""subs"")"=1
	set @"%xyz567890123456789012345678901(1,""subs"",""subs2"")"=1

	set @"xyz456789012345678901234567890"=0
	set @"^xyz456789012345678901234567890"=0
	set @"^%xyz56789012345678901234567890(1,""subs"")"=0
	set @"%xyz56789012345678901234567890(1,""subs"",""subs2"")"=0

	do ^examine($GET(@"xyz4567890123456789012345678901"),1,"xyz4567890123456789012345678901")
	do ^examine($GET(@"^xyz4567890123456789012345678901"),1,"^xyz4567890123456789012345678901")
	do ^examine($GET(^%xyz567890123456789012345678901(1,"subs")),1,"^%xyz567890123456789012345678901")
	do ^examine($GET(%xyz567890123456789012345678901(1,"subs","subs2")),1,"%xyz567890123456789012345678901")
	if ""=$get(errcnt) write "Long Name test for atomic indirection PASS",!
	quit

atmcset(act,subs,type)	;
	set t="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890"
	for i=1:1:31 do
	. set var=type_$extract(t,1,i)
	. set value=var
	. if subs>0 do
	. . set var=var_"("
	. . set sub=$extract(t,1,31)
	. . if act="set" do
	. . . set var=var_""""""_sub_""""""
	. . else  do
	. . . set var=var_""""_sub_""""
	. . for j=2:1:subs  do
	. . . set sub=$extract(t,j,31-j)
	. . . if act="set" do
	. . . . set var=var_","""""_sub_""""""
	. . . else  do
	. . . . set var=var_","""_sub_""""
	. . set var=var_")"
	. set cmd="set @"""_var_"""="""_value_""""
	. if act="set"  x cmd
	. if act="ver"  do ^examine($GET(@var),value,var)
	quit

