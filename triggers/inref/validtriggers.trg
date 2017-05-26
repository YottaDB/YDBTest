;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2010, 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
-*
; This is a valid file for M mode loads
; Unicode characters vs high 127 are not done yet

; 1. Global variables (testing both gvns and subscripts)
;	a. basic trigger requires only a GBL, command and an xectue string
+^a -commands=set -xecute="do ^twork"

;	i. allow leading % and numbers after the 1st column in global variable names
+^%pct	-commands=set -xecute="do ^twork"
+^%p2ct	-commands=set -xecute="do ^twork"
+^p1000	-commands=set -xecute="do ^twork"

;	b. ranges (with ':' or '*')
+^bcolon(:)	-commands=set -xecute="do ^twork"
+^%bstar(*)	-commands=set -xecute="do ^twork"
+^b2colon(1:5)	-commands=set -xecute="do ^twork"
+^bccolon(:50)	-commands=set -xecute="do ^twork"
+^bccolon(50:)	-commands=set -xecute="do ^twork"
+^bccolon("A":"z")	-commands=set -xecute="do ^twork"
+^bccolon(:"v")	-commands=set -xecute="do ^twork"
+^bccolon("K":)	-commands=set -xecute="do ^twork"

;	c. ranges and semi-colons
+^crange(10;50)		-commands=set -xecute="do ^twork"
+^crange(10;20;30;50)	-commands=set -xecute="do ^twork"
+^crange(10:20;30:50)	-commands=set -xecute="do ^twork"
+^crange("a";"A")	-commands=set -xecute="do ^twork"
+^%crange("a";20;30;50)	-commands=set -xecute="do ^twork"
+^crange(20:"a";30:50)	-commands=set -xecute="do ^twork"
+^crange("a";:;:;9:15;*)	-commands=set -xecute="do ^twork"
+^crange(*;:;:;;*)	-commands=set -xecute="do ^twork"

;	e. pattern matching with ?
+^%epat(?.e)				-commands=set -xecute="do ^twork"
+^epat(?2.3N1"-".e)			-commands=set -xecute="do ^twork"
+^epat(?3N1"-"3N1"-"4N)			-commands=set -xecute="do ^twork"
+^epat(?2N1"-"7N)			-commands=set -xecute="do ^twork"
+^epat(?3N1"-"2N1"-"4N;?2N1"-"7N)	-commands=set -xecute="do ^twork"
+^epatrange(?.e;*;:;:;;*)		-commands=set -xecute="do ^twork"

;	f. non-alphanumerics mixed in ranges
; set k=32 for i=k:1:126 write i_":"_$char(i)_$char(9) if (i-k)#9=8 write !
; 32: 	33:!	34:"	35:#	36:$	37:%	38:&	39:'	40:(
;41:)	42:*	43:+	44:,	45:-	46:.	47:/	48:0	49:1
;50:2	51:3	52:4	53:5	54:6	55:7	56:8	57:9	58::
;59:;	60:<	61:=	62:>	63:?	64:@	65:A	66:B	67:C
;68:D	69:E	70:F	71:G	72:H	73:I	74:J	75:K	76:L
;77:M	78:N	79:O	80:P	81:Q	82:R	83:S	84:T	85:U
;86:V	87:W	88:X	89:Y	90:Z	91:[	92:\	93:]	94:^
;95:_	96:`	97:a	98:b	99:c	100:d	101:e	102:f	103:g
;104:h	105:i	106:j	107:k	108:l	109:m	110:n	111:o	112:p
;113:q	114:r	115:s	116:t	117:u	118:v	119:w	120:x	121:y
;122:z	123:{	124:|	125:}	126:~

+^z1punc(" ":"~")			-commands=set -xecute="do ^twork"
+^zpunc(" ";"!":"%","(";")","(",")")	-commands=set -xecute="do ^twork"
+^zpunc("?":"~")				-commands=set -xecute="do ^twork"
+^zpunc(" ","""":",";":":"^")		-commands=set -xecute="do ^twork"
+^zpunc(" ";"!";"""";"#";"$";"%";"&";"'";"(";")";"*";"+";",";"-";".";"/";"0";"1";"2";"3";"4";"5";"6";"7";"8";"9";":";";";"<";"=";">";"?";"@";"A";"B";"C";"D";"E";"F";"G";"H";"I";"J";"K";"L";"M";"N";"O";"P";"Q";"R";"S";"T";"U";"V";"W";"X";"Y";"Z";"[";"\";"]";"^";"_";"`";"a";"b";"c";"d";"e";"f";"g";"h";"i";"j";"k";"l";"m";"n";"o";"p";"q";"r";"s";"t";"u";"v";"w";"x";"y";"z";"{";"|";"}";"~") -commands=set -xecute="do ^twork"
+^zepat(?3N1"-"2N1"-"4N;"?3N1-2N1-4N";)	-commands=set -xecute="do ^twork"
+^zepatpunc(?3N1"-;,"")(^%#",?2N,?2.5N,?5N,?2N;:)	-commands=set -xecute="do ^twork"
+^zepatpunc(?2.5N5U;?8.9N1A;?2N;)	-commands=set -xecute="do ^twork"
+^zepatpunc(?3N1"-;,"")(^%#")	-commands=set -xecute="do ^twork"
+^zepatpunc(?3N1"-"2N1"-"4N)	-commands=set -xecute="do ^twork"
+^zepatpunc(?2N1"-"7N)		-commands=set -xecute="do ^twork"
+^zepatpunc(?3N1"?""")		-commands=set -xecute="do ^twork"
+^zepatpunc("t2=?2N1-7N")	-commands=set -xecute="do ^twork"
+^zepatpunc("t=?3N1""-""4N")	-commands=set -xecute="do ^twork"

