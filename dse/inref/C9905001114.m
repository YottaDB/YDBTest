;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2011, 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
C9905001114	; check DSE sibling report
	;
	new (act)
	if '$data(act) new act set act="set io=$io use $p write !,$zstatus,!,$zpos,! zshow  use io"
	new $etrap
	set $ecode="",$zstatus="",$etrap="goto err"
	set zl=$zlevel
	set expect=""
	set edgecnt=(2+3)*2	;2 level directory tree 3 level global tree, each with 2 sides
	set file="dse_sib.out"
	open file:readonly
	use file:(rewind:exception="goto eof:$zeof,err")
	for  read y if y["Left" read x if $length(x) set x=$piece(x,$char(13)) do
	. set left=$piece(x,$char(9),2),block=$piece(x,$char(9),"none"=left+3),right=$piece(x,$char(9),"none"=left+4)
	. if $increment(blkcnt) set array(block,"l")=left,array(block,"r")=right
eof	set $ecode=""
	close file
	set b=""
	for  set b=$order(array(b)) quit:""=b  set blkcnt=blkcnt-1 for s="l","r" do
	. if "none"=array(b,s) set edgecnt=edgecnt-1 quit
	. if 10'=$data(array(array(b,s))),$increment(cnt) xecute act quit
	. set block=$get(array(array(b,s),$select("l"=s:"r",1:"l")))
	. if b'=block,$increment(cnt) xecute act
	if blkcnt,$increment(cnt) xecute act
	if edgecnt,$increment(cnt) xecute act
end	write !,$select($get(cnt):"FAIL",1:"PASS")," from ",$text(+0)
	quit
err	for lev=$stack:-1:0 quit:$stack(lev,"PLACE")[("^"_$text(+0))
	set loc=$stack(lev,"PLACE"),next=$zl_":"_$p(loc,"+")_"+"_($piece(loc,"+",2)+1)_"^"_$piece(loc,"^",2)
	set status=$zstatus
	if status'[$get(expect)!(""=$get(expect)),$increment(cnt) set io=$i write !,$stack(lev,"MCODE"),!,$zstatus use io xecute act
	set $ecode=""
	zgoto @next
	write !,"oops",!,$zstatus
	zhalt 4	; in case of error within err
