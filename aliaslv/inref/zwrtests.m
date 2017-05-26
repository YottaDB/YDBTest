;
; Various tests to check out ZWrite functionality in an aliased variable environment
;
	Write !,!,"******* Start of ",$Text(+0)," *******",!,!

	; Build list of cases and run them
	Set caselist="zwrbasic zwrorder zwrtac zwrcmplx zwrgc zwrgc2 zwrnest"
	W !,"--------------------------",!
	For i=1:1:$Length(caselist," ") Do
	. Set casename=$Piece(caselist," ",i)
	. Kill *	; Rid the world of aliases prior to new case
	. Write "Test case #",i,": ",casename,!
	. Do @casename
	. Write !,"--------------------------",!

	Write !,!,"******* Finish ",$Text(+0)," *******",!,!
	Quit

;
; test#1 - Various basic testing of ZWR with aliases and containers pointing to orphaned data.
;
zwrbasic
	New			; New symtab so don't pollute other tests with stuff
	Do zwrcbldalsbs("aVar")
	Set *bVar=aVar
	ZWrite
	Kill  Kill *	; Start over..
	Write "-------------",!
	Do zwrcbldalsbs("bVar")
	Set *aVar=bVar
	ZWrite
	Write "-------------",!
	Set *CT(24)=bVar	; Since name comes before bVar, forces forward reference lookup code to run
	Set *CT(25)=cVar
	ZWrite
	Write "-------------",!
	; create orphaned data for ZWrite to dump
	Do zwrcbldalstoct(.CT,42,"CT")
	ZWrite
	Write "-------------",!
	; and some more orphaned data
	Set *zot=CT(42)
	Do zwrcbldalstoct(.zot,"od","zot")
	Kill *zot
	ZWrite
	Quit
	; Rtn to create 3 subscripted vars in given var name
zwrcbldalsbs(bsname)
	New i,s
	Set s=$$zwrcnamehash(bsname)
	For i=s:1:s+2 Set @bsname@(i)="val-"_bsname_"-"_i
	Quit
	; Build local var with values, set container in passed-by-ref array to create orphaned data for ZWR to dump
zwrcbldalstoct(ct,ctidx,ctname)
	New i,s,newo
	Set s=$$zwrcnamehash(ctname)
	For i=s:1:s+2 Do
	. Set newo(i)="val-"_ctname_"-"_i
	Set *ct(ctidx)=newo
	Quit
	; simplistic hash to get a number from a string
zwrcnamehash(name)
	New sum,i
	Set sum=0
	For i=1:1:$Length(name) Set sum=sum+$ASCII(name,i)
	Quit sum

;
; test#2 - Test the order/resolution that the aliases get when alias shows a reference to another variable. The
;          reference should be to the earliest possible varname that is pointing to the same value. This case
;	   was found to violate that principle without changes to reference location code.
;
zwrorder
	New
	Set *a(1)=b,b="start"
	Do zwrordersub(.a,0)
	Set *b=a(1)
	ZWRite
	Quit
zwrordersub(x,y)
	Set y=y+5,*z=x(1)
	Set z(1)=1,z(2)=2,z(200)=y
	Quit

;
; Test #3:  Generate a LOT of orphaned data elements using only two variables. We
;	    will do a ZWrite of these vars into an external file, kill everything and
;	    load it back in. However we won't set the last record of the zwrite file
;	    which would be the statement that would clear the $ZWRTAC variables.
;	    Instead we will record the storage use at that point and THEN kill the
;	    vars with that last record from the zwrite. We should then be able to
;	    verify that our consumed storage has dropped because the hash table was
;	    compacted.
;
zwrtac
	New	; Our own private playground
	For a=1:1:1000 Set b=a,*a(a)=b Kill *b
	Open "zwr.txt":Newfile
	Use "zwr.txt"
	ZWrite
	Close "zwr.txt"
	Kill  Kill *	; Kill everything, nothing survives
	; Read the file back in and process it
	Open "zwr.txt":Readonly
	Use "zwr.txt"
	For  Quit:$ZEOF  Do
	. Read a
	. Quit:$ZEOF
	. If a'="$ZWRTAC=""""" Set @a
	Close "zwr.txt":Delete
	Use $P
	; Now verify the contents
	For a=1:1:1000 Set *b=a(a) If b'=a Write "Verification fail",! ZShow "*" Quit
	Quit:a'=1000
	; Record storage before $ZWRTAC vars are killed
	Kill a,*b	 ; Gets rid of the data and just leaves the $ZWRTAC vars
	Set a=$ZREALSTOR	
	Set b=$ZUSEDSTOR
	; Cause $ZWRTAC* entries to be deleted from hash table
	Set $ZWRTAC=""
	Write "PASS zwrtactest",!
	Quit

