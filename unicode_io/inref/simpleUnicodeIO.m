simpleUnicodeIO(encoding)
	SET $ZTRAP="GOTO errorAndCont^errorAndCont"
	do createFile(encoding)
	do readFile(encoding)
	do errorTest
	do error1MB
	quit
	;

createFile(encoding)
	write "CreatFile using encoding=",encoding,!
	if encoding="" set openarg="""abαβＡＢ:我能吞.下玻璃"":(newversion)"
	else  set openarg="""abαβＡＢ:我能吞.下玻璃"":(newversion:ochset="""_encoding_""")"
	open @openarg
	use "abαβＡＢ:我能吞.下玻璃"
	do writeUnicode(encoding)
	close "abαβＡＢ:我能吞.下玻璃"
	quit

readFile(encoding)
	use $P
	write "ReadFile using encoding=",encoding,!
	set data=""
	if encoding="" open "abαβＡＢ:我能吞.下玻璃":(readonly)
	else  open "abαβＡＢ:我能吞.下玻璃":(readonly:ichset=encoding)
	use "abαβＡＢ:我能吞.下玻璃"
	set cnt=0
	for  do  quit:$zeof 
	. read line
	. set data=data_line
	. set cnt=cnt+1
	close "abαβＡＢ:我能吞.下玻璃"
	write !,"Total Lines=",cnt,":Data Read:",!  zwr data
	quit


writeUnicode(encoding)
	write encoding,!
	write "Üäröß我",$C(65536,65537,65538)
	write "ＡＢＣＤＥＦ.Ｇ"
	write $CHAR(10)
	write "Üäröß我",$C(65536,65537,65538)
	write "ＡＢＣＤＥＦ.Ｇ"
	write $CHAR(12)
	write "Üäröß我",$C(65536,65537,65538)
	write "ＡＢＣＤＥＦ.Ｇ"
	write $CHAR(13)
	write "Üäröß我",$C(65536,65537,65538)
	write "ＡＢＣＤＥＦ.Ｇ"
	write $CHAR(133)
	write "Üäröß我",$C(65536,65537,65538)
	write "ＡＢＣＤＥＦ.Ｇ"
	write $CHAR(8232)
	write "Üäröß我",$C(65536,65537,65538)
	write "ＡＢＣＤＥＦ.Ｇ"
	write $CHAR(8233)
	write "Üäröß我",$C(65536,65537,65538)
	write "ＡＢＣＤＥＦ.Ｇ"
	quit
errorTest;
	SET $ZTRAP="GOTO errorAndCont^errorAndCont"
	write !,"---------------------------------",!
	write "errorTest for encoding=",encoding,!
	use $P
	open "abαβＡＢ:我能吞.下玻璃":(readonly:ichset="UTF-8BAD")
	use $P
	open "abαβＡＢ:我能吞.下玻璃":(readonly:ichset="UTF-16BAD")
	use $P
	open "abαβＡＢ:我能吞.下玻璃":(readonly:ochset="UTF-8BAD")
	use $P
	open "abαβＡＢ:我能吞.下玻璃":(readonly:ochset="UTF-16BAD")
	use $P
	open "abαβＡＢ:我能吞.下玻璃":(readonly:ichset=" ")
	use $P
	open "abαβＡＢ:我能吞.下玻璃":(readonly:ichset="")
	use $P
	set $PIECE(badchset,"A",1024*1024)=""
	open "abαβＡＢ:我能吞.下玻璃":(readonly:ichset=badchset)
	write "---------------------------------",!
	quit
error1MB
	set $ZTRAP="set $ZTRAP="""" do zterror^simpleUnicodeIO"
	set filename="bom"_encoding_".txt"
	;
	if encoding'="" open filename:(newversion:recordsize=1048576:ochset=encoding)
	else  open filename:(newversion:recordsize=1048576)
	use filename:WIDTH=1048576
	set $p(unistr,$C(194),1024*512)=""
	write unistr
	close filename
	write "zlength of unistr=",$zlength(unistr),!
	;
	if encoding'="" open filename:(readonly:recordsize=1048576:ichset=encoding)
	else  open filename:(readonly:recordsize=1048576)
	use filename:WIDTH=1048576
	read readstr
	close filename
	if readstr'=unistr write "error1MB test failed",!  write "zlength=",$zlength(readstr),!
	;
	quit
zterror
	use $PRINCIPAL
	write "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!",!
	write $ZSTATUS,!
	zshow "*"
	write "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!",!
	halt
