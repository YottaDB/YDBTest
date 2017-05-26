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
	; this test specifically tests the revised V54002 trigger delete
	; and select by trigger name
namedelete
	write "Testing named select and deletes",!
	do setup
nosetup
	do oneusername
	do onegenname
	do multigenname
	do multiusername
	do longnames
	do ^echoline
	quit

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
setup
	do ^echoline
	do text^dollarztrigger("tfile^namedelete","namedelete.trg")
	do file^dollarztrigger("namedelete.trg",1)
	do all^dollarztrigger
	do ^echoline
	quit

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
oneusername
	do ^echoline
	write "Testing deletion of individual user defined names",!
	do file^dollarztrigger("namedelete.trg",1)
	do testmain("tfileoneusername")
	quit

	;<trigger name>;<expected result>;<COMMENT>
tfileoneusername
	;-9notaname;INVALID;	leading number is not a m literal
	;-not.aname;INVALID;	non-alphanumeric in the string
	;-.notaname;INVALID;	non-alphanumeric in the string
	;-n.otaname;INVALID;	non-alphanumeric in the string
	;-no.taname;INVALID;	non-alphanumeric in the string
	;-yName#0;INVALID;	number after # does not pass auto name numeric parsing
	;-yName#a;INVALID;	the runtime information is parsed as numeric and it fails
	;-yName#;VALID
	;-%;VALID;		% is a valid GVN and name
	;-%pctgvn;VALID
	quit

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
onegenname
	do ^echoline
	write "Testing deletion of individual generated names",!
	do file^dollarztrigger("namedelete.trg",1)
	do testmain("tfileonegenname")
	write "Do a few more selects on auto#* and ^auto",!,!
	set selres=$ztrigger("select","auto#*,%pct*")
	do ^echoline
	set selres=$ztrigger("select","^auto,^%pct")
	do ^echoline
	quit

tfileonegenname
	;-auto#;VALID;		There is no trigger with this name
	;-auto#a;INVALID;	non-number in number portion of the name
	;-auto#.;INVALID;	non-number in number portion of the name
	;-auto##;INVALID;	extra # sign should fail numeric name check
	;-auto#4##;INVALID;	extra # sign should fail numeric name check
	;-auto#4#1;INVALID;	no run time information allowed
	;-auto#4#;VALID
	;-auto#2;VALID
	;-%pct#3#;VALID
	;-%pct#1;VALID
	;-%pctgvn#;VALID;	this is actually a user defined name
	;-%pctgvn#0;INVALID;	because #TNCOUNT starts from 1
	;-%pctgvn#2;VALID;
	;-%9lives#5;VALID;	does not exist
	;-%9lives#4;VALID
	quit

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
multigenname
	do ^echoline
	write "Testing deletion of multiple generated names",!
	do file^dollarztrigger("namedelete.trg",1)
	do testmain("tfilemultigenname")
	write !,"Do a few more selects on ^a and ^yName",!
	set selres=$ztrigger("select","^a,^yName")
	do ^echoline
	quit

tfilemultigenname
	;-yName##*;INVALID;		extra # sign should break
	;-yName##;INVALID;		extra # sign should break
	;-yName#1#1;INVALID;		no run time information allowed
	;-yName#1*;INVALID;		cannot put a wild card in the numeric portion of the auto name
	;-yName#*;VALID
	;-%pctgvn#034567#;INVALID;	number after # does not pass auto name numeric parsing
	;-%pctgvn#999999#;VALID;	this passes the parser but does not exist
	;-%pctgvn#1#a;INVALID;		no run time information allowed
	;-%pctgvn*;VALID;		This should delete both auto and user names
	;-%9lives#*;VALID
	quit


	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
multiusername
	do ^echoline
	write "Testing deletion of multiple user defined names",!
	do file^dollarztrigger("namedelete.trg",1)
	do testmain("tfilemultiusername")
	do ^echoline
	write !,"Do a complete select, we should only see yNamp",!
	set x=$ztrigger("select")
	do ^echoline
	quit

tfilemultiusername
	;-y*p;INVALID;	interior asterix is not allowed
	;-yName*;VALID
	;-a*;VALID
	;-b#*;VALID
	;-%*;VALID;	delete all triggers beginning with a % sign
	quit


	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; PATCODEs for valid names
	; user defined:		?1(1"%",1A).27(1A,1N).1(1"#",1"*")
	; auto generated:	?1(1"%",1A).20(1A,1N)1"#"1(1.6N.1"#",1"*")
