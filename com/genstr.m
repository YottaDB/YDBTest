genstr(int);
	; This converts int to some string or number or floating numbers
	; This has one to one mapping from int to the return value
	; This covers all kinds of valid data type (string, numbers, floats, binary)
	new str,radix,offset,nummod8,num,char
	set unix=$ZVersion'["VMS"
	set nummod8=int#8
	if nummod8=0  Q (3.14*int)
	if nummod8=1  Q (-3.14*int)
	if nummod8=2  Q (int)
	if nummod8=3  Q (-int)
	if nummod8=4  do
	.	set str=$C(0,1,2,3,4,5,6,7,8,9,10,0)
	.	set radix=256
	.	set offset=0
	if nummod8=5  do
	.	set str="ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	.	set radix=26
	.	set offset=65
	if nummod8=6  do
	.	set str="abcdefghijklmnopqrstuvwxyz"
	.	set radix=26
	.	set offset=97
	if nummod8=7  do
	.	set str="%"
	.	set radix=26
	.	set offset=65
	set num=int
	s flag=$E($P($ztrnlnm("gtm_exe"),"/",4),2,3)
	for  q:num=0  do
	. set temp=num#radix
	. set num=num\radix
	. if unix do
	. . ; since "BADCHAR" is default we need to disable it when we write the $ZCH counterpart
	. . if flag>51 set xstr="view ""NOBADCHAR"" set char=$ZCH(offset+temp)"
	. . else  set xstr="set char=$C(offset+temp)"
	. . x xstr
	. else  set char=$C(offset+temp)
	. set str=str_char
	Q str
