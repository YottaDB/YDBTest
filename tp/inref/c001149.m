trc1149 ;
	;	Test case for TR entry : C9906-001149
	;
	; assumes "^x" global spans across more GDS blocks than the global-buffers can hold
	;	this test case is to test that huge reads within a transaction work.
	;
	; *****************************************************************************************************************************	
	; the line { w "$trestart = ",$trestart,! } and the section { i x#1000=0 w "index = ",x,! } are commented because of a known bug
	; C9B11-001801 tp test failure for extra $TRESTART message 	Rajamani, Narayanan 5
	; Once the TR is fixed, please remove the comment and change the reference file too. 
	; *****************************************************************************************************************************	
	;
	f i=1:1:10000 s ^x(i)=$j(i,800)
	tstart ():serial
	;w "$trestart = ",$trestart,!
	s x="" f  s x=$o(^x(x)) q:x=""  ;i x#1000=0 w "index = ",x,!
	s ^x=1
	s ^x=2
	tcommit
	w "The value of ^x :",^x,!
	q
