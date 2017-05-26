testxecutelvn
	do ^echoline
	write "Local variable passing",!
	do text^dollarztrigger("tfile^testxecutelvn","testxecutelvn.trg")
	do file^dollarztrigger("testxecutelvn.trg",1)

	write "establish lvn1.31 in the current process space to prove stacking of LVNs",!
	set lvn="lvn" for i=1:1:31 set l=lvn_i set @l=i
	write "Test trigger LVNs",!
	set ^sublvn(1,"test",5,"test")=42
	set ^sublvn("pat","D9I08-002695")="Trigger TR ID"
	set ^sublvn("pat","nonalpanumeric",",./)")="testing non-alpanumerics in the subscript"
	set ^sublvn("char","=")="equals=sign"
	set ^sublvn("char"," ")="space cadet"
	set ^sublvn("char","#")="C-POUND"
	set ^sublvn("char","^#")="up-arrow pound T"
	set ^sublvn("char","~")="C-TILDE"
	set ^sublvn("int",11,11,55)="5 x 11"
	set ^sublvn("int",1,2,100)="Count 1 to 100"
	set ^sublvn("alpha","Alphard","beetleguesse","l")="Ford Prefect"
	set ^sublvn("alpha","babcock","rhyme","K")="Kelp on the mind"
	set ^sublvn(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31)="thirtyone subscript LVNs"
	set ^sublvn("testing thirtyonecharacterlongvariable1")="thirty-one character long variable"
	kill ^sublvn
	do ^echoline
	quit

tfile
	;+^sublvn -command=ZTK -xecute="write $ZTRIggerop,""Fire in the hole!"",!"
	;+^sublvn(lvn1="star",lvn2=?.e,lvn3=:,lvn4=*) -command=S,K -xecute="do ^lvncheck(4)"
	;+^sublvn(lvn1="pat",lvn2=?1(1"C",1"S",1"D")4(1U,1N)1"-"5.6N) -command=S,K -xecute="do ^lvncheck(2)"
	;+^sublvn(lvn1="pat",lvn2="nonalpanumeric",lvn3=?.(.C,.P)) -command=S,K -xecute="do ^lvncheck(3)"
	;+^sublvn(lvn1="char",lvn2=$char(32);$char(61)) -command=S,K -xecute="do ^lvncheck(2)"
	;+^sublvn(lvn1="char",lvn2=$char(32):$char(61);$char(122):$char(126)) -command=S,K -xecute="do ^lvncheck(2)"
	;+^sublvn(lvn1="int",lvn2=1:10;11:20,lvn3=10:;:5,lvn4=55;100) -command=S,K -xecute="do ^lvncheck(4)"
	;+^sublvn(lvn1="alpha",lvn2="A":"Z";"a":"z",lvn3="a":;:"Z",lvn4="K";"l") -command=S,K -xecute="do ^lvncheck(4)"
	;;write "^sublvn(" for i=1:1:31 write "lvn",i,"=:",$select(i>30:")",1:",") if i=31 write " -command=S,K -xecute=""do ^lvncheck(31)""",! 
	;+^sublvn(lvn1=:,lvn2=:,lvn3=:,lvn4=:,lvn5=:,lvn6=:,lvn7=:,lvn8=:,lvn9=:,lvn10=:,lvn11=:,lvn12=:,lvn13=:,lvn14=:,lvn15=:,lvn16=:,lvn17=:,lvn18=:,lvn19=:,lvn20=:,lvn21=:,lvn22=:,lvn23=:,lvn24=:,lvn25=:,lvn26=:,lvn27=:,lvn28=:,lvn29=:,lvn30=:,lvn31=:) -command=S,ZK -xecute="do ^lvncheck(31)"
	;+^sublvn(thirtyonecharacterlongvariable1=:) -command=S,ZK -xecute="write $reference,! write thirtyonecharacterlongvariable1,!"
