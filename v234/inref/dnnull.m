dnnull	;
	;
	s a(1)=1 
	w !,$s($n(a(""))=1:"OK",1:"BAD")," from DNNULL"
	k ^a s ^a(1)=1
	w !,$s($n(^a(""))=1:"OK",1:"BAD")," from DNNULL"
