;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2013 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Routine to process memory usage extract from mumps reports in gtmpcat test suite.
;
	Set TAB=$Char(9)
	Set infile="memuse.log"
	Open infile:Readonly
	Use infile
	For i=1:1 Quit:($ZEof)  Do
	. Read inline
	. Quit:($ZEof)
	. Set gtmver=$ZPiece(inline,".",3)		; Get version id from file name
	. Set inline=$ZExtract(inline,68,9999)		; What's left is the summary line from bottom of gtmpat memory map report
	.                                               ; (sans the "Total" and a bunch of whitespace)
	. Do EliminateExtraWhiteSpace(.inline)
	. Set proalloc=$ZPiece(inline," ",2)		; First real token is PRO version Read-alloc
	. Set vermem(gtmver)=proalloc
	Close infile
	Use $P
	;
	; Pick the last two versions. Compare then according to the following rules:
	;
	; 1. If major/minor version the same (e.g. both are V54), allow 1% increase (but any decrease).
	; 2. If major/minor version differ, allow a 5%
	;
	Set lastver=$Order(vermem($Char(255,255,255,255,255,255,255,255)),-1)
	Set nextlastver=$Order(vermem(lastver),-1)
	If ((lastver+0)=(nextlastver+0)) Set threshold=1.01	; Allows for 1% increase
	Else  Set threshold=1.05	     			; Allows for 5% increase
	If ((vermem(nextlastver)*threshold)<vermem(lastver)) Do
	. Write "Memory usage increase from ",nextlastver," to ",lastver," exceeds threshold of ",(threshold-1)*100,"%"
	. Write " (increased from ",vermem(nextlastver)," to ",vermem(lastver)," bytes - "
	. Write $FNumber((vermem(lastver)-vermem(nextlastver))/vermem(nextlastver)*100,"",2),"%)",!
	Else  Write "Memory use analysis within acceptable range",!
	Quit

;
; Eliminate multiple sequential white space chars to promote parsing with $Piece
;
EliminateExtraWhiteSpace(str)
	New lastch,sp,len,newstr
 	Set str=$Translate(str,TAB," ")	; Convert tabs to spaces first
	Set len=$ZLength(str)
	Set lastch=1,newstr=""
	For  Quit:(lastch>len)  Do
	. Set sp=$ZFind(str," ",lastch)
	. If (0<sp) Do
	. . Set newstr=newstr_$ZExtract(str,lastch,sp-1)
	. . For lastch=sp:1:len+1 Quit:(" "'=$ZExtract(str,lastch))	; Going to plus 1 terminates the loop
	. Else  Set newstr=newstr_$ZExtract(str,lastch,len),lastch=len+1
	Set str=newstr
	Quit
