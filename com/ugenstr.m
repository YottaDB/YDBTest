ugenstr(int,type)
	; Generates strings which fits as global subscript
	; int is an index which is mapped to a integer, float or string value to return
	; type = 0 gives all values including illegal utf-8 values
	; type = 1 gives all values but no illegal utf-8 values
	; type = 2 gives only ASCII strings: Same as earlier version
	new itemno,template,str,offset,dint
	if $data(type)=0 set type=0
	if $ztrnlnm("gtm_chset")'="UTF-8" set type=2
	if type=2 quit $$^genstr(int)
	;
	set itemno=int#13
	if itemno=0 quit (int)
	if itemno=1 quit (-int)
	if itemno=2 quit (int*3.1415692)
	if itemno=3 quit (-int*3.1415692)
	set template="ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz"
	set str=""
	if itemno=4 do
	.   	set str=$extract(template,int#13,int#61)
	.	if type="0" set str=str_$ZCHAR(127,128,129,130,254,255)_int
	.	else  set str=str_$CHAR(127,128,129,130,254,255)_int
	if itemno=4 quit str
	; itemno=5:12
	set dint=itemno-4	; dint=1:8
	;
	;set offset=$select(dint=1:0,dint=2:0x0030,dint=3:0x0080,dint=4:0x0800,dint=5:0x10000,dint=6:0x30000,dint=7:0xF0000,dint=8:0x10FF00)
	set offset=$select(dint=1:0,dint=2:48,dint=3:128,dint=4:2048,dint=5:65536,dint=6:196608,dint=7:983040,dint=8:1113856)
	set num=int
	set radix=10
	for  q:num=0  do
	. set temp=num#radix
	. set num=num\radix
	. set char=$CHAR(offset+temp) 
	. set str=char_str
	Q str
	;
