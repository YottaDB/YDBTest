; This script is used as a part of spanning_nodes/sn_repl4 test to fill the
; specified amount of data by writing a number of globals whose keys and
; values are chosen randomly and constrained in size by the specified limits.
fill
	set total=0
	read input
	set minkey=$piece(input," ",1)		; the min key length
	set maxkey=$piece(input," ",2)		; the max key length
	set minvalue=$piece(input," ",3)	; the min value length
	set maxvalue=$piece(input," ",4)	; the max value length
	set limit=$piece(input," ",5)		; amount of data to fill
	for i=1:1:10000 do  quit:total>limit	; 10000 to terminate very long loops
	.	set keylength=minkey+$random(maxkey-(2*minkey)+1)
	.	set valuelength=minvalue+$random(maxvalue-minvalue+1)
	.	write "key length is "_keylength_"; value length is "_valuelength,!
	.	set key=$$genkey(i,keylength)
	.	set value=$$genvalue(i,valuelength)
	.	set @("^"_key)=value
	.	set total=total+keylength+valuelength
	quit

genkey(index,length)
	set key=""
	for j=1:1:length set key=key_$$randchar()
	set ^gbl(index)="^"_key
	quit key

genvalue(index,length)
	set value=""
	if (length<27) do
	.	for j=1:1:length set value=value_$$randchar()
	.	set ^gbl(index)=^gbl(index)_"="""_value_""""
	else  do
	.	for j=1:1:26 set value=value_$$randchar()
	.	set ^gbl(index)=^gbl(index)_"=""..."_value_""""
	.	set value=$justify(value,length)
	quit value
	
randchar()
	quit $char(97+$random(26))
