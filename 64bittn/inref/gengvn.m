gengvn(int);
	new str,num,strarr,lenarr,lowerc,upperc
	set strarr(0)="abcdefghijklmnopqrstuvwxyz",lenarr(0)=26,lowerc=0
	set strarr(1)="ABCDEFGHIJKLMNOPQRSTUVWXYZ",lenarr(1)=26,upperc=1
	set strarr(2)="0123456789",lenarr(2)=10
	set num=int
	set nummod3=num#3
	if nummod3=0  do
	.	set str="%"
	if nummod3=1  do
	.	set index=num#26+1
	.	set str=$extract(strarr(lowerc),index,index)
	.	set num=num\26
	if nummod3=2  do
	.	set index=num#26+1
	.	set str=$extract(strarr(upperc),index,index)
	.	set num=num\26
	set lenmod3=0
	for  quit:num=0  do
	.	set lenstr=strarr(lenmod3)
	.	set radix=lenarr(lenmod3)
	.	set temp=num#radix
	.	set num=num\radix
	.	set char=$extract(lenstr,temp+1,temp+1)
	.	set str=str_char
	.	set lenmod3=(lenmod3+1)#3
	quit str
