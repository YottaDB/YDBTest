barith	; Basic test of arithmetic operators - "+  -  *  /  \  #"
	New
	Do begin^header($TEXT(+0))

	Do ^examine(1+2,"3","1+2")   ; Write 1+2,!
	Do ^examine(1-2,"-1","1-2")   ; Write 1-2,!
	Do ^examine(3*4,"12","3*4")   ; Write 3*4,!
	Do ^examine(4/3,"1.33333333333333333","4/3")   ; Write 4/3,!
	Do ^examine(4\3,"1","4\3")   ; Write 4\3,!
	Do ^examine(4#3,"1","4#3")   ; Write 4#3,!
	Do ^examine(10*10/10/10*10/10,"1","10*10/10/10*10/10")   ; Write 10*10/10/10*10/10,!
	Do ^examine(10-10+10+10,"20","10-10+10+10")   ; Write 10-10+10+10,!
	Do ^examine("2"_"0"*25/"2"_"0"/"2"_"5","12505","""2""_""0""*25/""2""_""0""/""2""_""5""")   ; Write "2"_"0"*25/"2"_"0"/"2"_"5",!
	New i,j,sum,prod

	Set sum=0  For i=.001:.01:1  Set sum=sum+i
	Do ^examine(sum,"49.6","Set sum=0  For i=.001:.01:1  Set sum=sum+i")
	For i=.001:.01:1  Set sum=sum-i
	Do ^examine(sum,"0","For i=.001:.01:1  Set sum=sum-i")

	For i=1:1:40  Set j=i  Set:i>19 j=i-19  Set:i=40 j=2  Do
	.  Do ^examine((i#20)+(i\20),j,"i = "_i_"   (i#20)+(i\20)")

	Set prod=1
	Set prod=prod*0.01  Do ^examine(prod,".01","prod=prod*0.01")
	Set prod=prod*0.02  Do ^examine(prod,".0002","prod=prod*0.02")
	Set prod=prod*0.03  Do ^examine(prod,".000006","prod=prod*0.03")
	Set prod=prod*0.04  Do ^examine(prod,".00000024","prod=prod*0.04")
	Set prod=prod*0.05  Do ^examine(prod,".000000012","prod=prod*0.05")
	Set prod=prod*0.06  Do ^examine(prod,".00000000072","prod=prod*0.06")
	Set prod=prod*0.07  Do ^examine(prod,".0000000000504","prod=prod*0.07")
	Set prod=prod*0.08  Do ^examine(prod,".000000000004032","prod=prod*0.08")
	Set prod=prod*0.09  Do ^examine(prod,".00000000000036288","prod=prod*0.09")
	Set prod=prod*0.10  Do ^examine(prod,".000000000000036288","prod=prod*0.10")

	Set prod=prod/0.01  Do ^examine(prod,".0000000000036288","prod=prod/0.01")
	Set prod=prod/0.02  Do ^examine(prod,".00000000018144","prod=prod/0.02")
	Set prod=prod/0.03  Do ^examine(prod,".000000006048","prod=prod/0.03")
	Set prod=prod/0.04  Do ^examine(prod,".0000001512","prod=prod/0.04")
	Set prod=prod/0.05  Do ^examine(prod,".000003024","prod=prod/0.05")
	Set prod=prod/0.06  Do ^examine(prod,".0000504","prod=prod/0.06")
	Set prod=prod/0.07  Do ^examine(prod,".00072","prod=prod/0.07")
	Set prod=prod/0.08  Do ^examine(prod,".009","prod=prod/0.08")
	Set prod=prod/0.09  Do ^examine(prod,".1","prod=prod/0.09")
	Set prod=prod/0.10  Do ^examine(prod,"1","prod=prod/0.10")

	Set sum=0
	For i=.001:.001:1  Set sum=sum+i
	Do ^examine(sum,"500.5","Set sum=0  For i=.001:.001:1  Set sum=sum+i")
	For i=.001:.001:1  Set sum=sum-i
	Do ^examine(sum,"0","For i=.001:.001:1  Set sum=sum-i")

	If errcnt=0 Write "   PASS",!

	Do end^header($TEXT(+0))
	Quit