;	l. extraneous ';', ':' and '*' removal
+^%lextra("a":"b";;;;)	-commands=set -xecute="do ^twork"
+^lextra("a":"b";"c";;)	-commands=set -xecute="do ^twork"
+^lextra("a":"b";)	-commands=set -xecute="do ^twork"
+^lextra("a":"b";:;;)	-commands=set -xecute="do ^twork"
+^lextra("a":"b";*)	-commands=set -xecute="do ^twork"

;	ll. $char in subscripts
+^llchar("$char(32)")	-commands=set -xecute="do ^twork"
+^llchar($char(36,99,104,97,114,40,51,50,41))	-commands=set -xecute="do ^twork"
+^llchar($char(32):$char(126))	-commands=set -xecute="do ^twork"
+^llextra($char(97):"b";:;;)	-commands=set -xecute="do ^twork"
+^llextra($char(97):"c";":";;)	-commands=set -xecute="do ^twork"
+^llextra($char(97):"c";$char(58);;)	-commands=set -xecute="do ^twork"
+^llchar($char(97):$char(122);$char(65):$char(90))	-commands=set -xecute="do ^twork"
+^llchar("a":$char(122);$char(65):"Z")	-commands=set -xecute="do ^twork"
+^llchar($char(97):$char(122),$char(65):$char(90))	-commands=set -xecute="do ^twork"

;	g. local variables as part of the trigger subscript range(s)
+^%glvn(tvar=:)				-commands=set -xecute="do ^twork"
+^glvn(tvar=*)				-commands=set -xecute="do ^twork"
+^glvn(tvar=?.e)				-commands=set -xecute="do ^twork"
+^glvn(tvaris=tvar=:)			-commands=set -xecute="do ^twork"
+^glvn(tvaris=tvar=*)			-commands=set -xecute="do ^twork"
+^glvn(tvaris=tvar=?.e)			-commands=set -xecute="do ^twork"
+^glvn(ttvaris=tvaris=tvar=:)		-commands=set -xecute="do ^twork"
+^glvn(ttvaris=tvaris=tvar=*)		-commands=set -xecute="do ^twork"
+^g1vn(ttvaris=tvaris=tvar=?.e)		-commands=set -xecute="do ^twork"
+^%gepat(tvar=?3N1"-"2N1"-"4N;?2N1"-"7N)	-commands=set -xecute="do ^twork"
+^gepat(tvaris=tvar=?3N1"-"2N1"-"4N;?2N1"-"7N)	-commands=set -xecute="do ^twork"
+^gcrange(tvar=10;50:)			-commands=set -xecute="do ^twork"
+^gcrange(tvar=tvaris=ttvaris=10;20;30;50) -commands=set -xecute="do ^twork"
+^gcrange(tvar=0:20;30:50)		-commands=set -xecute="do ^twork"
+^gcrange(tvaris="a":;:"A")		-commands=set -xecute="do ^twork"
+^gcrange(tvaris=$char(97):;:"A")		-commands=set -xecute="do ^twork"
+^%gcrange(tvar="a":;20;30;50)		-commands=set -xecute="do ^twork"
+^gcrange(tvaris=tvar=20:"a";30:50)	-commands=set -xecute="do ^twork"
+^glextra(tvar="a;":"b";)		-commands=set -xecute="do ^twork"
+^glextra(tvaris=tvar="a=":"b=";:;)	-commands=set -xecute="do ^twork"
+^glextra(tvar2="a":"b;""";*)		-commands=set -xecute="do ^twork"

