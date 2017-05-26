basfill	; simple fill routine to create some globals in the form:
	; Xx0123<...>, for X:A,B,C,D,E, and x:a,b,c,d,e
	set gbls="ABCDEFGH"
	set letters="abcdefgh"
	set maxlen=$ztrnlnm("maxlen")
	for xg=1:1:5  do
	. set gbl=$EXTRACT(gbls,xg,xg)
	. for xl=1:1:5  do
	. . set let=$EXTRACT(letters,xl,xl)
	. . set num=""
	. . for xn=3:1:(maxlen+1)  do
	. . . set num=num_(xn#10)
	. . . set gblnum="^"_gbl_let_num
	. . . set gblnum1=gblnum
	. . . set @gblnum1=1
	. . . set gblnum2=gblnum_"a"
	. . . set @gblnum2=2
	. . . set gblnum3=gblnum_"(1)"
	. . . set @gblnum3=3
	. . . set gblnum4=gblnum_"a(1)"
	. . . set @gblnum4=4
	set filen="basfill.out"
	open filen:(newversion)
	use filen
	zwrite ^?.E
	close filen
	quit
