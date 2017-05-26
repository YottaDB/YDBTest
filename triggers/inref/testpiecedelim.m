;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
testpiecedelim
	; 4. delim matching
	; - ztupdate testing
	write "4. delim matching",!

	; Validate the entire range of delimiters for ASCII
	; Generate test data
	kill ^bpieces,^delim,^pdelim,^tpd,^FAIL
	; There are 3 first level subscripts, 1 through 3. Each value means a certain number of pieces. 1 means 10, 2 means 25 pieces and 3 means 50.
	for i=32:1:64 set x(3,$char(i))=$$^gendata(i,50),x(1,$char(i))=$$^gendata(i,10),x(2,$char(i))=$$^gendata(i,25)
	for i=91:1:96 set x(3,$char(i))=$$^gendata(i,50),x(1,$char(i))=$$^gendata(i,10),x(2,$char(i))=$$^gendata(i,25)
	for i=122:1:126 set x(3,$char(i))=$$^gendata(i,50),x(1,$char(i))=$$^gendata(i,10),x(2,$char(i))=$$^gendata(i,25)
	if $zchset="M" do
	.	for i=127:1:254 set x(3,$char(i))=$$^gendata(i,50),x(1,$char(i))=$$^gendata(i,10),x(2,$char(i))=$$^gendata(i,25)
	; Save test data to DB
	merge ^delim=x
	merge ^pdelim=x

	; Creating the delimiter testing trigger file
	set file="delim.trg" open file:newversion use file write "-*",!
	for i=32:1:47 do writeTrigSpec("delim",i)
	for i=58:1:64 do writeTrigSpec("delim",i)
	for i=91:1:96 do writeTrigSpec("delim",i)
	for i=122:1:126 do writeTrigSpec("delim",i)
	for i=127:1:254 do writeTrigSpec("delim",i,"z")  ; High 128 ASCII need to use zdelim in UTF-8 mode
	;
	for i=32:1:47 do writeTrigSpec("pdelim",i,,"5:10;15:20;25:30;35:40;45:50")
	for i=58:1:64 do writeTrigSpec("pdelim",i,,"5:10;15:20;25:30;35:40;45:50")
	for i=91:1:96 do writeTrigSpec("pdelim",i,,"1;2;3;5;7;11;13;17;19")
	for i=122:1:126 do writeTrigSpec("pdelim",i,,"6;10;11;20;21;50;51")
	for i=127:1:254 do writeTrigSpec("pdelim",i,"z","6;10;11;20;21;50;51")

	open "trigger_output.txt":newversion
	use "trigger_output.txt"
	if '$ztrigger("file",file) zshow "*" quit
	close "trigger_output.txt"

	; Running the delimiter tests
	for i=1:1:254  set dc=$char(i) if $data(^delim(1,dc)) set ^delim(1,dc)=$$randomPieceUpdate(1,dc,^delim(1,dc),i)
	for i=1:1:254  set dc=$char(i) if $data(^delim(1,dc)) set ^delim(2,dc)=$$randomPieceUpdate(2,dc,^delim(2,dc),i)
	for i=1:1:254  set dc=$char(i) if $data(^delim(2,dc)) set ^delim(2,dc)=$$randomPieceUpdate(2,dc,^delim(2,dc),i)
	for i=1:1:254  set dc=$char(i) if $data(^delim(3,dc)) set ^delim(3,dc)=$$randomPieceUpdate(3,dc,^delim(3,dc),i)
	; Running the piece and delimiter tests
	for i=1:1:254  set dc=$char(i) if $data(^pdelim(1,dc)) set ^pdelim(1,dc)=$$randomPieceUpdate(1,dc,^pdelim(1,dc),i)
	for i=1:1:254  set dc=$char(i) if $data(^pdelim(2,dc)) set ^pdelim(2,dc)=$$randomPieceUpdate(2,dc,^pdelim(2,dc),i)
	for i=1:1:254  set dc=$char(i) if $data(^pdelim(3,dc)) set ^pdelim(3,dc)=$$randomPieceUpdate(3,dc,^pdelim(3,dc),i)

	write:'$data(^FAIL) "PASS",!
	quit

writeTrigSpec(gvn,charIndex,z,pieces)
	do:$data(pieces)
	.	new i,arg,args
	.	set pieceList="-piece="_pieces
	.	; Split piece list at semi-colons, handling ranges
	.	for i=1:1:$length(pieces,";") do
	.	.	set slice=$piece(pieces,";",i)
	.	.	set ^bpieces($char(charIndex),+slice)=1
	.	.	quit:$length(slice,":")=1
	.	.	; range detected
	.	.	new start,stop,j
	.	.	set start=$piece(slice,":",1),stop=$piece(slice,":",2)
	.	.	for j=start:1:stop set ^bpieces($char(charIndex),j)=1
	write "+^",gvn,"(sz=:,dlm=$char(",charIndex,")) -xecute=""do trigrtn^testpiecedelim"""
	write " -",$get(z),"delim=$char(",charIndex,") -command=Set,Kill,Ztrigger ",$get(pieceList),!
	quit

randomPieceUpdate(cnt,delim,value,step)
	new i,piece
	for i=1:1:cnt do
	.	set piece=$random(49)+1
	.	set $piece(value,delim,piece)=step
	quit value
	;
	; the following function was used to change only the pieces
	; targetted by -piece=1:3;7:10
list(mlist,delim)
	new i,p
	for  set p=$piece(mlist,delim,$increment(i)) quit:p=""  do
	.	write p
	.	if $select(p<4:1,p<7:0,p<11:1,1:0) write " Be EVIL",!
	.	else  write !
	quit

trigrtn
	; The purpose of this subroutine is to check that all the updates
	; in $ZTUPdate are in fact the only pieces that have changed
	; between $ZTVAlue and $ZTOLdvalue
	set ref=$reference,update=""
	set ^tpd(ref,"ZTVAlue")=$ZTVAlue
	set ^tpd(ref,"ZToldvalue")=$ZToldvalue
	set ^tpd(ref,"ZTUPdate")=$ZTUPdate
	; validate that all the pieces from $ztupdate are in fact changed
	for  set p=$piece($ZTUPdate,",",$increment(i)) quit:p=""  do
	. set newP=$piece($ZTVAlue,$ZTDElim,p)
	. set oldP=$piece($ZTOLdvalue,$ZTDElim,p)
	. if oldP=newP,$length(newP) write "$ztupdate piece ",p," is not valid",! set ^FAIL=1
	; Validate that everything that has changed, is in $ztudpate
	for i=1:1:$length($ztvalue,$ZTDElim) do
	. set oldP=$piece($ztoldvalue,$ZTDElim,i)
	. set newP=$piece($ztvalue,$ZTDElim,i)
	. quit:(oldP=newP)&(i'>$length($ztoldvalue,$ZTDElim))
	. set:($get(^bpieces(dlm,i),0))!(ref["^delim") $piece(update,",",$incr(j))=i
	if update'=$ztupdate set ^FAIL=1 zwrite update,^tpd(ref,*) zwrite:ref'["^delim" ^bpieces(dlm,:)
	quit