;	d. multiple subscripts
+^%d500N(t=:;;*;;?.e,*;,t2=;;?.e,t3=","","",";;)	-commands=set -xecute="do ^twork"
+^%d500N(t=:;$char(42),*,t2=?.e,t3=","","",")	-commands=set -xecute="do ^twork"
+^dzepat(?3N1"-"2N1"-"4N,:;"?3N1-2N1-4N";,*,?.e)	-commands=set -xecute="do ^twork"
+^dcrange(tvar="a":;20;30;50)			-commands=set -xecute="do ^twork"
+^gcrange(t3=tv="a":;:"A","Bb,;)^a())),""",t2=*)	-commands=set -xecute="do ^twork"
+^dzpunc(" ",tv="""":",";;":":"~",n5="*";"`")	-commands=set -xecute="do ^twork"
+^%t2(t=:2;9:;,t2=;;?.e,t3="^a(""t"")";:)	-commands=set -xecute="do ^twork"
+^dbcolon(:,*,1:5,:50,50:,"A":"z",:"v","K":)	-commands=set -xecute="do ^twork"
+^dlextra("a":"b";*,1:5;:,""","":";"-piece=")	-commands=set -xecute="do ^twork"
+^dgepatpunc(t2=tvar=?3N1"-;,"")(^%#",?2N,?2.5N,?5N,?2N;:)	-commands=set -xecute="do ^twork"
+^dgepatpunc(t=?3N1"-"2N1"-"4N,t2=?2N1"-"7N,:,t4=*,t5=?3N1"?""")	-commands=set -xecute="do ^twork"
+^dgepatpunc(t="t=?3N1""-""4N","t2=?2N1-7N",*)	-commands=set -xecute="do ^twork"

;	j. COLLATION checking on ranges HERE TODO
;	k. Unicode testing goes here TODO
;^unicode("અમૂલ") -commands=set -xecute="do ^twork"

; 2. Options
;	a. consistencycheck/noconsistencycheck (c/noc)
;	b. isolation/noisolation (i/noi)
+^%d500N(t=:;;*;;?.e,*;,t2=;;?.e,t3=","","",";;)	-commands=set -xecute="do ^twork" -options=noi,noc
+^%d500N(t=:;$char(42),*,t2=?.e,t3=","","",")	-commands=set -xecute="do ^twork" -options=i -options=noi,noc
+^dzepat(?3N1"-"2N1"-"4N,:;"?3N1-2N14N:";,*,?.e)	-commands=set -xecute="do ^twork" -options=i,c
+^dcrange(tvar="a":;20;30;50)			-commands=set -xecute="do ^twork" -options=i
+^gcrange(t3=tv="a":;:"A","Bb,;)())),""",t2=*)	-commands=set -xecute="do ^twork" -options=c
+^dzpunc(" ",tv="""":",";;":":"~",n5="*";"`")	-commands=set -xecute="do ^twork" -options=isolation,consistencycheck
+^%t2(t=:2;9:;,t2=;;?.e,t3="^a(""t"")";:)	-commands=set -xecute="do ^twork" -options=noc,isolation
+^dbcolon(:,*,1:5,:50,50:,"A":"z",:"v","K":)	-commands=set -xecute="do ^twork" -options=consistencycheck,noi
+^gepatpunc(t2=tvar=?3N1"-;,"")(^%#",?2N,?2.5N,?5N,?2N;:)	-commands=set -xecute="do ^twork" -options=noi,c
+^dlextra("a":"b";*,1:5;:,""","":";"-piece=")	-commands=set -xecute="do ^twork" -options=noc,i
+^dgepatpunc(t2=tvar=?3N1"-;,"")(^%#",?2N,?2.5N,?5N,?2N;:)	-commands=set -xecute="do ^twork" -options=c -options=noc
+^dgepatpunc(t=?3N1"-"2N1"-"4N,t2=?2N1"-"7N,:,t4=*,t5=?3N1"?""")	-commands=set -xecute="do ^twork" -options=i,i
+^dgepatpunc(t="t=?3N1""-""4N","t2=?2N1-7N",*)	-commands=set -xecute="do ^twork" -options=c,i

; 3. [z]delimiters with/without piece
;	a. 0/1 piece with quoted character
+^%d500N(t=:;;*;;?.e,*;,t2=;;?.e,t3=","","",";;)	-commands=set -xecute="do ^twork" -options=noi,noc -piece=1 -delim=" "
+^%d500N(t=:;;*;;?.e,*;,t2=;;?.e,t3=","","",";;)	-commands=set -xecute="do ^twork" -options=noi,noc -delim=" "

;	b. 0/1 piece with $[z]char delimiter
+^%d500N(t=:;;*;;?.e,*;,t2=;;?.e,t3=","","",";;)	-commands=set -xecute="do ^twork" -options=noi,noc -piece=1 -delim=$char(32)
+^%d500N(t=:;;*;;?.e,*;,t2=;;?.e,t3=","","",";;)	-commands=set -xecute="do ^twork" -options=noi,noc -delim=$char(32)

;	c. 0/1 piece with string (includes $[z]char getting butchered)
+^dzepat(?3N1"-"2N1"-"4N,:;"?3N1-2N14N:";,*,?.e)	-commands=set -piece=50 -xecute="do ^twork" -options=i,c -delim="$char(32)"
+^gcrange(t3=tv="a":;:"A","Bb,;)())),""",t2=*)	-commands=set -xecute="do ^twork" -options=c -piece=1 -delim="||"
+^gcrange(t3=tv="a":;:"A","Bb,;)())),""",t2=*)	-commands=set -xecute="do ^twork" -options=c -piece=1 -delim=$char(124,124)
+^gcrange2($char(98):;:"A","Bb,;)())),""",t2=*)	-commands=set -xecute="do ^twork" -options=c -delim="<=>"
+^gcrange2($char(98):;:"A","Bb,;)())),""",t2=*)	-commands=set -xecute="do ^twork" -options=c -delim=$char(60,61,62)

;	e. 0/1 piece with expression delimiter
+^gcrange(t3=tv="a":;:"A","Bb,;)())),""",t2=*)	-commands=set -xecute="do ^twork" -options=c -piece=1 -delim="|"_$char(124)
+^gcrange(t3=tv="a":;:"A","Bb,;)())),""",t2=*)	-commands=set -xecute="do ^twork" -options=c -piece=1 -delim="|"_"|"
+^gcrange(t3=tv="a":;:"A","Bb,;)())),""",t2=*)	-commands=set -xecute="do ^twork" -options=c -piece=1 -delim=$char(124)_"|"
+^gcrange(t3=tv="a":;:"A","Bb,;)())),""",t2=*)	-commands=set -xecute="do ^twork" -options=c -piece=1 -delim=$char(124)_$zchar(124)
+^gcrange2($char(98):;:"A","Bb,;)())),""",t2=*)	-commands=set -xecute="do ^twork" -options=c -piece=2 -delim="<"_"="_">"
+^gcrange2($char(98):;:"A","Bb,;)())),""",t2=*)	-commands=set -xecute="do ^twork" -options=c -piece=2 -delim="<"_"=>"
+^gcrange2($char(98):;:"A","Bb,;)())),""",t2=*)	-commands=set -xecute="do ^twork" -options=c -piece=2 -delim=$zchar(60)_$char(61)_$zchar(62)
+^gcrange2($char(98):;:"A","Bb,;)())),""",t2=*)	-commands=set -xecute="do ^twork" -options=c -piece=2 -delim=$char(60,61)_$zchar(26)
+^gcrange3($char(98):;:"A","B,;)())),""",t2=*)	-commands=set -xecute="do ^twork" -options=c -delim="$zchar(60)_$char(61)_$zchar(62)"
+^gcrange3($char(98):;:"A","B,;)())),""",t2=*)	-commands=set -xecute="do ^twork" -options=c -delim="$char(60,61)_$zchar(26)"

;	f. 1 piece with nasty characters in the expression
+^dzpunc(" ",tv="""":",";;":":"~",n5="*";"`")	-commands=set -xecute="do ^twork" -options=i,c -delim="-"_"|"_" -piece=66" -piece=10
+^%t2(t=:2;9:;,t2=;;?.e,t3="^a(""t"")";:)	-commands=set -xecute="do ^twork" -options=noc,i -piece=9 -delim=""""
+^dbcolon(:,*,1:5,:50,50:,"A":"z",:"v","K":)	-commands=set -xecute="do ^twork" -options=c,noi -piece=6 -delim=$char(254)_$char(11)
+^gepatpunc(t2=tvar=?3N1"-;,"")(^%#",?2N,?2.5N,?5.7N,?2N;:)	-commands=set -xecute="do ^twork" -options=noi,c -piece=1 -delim=" "" -options=i,noi"
+^dlextra("a":"b";*,1:5;:,""","":";"-piece=")	-commands=set -xecute="do ^twork" -options=noc,i -piece=7 -delim=$char(71,84)_$zchar(46,77)
+^dgepat(t=?3N1"-"2N1"-"4N,t2=?2N1"-"7N,:,t4=*,t5=?3N1"?""")	-commands=set -xecute="do ^twork" -delim="$zchar(9)_$char(254)_""" -options=i,i -piece=1
+^dgepat(t="t=?3N1""-""4N","t2=?2N1-7N",*)	-delim="-commands=kill,ztkill -"_"|"_" -piece=55" -piece=9 -commands=set -xecute="do ^twork" -options=c
+^%dzepat(?3N1"-"2N1"-"4N,:;"?3N1-2N14N:";,*,?.e)	-commands=set -xecute="do ^twork" -options=i,c -piece=100 -delim=" !""#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^"
+^%dzepat(?3N1"-"2N1"-"4N,:;"?3N1-2N14N:";,*,?.e)	-commands=set -xecute="do ^twork" -options=i,c -piece=100 -delim=" !""#$%&'()*+,-./0123456789:; _`abcdefghijklmnopqrstuvwxyz{|}~"
+^%dzepat(?3N1"-"2N1"-"4N,:;"?3N1-2N14N:";,*,?.e)	-commands=s,zk -xecute="do ^twork" -options=i,c -piece=100 -delim=$char(32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55)
+^%dzepat(?3N1"-"2N1"-"4N,:;"?3N1-2N14N:";,*,?.e)	-commands=s,zk -xecute="do ^twork" -options=i,c -piece=100 -delim=$char(56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79)
+^%dzepat(?3N1"-"2N1"-"4N,:;"?3N1-2N14N:";,*,?.e)	-commands=s,zk -xecute="do ^twork" -options=i,c -piece=100 -delim=$char(80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102)
+^%dzepat(?3N1"-"2N1"-"4N,:;"?3N1-2N14N:";,*,?.e)	-commands=s,zk -xecute="do ^twork" -options=i,c -piece=100 -delim=$char(103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120)
+^%dzepat(?3N1"-"2N1"-"4N,:;"?3N1-2N14N:";,*,?.e)	-commands=s,zk -xecute="do ^twork" -options=i,c -piece=100 -delim=$char(121,122,123,124,125,126)

;	g. UNICODE testing with zdelim TODO!!!!!!!!!
;^dcrange(tvar="a":;20;30;50)			-commands=set -xecute="do ^twork" -options=i -piece=1 -delim="" <-unicode gujarati a
;^dcrange5(tvar="a":;20;30;50)			-commands=set -xecute="do ^twork" -options=i -piece=1 -delim=$char(2693)
;^dcrange5(tvar="a":;20;30;50)			-commands=set -xecute="do ^twork" -options=i -piece=1 -delim=$zchar(224,170,133)
;^dcrange5(tvar=$char(2693):;20;30;50)		-commands=set -xecute="do ^twork" -options=i -piece=1 -delim="$char(2693)"
;^dcrange5(tvar="a":;20;30;50)			-commands=set -xecute="do ^twork" -options=i -piece=1 -delim="$zchar(224,170,133)"
;$char(2693,2734,2754,2738)
;$zchar(256)

; 4. Pieces with static delimiter
;	a. single piece (done)
;	b. multiple pieces
+^%d500N(t=:;;*;;?.e,*;,t2=;;?.e,t3=","","",";;)	-commands=set -xecute="do ^twork" -options=noi,noc -delim="`" -piece=1;20
+^gcrange2($char(97):;:"A","Bb,;)())),""",t2=*)	-commands=set -xecute="do ^twork" -options=c -delim="^%GD" -piece=1;2;3;4;5
+^%t2(t=:2;9:;,t2=;;?.e,t3="^a(""t"")";:)	-commands=set -xecute="do ^twork" -options=noc,i -delim="""" -piece=1;2;55

;	c. ranges of pieces
+^gcrange2($char(97):;:"A","Bb,;)())),""",t2=*)	-commands=set -xecute="do ^twork" -options=c -delim="^%GD" -piece=1:5
+^dzpunc(" ",tv="""":",";;":":"~",n5="*";"`")	-commands=set -xecute="do ^twork" -options=i,c -delim="-"_"|"_" -piece=66" -piece=1:3;5:9
+^dbcolon(:,*,1:5,:50,50:,"A":"z",:"v","K":)	-commands=set -xecute="do ^twork" -options=c,noi -delim=$char(254)_$char(11) -piece=1;2;3;5:9
+^dbcolon(:,*,1:5,:50,50:,"A":"z",:"v","K":)	-commands=set -xecute="do ^twork" -options=c,noi -delim=$char(254)_$char(11) -piece=1:3;5:6;7:9
;	d. pieces with LVN
; TODO


; 5. Commands
;	a. single commands
+^a -command=set -xecute="do ^twork"
+^a -command=kill -xecute="do ^twork"
+^a -command=zkill -xecute="do ^twork"
+^a -command=zwithdraw -xecute="do ^twork"
+^%pct -command=ztkill -xecute="do ^twork"

;	b. vary the case
+^a -command=SET -xecute="do ^twork"
+^a -command=sET -xecute="do ^twork"
+^a -command=KiLl -xecute="do ^twork"
+^a -command=ZKiLl -xecute="do ^twork"
+^a -command=ZWiTHDRaW -xecute="do ^twork"
+^%pct -command=ZTKilL -xecute="do ^twork"

;	c. short form
+^a5c -command=S -xecute="do ^twork"
+^a5c -command=sET -xecute="do ^twork"
+^a5c -command=K -xecute="do ^twork"
+^a5c -command=k -xecute="do ^twork"
+^a5c -command=ZK -xecute="do ^twork"
+^a5c -command=zw -xecute="do ^twork"
+^%pct -command=ztk -xecute="do ^twork"

;	d. multiple commands (needs to show ZKill and ZWithdraw as the same)
+^a5d -command=set,kill,zkill,zwithdraw -xecute="do ^twork"
+^%pct -command=set,zkill,zwithdraw,ztkill -xecute="do ^twork"
+^%d500N(t=:;;*;;?.e,*;,t2=;;?.e,t3=","","",";;)	-commands=set,kill,zkill,zwithdraw -xecute="do ^twork" -options=noi,noc -delim="`" -piece=1;20
+^%d500N(t=:;$char(42),*,t2=?.e,t3=","","",")	-commands=s,k,zk,zw -xecute="do ^twork" -options=i -options=noi,noc -delim=$char(96) -piece=1;20
+^gcrange2($char(97):;:"A","Bb,;)())),""",t2=*)	-commands=set  -xecute="do ^twork" -options=c -delim="^%GD" -piece=1;2;3;4;5
+^%t2(t=:2;9:;,t2=;;?.e,t3="^a(""t"")";:)	-commands=set  -xecute="do ^twork" -options=noc,i -delim="""" -piece=1;2;55
+^dzpunc8(" ",tv="""":",";;":":"~",n5="*";"`")	-commands=set  -xecute="do ^twork" -options=i,c -delim="-"_"|"_" -piece=66" -piece=1:3;5:9
+^d5bcolon(:,*,1:5,:5,5:,"A":"z",:"v","K":)	-commands=s,zk -xecute="do ^twork" -options=c,noi -delim="_"_$char(11) -piece=1;2;3;5:9 -options=noi,c
+^d5bcolon(:,*,1:5,:5,5:,"A":"z",:"v","K":)	-commands=s,k,zw -xecute="do ^twork" -options=c,noi -delim="_"_$char(11) -piece=1:3;5:6;7:9
+^%d500N(t=:;;*;;?.e,*;,t2=;;?.e,t3=","","",";;)	-delim="-commands=k,ztk -"_"|"_" -piece=5" -commands=s,k -xecute="do ^twork" -options=noi,noc -piece=3
+^dzepatn(?3N1"-"2N1"-"4N,:;"?3N1-2N14N:";,*,?.e)	-commands=set -xecute="do ^twork" -options=i,c -piece=1;2 -delim=$char(126)
+^dzepatn(?3N1"-"2N1"-"4N,:;"?3N1-2N14N:";,*,?.e)	-commands=s,zk -xecute="do ^twork" -options=i,c -piece=1:2 -delim=$char(126)

; 6. xecute string
+^dzepatn(?3N1"-"2N1"-"4N,:,*,?.e)		-xecute="do ^twork" -options=i,c -commands=ztk
+^dcrange(tvar="a":;20;30;50)			-commands=set -xecute="do some^twork" -options=i -piece=55:101 -delim=$char(46)
+^gcrange(t3=tv="a":;:"A","Bb,;)())),""",t2=*)	-commands=kill -xecute="set ^done($ztwormhole)=$$kill^job" -options=c
+^dzpunc(" ",tv="""":",";;":":"~",n5="*";"`")	-commands=zk,k -xecute="do ^twork" -options=isolation,consistencycheck
+^%t2(t=:2;9:;,t2=;;?.e,t3="^a(""t"")";:)	-commands=zw -xecute="do ^twork" -options=noc,isolation
+^dbcolon(:,*,1:5,:50,50:,"A":"z",:"v","K":)	-commands=set -xecute="set ^last(""axn"",$ztwormhole)=$$^teller" -options=consistencycheck,noi
+^gepatpunc(t2=tvar=?3N1"-;,"")(^%#",?2N,?2.5N,?5N,?2N;:)	-commands=set -xecute="do ^twork" -options=noi,c -delim="?3N1" -piece=3
+^dlextra("a":"b";*,1:5;:,""","":";"-piece=")	-commands=set -xecute="set ^me=""""" -options=noc,i
+^dgepatpunc(t2=tvar=?3N1"-;,"")(^%#",?2N,?2.5N,?5N,?2N;:)	-commands=set -xecute="set x=""test"" do ^twork" -options=c -options=noc
+^dgepatpunc(t2=tvar=?3N1"-;,"")(^%#",?2N,?2.5N,?5N,?2N;:)	-options=noc -commands=set -xecute="do ^somemrtn(""trigg-AH"")"
+^dgepatpunc(t2=tvar=?3N1"-;,"")(^%#",?2N,?2.5N,?5N,?2N;:)	-options=noc -xecute="do ^sometworker" -commands=s
+^dgepatpunc(t=?3N1"-"2N1"-"4N,t2=?2N1"-"7N,:,t4=*,t5=?3N1"?""")	-commands=ztk -xecute="do multi^tkilla" -options=i,i
+^dgepatpunc(t="t=?3N1""-""4N","t2=?2N1-7N",*)	-commands=set -xecute="do ^twork" -options=c,i -delim="_"" " -options=i,i -piece=1:7

; 7. trigger names
+^tnamed -commands=set -xecute="do ^twork" -name=trinamel
+^tnamed -commands=set -xecute="do ^twork"
+^tnamepatn(?3N1"-"2N1"-"4N,:,*,?.e)		-xecute="do ^twork" -options=i,c -commands=ztk -name=makemedizzy
+^tnmcolon(:,*,1:5,:50,50:,"A":"z",:"v","K":)	-name=colon -commands=S -xecute="set ^last(""axn"")=$$^teller" -options=consistencycheck,noi
+^tnpatpunc(t="t=?3N1""-""4N","t2=?2N1-7N",*)	-commands=set -xecute="do ^twork" -options=c,i -delim="_"" " -options=i,i -piece=1:7
+^tnpatpunc(t="t=?3N1""-""4N","t2=?2N1-7N",*)	-commands=set -xecute="do ^twork" -options=c,i -delim="_"" " -options=i,i -piece=1:7 -name=patpunk

; [GTM-7947] SIG-11 while deleting triggers with wildcard when global name is greater than 21 characters
+^abcdefghijklmnopqrstuvwxyz -commands=K -xecute="do ^tkill1"
+^abcdefghijklmnopqrstuvwxyz -commands=K -xecute="do ^tkill2"
-abc*
