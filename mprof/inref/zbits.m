;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2019 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; This module was derived from FIS GT.M code.
;
zbits	; Test of bit string functions - $ZBIT prefix.
	New
	New $ZTRAP
	New indlen,indstr1,indstrk
	New indlenxstr,indstr1xstr,indstrkxstr
	Do begin^header($TEXT(+0))
	Set maxlen=253952
	set unix=$zversion'["VMS"

; Test $ZBITSTR and $ZBITLEN
	Set errstep=errcnt
	if unix  do
	.	set indlenxstr="set indlen=$ZLENGTH(str)"
	.	set indstr1xstr="set indstr1=$ZASCII($ZEXTRACT(str,1))"
	.	set indstrkxstr="set indstrk=$ZASCII($ZEXTRACT(str,k))"
	if 'unix do
	.	set indlenxstr="set indlen=$LENGTH(str)"
	.	set indstr1xstr="set indstr1=$ASCII($EXTRACT(str,1))"
	.	set indstrkxstr="set indstrk=$ASCII($EXTRACT(str,k))"
	For i=1:1:32,1031:1:1038,97397:1:97404,(maxlen-7):1:maxlen  Do
	.  For j=0:1:1  Set value=j*255   Set str=$ZBITSTR(i,j)  Do
	.  .  Set len=1+(i\8)  Set:i#8>0 len=len+1
	.  .  xecute indlenxstr
	.  .  Do ^examine(len,indlen,"$ZBITSTR 1  "_i_"  "_j)
	.  .  Do ^examine($ZBITLEN(str),i,"$ZBITSTR 2  "_i_"  "_j)
	.  .  Set rem=8-(i#8)  Set:rem=8 rem=0
	.  .  xecute indstr1xstr
	.  .  Do ^examine(indstr1,rem,"$ZBITSTR 3  "_i_"  "_j)
	.  .  For k=2:1:len-1  xecute indstrkxstr  If indstrk'=value Do
	.  .  .  Do ^examine(indstrk,value,"$ZBITSTR 4  "_i_"  "_j_"  "_k)
	If errstep=errcnt Write "   PASS - $ZBITSTR $ZBITLEN",!

; Test $ZBITSET
	Set errstep=errcnt
	For i=1:1:32  Set str=$ZBITSTR(32,0)  Set str=$ZBITSET(str,i,1)  Do
	.  For k=2:1:5 Do
	.  .  xecute indstrkxstr
	.  .  If (i+7\8+1)'=k Do ^examine(indstrk,"0","$ZBITSET 1  "_i_"  "_k)  Quit
	.  .  Do ^examine(indstrk,(2**(40-i#8)),"$ZBITSET 2  "_i_"  "_k)
	For i=1:1:32  Set str=$ZBITSTR(32,1)  Set str=$ZBITSET(str,i,0)  Do
	.  For k=2:1:5 Do
	.  .  xecute indstrkxstr
	.  .  If (i+7\8+1)'=k Do ^examine(indstrk,255,"$ZBITSET 3  "_i_"  "_k)  Quit
	.  .  Do ^examine(indstrk,(255-(2**(40-i#8))),"$ZBITSET 4  "_i_"  "_k)
	If errstep=errcnt Write "   PASS - $ZBITSET",!

; Test $ZBITGET
	Set errstep=errcnt
	Set str=$ZBITSTR(253952,0)
	For i=1:1:32,100,1024,62985,200000,maxlen  Do
	.  Set n=$ZBITGET(str,i)  If n'=0 Do ^examine(n,0,"$ZBITGET 1  "_i)
	.  Set str=$ZBITSET(str,i,1)
	.  Set n=$ZBITGET(str,i)  If n'=1 Do ^examine(n,1,"$ZBITGET 2  "_i)
	If errstep=errcnt Write "   PASS - $ZBITGET",!

; Test $ZBITCOUNT
	Set errstep=errcnt
	For i=1:1:32,220,1363,50300,18652,maxlen  Do
	.  Set str=$ZBITSTR(i,0)  Set n=$ZBITCOUNT(str)
	.  If n'=0  Do ^examine(n,0,"$ZBITCOUNT 1  "_i)
	.  Set str=$ZBITSTR(i,1)  Set n=$ZBITCOUNT(str)
	.  If n'=i  Do ^examine(n,i,"$ZBITCOUNT 2  "_i)
	Set size=$RANDOM(12000)+12000  Set str=$ZBITSTR(size,0)
	For i=1:1:100  Do
	.  For  Set j=$RANDOM(size)+1  Quit:$ZBITGET(str,j)=0
	.  Set str=$ZBITSET(str,j,1)  Set n=$ZBITCOUNT(str)
	.  If n'=i  Do ^examine(n,i,"$ZBITCOUNT 3  "_i)
	Set str=$ZBITSET($ZBITSTR(32,1),1,0)
	For i=3:2:32  Set str=$ZBITSET(str,i,0)  Set n=$ZBITCOUNT(str)  Do
	.  If n'=(31-((i-1)/2))  Do ^examine(n,(31-((i-1)/2)),"$ZBITCOUNT 4  "_i)
	Set str=$ZBITSET($ZBITSTR(25,1),2,0)
	For i=4:2:25  Set str=$ZBITSET(str,i,0)  Set n=$ZBITCOUNT(str)  Do
	.  If n'=(25-(i/2))  Do ^examine(n,(25-(i/2)),"$ZBITCOUNT 5  "_i)
	If errstep=errcnt Write "   PASS - $ZBITCOUNT",!

; Test $ZBITFIND
	Set errstep=errcnt
	For i=1:1:32  Set str=$ZBITSTR(i,1)  Do
	.  For j=1:1:i  Do
	.  .  Set n=$ZBITFIND(str,1,j)
	.  .  If n'=(j+1) Do ^examine(n,(j+1),"$ZBITFIND 1  "_i_"  "_j)
	.  .  Set n=$ZBITFIND(str,0,j)
	.  .  If n'=0 Do ^examine(n,0,"$ZBITFIND 2  "_i_"  "_j)
	.  Set n=$ZBITFIND(str,1,0)
	.  If n'=2  Do ^examine(n,2,"$ZBITFIND 3  "_i)
	.  Set n=$ZBITFIND(str,1,-1)
	.  If n'=2  Do ^examine(n,2,"$ZBITFIND 4  "_i)
	.  Set n=$ZBITFIND(str,1,33)
	.  If n'=0  Do ^examine(n,0,"$ZBITFIND 5  "_i)
	.  Set n=$ZBITFIND(str,1,40)
	.  If n'=0  Do ^examine(n,0,"$ZBITFIND 6  "_i)
	.  Set n=$ZBITFIND(str,1,50)
	.  If n'=0  Do ^examine(n,0,"$ZBITFIND 7  "_i)

	Set size=$RANDOM(maxlen-100)+100  Set str=$ZBITSTR(size,0)
	Do ^examine($ZBITFIND(str,1),0,"$ZBITFIND 8")
	For i=1:1:25  Do
	.  For  Set j=$RANDOM(size)+1  Quit:$ZBITGET(str,j)=0
	.  Set x(i)=j+1  Set str=$ZBITSET(str,j,1)
	Do sortx(25)
	Set n=$ZBITFIND(str,1) If n'=x(1) Do ^examine(n,x(i),"$ZBITFIND 9  size = "_size)
	For i=2:1:25  Set n=$ZBITFIND(str,1,n)  If n'=x(i) Do  Quit
	.  Do ^examine(n,x(i),"$ZBITFIND 10  "_i_"  size = "_size)
	Do ^examine($ZBITFIND(str,1,n),0,"$ZBITFIND 11  size = "_size)

	Set size=$RANDOM(maxlen-100)+100  Set str=$ZBITSTR(size,1)
	Do ^examine($ZBITFIND(str,0),0,"$ZBITFIND 12")
	For i=1:1:25  Do
	.  For  Set j=$RANDOM(size)+1  Quit:$ZBITGET(str,j)=1
	.  Set x(i)=j+1  Set str=$ZBITSET(str,j,0)
	Do sortx(25)
	Set n=$ZBITFIND(str,0) If n'=x(1) Do ^examine(n,x(i),"$ZBITFIND 13  size = "_size)
	For i=2:1:25  Set n=$ZBITFIND(str,0,n)  If n'=x(i) Do  Quit
	.  Do ^examine(n,x(i),"$ZBITFIND 14  "_i_"  size = "_size)
	If errstep=errcnt Write "   PASS - $ZBITFIND",!

; Test $ZBITNOT
	Set errstep=errcnt
	For i=1:1:10 Set size=$RANDOM(maxlen-32)+32 Set str=$ZBITSTR(size,0) Do
	. Set strx=$ZBITNOT(str)
	. Do ^examine($ZBITCOUNT(strx),size,"$ZBITNOT 1 "_i_"  size = "_size)
	. Do ^examine($ZBITCOUNT($ZBITNOT(strx)),0,"$ZBITNOT 2 "_i_"  size = "_size)
	. For j=1:1:32 Set str=$ZBITSET(str,$RANDOM(size)+1,1)
	. Set strx=$ZBITNOT(str),n=0
	. For  Set pos=$ZBITFIND(str,1,n)  Do   Quit:'n
	. . Set posx=$ZBITFIND(strx,0,n)  If pos=posx  Set n=pos  Quit
	. . Do ^examine(posx,pos,"$ZBITNOT 3  pos = "_pos_"  size = "_size)
	If errstep=errcnt Write "   PASS - $ZBITNOT",!

; Test $ZBITAND
	Set errstep=errcnt
	Set str0=$ZBITSTR(64,0),str1=$ZBITSTR(64,1)
	Do ^examine($ZBITCOUNT($ZBITAND(str0,str0)),0,"$ZBITAND 1")
	Do ^examine($ZBITCOUNT($ZBITAND(str1,str0)),0,"$ZBITAND 2")
	Do ^examine($ZBITCOUNT($ZBITAND(str1,str1)),64,"$ZBITAND 3")
	Set str0=$ZBITSTR(maxlen,0),strx=$ZBITAND(str0,str1)
	Do ^examine($ZBITLEN(strx),64,"$ZBITAND 4")
	Do ^examine($ZBITCOUNT(strx),0,"$ZBITAND 5")
	Set str1=$ZBITSTR(maxlen,1)
	Do ^examine($ZBITCOUNT($ZBITAND(str0,str0)),0,"$ZBITAND 6")
	Do ^examine($ZBITCOUNT($ZBITAND(str1,str0)),0,"$ZBITAND 7")
	Do ^examine($ZBITCOUNT($ZBITAND(str1,str1)),maxlen,"$ZBITAND 8")
	Set str0=$ZBITSTR(64,1),strx=$ZBITAND(str0,str1)
	Do ^examine($ZBITLEN(strx),64,"$ZBITAND 9")
	Do ^examine($ZBITCOUNT(strx),64,"$ZBITAND 10")
	Set str0=$ZBITSTR(maxlen,0),str1=$ZBITSTR(maxlen,1)
	Set n=$RANDOM(maxlen-2000)+1000
	Do setpat(.str0,"1111000010100101",1),setpat(.str0,"0010001000010000",n)
	Do setpat(.str1,"1100110011110000",1),setpat(.str1,"1111111111111111",n)
	Do setpat(.str0,"0101010101010101",maxlen-15)
	Do setpat(.str1,"0010010010010010",maxlen-15)
	Set strx=$ZBITAND(str0,str1)
	Do ^examine($$getpat(strx,1),"1100000010100000","$ZBITAND 11")
	Do ^examine($$getpat(strx,n),"0010001000010000","$ZBITAND 12")
	Do ^examine($$getpat(strx,maxlen-15),"0000010000010000","$ZBITAND 13")
	If errstep=errcnt Write "   PASS - $ZBITAND",!

; Test $ZBITOR
	Set errstep=errcnt
	Set str0=$ZBITSTR(64,0),str1=$ZBITSTR(64,1)
	Do ^examine($ZBITCOUNT($ZBITOR(str0,str0)),0,"$ZBITOR 1")
	Do ^examine($ZBITCOUNT($ZBITOR(str1,str0)),64,"$ZBITOR 2")
	Do ^examine($ZBITCOUNT($ZBITOR(str1,str1)),64,"$ZBITOR 3")
	Set str0=$ZBITSTR(maxlen,0),strx=$ZBITOR(str0,str1)
	Do ^examine($ZBITLEN(strx),maxlen,"$ZBITOR 4")
	Do ^examine($ZBITCOUNT(strx),64,"$ZBITOR 5")
	Set str1=$ZBITSTR(maxlen,1)
	Do ^examine($ZBITCOUNT($ZBITOR(str0,str0)),0,"$ZBITOR 6")
	Do ^examine($ZBITCOUNT($ZBITOR(str1,str0)),maxlen,"$ZBITOR 7")
	Do ^examine($ZBITCOUNT($ZBITOR(str1,str1)),maxlen,"$ZBITOR 8")
	Set str0=$ZBITSTR(64,1),strx=$ZBITOR(str0,str1)
	Do ^examine($ZBITLEN(strx),maxlen,"$ZBITOR 9")
	Do ^examine($ZBITCOUNT(strx),maxlen,"$ZBITOR 10")
	Set str0=$ZBITSTR(maxlen,0),str1=$ZBITSTR(maxlen,1)
	Set n=$RANDOM(maxlen-2000)+1000
	Do setpat(.str0,"1111000010100101",1),setpat(.str0,"0010001000010000",n)
	Do setpat(.str1,"1100110011110000",1),setpat(.str1,"1111111111111111",n)
	Do setpat(.str0,"0101010101010101",maxlen-15)
	Do setpat(.str1,"0010010010010010",maxlen-15)
	Set strx=$ZBITOR(str0,str1)
	Do ^examine($$getpat(strx,1),"1111110011110101","$ZBITOR 11")
	Do ^examine($$getpat(strx,n),"1111111111111111","$ZBITOR 12")
	Do ^examine($$getpat(strx,maxlen-15),"0111010111010111","$ZBITOR 13")
	If errstep=errcnt Write "   PASS - $ZBITOR",!

; Test $ZBITXOR
	Set errstep=errcnt
	Set str0=$ZBITSTR(64,0),str1=$ZBITSTR(64,1)
	Do ^examine($ZBITCOUNT($ZBITXOR(str0,str0)),0,"$ZBITXOR 1")
	Do ^examine($ZBITCOUNT($ZBITXOR(str1,str0)),64,"$ZBITXOR 2")
	Do ^examine($ZBITCOUNT($ZBITXOR(str1,str1)),0,"$ZBITXOR 3")
	Set str0=$ZBITSTR(maxlen,0),strx=$ZBITXOR(str0,str1)
	Do ^examine($ZBITLEN(strx),64,"$ZBITXOR 4")
	Do ^examine($ZBITCOUNT(strx),64,"$ZBITXOR 5")
	Set str1=$ZBITSTR(maxlen,1)
	Do ^examine($ZBITCOUNT($ZBITXOR(str0,str0)),0,"$ZBITXOR 6")
	Do ^examine($ZBITCOUNT($ZBITXOR(str1,str0)),maxlen,"$ZBITXOR 7")
	Do ^examine($ZBITCOUNT($ZBITXOR(str1,str1)),0,"$ZBITXOR 8")
	Set str0=$ZBITSTR(64,1),strx=$ZBITXOR(str0,str1)
	Do ^examine($ZBITLEN(strx),64,"$ZBITXOR 9")
	Do ^examine($ZBITCOUNT(strx),0,"$ZBITXOR 10")
	Set str0=$ZBITSTR(maxlen,0),str1=$ZBITSTR(maxlen,1)
	Set n=$RANDOM(maxlen-2000)+1000
	Do setpat(.str0,"1111000010100101",1),setpat(.str0,"0010001000010000",n)
	Do setpat(.str1,"1100110011110000",1),setpat(.str1,"1111111111111111",n)
	Do setpat(.str0,"0101010101010101",maxlen-15)
	Do setpat(.str1,"0010010010010010",maxlen-15)
	Set strx=$ZBITXOR(str0,str1)
	Do ^examine($$getpat(strx,1),"0011110001010101","$ZBITXOR 11")
	Do ^examine($$getpat(strx,n),"1101110111101111","$ZBITXOR 12")
	Do ^examine($$getpat(strx,maxlen-15),"0111000111000111","$ZBITXOR 13")
	If errstep=errcnt Write "   PASS - $ZBITXOR",!

	Do end^header($TEXT(+0))
	Quit

	Do end^header($TEXT(+0))
	Quit

sortx(n)	; Called $ZBITFIND test section only.
	Set last=n-1,swap=0
	For  Do   Quit:swap=0  Set last=swap-1,swap=0
	.  For i=1:1:last  Do
	.  .  If x(i)>x(i+1)  Set temp=x(i),x(i)=x(i+1),x(i+1)=temp,swap=i
	Quit

setpat(str,pat,n)	; Set 16 bit pattern from given point in a bit string.
	New i
	For i=0:1:15 Do
	. If $EXTRACT(pat,i+1)=1 Set str=$ZBITSET(str,n+i,1)
	. Else  Set str=$ZBITSET(str,n+i,0)
	Quit

getpat(str,n)	; Extract a 16 bit pattern from a given point in a bit string.
	New i,xstr
	Set xstr=""
	For i=0:1:15 Set xstr=xstr_$ZBITGET(str,n+i)
	Quit xstr
