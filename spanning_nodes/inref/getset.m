; Test set/get facilities.
; This code assumes block size is set to 1024, maximum record size is 4000.
; Character set is NOT UTF-8. This script is called from basic.csh.
getset
	for i=1:1:100 do
	.   set blength=$random(2976)+1025-7
	.   set ^x=$justify(" ",blength)
	.   if $length(^x)'=blength write "Block size does not match. Length is:"_blength_" $length(^x)="_$length(^x),! quit  
	.   set ^y=^x
	.   if '(($length(^x)=$length(^y))) write "Block size does not match when set is used. Length is:"_blength_" $length(^x)="_$length(^x)_" $length(^y)="_$length(^y),!
	
	do testset("create non-bsg","^a",5)
	do testset("non-bsg to non-bsg","^a",7)
	do testset("non-bsg to bsg","^a","begin"_$justify("2",2000)_"end")
	do testset("non-bsg to non-bsg (smaller)","^a","begin"_$justify("1",1000)_"end")
	do testset("non-bsg to non-bsg (larger)","^a","begin"_$justify("5",3500)_"end")
	do testset("bsg to non-bsg","^a",5)
	for i=1:1:3 do
	.   set assignvalue="begin"_$justify(i,i*1000)_"end"
	.   do testset("progressively larger bsgs - size="_$length(assignvalue),"^a",assignvalue)
	do testset("transition back to non-bsg","^a",5)
	for i=1:1:3 do
	.   set assignvalue="begin"_$justify(4-i,4-i*1000)_"end"
	.   do testset("progressively smaller bsgs - size="_$length(assignvalue),"^a",assignvalue)
	quit

testset(testname,globalname,assignvalue)
	write testname_" test has started.",!
	set @globalname=assignvalue
	; below forces a failure, to check FAIL path
	if (@globalname=assignvalue) write "PASSED",!
	else  write "FAILED::"_globalname_"="_@globalname," expected value="_assignvalue,!
	quit

