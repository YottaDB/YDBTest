;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2015 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
; Copyright (c) 2020 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Test the ability of TRIGGER DELETE STAR to delete all triggers. Take the
; triggers from an existing trigger routine and randomly fuzz #COUNT and
; #CYCLE.  Compare the deletion and message counts from trigger delete with our
; expectations.
gtm8399
	set $etrap="use $p zshow ""*"" halt" do init
	set dseprompt="DSE> "
	set trg=$zcmdline
	set i=0
	open trg:readonly
	use trg
	for  read line quit:$zeof  do
	.	quit:line'?1"+^".E
	.	set $extract(line,1,2)=""
	.	set trigvn=$piece(line,"(")
	.	quit:($increment(total))&(1'=$increment(countsby(trigvn)))
	.	set $piece(list," ",$increment(listcount))=trigvn
	close trg
	; Load triggers
	do file^dollarztrigger(trg,1,.resp)
	; Begin fuzzing #COUNT and #CYCLE
	set fuzzcount=1+$random(listcount),reduction=0,listin=list
	for cnt=1:1:fuzzcount do  quit:list=""
	.	set pos=$random($length(list," "))+1
	.	set trigvn=$piece(list," ",pos)
	.	quit:trigvn=""
	.	set $piece(order," ",$i(ordertop))=trigvn
	.	if pos=$length(list," ") set $piece(list," ",pos-1,pos)=$piece(list," ",pos-1)
	.	else  set $piece(list," ",pos,pos+1)=$piece(list," ",pos+1)
	.	set node(trigvn)=$random(3) ; 0 = #COUNT, 1 = #CYCLE, 2 = both
	.	; Accumulate #COUNT fuzzed triggers to reduce the total number seen deleted
	.	if 0=(node(trigvn)#2) set reduction=reduction+$$dsefuzz(trigvn,"#COUNT",.line,.i)
	.	; Fuzzing #CYCLE
	.	if 0<node(trigvn),$$dsefuzz(trigvn,"#CYCLE",.line,.i)
	.	set msgcnt=$get(msgcnt,0)+$select(node(trigvn)=2:2,1:1)
	kill ^line merge ^line=line kill line
	do validate(total,total-reduction,msgcnt,trg,i)
	quit
;;;;;;;;;;;;;;;;
init
	kill ^dsecmd,^reduction
	quit
;;;;;;;;;;;;;;;;
delete
	set which=$random(2)
	if 0=which,'$ztrigger("file",$zcmdline)
	if 1=which,'$ztrigger("item","-*")
	quit
;;;;;;;;;;;;;;;;
dsefuzz(trigvn,node,line,i)
	new reduction,dsecmd
	; Generate the first DSE command to find the target #COUNT
	set reduction=$select(node="#COUNT":countsby(trigvn),1:0)
	set:node="#COUNT" ^reduction($i(^reduction))=trigvn_":"_countsby(trigvn)
	set trigvn=$extract(trigvn,1,31) ; mident length searches
	set target="^#t("""""_trigvn_""""","""""_node_""""")"
	merge dsecmd=^dsecmd
	set dsecmd($increment(dsecmd))="find -key="""_target_""""
	; Open the DSE pipe
	set pipe="dse"
	open pipe:(command="$gtm_dist/dse")::"PIPE"
	use pipe
	; Strip off the DSE startup headers and read until dse prompt
	for i=i:1 quit:$zeof  read line(i):1 quit:line(i)=dseprompt
	write dsecmd(dsecmd),!
	; Find desired output and read until dse prompt
	for i=i:1 quit:$zeof  read line(i):1 do:line(i)?1"Key".E  quit:line(i)=dseprompt
	.	set dsecmd($increment(dsecmd))="dump -block="_$piece($tr(line(i),".","")," ",$length(line(i)," "))
	write dsecmd(dsecmd),!
	;
	for i=i:1 quit:$zeof  read line(i):1 do:(line(i)[node)&(line(i)[trigvn)  quit:line(i)=dseprompt
	.	set line=$$^%MPIECE(line(i)," ")
	.	set block=$piece(line," ",3)
	.	set offset=$$FUNC^%HD($piece(line," ",5))
	.	set hexoffset=$$FUNC^%DH(offset+7)
	.	set dsecmd($increment(dsecmd))="remove -block="_block_" -offset="_hexoffset
	.	set dsecmd($increment(dsecmd))="dump -block="_block_" -offset="_hexoffset
	write dsecmd(dsecmd-1),!
	for i=i:1 quit:$zeof  read line(i):1 quit:line(i)=dseprompt
	write dsecmd(dsecmd),!
	for i=i:1 quit:$zeof  read line(i):1 quit:line(i)=dseprompt
	close pipe
	merge ^dsecmd=dsecmd
	quit reduction
;;;;;;;;;;;;;;;;
validate(origtotal,newtotal,msgcnt,trg,i)
	new out,msg
	if '$data(i) set i=1
	zsystem "mkdir -p mangled ; $MUPIP backup ""*"" ./mangled/ >&! mangled.log"
	set out="trg_delete.outx"
	zsystem "$gtm_dist/mumps -run delete^gtm8399 "_trg_" >&! "_out
	set pass=0
	if newtotal=0 set delstr="No matching triggers found for deletion"
	else  set delstr="All existing triggers (count = "_newtotal_") deleted"
	open out:readonly
	use out
	for i=i:1  read line(i) quit:$zeof  do
	.	if line(i)["TRIGDEFBAD",$increment(pass) set msg=line(i) ;use $p w "DEFBAD",$i(DEBAD),! use out
	.	if line(i)[delstr,$increment(pass) set count=line(i) ;use $p w "finstr",$i(finstr),! use out
	use $p
	if pass=(msgcnt+1) write "PASS",!
	else  do
	.	write "FAIL",!
	.	write "Expected to see ",newtotal," out of ",origtotal,!
	.	zwrite pass,count,msgcnt,delstr
	.	zsystem "cp mumps.dat{,"_$zut_"}"
	quit

