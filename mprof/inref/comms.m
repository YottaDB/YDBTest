comms	; no label is checked elsewhere (this checks comment on 0th line)
	s ^gbl0=0
	d fg1
	h 3
	s lcl=0
lock	l me
	s lcl=0
	; these labels are not called as routines, should they be counted?
thru0	f i=1:1:5 q:i=3  f j=1:1:2 s k=k+1
	s lcl=0
thru	f i=1:1:3 q:i=2  f j=1:1:2 s a=i
	w " sdf "
	s lcl=0
thru1	f i=1:1:3 f j=1:1:2 s a=i
	s lcl=0
thru2	f i=-5:1:1 f j=1:1:3 s lcl=lcl_","_n s n=n+1 
	w lcl,!
thru3	q:0
thru4	f i=1:1:3 f j=1:1:2 s a=a_i s n=i
	s lcl=1
thru5	f i=-5:1:1 f j=1:1:3 s lcl=lcl_","_n s n=n+1 
	; o/u/c file
file	s fil="tmp.txt"
	o fil:new
	u fil
	w "this is my file only",!
	c fil
	l
	q
	; various commands local/global/ do/ comment/kill/ and variations
fg1	s ^gbl1=1
	d fl0
	q
fl0	; comment on 0th line, local var
	s lcl=0
	d fl1
	q
fl1	s lcl=1
	d k0
	s ^gbl=1 	
	q
k0	; comment on 0th line
	k ^gbl0
	d k1
	s lcl=1
	q	
k1	k ^gbl1
	d for0
	f i=1:1:3 s a=i
	q
for0 	f abcd=1:1:7 d
	. f efgh=1:1:11 d
	. . s lcl=2
	. . s ^gbl=2
	. . if (lcl=^gbl) f whatn=1:1:29 s lcl=^gbl+lcl
	. s lcl=lcl+1
	. w "post"
	s lcl=2
	d comment
	s lcl=""
	s n=1
	f i=-5:1:1 f j=1:1:3 s lcl=lcl_","_n s n=n+1 
	w lcl,!
	f i=1:1:4 q:i=3  w i
	w !
	s k=0
	f i=1:1:5 q:i=3  f j=1:1:2 s k=k+1
	w "k is:",k,!
	q
comment	; now let's play with comments
	w "Comments",!
	; some comments
	s lcl=1
	; some comments
	s ^gbl=1
	; some comments
	k lcl
	; some comments
	k ^gbl
	; some comments
	f i=1:1:3 s lcl=i
	; some comments
	f i=1:1:3 s ^gbl=i
	; some comments
	f i=1:1:3 d
	. s lcl=i
	; more comments
	; more comments
	; more comments
	; more comments
	; more comments
	; more comments
	q
