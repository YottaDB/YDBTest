differentutf ;
		do sets
		for i=1:1:cnti do
		. for type="UTF-8","UTF-16LE","UTF-16BE" do
		. . do testzcenc(i,type)
		quit
sets ;
		set cnti=0
		set cnti=cnti+1,testar(cnti)=$ZCHAR(150,151,152),comments(cnti)="$ZCHAR(150,151,152)",vutf8(cnti)=0,vutf16le(cnti)=0,vutf16be(cnti)=0 ; invalid
		;set cnti=cnti+1,testar(cnti)=$ZCHAR(0,97),comments(cnti)="$ZCHAR(0,97)",vutf8(cnti)=1,vutf16le(cnti)=1,vutf16be(cnti)=0 ; a, in UTF-8, UTF-16LE
		;set cnti=cnti+1,testar(cnti)=$ZCHAR(97,0),comments(cnti)="$ZCHAR(97,0)",vutf8(cnti)=1,vutf16le(cnti)=0,vutf16be(cnti)=1 ; a, in UTF-8, UTF-16BE
		set cnti=cnti+1,testar(cnti)=$ZCHAR(239,188,161),comments(cnti)="$ZCHAR(239,188,161)",vutf8(cnti)=1,vutf16le(cnti)=0,vutf16be(cnti)=0 ; Ａ, in UTF-8
		set cnti=cnti+1,testar(cnti)=$ZCHAR(255,33),comments(cnti)="$ZCHAR(255,33)",vutf8(cnti)=0,vutf16le(cnti)=1,vutf16be(cnti)=1 ; Ａ, in UTF-16LE
		set cnti=cnti+1,testar(cnti)=$ZCHAR(33,255),comments(cnti)="$ZCHAR(33,255)",vutf8(cnti)=0,vutf16le(cnti)=1,vutf16be(cnti)=1 ; Ａ, in UTF-16BE
		set cnti=cnti+1,testar(cnti)=$ZCHAR(224,174,133),comments(cnti)="$ZCHAR(224,174,133)",vutf8(cnti)=1,vutf16le(cnti)=0,vutf16be(cnti)=0 ; அ, in UTF-8
		set cnti=cnti+1,testar(cnti)=$ZCHAR(11,133),comments(cnti)="$ZCHAR(11,133)",vutf8(cnti)=0,vutf16le(cnti)=1,vutf16be(cnti)=1 ; அ, in UTF-16LE
		set cnti=cnti+1,testar(cnti)=$ZCHAR(133,11),comments(cnti)="$ZCHAR(133,11)",vutf8(cnti)=0,vutf16le(cnti)=1,vutf16be(cnti)=1 ; அ, in UTF-16BE
		set cnti=cnti+1,testar(cnti)=$ZCHAR(224,176,133),comments(cnti)="$ZCHAR(224,176,133)",vutf8(cnti)=1,vutf16le(cnti)=0,vutf16be(cnti)=0 ; అ, in UTF-8
		set cnti=cnti+1,testar(cnti)=$ZCHAR(12,5),comments(cnti)="$ZCHAR(12,5)",vutf8(cnti)=1,vutf16le(cnti)=1,vutf16be(cnti)=1 ; అ, in UTF-16LE
		set cnti=cnti+1,testar(cnti)=$ZCHAR(5,12),comments(cnti)="$ZCHAR(5,12)",vutf8(cnti)=1,vutf16le(cnti)=1,vutf16be(cnti)=1 ; అ, in UTF-16BE
		set cnti=cnti+1,testar(cnti)=$ZCHAR(227,129,130),comments(cnti)="$ZCHAR(227,129,130)",vutf8(cnti)=1,vutf16le(cnti)=0,vutf16be(cnti)=0 ; あ, in UTF-8
		set cnti=cnti+1,testar(cnti)=$ZCHAR(48,66),comments(cnti)="$ZCHAR(48,66)",vutf8(cnti)=1,vutf16le(cnti)=1,vutf16be(cnti)=1 ; あ, in UTF-16LE
		set cnti=cnti+1,testar(cnti)=$ZCHAR(66,48),comments(cnti)="$ZCHAR(66,48)",vutf8(cnti)=1,vutf16le(cnti)=1,vutf16be(cnti)=1 ; あ, in UTF-16BE
		quit
testzcenc(ci,enc) ;
		new flag;
		write "Processing "_comments(ci)_" for "_enc,!
		set $ZTRAP="set errpos=$ZPOS goto errortrap"
		;if ("M"=enc) set legalsequence=1 ; all byte seqences are legal in "M"
		if ("UTF-8"=enc) set legalsequence=vutf8(ci)
		if ("UTF-16BE"=enc) set legalsequence=vutf16be(ci)
		if ("UTF-16LE"=enc) set legalsequence=vutf16le(ci)
		if (0=legalsequence) do
		. set file1="zconvert_badchar.out"
		. open file1:(APPEND)
		. use file1
		. set flag="expected"
		. write $ZCONVERT(testar(ci),enc,"UTF-8")
		. close file1
		. if ("expected"=flag) write "TEST-E-EXPECTED ZCONVERT BADCHAR NOT ISSUED on "_comments(ci)_" for encoding "_enc,!
		if (1=legalsequence) do 
		. set file2="zconvert_nobadchar.out"
		. open file2:(APPEND)
		. use file2
		. set flag="notexpected"
		. write $ZCONVERT(testar(ci),enc,"UTF-8")
		. close file2
		quit
errortrap ;
		if ($FIND($zstatus,"GTM-E-BADCHAR")=0) set $ZTRAP="" w "TEST-E-UNEXPECTED "_$zstatus_" ERROR " quit
		if ("notexpected"=flag) write "TEST-E-UNEXPECTED ZCONVERT BADCHAR ISSUED on "_comments(ci)_" for encoding "_enc,!
                W "$ZSTATUS on "_comments(ci)_" for "_enc_" "_$zstatus,!
                set lab=$PIECE(errpos,"+",1)
                set offset=$PIECE($PIECE(errpos,"+",2),"^",1)+1
                set nextline=lab_"+"_offset
		set flag=""
                goto @nextline
