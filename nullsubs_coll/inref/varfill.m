varfill ;	fills database with subscripted globals
;
one ;
	set ^aglobalv("")=1
	set ^aglobalv(1)=94756
	set ^aglobalv("str")="iam a string subscript"
	set ^aglobalv(1,"","str")="mixed fill"
	set ^aglobalv(1,"hi")="hello"
	quit
two ;
	set ^aforavariable("")="iam null"
	set ^aforavariable("ohayogozaimasu")="i said goodmorning"
	set ^aforavariable(78)=1090
	set ^iamdefault("")="konnichiwa"
	set ^iamdefault("konbanwa")="goodafternoon"
	set ^iamdefault(1009)=7869,^iamdefault(1009,"")=5090,^iamdefault(1009,"nippon")=90
	quit
three ;
	set (^aregvar(""),^bregvar(""),^cregvar(""))="iam null"
	set (^aregvar("odakyo"),^bregvar("sakuraya"),^cregvar("samurai"))="iam string"
	set (^aregvar(100),^bregvar(89,45),^cregvar(89))=1078
	set ^aregvar(68,"",56)="some num mix"
	set ^bregvar("","hi",34)=456
	set ^cregvar("gogo",56,"")=789
	quit
mergefill;
	set ^defregvar("")=1
	set ^defregvar(1,"")=10
	set ^defregvar(1,"",2,3)=1023
	set ^defregvar("abc","")=100
	set ^defregvar("abc","","hi",2)=1002
	set ^defregvar("",4)=40
	set ^defregvar("dgh")=50
	set ^defregvar("efg",2,"",4)=1204
	set ^defregvar("iamdefault")=60
	set ^defregvar(907)=333
chkMfunc;
	set ^aregionvar("")="iam null aregionvar"
	set ^aregionvar(1,"")="one_null"
	set ^aregionvar(1,"",2,3)="one_null_two_three"
	set ^aregionvar("abc","")="string_null"
	set ^aregionvar("abc","","hi",2)="string_null_string_two"
	set ^aregionvar("",4)="null_four"
	set ^aregionvar("dgh")="string"
	set ^aregionvar("efg",2,"",4)="string_two_four"
	set ^aregionvar("iamAREG",2)="string_two"
	set ^aregionvar(565,90,76)=222
	quit
