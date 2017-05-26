parse   s x=$zsearch("*.x"),count=0
	f   s x=$zsearch("*.m"),count=count+1 q:x=""  w !,$zparse(x,"NAME") 
	w !,count-1
