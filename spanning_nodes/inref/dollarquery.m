; Test $query() and set/get facilities.
; This code assumes block size is set to 1024, maximum record size is 4000.
; Character set is NOT UTF-8.
; backup parameter duplicates ^nsgbl. This duplicate is not used in this test, but it will be
; used later to check if spanning nodes work correctly with multiple regions.
; This is called from basic.csh.
tquery(backup1,backup2)
	kill ^nsbgl
	; spanning/non-spanning mixed root undefined
	set ^nsbgl(1)="not nsb"
	set ^nsbgl(2)="nsb BEGIN"_$justify("nsb END",2000)
	set ^nsbgl(3)="some more string at the end."
	write $query(^nsbgl(1)),!
	write $query(^nsbgl(2)),!
	write $query(^nsbgl(3)),!
	
	; non-spanning parent, spanning children
	set ^nsbgl("id1","name")="Anton"
	set ^nsbgl("id1","last name")="Chekhov"
	set ^nsbgl("id1","desc","title")="very long"_$justify(" ",1000)_"very long end"
	set ^nsbgl("id1","desc","body")="foo bar"_$justify(" ",1000)_"foo bar end"
	set ^nsbgl("id1","desc","conc")="last words"_$justify(" ",100)_"last words end"
	set ^nsbgl("id1","desc","credits")="thanks"_$justify(" ",1100)_"thanks end"
	write $query(^nsbgl),!
	write $query(^nsbgl("id1")),!
	write $query(^nsbgl("id1","body")),!
	write $query(^nsbgl("id1","desc","credits")),!
	write $query(^nsbgl("id1","desc","title")),!
	write $query(^nsbgl("id1","name")),!
	write $query(^nsbgl("id0")),!
	write $query(^nsbgl("")),!

	; write out contents to test $get()
	write $get(^nsbgl("id1","name")),!
	write $get(^nsbgl("id1","last name")),!
	write $get(^nsbgl("id1","desc","title")),!
	write $get(^nsbgl("id1","desc","body")),!
	write $get(^nsbgl("id1","desc","conc")),!
	write $get(^nsbgl("id1","desc","credits")),!
	
	merge @backup1=^nsgbl
	kill ^nsgbl
	; ^nsgbl and ^nsgbl("xyz","") are kept in the same block but ^nsgbl("xyz") spans to multiple blocks
	set ^nsgbl="root"
	set ^nsgbl("xyz","")="begin1"_$justify(" ",970)_"end1"
	set ^nsgbl("xyz","b")="b"
	set ^nsgbl("xyz",1)=1
	set ^nsgbl("xyz")="begin2"_$justify(" ",2000)_"end2"
	do pquery
	
	; Each of the following spans: ^nsgbl, ^nsgbl("xyz","") and ^nsgbl("xyz")
	set ^nsgbl="begin1"_$justify(" ",2000)_"end1"
	set ^nsgbl("xyz","")="begin2"_$justify(" ",2000)_"end2"
	set ^nsgbl("xyz","b")="b"
	set ^nsgbl("xyz",1)=1
	set ^nsgbl("xyz")="begin3"_$justify(" ",2000)_"end3"
	do pquery

	; ^nsgbl | ^nsgbl("xyz","") + ^nsgbl("xyz")
	; ^nsgbl should occupy one block, ^nsgbl("xyz","") and ^nsgbl("xyz") should be packed within another (single) block
	set ^nsgbl="begin1"_$justify(" ",970)_"end1"
	set ^nsgbl("xyz","")="begin2"_$justify(" ",250)_"end2"
	set ^nsgbl("xyz","b")="b"
	set ^nsgbl("xyz",1)=1
	set ^nsgbl("xyz")="begin3"_$justify(" ",250)_"end3"
	do pquery

	merge @backup1=^nsgbl
	set @(backup2_"(""merge"")")=1
	merge @backup2=@backup1
	; other various
	kill ^nsgbl
	set ^nsgbl("a","")="begin1"_$justify(" ",3000)_"end1"
	set ^nsgbl("b")=2
	set ^nsgbl("b","")="begin2"_$justify(" ",3000)_"end2"
	set it="^nsgbl"
	write "IN LOOP",!
	for  set it=$query(@it) quit:it=""  write it,!
	quit

pquery
	write $query(^nsgbl),!
	write $query(^nsgbl("xyz")),!
	write $query(^nsgbl("xyz","")),!
	write $query(^nsgbl("xyz","b")),!
	write $query(^nsgbl("xyz",1)),!
	write $query(^nsgbl("xyz","","")),!
	quit
