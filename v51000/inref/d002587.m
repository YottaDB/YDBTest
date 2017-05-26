d002587 ;
	; D9G01-002587 Errors during MUPIP LOAD with a fillfactor of less than 100%
	; The following test assumes 950-byte max-record-size and 1024-byte GDS block size 
	;
	quit

data1	;
	set ^x(1)=$j(1,100)
	quit

data2	;
	set ^x(2)=$j(1,500)
	quit

data3	;
	set ^x(3)=$j(1,900)
	quit

data4	;
	; Do the following updates on a database with 1024 blocksize and 768 reserved bytes.
	; For the first update, the leaf level record will take up space of 256 bytes which fits in the block JUST RIGHT.
	; For the second update, the leaf level record will take up the same 256 bytes but it will cause a block split
	;	and the index record will take up 259 bytes since the leaf level record stores the value 1 in 1-byte while
	;	the index record needs to store the block number of the child in 4-bytes (3 more bytes). This is more than
	;	the 256 bytes that the block can fit in. Hence a RSVDBYTE2HIGH error should be issued for the second update.
	set ^x($j(1,230))=1
	set ^x($j(2,230))=1
	quit

checkview	;
	set oktorunview=$piece($zv," ",2)]"V5.0-000C"
	set setfill30="view ""FILL_FACTOR"":30"
	set setfill60="view ""FILL_FACTOR"":60"
	set setfill100="view ""FILL_FACTOR"":100"
	quit

viewfillfactor	;
	; Test the new VIEW and $VIEW commands that allow GT.M to run with a
	; fillfactor anywhere from 30% to 100%. Until now, only MUPIP LOAD and
	; MUPIP REORG had this ability.
	write !,"--------- (a) Test viewfillfactor ------------",!
	do checkview
	if 'oktorunview  quit
	write !,"Fill factor = ",$view("FILL_FACTOR")	; check that default is 100%
	xecute setfill30	; set fillfactor of 30
	write !,"Fill factor = ",$view("FILL_FACTOR")	; check it is 30
	xecute setfill60	; set fillfactor of 60
	write !,"Fill factor = ",$view("FILL_FACTOR")	; check it is 60
	quit

fillfactor;
	; Test that even though new record size exceeds fillfactor no error
	; is issued as long as it can be accommodated within the current
	; reserved bytes setting.
	;
	write !,"--------- (b1) Test fillfactor -------------------",!
	do checkview
	do data2
	if oktorunview  xecute setfill60	; set fillfactor of 60
	do data2	; should not get any error
	if oktorunview  xecute setfill30	; set fillfactor of 30
	do data2	; should not get any error even though data2 exceeds fillfactor size
			; because it still is less than what the reserved_bytes allows
	quit

rsvdbyte2high;
	; Test that adding a record that is bigger than what the 
	; current reserved bytes settings allow causes a RSVDBYTE2HIGH
	; message to be issued instead of a GVxxxFAIL error.
	;
	write !,"--------- (b2) Test RSVDBYTE2HIGH error at the leaf level -------------------",!
	do checkview
	if oktorunview  xecute setfill100	; set fillfactor of 100
	do data3	; should get a RSVDBYTE2HIGH error
	quit

rsvdbyte2highINDEX;
	write !,"--------- (b3) Test RSVDBYTE2HIGH error at the index level -------------------",!
	do data4
	quit

emptyrightblock	;
	; Test that with a fillfactor of less than 100%, adding a new record
	; at the tail end of the block does not cause an empty right split
	; block.
	write !,"--------- (c) Test emptyrightblock ------------",!
	do checkview
	do data1
	if oktorunview  xecute setfill60	; set fillfactor of 60
	do data2
	quit

copyextrarecord	;
	; Test that the "copy_extra_record" logic in gvcst_put.c does not pull
	; in the only remaining record from the right sibling block thereby
	; causing an empty right block. This is similar to the "emptyrightblock"
	; test except that the new record is added at the beginning of a block
	; that otherwise contains only one other record.
	write !,"--------- (d) Test copyextrarecord ------------",!
	do checkview
	if oktorunview  xecute setfill60	; set fillfactor of 60
	do data2
	if oktorunview  xecute setfill30	; set fillfactor of 30
	do data1
	quit

createfullblock;
	; this assumes block-size of 1024
	; doing the 5 sets below does make the block full
	set ^x(1)=$j(1,175)
	set ^x(2)=$j(1,175)
	set ^x(3)=$j(1,175)
	set ^x(4)=$j(1,175)
	set ^x(5)=$j(1,175)
	quit
		
;---------------------------------------------------------------------------------------------------------------
; Create a scenario where newly inserted record goes to the left block (leftsplit) but left block ends up
; holding more than the current reserved bytes setting allows. Note that this should be done in two steps.
; Populating a block with reserved_bytes=0 and causing a block split with reserved_bytes=512 (db-block-size/2).
;
leftsplitLEFTBLOCKpart1;
	write !,"--------- (e) Test leftsplitLEFTBLOCK ------------",!
	do createfullblock
	quit

leftsplitLEFTBLOCKpart2;
	set ^x(3.5)=$j(1,175)
	; ^x(1),^x(2),^x(3),^x(3.5) stay in left  block
	; ^x(4),^x(5)               stay in right block
	quit

;---------------------------------------------------------------------------------------------------------------
; Create a scenario where newly inserted record goes to the left block (leftsplit) but right block ends up
; holding more than the current reserved bytes setting allows. Note that this should be done in two steps.
; Populating a block with reserved_bytes=0 and causing a block split with reserved_bytes=512 (db-block-size/2).
;
leftsplitRIGHTBLOCKpart1;
	write !,"--------- (f) Test leftsplitRIGHTBLOCK ------------",!
	do createfullblock
	quit

leftsplitRIGHTBLOCKpart2;
	set ^x(1.5)=$j(1,175)
	; ^x(1),^x(1.5)           stay in left  block
	; ^x(2),^x(3),^x(4),^x(5) stay in right block
	quit

;---------------------------------------------------------------------------------------------------------------
; Create a scenario where newly inserted record goes to the right block (rightsplit) but left block ends up
; holding more than the current reserved bytes setting allows. Note that this should be done in two steps.
; Populating a block with reserved_bytes=0 and causing a block split with reserved_bytes=512 (db-block-size/2).
;
rightsplitLEFTBLOCKpart1;
	write !,"--------- (g) Test rightsplitLEFTBLOCK ------------",!
	do createfullblock
	quit

rightsplitLEFTBLOCKpart2;
	set ^x(4.5)=$j(1,175)
	; ^x(1),^x(2),^x(3),^x(4) stay in left  block
	; ^x(4.5),^x(5)           stay in right block
	quit

;---------------------------------------------------------------------------------------------------------------
; Note that the scenario where newly inserted record goes to the right block (rightsplit) and right block
; ends up holding more than the current reserved bytes setting allows is NOT possible due to the way 
; the block-split move determination is done in gvcst_put.c. Hence no test for this scenario.

