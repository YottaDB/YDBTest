socset
	; Test long strings, this sets up the ^dataasalongvariablename45678901 array for use with socdev.m
	; write strings of growing length upto 1MB
	if '$DATA(count) set count=1
	for pow=13:1:20  d
	. set len=2**pow-1
	. set ^dataasalongvariablename45678901(count,"read")="u tcpdevasalongvariablename678901 r rxasalongvariablename2345678901#"_len_"  s t=$T  u 0 s x=$LENGTH(rxasalongvariablename2345678901),longstr=$$^longstr(x) if rxasalongvariablename2345678901'=longstr s x=x_""BADSTRING""  u 0"
	. set ^dataasalongvariablename45678901(count,"read","x","ref")=len
	. set ^dataasalongvariablename45678901(count,"write")="h 10  u tcpdevasalongvariablename678901:width=1048576 w $$^longstr("_len_"),# s x=$x,y=$y u 0"
	. set ^dataasalongvariablename45678901("total")=count
	. set ^xdataasalongvariablename(count,"write")="this piece of code will crash"
	. set count=count+1
	quit

