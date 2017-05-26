per0358	;per0358 - increase stringpool limit of 4096 dynamic items
	;
	f i=1:1:5000 s @("a"_i)="soup"
	w !,"OK from test of stingpool holding many items"
	q
