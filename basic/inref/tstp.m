tstp	;

	Set er=0

; Test simple $piece reference

        For i=1:1:20 Do  
	. For j=1:1:5*i Do  
	. . If j=1 Set x(i)=i*j
	. . Else  Set x(i)=x(i)_"|"_(i*j)

	Set delim="|"
	For i=1:1:20 Do
	. For j=1:1:7*i Do
	. . Set x=$Piece(x(i),"|",j)
	. . Set y=$Piece(x(i),delim,j)
	. . If x'=y Do
	. . . Write "** Error ** Test failed: $Piece(x("_i_"),'|',"_j_")",!
	. . . Write "   Error **     expected: """,y,"""",!
	. . . Write "   Error **     received: """,x,"""",!
	. . . Set er=er+1

	Set delim="."
	Set x="ab.cd.ef"
	Set y=$Extract(x,1,1)
	Set a=$Piece(x,".",1)
	Set b=$Piece(y,".",1)
	Set c=$Piece(x,delim,1)
	Set d=$Piece(y,delim,1)
	If a'=c Do
	. Write "** Error ** Test failed: Extracted subset test #1",!
	. Write "   Error **     expected: """,c,"""",!
	. Write "   Error **     received: """,a,"""",!
	. Set er=er+1
	If b'=d Do
	. Write "** Error ** Test failed: Extracted subset test #2",!
	. Write "   Error **     expected: """,d,"""",!
	. Write "   Error **     received: """,b,"""",!
	. Set er=er+1
	Set y=$Extract(x,1,4)
	Set a=$Piece(x,".",2)
	Set b=$Piece(y,".",2)
	Set c=$Piece(x,delim,2)
	Set d=$Piece(y,delim,2)
	If a'=c Do
	. Write "** Error ** Test failed: Extracted subset test #3",!
	. Write "   Error **     expected: """,c,"""",!
	. Write "   Error **     received: """,a,"""",!
	. Set er=er+1
	If b'=d Do
	. Write "** Error ** Test failed: Extracted subset test #4",!
	. Write "   Error **     expected: """,d,"""",!
	. Write "   Error **     received: """,b,"""",!
	. Set er=er+1

; Test simple $piece set

	Set x="1,2,3,4,5,6,7,8,9,0,"
	Set x=x_x_x_x_x_x_x_x_x
	Set z=","
	For i=-1:1:85 Do Checkit(x,i,"xxx"_i_"xxx")
	
	For i=-1:1:85 Do Checkit(x,i,"")

	Set x=""
	For i=-1:1:85 Do Checkit(x,i,"xxx"_i_"xxx")

	Set x="*<*>*<*>*<*>*<*>*"
	For i=-1:1:5 Do Checkit(x,i,"xxx"_i_"xxx")

	Set x=",2,3,"
	For i=-1:1:85 Do Checkit(x,i,"xxx"_i_"xxx")

	Set x=",,,,,,,,,,"
	Set x=x_x_x_x_x_x_x_x_x
	For i=-1:1:85 Do Checkit(x,i,"xxx"_i_"xxx")

	Kill x,y
	Set $Piece(x,",",1)="xxxZonkxxx"
	Set $Piece(y,z,1)="xxxZonkxxx"
	If x'=y Do 
	. Write "** Error ** Test failed: string=<undefined> start=1 value=xxxZonkxxx",!
	. Write "   Error **     expected: """,y,"""",!
	. Write "   Error **     received: """,x,"""",!
	. Set er=er+1

	Kill x,y
	Set $Piece(x,",",2)="xxxZonkxxx"
	Set $Piece(y,z,2)="xxxZonkxxx"
	If x'=y Do 
	. Write "** Error ** Test failed: string=<undefined> start=2 value=xxxZonkxxx",!
	. Write "   Error **     expected: """,y,"""",!
	. Write "   Error **     received: """,x,"""",!
	. Set er=er+1

	; Test the cacheing characteristics of set piece
	Set z="|"

	; Fill from front to back
	Kill x,y
	For i=1:1:100 Set $Piece(x,"|",i)=i Set $Piece(y,z,i)=i
	If x'=y Do 
	. Write "** Error ** Test failed: string build #1",!
	. Write "   Error **     expected: """,y,"""",!
	. Write "   Error **     received: """,x,"""",!
	. Set er=er+1

	; Fill from back to front
	Kill x,y
	For i=1:1:100 Set $Piece(x,"|",101-i)=101-i Set $Piece(y,z,101-i)=101-i
	If x'=y Do 
	. Write "** Error ** Test failed: string build #2",!
	. Write "   Error **     expected: """,y,"""",!
	. Write "   Error **     received: """,x,"""",!
	. Set er=er+1

	; PreFill and set from front to back
	Kill x,y
	Set $Piece(x,"|",101)="TheEnd"
	Set $Piece(y,z,101)="TheEnd"
	For i=1:1:100 Set $Piece(x,"|",i)=i Set $Piece(y,z,i)=i
	If x'=y Do 
	. Write "** Error ** Test failed: string build #3",!
	. Write "   Error **     expected: """,y,"""",!
	. Write "   Error **     received: """,x,"""",!
	. Set er=er+1

	; Prefill and set from back to front
	Kill x,y
	Set $Piece(x,"|",101)="TheEnd"
	Set $Piece(y,z,101)="TheEnd"
	For i=1:1:100 Set $Piece(x,"|",101-i)=101-i Set $Piece(y,z,101-i)=101-i
	If x'=y Do 
	. Write "** Error ** Test failed: string build #4",!
	. Write "   Error **     expected: """,y,"""",!
	. Write "   Error **     received: """,x,"""",!
	. Set er=er+1

	; Exercise code
	Kill x,y
	Set x="0|1|2|3|4|5|6|7|8|9"
	Set y=x
	Set $Piece(x,"|",99)="aaa"
	Set $Piece(y,z,99)="aaa"
	If x'=y Do 
	. Write "** Error ** Test failed: string build #5",!
	. Write "   Error **     expected: """,y,"""",!
	. Write "   Error **     received: """,x,"""",!
	. Set er=er+1

	If $Get(QUIET)="" Do 
	 . If er=0 Write "All tests passed",!
	 . Else    Write "Tests that FAILed: ",er,!

	Quit

Checkit(string,start,value)
	New x,y
	Set x=string
	Set y=string
	Set $Piece(x,",",start)=value
	Set $Piece(y,z,start)=value
	If x'=y Do 
	. Write "** Error ** Test failed: string=",string," start=",start," value=",value,!
	. Write "   Error **     expected: """,y,"""",!
	. Write "   Error **     received: """,x,"""",!
	. Set er=er+1

	Quit
	