isvalid(name)
	if name?1(1"%",1A).27(1A,1N).1(1"#",1"*") quit 1
	if name?1(1"%",1A).20(1A,1N)1"#"1(1.6N.1"#",1"*") quit 1
	write:$data(debug) "length:",?16,$length($piece(name,"#",1)),?32,$length(name,"#"),!
	quit 0

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; does most of the test work by loading lines from $TEXT and
	; grabbing the name and expected status. SELECT result reports
	; failure IFF there is something wrong with the trigger name
testmain(target)
	new i,x,line,name,expected,status
	for  quit:$text(@target+$i(i)^namedelete)=" quit"  do
	.	set line=$text(@target+i^namedelete)
	.	set name=$piece(line,";",2),selname=name
	.	set $extract(selname,1,1)="" ; strip off the leading minus sign
	.	set expected=$select($piece(line,";",3)="INVALID":0,1:1)
	.	; SELECT
	.	write !,"Select '",selname,"'(",$length(selname),")",!
	.	set selres=$ztrigger("select",selname)
	.	; if 'selres write "FAIL - unexpected $ztrigger(select) result for '",?32,name,"'",!
	.	; DELETE
	.	write !,"Delete '",name,"'(",$length(name)-1,")",!
	.	set status=$ztrigger("item",name)
	.	if status'=selres write "FAIL - unexpected $ztrigger(item) delete result for '",?32,name,"'",!
	.	; SELECT after DELETE
	.	set selres2=$ztrigger("select",selname)
	.	if selres'=selres2 write "FAIL - unexpected $ztrigger(select2) result for '",?32,name,"'",!
	do ^echoline
	quit

	; target triggers to delete by names, auto generated and user defined
tfile
	;-*
	;;^a has mixed auto and user generated names
	;+^a -command=S -xecute="set x=1"
	;+^a -command=S -xecute="set x=2"
	;+^a -command=S -xecute="set x=3" -name=yName
	;+^a -command=S -xecute="set x=10" -name=yNamp
	;
	;;^b has mixed auto and user generated names
	;+^b -command=S -xecute="set x=4"
	;+^b -command=S -xecute="set x=5"
	;+^b -command=S -xecute="set x=6" -name=yName2
	;
	;;^yName is only auto generated names
	;+^yName -command=S -xecute="set x=7"
	;+^yName -command=S -xecute="set x=8"
	;+^yNamp -command=S -xecute="set x=9"
	;
	;; stray ^a for fun
	;+^a -command=S -xecute="set x=12"
	;
	;; Whoa! the name is the same as an auto generated name
	;+^%pctgvn -command=S -xecute="set x=13" -name=%pctgvn
	;+^%pctgvn -command=S -xecute="set x=16"
	;+^%pctgvn -command=S -xecute="set x=17"
	;+^%pctgvn -command=S -xecute="set x=18"
	;
	;+^%pct    -command=S -xecute="set x=14"
	;+^%pct    -command=S -xecute="set x=15"
	;+^%pct    -command=S -xecute="set x=19"
	;+^%pct    -command=S -xecute="set x=20"
	;+^pct     -command=S -xecute="set x=25" -name=%
	;
	;+^%9lives -command=S -xecute="set x=21"
	;+^%9lives -command=S -xecute="set x=22"
	;+^%9lives -command=S -xecute="set x=23"
	;+^%9lives -command=S -xecute="set x=24"
	;
	;; ^auto is auto generated only but will get picked up by -a*
	;+^auto -command=ZTR -xecute="set x=1"
	;+^auto -command=ZTR -xecute="set x=2"
	;+^auto -command=ZTR -xecute="set x=3"
	;+^auto -command=ZTR -xecute="set x=4"
	quit

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
longnames
	do ^echoline
	write "Install some long named, > 21 char, triggers",!
	do item^dollarztrigger("tfilelong^namedelete","long.trg.trigout")
	write "Delete long generated and user defined names",!
	set x=$ztrigger("select")
	do testmain("tfilelongdelete")
	write !,"Do a complete select",!
	set x=$ztrigger("select")
shortnameLONGGVN
	do ^echoline
	do item^dollarztrigger("tfilelongnamed^namedelete","longnamed.trg.trigout")
	write "Delete long GVNs with short names",!
	set x=$ztrigger("select")
	do testmain("tfilelongnamedelete")
	write !,"Do a complete select. We expected everything was deleted!",!
	set x=$ztrigger("select")
	quit

longname21chars	;
	do text^dollarztrigger("longnamediffregs^namedelete","longnamediffregs.trg")
	do file^dollarztrigger("longnamediffregs.trg",1)
	write $ztrigger("select"),!
	write $ztrigger("item","-a23456789012345678901#2"),!
	write $ztrigger("select","a23456789012345678901#1"),!
	write $ztrigger("select","a23456789012345678901#3"),!
	write $ztrigger("item","-a23456789012345678901#1"),!
	write $ztrigger("select","*"),!

	; Delete long generated and user defined names
