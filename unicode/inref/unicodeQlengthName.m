unicodeQlength;
	if $qlength("myvar(1,2,""Falsches Üben von Xylophonmusik quält jeden größeren Zwerg."",""Pchnąć w tę łódź jeża lub ośm skrzyń fig."")")'=4 write "fail $qlength()",!
	else  write "pass $qlength()",!
	if $qlength("myvar(""Příliš žluťoučký kůň úpěl ďábelské"",""чащах юга жил-был цитрус? Да, но фальшивый экземпляр"")")'=2 write "fail $qlength()",!
	else  write "pass $qlength()",!
	if $qlength("myvar(""いろはにほへど　ちりぬるを"",""あさきゆめみじ　ゑひもせず"")")'=2 write "fail $qlength()",!
	else  write "pass $qlength()",!
	if $qlength("myvar(""①②③④⑤⑥⑦⑧"",0,""लोकांना मराठी का बोलता येत नाही?"")")'=3 write "fail $qlength()",!
	else  write "pass $qlength()",!
	write "zwrite",!  zwrite 
	set ^myvar("Falsches Üben von Xylophonmusik quält jeden größeren Zwerg.","Pchnąć w tę łódź jeża lub ośm skrzyń fig.")=1
	set ^("いろはにほへど　ちりぬるを","あさきゆめみじ　ゑひもせず")=2
	Write "$reference=",$reference,!
	write "$Name=",$NAME(^("αβγδε"),3),!
	write "$Name=",$NAME(^("我能吞下玻璃而不伤身体"),4),!
	write "$Name=",$NAME(^(0),4),!
	if $qlength("^myvar(1,2,""Falsches Üben von Xylophonmusik quält jeden größeren Zwerg."",""Pchnąć w tę łódź jeża lub ośm skrzyń fig."")")'=4 write "fail $qlength()",!
	else  write "pass $qlength()",!
	if $qlength("^myvar(""Příliš žluťoučký kůň úpěl ďábelské"",""чащах юга жил-был цитрус? Да, но фальшивый экземпляр"")")'=2 write "fail $qlength()",!
	else  write "pass $qlength()",!
	if $qlength("^myvar(""いろはにほへど　ちりぬるを"",""あさきゆめみじ　ゑひもせず"")")'=2 write "fail $qlength()",!
	else  write "pass $qlength()",!
	if $qlength("^myvar(""①②③④⑤⑥⑦⑧"",0,""लोकांना मराठी का बोलता येत नाही?"")")'=3 write "fail $qlength()",!
	else  write "pass $qlength()",!
	quit
