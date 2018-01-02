;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2017-2018 YottaDB LLC. and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Routine to list all nodes in the database files accessible through the gld pointed to by $gtmgbldir
;
gvnZWRITE ;
	set (printit(1),printit(11))=1
	set x="^%",y=x do  for  set x=$order(@x,1) quit:x=""  set y=x  do
	. if ($get(printit($data(@y)),0)) do print(y)
	. for  set y=$query(@y) quit:y=""  do print(y)
	quit

print(node);
	write node,"=",$zwrite($get(@node)),!
	quit
