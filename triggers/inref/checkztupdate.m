;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2010, 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
checkztupdate
	; The purpose of this program is to check that all the updates
	; in $ZTUPdate are in fact the only pieces that have changed
	; between $ZTVAlue and $ZTOLdvalue
	;
	write $reference,$char(9),$ztupdate,!
	write "The new value ",$char(9),$ZTVAlue,!
	write "The old value ",$char(9),$ZToldvalue,!
	; validate that all the pieces from $ztupdate are in fact changed
	for  set p=$piece($ZTUPdate,",",$increment(i)) quit:p=""  do
	. set newP=$piece($ZTVAlue,$ZTDElim,p)
	. set oldP=$piece($ZTOLdvalue,$ZTDElim,p)
	. if oldP=newP write "$ztupdate piece ",p," is not valid",!
	; Validate that everything that has changed, is in $ztudpate
	set stop=$select(sz="short":10,sz="medium":25,sz="long":50,1:100)
	for i=1:1:stop do
	. set oldP=$piece($ztoldvalue,$ZTDElim,i)
	. set newP=$piece($ztvalue,$ZTDElim,i)
	. if oldP'=newP set $piece(update,",",$incr(j))=i
	if update'=$ztupdate write "MISMATCH:"  write update,$char(9),$ztupdate,!
	quit
