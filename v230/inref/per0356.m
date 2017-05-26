per0356	;per0356 - follows incorrect for characters > 127
	;
	s c=0
	f i=0:1:255 d test q:c>10
	w !,$s(c:"BAD result",1:"OK")," from test of follows"
	q
test	s c1=$c(i)
	i c1']"" s c=c+1 w !,"BAD follows: $c(",i,")]"""""
	i ""]c1  s c=c+1 w !,"BAD follows: """"]$c(",i,")"
	f j=0:1:255 d lots q:c>10
	q
lots	s c2=$c(j)
	i ((c1_"some stuff")](c2_"lots more stuff")'=(i'<j)) s c=c+1 w !,"BAD follows: $c(",i,")]$c(",j,")"
	i (c1]c2)'=(i>j) s c=c+1 w !,"BAD follows: $c(",i,")]$c(",j,")"
	q
