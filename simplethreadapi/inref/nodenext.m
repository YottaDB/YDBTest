;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2017-2018 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Routine to test ydb_node_next_st() with a local variable.
;
; Operation:
;   1. Create MAXNODES randomized nodes node in a single variable.
;   2. Each node has a random (1 to 31) number of subscripts each of MAXSUBLEN length
;   3. Use $QUERY to run all the created nodes and for each node, writing a record to
;      a file containing the list of subscripts separated by spaces for comparison purposes later.
;   4. Drive an external call whose job it is to use ydb_node_next_st() to also run through the nodes
;      of the variable similarly recording the subscripts it finds in a (different) file.
;   5. After these routines complete, the files are compared (should be the same).
;
; First create a significant number of subscripted nodes in one base var.
;
nodenext(lvgn)
	set MAXNODES=10000
	set MAXSUBLEN=10
	set MAXSUBS=31
	set alphanums="%abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789~!@#$^&*()_+=-|\\}]{[':;?/>.<," ; no dbl quote
	set alphalen=$zlength(alphanums)
	set outfile="nodenextsublist_M.txt"
	set nodeexist(1)=1
	set nodeexist(11)=1
	;
	; Verify our input parm
	;
	set BASEVAR=$get(lvgn)
	if (""=lvgn) write "Missing basevar parameter",! quit
	;
	; Generate the nodes
	;
	for node=1:1:MAXNODES do
	. set subcnt=$random(MAXSUBS)+1
	. for subindx=1:1:subcnt do
	. . set:(1=subindx) sublist=""
	. . set sublen=$random(MAXSUBLEN)+1				; Subscript 1 to 10 chars
	. . set sub=""
	. . for subc=1:1:sublen do
	. . . set char=$zextract(alphanums,$random(alphalen)+1)
	. . . set sub=sub_char
	. . set sublist=sublist_""""_sub_""","
	. set sublist=$zextract(sublist,1,$zlength(sublist)-1)		; Remove trailing comma
	. set ref=BASEVAR_"("_sublist_")"
	. if ($get(nodeexist($data(@ref)),0)) set node=node-1 quit	; If same ref as one already generated, rebuild it
	. set @ref=node
	;
	; Now write out an unquoted list of subscripts
	;
	open outfile:new
	use outfile
	set sub=""
	set node=BASEVAR
	for  set node=$query(@node) quit:(""=node)  do
	. set sublist=""
	. for i=1:1:$qlength(node) do
	. . set sublist=sublist_$qsubscript(node,i)_" "
	. set sublist=$zextract(sublist,1,$zlength(sublist)-1)		; Remove trailing space
	. write sublist,!
	close outfile
	use $principal
	;
	; Now drive external call that will call back in via ydb_get_st() to fetch these same vars/values
	; and will write its own file that we will compare afterwards.
	;
	do &nodenextcb(.BASEVAR)
	;
	write !,"Completed",!
	quit

lvn	;
	do nodenext("Avar")
	quit

gvn	;
	do nodenext("^Avar")
	quit
