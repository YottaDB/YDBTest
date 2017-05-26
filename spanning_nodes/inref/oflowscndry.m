; This is a helper script used in spanning_nodes/sn_repl5. Based on the passed option we generate a
; scenario in which the update process on the receiving side should choke because of either REC2BIG,
; KEY2BIG, or GVSUBOFLOW error, as expected in the current design.
oflowscndry
	read input
	set option=$piece(input," ",1)		; option: 1) key, no subscripts; 2) key with subscripts; 3) value
	set max=$piece(input," ",2)		; the max integer value
	if 1=option do
	.	set key=$$genkey(max+1)
	.	set @("^"_key)="this is ^"_key
	else  if 2=option do
	.	set key=$$genkey(max-10)
	.	set @("^"_key_"(""firstsubscript"",""secondsubscript"")")="this is ^"_key
	else  do
	.	set value=$$genvalue(max+1)
	.	set ^v=value
	quit

genkey(length)
	set key=""
	for i=1:1:length set key=key_$$randchar()
	quit key

genvalue(length)
	set value=""
	for i=1:1:26 set value=value_$$randchar()
	set value=$justify(value,length)
	quit value
	
randchar()
	quit $char(97+$random(26))
