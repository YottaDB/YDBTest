unicodeQsubscript;
	set x="myvar1(""Falsches jeden größeren"",""łódź jeża lub ośm skrzyń"",""Falsches ."",""łódź jeża lub ośm skrzyń fig."")"
	set y="myvar2(""いろはにほへど　ちりぬるを"",""あさきゆめみじ　ゑひもせず"",""Příliš"",""жил-был цитрус"")"
	write "zwrite",!  zwrite
	write $qsubscript(x,1),!
	write $qsubscript(x,2),!
	write $qsubscript(x,3),!
	write $qsubscript(x,4),!
	write $qsubscript(x,5),!
	write $qsubscript(y,1),!
	write $qsubscript(y,2),!
	write $qsubscript(y,3),!
	write $qsubscript(y,4),!
	write $qsubscript(y,5),!
	quit
