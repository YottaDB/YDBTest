PER3184	; ; ; chain wreck 6/19/95
	;
;
;            Database corruption due to mishandling of chains during a 
;	     particular kind of index block split.
;		
;		    index block with some tp changes
;		----------------------------------------
;		|    .      .   .     .      .    .  .x|
;		|    .      .   . new .      .new .  .x|
;		| r1 .  r2  . r3. rec .      .rec .rn.x|
;		|    .      .   .  1  .      . 2  .  .x|
;		|    .      .   .     .      .    .  .x|
;		----------------------------------------
;		                   |           ^      ^
;		                   -------------      |
;				      chain	      |
;						      |
;	                                        --------
;	                                        |      |
;		                                | new  |   record to be
;		                                |  rec |   added causing
;		                                |   3  |   an index block 
;		                                |      |   split
;		                                --------
;
; When a several new blocks are added in a transaction, the new block numbers
; are not determined until the transaction is committed.  The index blocks
; pointing to these new blocks must be updated, so we keep track of each
; location within the index block that is to receive the new block number.
;
; In the cw set, cs->first_off contains the offset to the first index
; record to be updated.  At the location cs->first_off points to is
; a chain record (see tp.h, struct off_chain).  Within this chain record
; is an offset to the next chain record within the index block.
;
; When the index block is split, the chain offset values must be updated.
; This program identified a bug where we were incorrectly calculating the
; chain offset values.  This would happen when the new record was added
; to the end of an index block which already had changes made to it.
;
	n (act)
	i '$d(act) n act s act="w var,"" = "",@$g(var,""**UNDEF**""),!"
	s cnt=0
	f i=1:1:91 s @("^a"_i_"(i,i)=$j(i,100)")
	ts
	f i=92:1:102 s @("^a"_i_"(i,i)=$j(i,100)")
	tc
	f i=1:1:102 Do
	. s var="^a"_i_"(i,i)"
	. s cmp=$j(i,100)
	. i @var'=cmp s cnt=cnt+1 x act
	w !,$s(cnt:"FAIL",1:"PASS")," from ",$t(+0)
	q
