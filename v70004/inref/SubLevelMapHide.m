;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

main	; main entry
	;
	do args
	do mkdata
	do printregions
	do next()
	do order(+1)
	do order(-1)
	do query
	do zprev
	quit
	;
merge	; entry for merge test
	;
	new index,numero,line,cmd
	do args
	do mkdata
	;
	write "# Kill target global ^merge",!
	kill ^merge
	set ^merge=1
	;
	write "# Execute MERGE command",!
	set $ztrap="goto merror"
	if tref="^t1" merge ^merge=^t1
	if tref="^t2" merge ^merge=^t2
	if tref="^t3" merge ^merge=^t3
	if tref="^t4" merge ^merge=^t4
	do mprint
	quit
	;
merror	; merge error
	write "  error caught: ",$piece($zstatus,",",3,4),!
	zgoto 1
	;
mprint	; merge print
	;
	set index=""
	for numero=1:1 do  quit:index=""
	.set index=$order(^merge(index))
	.if index="" quit
	.set line="  numero: "_$justify(numero,2)
	.set line=line_",  index="_$justify(index,2)
	.set line=line_",  value="_$justify(^merge(index),3)
	.set report(count)=line
	.set count=1+count
	.set found=1+found
	;
	do header("MERGE")
	do print
	quit
	;
args	; parse CLI args
	;
	set reg=$piece($zcmdline," ",1)
	set tref="^"_$piece($zcmdline," ",2)
	quit
	;
mkdata	; make some data and reset counters for the first test
	;
	new index,ref
	if reg="1" set $zgbldir="1reg.gld"
	if reg="2" set $zgbldir="2reg.gld"
	write "# Create some test data",!
	do wrzgbldir
	kill @tref
	set total=5
	for index=1:1:total do
	.set ref=tref_"("""_index_""")"
	.set @ref=index*index
	;
	set $zgbldir="2reg.gld"
	write "# Set $ZGBLDIR for the rest of the test",!
	do wrzgbldir
	;
	set count=0
	set found=0
	quit
	;
wrzgbldir ; remove paths and print $ZGBLDIR="	,$zgbldir,!`
	;
	new last
	write "  $ZGBLDIR="
	set last=""
	for i=1:1 quit:$piece($zgbldir,"/",i)=""&($piece($zgbldir,"/",1+i)="")  do
	.set last=$piece($zgbldir,"/",i)
	write last,!
	;
	quit
	;
printregions() ;
	;
	write "# Display regions for root level",!
	write "  regions=",$view("region",tref),!
	;
	write "# Display region for each sublevel",!
	new i
	for i=1:1:total do
	.write "  global=",tref
	.write ",  index="_$justify(i,2)
	.write ",  region="_$view("region",tref_"("_i_")")
	.write !
	quit
	;
next() ;
	new index,numero,ref
	;
	set index=-1
	for numero=1:1 do  quit:index=-1
	.set ref=tref_"("""_index_""")"
	.set index=$next(@ref)
	.do report
	;
	do header("$NEXT()")
	do print
	quit
	;
order(dir) ;
	new index,numero,ref,printdir
	set printdir=$select(dir=1:"+1",1:dir)
	;
	set index=""
	for numero=1:1 do  quit:index=""
	.set ref=tref_"("""_index_""")"
	.set index=$order(@ref,dir)
	.do report
	;
	do header("$ORDER(direction: "_printdir_")")
	do print
	quit
	;
query	;
	new index,numero
	set index=tref_"("""")"
	for numero=1:1 do  quit:index=""
	.set index=$query(@index)
	.do report
	;
	do header("$QUERY()")
	do print
	quit
	;
zprev	;
	new index,numero,ref
	set index=""
	for numero=1:1 do  quit:index=""
	.set ref=tref_"("""_index_""")"
	.set index=$zprevious(@ref)
	.do report
	;
	do header("$ZPREVIOUS()")
	do print
	quit
	;
header(cmd) ; print header
	;
	write "# Test result for ",cmd
	write ", enumerated=",found
	write ", has_value=",count
	write ", total_count=",total
	write !
	quit
	;
report	; collect report item: numero, index (can be glvn)
	;
	if index="" quit
	if index=-1 quit
	;
	new line,value,success,ref
	set success=0
	set line="  global: "_tref
	set line=line_",  numero: "_$justify(numero,2)
	set line=line_",  index="_$justify(index,2)
	;
	if $extract(index,1,1)="^" do
	.set value=$get(@index,"<undef>")
	.set line=line_",  value="_$justify(value,3)
	.if $data(@index) set success=1
	else  do
	.set ref=tref_"("""_index_""")"
	.set value=$get(@ref,"<undef>")
	.set line=line_",  value="_$justify(value,3)
	.if $data(@ref) set success=1
	;
	set report(count)=line
	set count=1+count
	if success set found=1+found
	quit
	;
print	; print report, reset counter and collect array
	;
	new i
	for i=0:1:count-1 write report(i),!
	;
	set count=0
	set found=0
	kill report
	quit
