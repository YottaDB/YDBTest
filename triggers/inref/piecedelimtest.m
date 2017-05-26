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
piecedelimtest(cnt,delim,value,step)
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
