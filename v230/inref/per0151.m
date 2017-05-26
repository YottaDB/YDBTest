per0151	;per0151 - Implement the [] syntax for global references
	;
	s c=0,one="per0151.gld",two="per0151a.gld",three="per0151b.gld",four="per0151c"
	s zt=$zt,$zt="s next=$zpos,$p(next,""+"",2)=$p(next,""+"",2)+1 w !,$zs g @next"
	i $zgbldir'=$tr(one,"perabcdgl","PERABCDGL") s c=c+1 w !,"bad $ZGBldir = ",$ZGB
	s ^a="one"
	s $zgbldir="per0151a.gld"
	i $zgbldir'=$tr(two,"perabcdgl","PERABCDGL") s c=c+1 w !,"bad $ZGBldir = ",$ZGB
	i $d(^a) s c=c+1 w !,"^a should not be defined"
	s ^a="other"
	i ^["per0151.gld"]a'="one" s c=c+1 w !,^["per0151.gld"]a," expected to be ""one"""
	i ^["per0151a.gld"]a'="other" s c=c+1 w !,^["per0151a.gld"]a," expected to be ""other"""
	i ^[one]a'="one" s c=c+1 w !,^[one]a," expected to be ""one"""
	i ^[two]a'="other" s c=c+1 w !,^[two]a," expected to be ""other"""
	i $d(^[three]a) s c=c+1 w !,"reference to an undefined database dir not fail"
	i $d(^[four]a) s c=c+1 w !,"reference to an undefined global directory dir not fail"
	s onei="one",twoi="two"
	i ^[@onei]a'="one" s c=c+1 w !,^[@onei]a," expected to be ""one"""
	i ^[@twoi]a'="other" s c=c+1 w !,^[@twoi]a," expected to be ""other"""
	x "i ^[@onei]a'=""one"" s c=c+1 w !,^[@onei]a,"" expected to be """"one"""""""
	k ^a
	d dna
	s ^a="other"
	k ^[one]a
	d ona
	s ^[@onei]a="one"
	k @"^a"
	d dna
	s @("^a=""other""")
	k ^[@onei]a
	d ona
	x "s ^[one]a=""one"""
	x "k ^a"
	d dna
	x "k ^[one]a"
	x "s ^a=""other"""
	d ona
	s @"^[one]a"="one"
	k ^a
	d dna
	s $zt=zt
	w !,$s(c:"BAD result",1:"OK")," from simple test of ^[]"
	q
dna	i $d(^a) s c=c+1 w !,"^a should not be defined"
	i '$d(^[one]a) s c=c+1 w !,"^[one]a should be defined"
	q
ona	i $d(^[one]a) s c=c+1 w !,"^[one]a should not be defined"
	i '$d(^a) s c=c+1 w !,"^a should be defined"
	q
