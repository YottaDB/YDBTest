lvls;
lvl3	;
	s ^gbl(3)=3
lvl2	;
	s ^gbl(2)=2
lvl1	;
	f n=1:1:29 s ^gbl(1)=1 f nn=1:1:197 d ^one
	w "another line here"
	q:0
	w "I am still here"
	q:1
	w "now I'm gone"
noone	w "noone calls me",!
	; 29*197*3 is equal to 17139
