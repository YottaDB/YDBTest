fixed(encoding)	
	; Test the FIXED deviceparameter
	set mainlvl=$ZLEVEL
	set $ZTRAP="set $ZTRAP="""" do zterror^fixed"
	do init
	f i=1:1:3 do
	. f j=1:1:$length(str(i)) w $e(str(i),j),?7*j," "
	. write !
	. f j=1:1:$length(str(i)) w $a(str(i),j),?7*j," "
	. write !
	w !,"## CASE 1 ##",!
	set (rsize,minrsize)=minstrlen-1
	set verbose=1
	if ("UTF-8"'=encoding) if (rsize#2) s rsize=rsize-1
	do open^io(file(1),"NEWVERSION:FIXED:WRAP:RECORDSIZE="_rsize,encoding)
	close file(1)
	for rsize=minstrlen-1,minstrlen,maxstrlen+1 do
	.	if ("UTF-8"'=encoding) if (rsize#2) s rsize=rsize-1
	.	do open^io(file(1),"APPEND:FIXED:WRAP:RECORDSIZE="_rsize,encoding)
	.	do use^io(file(1),"WRAP")
	.	do wrtFixedNOEOL(rsize,rsize,1)
	.	close file(1)
	;
	set readtotstr=1
	write !,"### Now Read ###",!
	set verbose=0
	do open^io(file(1),"READONLY:FIXED",encoding)
	do use^io(file(1))
	read strr
	close file(1)
	use $P write strr,!,!
	s llen=$length(strr)
	for i=1:1:llen w $a(strr,i)," "
	;
	;
	;
	w !,!,"## CASE 2 ##",!
	set padint=0
	set verbose=1
	set wsize=maxstrlen+1
	do open^io(file(2),"NEWVERSION:FIXED:RECORDSIZE=50",encoding)
	if ("UTF-8"'=encoding) if (wsize#2) s wsize=wsize+1
	do use^io(file(2),"NOWRAP:WIDTH="_wsize)	
	do wrtFixedNOEOL(50,wsize,1)
	close file(2)
	for wsize=minstrlen-1,minstrlen,maxstrlen+1 do
	.	do open^io(file(2),"APPEND:FIXED:RECORDSIZE=50:PAD="_padint,encoding)
	.	if ("UTF-8"'=encoding) if (wsize#2) s wsize=wsize-1
	.	do use^io(file(2),"WRAP:WIDTH="_wsize)	
	.	do wrtFixedNOEOL(50,wsize,1)
	. 	set padint=padint+1
	.	close file(2)
	;
	write !,"### Now Read ###",!
	set verbose=1
	do open^io(file(2),"READONLY",encoding)
	do use^io(file(2),"WRAP")
	read strr
	close file(2)
	use $P write strr,!,!
	s llen=$length(strr)
	for i=1:1:llen w $a(strr,i)," "
	;
	;
	w !,!,"## CASE 3 ##",!
	do open^io(file(3),"NEWVERSION:FIXED:RECORDSIZE=50",encoding)
	close file(3)
	set verbose=1
	for wsize=minstrlen-1,maxstrlen+1 do
	. do open^io(file(3),"APPEND:FIXED:RECORDSIZE=50",encoding)
	. if ("UTF-8"'=encoding) if (wsize#2) s wsize=wsize-1
	. do use^io(file(3),"WRAP:WIDTH="_wsize)	
	. do wrtFixedEOL(50,wsize,1)
	. close file(3)
	;
	set verbose=1
	write !,"### Now Read ###",!
	set wsize=maxstrlen+10
	do open^io(file(3),"READONLY:FIXED",encoding)
	do use^io(file(3),"WRAP")	
	read strr
	close file(3)
	use $P write strr,!,!
	s llen=$length(strr)
	for i=1:1:llen w $a(strr,i)," "
	;
	;
	w !,!,"## CASE 4 ##",!
	set (rsize,minrsize)=minstrlen-1
	set verbose=1
	if ("UTF-8"'=encoding) if (rsize#2) s rsize=rsize-1
	do open^io(file(4),"NEWVERSION:FIXED:NOWRAP:RECORDSIZE="_rsize,encoding)
	close file(4)
	for rsize=minstrlen-1,minstrlen,maxstrlen+1 do
	.	if ("UTF-8"'=encoding) if (rsize#2) s rsize=rsize-1
	.	do open^io(file(4),"APPEND:FIXED:NOWRAP:RECORDSIZE="_rsize,encoding)
	.	do use^io(file(4),"NOWRAP")
	.	do wrtFixedNOEOL(rsize,rsize,0)
	.	close file(4)
	;
	write !,"### Now Read ###",!
	set verbose=1
	do open^io(file(4),"READONLY:FIXED:NOWRAP",encoding)
	do use^io(file(4),"NOWRAP")
	read strr
	close file(4)
	use $P write strr,!,!
	s llen=$length(strr)
	for i=1:1:llen w $a(strr,i)," "
	;
	quit
init
	set totstr=3
	set str(1)="１２３４５６７８９０"
	set str(2)="В чащах юга"
	set str(3)="나는 유리를 먹을 수 있어요"
	set maxstrlen=-1
	set minstrlen=99999999
	for i=1:1:totstr if maxstrlen<$zlength(str(i)) set maxstrlen=$zlength(str(i))
	for i=1:1:totstr if minstrlen>$zlength(str(i)) set minstrlen=$zlength(str(i))
	set file(1)=encoding_"_fixed1.txt"
	set file(2)=encoding_"_fixed2.txt"
	set file(3)=encoding_"_fixed3.txt"
	set file(4)=encoding_"_fixed4.txt"
	quit
	;
wrtFixedNOEOL(rsize,wsize,wrap)
	k dollarx,dollary,len,zlen
	if wsize>rsize set wsize=rsize
	set totlen=0
	set verx=0
	set very=0
	set line=0
	set fixederr=0
	for i=1:1:totstr do  quit:fixederr=1
	. write str(i)
	. set dollarx(i)=$X
	. set dollary(i)=$Y
	. if wrap=1 do
	. . set len(i)=$length(str(i))
	. . set zlen(i)=$zlength(str(i))
	. . set totlen=totlen+len(i)
	. . set line=(totlen-1)\wsize
	. . set very=line#66
	. . set verx=((verx+len(i))#wsize)  if verx=0 set verx=wsize
	. . ;if verx'=dollarx(i)  use $P zshow "*" set fixederr=1
	. . ;if very'=dollary(i)  use $P zshow "*" set fixederr=2
	use $P
	;zwrite 	
	quit
	;
readFixed
	set $ZTRAP="set $ZTRAP="""" do zterror^fixed"
	for i=1:1  do  quit:$ZEOF
	. read strr(i)
	set readtotstr=i
	quit
	;
	;
	;
wrtFixedEOL(rsize,wsize,wrap)
	k dollarx,dollary,len,zlen
	if wsize>rsize set wsize=rsize
	set verx=0
	set very=0
	set fixederr=0
	set line=0
	set totline=0
	for i=1:1:totstr do  quit:fixederr=1
	. write str(i),!
	. set dollarx(i)=$X
	. set dollary(i)=$Y
	. set len(i)=$length(str(i))
	. set zlen(i)=$zlength(str(i))
	. set line=(len(i)-1)\wsize
	. set totline=totline+line+1
	. set very=totline#66
	. set verx=0
	. ;if verx'=dollarx(i)  use $P zshow "*" set fixederr=1
	. ;if very'=dollary(i)  use $P zshow "*" set fixederr=2
	use $P
	;zwrite
	quit
	;
	;
	;
zterror
	use $PRINCIPAL
	write "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!",!
	write $ZSTATUS,!
	zshow "*"
	write "continue...",!
	write "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!",!
	zgoto mainlvl
	quit
