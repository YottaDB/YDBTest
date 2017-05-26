unicodeZwritePattern;
	set badcharsamples=0
	do initdata
	write "zwrite zwrdata(:""A"")",!,!  zwrite zwrdata(:"A")
	write "zwrite zwrdata(""A"":""Z"")",!,!  zwrite zwrdata("A":"Z")
	write "zwrite zwrdata(""a"":""z"")",!,!  zwrite zwrdata("a":"z")
	write "zwrite zwrdata(""z"":""Ḁ"")",!,!  zwrite zwrdata("z":"Ḁ")
	write "zwrite zwrdata(""Ḁ"":)",!,!  zwrite zwrdata("Ḁ":)
	write "zwr zwrdata(?1.10A)",!,!
	zwr zwrdata(?1.10A)
	write "zwr zwrdata(?1.10AN)",!,!
	zwr zwrdata(?1.10AN)
	write "zwr zwrdata(?10.20APN)",!,!
	zwr zwrdata(?10.20APN)
	write "zwr zwrdata(?30.APN)",!,!
	zwr zwrdata(?30.APN)
	write "zwr zwrdata(?1.10N)",!,!
	zwr zwrdata(?1.20N)
	write "zwrite zwrdata",!,!
	zwrite zwrdata
	quit

initdata;
	set zwrdata(0)=0
	set zwrdata(1)=1
	set zwrdata($C(0))=$C(0)
	set zwrdata($C(1))=$C(1)
	set zwrdata($C(64))=$C(64)
	set zwrdata($C(65))=$C(65)
	set zwrdata($C(96))=$C(96)
	set zwrdata($C(97))=$C(97)
	set zwrdata($C(100))=$C(100)
	set zwrdata($C(121))=$C(121)
	set zwrdata($C(122))=$C(122)
	set zwrdata("乴亐亯仑件伞佉佷")="CJK"
	set zwrdata("Üben Pchnąć")="Mixed1"
	set zwrdata("Falsches Üben von")="German"
	set zwrdata("Příliš žluťoučký")="Polish"
	set zwrdata("いろはにほへど　ちりぬるを")="Japanese"
	set zwrdata("В чащах юга жил-был цитрус? Да, но фальшивый экземпляр! ёъ.")="Russian"
	set zwrdata("यह लोग हिन्दी क्यों नहीं बोल सकते हैं ?")="Hindi"
	set zwrdata("ওরা েকন বাংলা বলেত")="Bengali"
 	set zwrdata("١٢১২೧೨೩൧൨9")="digits"
 	set zwrdata("১২")="digits"
	set zwrdata("²")="superscript"
	set zwrdata("٥")="Arabic Five"
	set zwrdata("""")="null"
	set zwrdata($ZCHAR(128))=$ZCHAR(128)
	set zwrdata($ZCHAR(129))=$ZCHAR(129)
	set zwrdata($ZCHAR(160))=$ZCHAR(160)
	set zwrdata($ZCHAR(200))=$ZCHAR(200)
	set zwrdata($ZCHAR(255))=$ZCHAR(255)
	q