;
; test#4 - Generate complex layering of vars with orphaned data and nested container pointers. ZWrite dump it
;	   then read it back in to verify both write and reload worked properly.
;
zwrcmplx
	New			; New symtab so don't pollute other tests with stuff
	Set filecomp="zwrcmplxcomp.txt"
	Set filechk="zwrcmplxchk.txt"
	Set *aa=a
	Set a=42
	For i=1:1:50 Do
	. If 0=(i#5) Do
	. . Set varb="b"_i_"a"
	. . Xecute "Set *a(i)="_varb
	. . For j=1:1:i*2 Do
	. . . If 0=(j#10) Do
	. . . . Set varc="c"_j_varb
	. . . . Xecute "Set *"_varb_"(j)="_varc
	. . . . For k=1:1:j/2 Xecute "Set "_varc_"(k)=k"
	. . . . Xecute "kill *"_varc
	. . . If 0'=(j#10) Xecute "Set "_varb_"(j)=j"
	. . Xecute "kill *"_varb
	. If 0'=(i#5) Set a(i)=i
	;
	; Write to log for verification with reference file
	;
	ZWrite a
	;
	; Write to file which will be basis for future comparison
	;
	Open filecomp:(New:Write)
	Use filecomp
	ZWrite a
	Close filecomp
	Kill a	; Array is no longer..
	;
	; Reload array from filecomp
	;
	Open filecomp:Readonly
	Use filecomp
	Set eof=0
	For  Do  Quit:eof
	. Read recvar
	. Set eof=$ZEOF
	. Quit:$ZEOF
	. Set @recvar
	; Now write it out again to compare with the first dump (verifies load)
	Open filechk:(New:Write)
	Use filechk
	ZWrite a
	Close filechk
	Use $P
	;
	; Compare the files .. method depends on platform
	;
	Set unix=$ZVersion'["VMS"
	Set borked=0
	If unix Do
	. ZSystem "diff "_filecomp_" "_filechk_" > /dev/null"
	. If 0'=$ZSystem Set borked=1
	If 'unix Do
	. ZSystem "diff "_filecomp_" "_filechk_" /output=ignore.dif"
	. If 1'=($ZSystem&7) Set borked=1
	. Else  ZSystem "DELETE ignore.dif."
	Write "zwrcmplx test ",$Select(borked:"FAIL",1:"PASS"),!
	;
	; If test failed, leave files
	;
	Quit:borked
	; Now let's get rid of the comparison files
	Open filecomp
	Close filecomp:Delete
	Open filechk
	Close filechk:Delete
	Quit

;
; test#5:  This test exposed a failure in V54001/2. If a garbage collection occurred while processing
; 	   an lvzwrite_block for orphaned data, the earlier (pushed down) block could be compromised.
;	   Symptom seen was garbage characters in subscripts.
;
zwrgc 
	New
	Set filecomp="zwrgccomp.txt"
	For i=1:1:10000 Do zwrgcsub
	Open filecomp:(New:Write)
	Use filecomp
	ZWrite a
	Close filecomp
	Use $P
	;
	; compare the output to the actual array in memory.
	;
	Open filecomp:(Readonly)
	Use filecomp
	Read line
	If "$ZWRTAC="""""'=line Do
	. Use $P
	. Write "FAIL: At line 1 in the comparison file (zwrgccomp.txt), output is incorrect",!
	. ZShow "*"
	. Halt
	For i=1:1:10000 Do
	. Read line1
	. If $ZEof Do
	. . Use $P
	. . Write "Premature EOF reading line1",!!
	. . ZShow "*"
	. . Halt
	. Read line2
	. If $ZEof Do
	. . Use $P
	. . Write "Premature EOF reading line2",!!
	. . ZShow "*"
	. . Halt
	. ;
	. ; Records are in pairs of *a(1,<i>)=$ZWRTAC<i> and $ZWRTAC<i>=i. Verify them
	. ;
	. If "*a(1,"_i_")=$ZWRTAC"_i'=line1 Do
	. . Use $P
	. . Write "FAIL: At line ",(i*2)," in the comparison file (zwrgccomp.txt), line1 value is incorrect",!
	. . ZShow "*"
	. . Halt
	. If "$ZWRTAC"_i_"("_i_")="_i'=line2 Do
	. . Use $P
	. . Write "FAIL: At line ",(i*2)+1," in the comparison file (zwrgccomp.txt), line2 value is incorrect",!
	. . ZShow "*"
	. . Halt
	Read line
	If "$ZWRTAC="""""'=line Do
	. Use $P
	. Write "FAIL: At line 20000 in the comparison file (zwrgccomp.txt), output is incorrect",!
	. ZShow "*"
	. Halt
	Close filecomp
	Use $P
	Write "zwrgc PASS",!
zwrgcsub
	New (a,i)
	Set b(i)=i
	Set *a(1,i)=b
	Quit

;
; test#6:  Variation on test#6 that produced a sig-11/accvio on V54002. 
;
zwrgc2
	New
	Set a(1)=1
	For i=1:1:1000 Do zwrgc2sub
	ZWrite
	Quit
zwrgc2sub
	New (a)
	For i=1:1:10 Set b(i)=i
	Set *a(1,2)=b
	Quit

;
; test#7:  Create tree of orphaned nodes. Validate deep(er) nesting
;
zwrnest
	New
	Set ^gbl=1
	Set *a=$$recurse(4)
	ZWrite
	Quit
recurse(depth)  ;
	New gbl
	Set ^gbl=(^gbl+1)
	Set gbl=^gbl
	Quit:(depth=0) *gbl
	Set *gbl(1)=$$recurse(depth-1)
	Set *gbl(2)=$$recurse(depth-1)
	Quit *gbl
