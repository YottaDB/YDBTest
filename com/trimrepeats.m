;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;
trimrepeats	;
	;
	; This function reads stdin and replaces n consecutive occurrences of a letter with the letter followed by n
	; in each line of input that is read. Input with no consecutive occurrences of a letter is left untouched.
	; In files with lots of repeated output, this helps trim down the output length.
	; For example, the "ddd" sequence is replaced with "d3" and "ee" sequence is replaced with "e2" in the below.
	;	$ echo "abcdddee" | $ydb_dist/yottadb -run trimrepeats
	;	abcd3e2
	;
	set minrepeat=+$zcmdline
	set:'minrepeat minrepeat=2
	use $principal:(width=65535:nowrap)	; needed to ensure a long line we write out is not split into multiple lines
	new prev,cur,line,i,j
        for  read line quit:$zeof  do
	. set prev="",prevcnt=1,out=""
	. for j=1:1:$length(line) do
	. . set cur=$extract(line,j)
	. . if (prev=cur),$increment(prevcnt) quit
	. . set:(prev'="") out=out_$$trim(prev,prevcnt,minrepeat)
	. . set prev=cur,prevcnt=1
	. set:(prev'="") out=out_$$trim(prev,prevcnt,minrepeat)
	. write out,!
	quit

trim(char,cnt,minrepeat)	;
	new i,str
	set str=""
	if cnt<minrepeat for i=1:1:cnt set str=str_char
	else  set str=char_cnt
	quit str

