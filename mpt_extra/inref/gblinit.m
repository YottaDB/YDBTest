;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2006-2015 Fidelity National Information 	;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gblinit ;
		; set of gbls to be used by gbl subtest
		; singl byte set
		set string="abcdefghijklmnopqrstuvwxyz"
		f i=1:1:5 s (^A(i),^B(i),^a(i+i),^c(i))=$E(string,i*i,i*i+8),^D(i)=$E(string,i,i+5),^b(i*i)=$E(string,i-5,i),x="^"_$E(string,i,i+3),@x=x,y="^"_$E(string,i+2,i+5),@y=y
		set ^A(-11)=-11
		set ^ATMP="ATMP"
		set ^BTMP="BTMP"
		set ^CTMP("RICK")="..."
		set ^CTMP("ZZZZ")="..."
		set ^CTMP("Z123")="..."
		set ^X123("RICK")="..."
		set ^X123(599,"X")="tmp"
		set ^C="CLASS"
		set ^C(1)="MARY"
		set ^C(1,2)="MATH"
		set ^C(1,2,1)=80
		set ^C(1,3)="BIO"
		set ^C(1,3,1)=90
		set ^C(2)="JOHN"
		set ^C(3)="PETER"
		set ^%XXX="XXa"_$C(9)_"aXX"
		set ^name5678="short name5678"
		set ^name567890123456789012345678901="Long name5678901..."
		quit
unicode ;
		; multi byte characters
		; add unicode strings to every kind of varibale set above for single byte.
		; This is to ensure for all the path covered in "gbl" subtest we have unicode data covered too
		; and they should not behave any different
		set string="ａ ｂ ｃ ｄ ｅ ｆ ｇ ｈ ｉ ｊ ｋ ｌ ｍ ｎ ｏ ｐ ｑ ｒ ｓ ｔ ｕ ｖ ｗ ｘ ｙ ｚ"
		f i=1:1:5 s (^uniA(i),^uniB(i),^unia(i+i),^unic(i))=$E(string,i*i,i*i+8),^uniD(i)=$E(string,i,i+5),^unib(i*i)=$E(string,i-5,i)
		set ^uniA(11)="ĀāĂăĄąĆćĈĉĊċČčĎď"
		set ^unia(12)="ưƱƲƳƴƵƶƷƸƹƺƻƼƽƾƿ"
		set ^uniATMP="ΨΈẸẪΆΨ"
		set ^uniBTMP="۩۩۝۞"
		set ^uniCTMP("ＤＩＥＧＯ")="♚♝A♞♜"
		set ^uniCTMP("XXXX")="ĂȑƋ"
		set ^uniCTMP("uniX123")="ڦAΨמ"
		set ^uniX123("ＤＩＥＧＯ")="ẙ۩Ÿ"
		set ^uniX123(599,"Ｘ")="♚♝"
		set ^uniC(1,4)="₉₀"
		set ^uniC(1,4,1)="₂₀"
		set ^uniC(1,4,2)="ａｂｃｄｅ"
		set ^%uniYYY="ａｂｃｄｅ"_$C(9)_"♚♝"
		set ^uniname5678="Some tamil அவர்கள் ஏன் தமிழில் பேசக்கூடாது ?"
		set ^uniname567890123456789012345678901="Some telugu తెలుగులో ఎందుకు మాట్లాడరు?"
		set ^samplegbl("我")="end character 我meant to be matched by %G"
		set ^samplegbl("下")="start character 下meant to be matched by %G"
		set ^samplegbl("aづぎぬまめわ")="a with hiraganas"
		set ^samplegbl("aづぎめまぬまわ")="a with some more hiraganas"
		set ^samplegbl("づぎぬまめわ")="oh only hiraganas NOT meant to be matched by %G"
		set ^samplegbl("aづぎ")="oh very few hiraganas NOT meant to be matched by %G"
		set ^samplegbl("Τ")="Greek letter"
		set ^samplegbl("２")="full-width number 2,%GO will catch me"
		set ^samplegbl("２","３,４","５","６")="many full-width numbers"
		set ^samplegbl("２３４５６")="full-width range numbers not for %G"
		set ^samplegbl("３４５６")="full-width range numbers for %G"
		set ^samplegbl("２","Ｍ,４")="not just full width numbers but full width alphabets too"
		set ^samplegbl("▄")="just a block and %G will NOT catch me"
		set ^samplegbl("levels","▄")="string levels folowed by block"
		set ^samplegbl("levels","▄▄▄▄▄▄")="string levels followed by blocks"
		set ^samplegbl("levels","▄","▍▌▋▊▉█")="ok string levels followed by various sized blocks"
		set ^samplegbl($ZCHAR(240,144,128,131))="I am an invalid mix"
		set ^samplegbl("我能吞下玻璃而不伤身体")="whoami three bytes"
		set ^samplegbl("的编纂")="whoever iam %G is meant to catch me"
		set ^samplegbl("的编纂","的编纂")="whoami"
		set ^samplegbl("的编纂","abcd")="whoami with abcd"
		set ^samplegbl("¾")="three-fourth sign meant for %G"
		set ^samplegbl("¾","½")="three-fourth and half signs"
		set ^samplegbl("¾","½,¼")="three-fourth half and quarter signs"
		set ^samplegbl("¾",1)="three-fourth signs and number 1"
		set ^samplegbl("umlaut")="I have an umlaut ü"
		set ^samplegbl("combining-umlaut")="I have a combining umlaut ü"
		set ^samplegbl("u-and-umlaut")="I have a u and an umlaut separately u¨"
		set ^samplegbl("u-and-umlaut")="I have a u and an umlaut separately u¨"
		set ^samplegbl("u-and-umlaut")="I have a u and an umlaut separately u¨"
		set ^samplegbl("u-and-umlaut")="I have a u and an umlaut separately u¨"
		set ^mix1="我能 end here"
		set ^mix2="♋"
		set ^mix3="我能吞下玻璃而不伤身体 end here"
		quit
