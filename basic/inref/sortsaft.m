sortsaft; Test of the ]] (sorts after) operator.
	New
	Do begin^header($TEXT(+0))

	Set i=1  Do ^examine(i]]2,0,"i]]2 where i=1")
	Set i=i+1  Do ^examine(i]]2,0,"i]]2 where i=2")
	Set i=i+1  Do ^examine(i]]2,1,"i]]2 where i=3")

	Set ans="010101"
	Set j="1a",k=1  For i="2b":1:4 Do
	. Set msg="i]]j where i="_i_" and j="_j,x=i]]j  Do ^examine(x,$EXTRACT(ans,k),msg)
	. Set k=k+1
	. Set msg="j]]i where j="_j_" and i="_i,x=j]]i  Do ^examine(x,$EXTRACT(ans,k),msg)
	. Set k=k+1

	If errcnt=0 Write "   PASS",!

; End RTNNEXT
	Do end^header($TEXT(+0))
	Quit
