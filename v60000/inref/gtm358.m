gtm358
	set maxsublen=1014
	for i=1:1:maxsublen set ^x($j(i,i))=i
	write "$reference: ",$reference,!
	for i=1:1:maxsublen-2 kill ^x($j(i,i))
	write "zwrite ^x",!
	zwrite ^x
	kill ^x
	for i=1:1:maxsublen set ^x($j(i,i))=0
	for i=1:1:maxsublen set ^x($j(i,i))=i
	set sum=0
	for i=1:1:maxsublen set sum=sum+^x($j(i,i))
	write "sum ^x(i) = ",sum,!
	write "merge ^y=^x",!
	merge ^y=^x
	set sum=0
	for i=1:1:maxsublen set sum=sum+^y($j(i,i))
	write "sum ^y(i) = ",sum,!
	; Test maximum number of subscripts, which is 31
	set len=500
	set ^z(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,$j("keyend",len))="val"
	zwrite ^z
	; Insert two keys, one with maximal compression count (1020). Used for DSE testing.
	set ^d($j(maxsublen-1,maxsublen))=maxsublen-1
	set ^d($j(maxsublen,maxsublen))=maxsublen
	quit
error1	; Expect errors from the following commands
	write "GVSUBOFLOW expected:",!
	set maxsublen=1014
	set i=maxsublen+1,^x($j(" ",i))=i
	quit
error2
	write "GVSUBOFLOW expected:",!
	merge ^yy=^x
	quit

