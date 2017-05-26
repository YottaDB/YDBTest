c9002539;
	; This routine does big sets so that for 2MB align size for every 16 updates it has an align record.
	; This way minor change in journal record format will still have same number of ALIGN records and
	; still for every 16 sets there will be one ALIGN record
	; For primary server we will use resync sequence number 126 so that for all regions with align size 2MB, 
	;	they have just one record after an ALIGN record.
	; For secondary side we undo till sequence number 41 so that source server sends sequence number 41 first.
	; After resync=41 in primary side::
	; 	Sequence number 41 is first record after ALIGN record in AREG 
	; 	Sequence number 42 is first record after ALIGN record in BREG
	; 	Sequence number 43 is first record after ALIGN record in CREG (has TP)
	; 	Sequence number 44 is first record after ALIGN record in DREG
	; 	Sequence number 45 is NOT first record after ALIGN record in DEFAULT
main;
	for i=1:1:33 do
	. set ^a("a"_i)=$j(i,130680)
	. set ^b("b"_i)=$j(i,130680)
        . ts ():(serial:transaction="BA")
	. set ^c("c"_i)=$j(i,130680)
	. tc
	. set ^d("d"_i)=$j(i,130680)
	. set ^e("e"_i)=$j(i,130680)
	quit
verify(max);
	for i=1:1:max do
	. if ^a("a"_i)'=$j(i,130680) write "Verify Failed for index",i,!
	. if ^b("b"_i)'=$j(i,130680) write "Verify Failed for index",i,!
	. if ^c("c"_i)'=$j(i,130680) write "Verify Failed for index",i,!
	. if ^d("d"_i)'=$j(i,130680) write "Verify Failed for index",i,!
	. if ^e("e"_i)'=$j(i,130680) write "Verify Failed for index",i,!
	quit