tfilelong
	;-*
	;+^aaaaaaaaaaaaaaaaaaaab    -commands=S -xecute="set x=21"
	;+^aaaaaaaaaaaaaaaaaaaabc   -commands=S -xecute="set x=22"
	;+^aaaaaaaaaaaaaaaaaaaabcd  -commands=S -xecute="set x=23"
	;+^aaaaaaaaaaaaaaaaaaaabcde -commands=S -xecute="set x=24"
	;+^z			    -commands=S -xecute="set x=21" -name=aaaaaaaaaaaaaaaaaaaab
	;
	;;Note: set y vs set x in the XECUTE string and the leading %
	;+^%aaaaaaaaaaaaaaaaaaab    -commands=S -xecute="set y=21"
	;+^%aaaaaaaaaaaaaaaaaaabc   -commands=S -xecute="set y=22"
	;+^%aaaaaaaaaaaaaaaaaaabcd  -commands=S -xecute="set y=23"
	;+^%aaaaaaaaaaaaaaaaaaabcde -commands=S -xecute="set y=24"
	;+^z			    -commands=S -xecute="set y=21" -name=%aaaaaaaaaaaaaaaaaaab
	quit

tfilelongdelete
	;-aaaaaaaaaaaaaaaaaaaabcd#;VALID;		under user generated name length
	;-aaaaaaaaaaaaaaaaaaaabc#;VALID;		under user generated name length
	;-aaaaaaaaaaaaaaaaaaaab#;VALID;			exactly match auto defined name length but under user generated name length
	;-aaaaaaaaaaaaaaaaaaaabcd#*;INVALID;		exceed auto name length
	;-aaaaaaaaaaaaaaaaaaaabc#*;INVALID;		exceed auto name length
	;-aaaaaaaaaaaaaaaaaaaab#1234567#;INVALID;	exceed numeric portion of auto name
	;-aaaaaaaaaaaaaaaaaaaab#1234567;INVALID;	exceed numeric portion of auto name
	;-aaaaaaaaaaaaaaaaaaaab#3;VALID;		within auto generated name length
	;-aaaaaaaaaaaaaaaaaaaab#*;VALID;		targets only auto gen names
	;-%aaaaaaaaaaaaaaaaaaab*;VALID;			target auto and user defined names, note the leading %
	quit

	; Delete long GVNs with short names
tfilelongnamed
	;+^aaaaaaaaaaaaaaaaaaaab    -name=x21 -commands=S -xecute="set x=211"
	;+^aaaaaaaaaaaaaaaaaaaabc   -name=x22 -commands=S -xecute="set x=222"
	;+^aaaaaaaaaaaaaaaaaaaabcd  -name=x23 -commands=S -xecute="set x=233"
	quit

tfilelongnamedelete
	;-aaaaaaaaaaaaaaaaaaaabc123456789;INVALID;	exceed user defined name length
	;-aaaaaaaaaaaaaaaaaaaabc12345678;INVALID;	exceed user defined name length
	;-aaaaaaaaaaaaaaaaaaaabc1234567;INVALID;	exceed user defined name length
	;-aaaaaaaaaaaaaaaaaaaabc123456;VALID;		under user defined name length, but does not match
	;-aaaaaaaaaaaaaaaaaaaabcd#;VALID;		under user defined name length
	;-aaaaaaaaaaaaaaaaaaaabcd*;VALID;		does not exist but does match due to wildcard deletion usage
	;-aaaaaaaaaaaaaaaaaaaabc;VALID;			under user defined name length, but does not match
	;-aaaaaaaaaaaaaaaaaaaabcd#;VALID;		under user defined name length, but does not match
	;-aaaaaaaaaaaaaaaaaaaabcd*;VALID;		does not exist but does match due to wildcard deletion usage
	;-x#*;VALID;					does not exist but does match due to wildcard deletion usage
	;-x2*;VALID;					match short names for long GVN triggers
	quit

longnamediffregs	;
	;+^a23456789012345678901a -commands=SET -xecute="do ^twork(1)"
	;+^a23456789012345678901b -commands=SET -xecute="do ^twork(1)"
	;+^a23456789012345678901c -commands=SET -xecute="do ^twork(1)"
	;+^a23456789012345678901d -commands=SET -xecute="do ^twork(1)"
	;+^a23456789012345678901e -commands=SET -xecute="do ^twork(1)"
	;+^a23456789012345678901f -commands=SET -xecute="do ^twork(1)"
	quit
