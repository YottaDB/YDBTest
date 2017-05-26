varstr(encoding)	
	; Test the VARIABLE deviceparameter
	SET $ZTRAP="GOTO errorAndCont^errorAndCont"
	set mainlvl=$ZLEVEL
	set $ZTRAP="set $ZTRAP="""" do zterror^varstr"
	do init
	if ("UTF-8"=encoding) do
	. f i=1:1:3 w $zwidth(str(i)),?4,$zlength(str(i)),?4,str(i),!
	. w minstrlen,!,maxstrlen,!,minwid,!,maxwid,!
	set (rsize,minrsize)=minstrlen-1
	set verbose=1
	if ("UTF-8"'=encoding) if (rsize#2) s rsize=rsize-1
	do open^io(file(1),"NEWVERSION:STREAM:NOWRAP:RECORDSIZE="_rsize,encoding)
	close file(1)
	for rsize=minstrlen-1,minstrlen,maxstrlen-1,maxstrlen+1 do
	.	if ("UTF-8"'=encoding) if (rsize#2) s rsize=rsize-1
	.	do open^io(file(1),"APPEND:STREAM:NOWRAP:RECORDSIZE="_rsize,encoding)
	.	do use^io(file(1),"NOWRAP")
	.	do wrtFixedNOEOL(rsize,rsize,0)
	.	close file(1)
	write !,"### Now read ###",!
	set verbose=0
	do open^io(file(1),"READONLY:STREAM:NOWRAP",encoding)
	do use^io(file(1),"NOWRAP")
	do readVar
	close file(1)
	use $P for i=1:1:readtotstr write $ZWIDTH(strr(i)),":",$LENGTH(strr(i)),":",$ZLENGTH(strr(i)),?12,strr(i),!
	;
	;
	;
	set padint=0
	set verbose=1
	set wsize=maxwid+1
	do open^io(file(2),"NEWVERSION:VARIABLE:RECORDSIZE=32000",encoding)
	do use^io(file(2),"NOWRAP:WIDTH="_wsize)	
	do wrtFixedNOEOL(32000,wsize,0)
	close file(2)
	for wsize=minwid-1,minwid,maxwid-1,maxwid+1 do
	.	do open^io(file(2),"APPEND:VARIABLE:RECORDSIZE=32000:PAD="_padint,encoding)
	.	do use^io(file(2),"NOWRAP:WIDTH="_wsize)	
	.	do wrtFixedNOEOL(32000,wsize,0)
	. 	set padint=padint+1
	.	close file(2)
	write !,"### Now read ###",!
	set verbose=0
	do open^io(file(2),"READONLY:VARIABLE:RECORDSIZE=32000",encoding)
	do use^io(file(2),"NOWRAP")
	do readVar
	close file(2)
	use $P for i=1:1:readtotstr write $ZWIDTH(strr(i)),":",$LENGTH(strr(i)),":",$ZLENGTH(strr(i)),?12,strr(i),!
	write !
	;
	;
	;
	set verbose=1
	do open^io(file(3),"NEWVERSION:VARIABLE:RECORDSIZE=32000:PAD=127",encoding)
	close file(3)
	for wsize=minwid-1,maxwid+1 do
	. do open^io(file(3),"APPEND:VARIABLE:RECORDSIZE=32000:PAD=127",encoding)
	. do use^io(file(3),"WRAP:WIDTH="_wsize)	
	. do wrtFixedEOL(32000,wsize,1)
	. close file(3)
	set verbose=0
	write !,"### Now read ###",!
	set wsize=maxwid+10
	do open^io(file(3),"READONLY:VARIABLE:RECORDSIZE=32000",encoding)
	do use^io(file(3),"WRAP:WIDTH="_wsize)	
	do readVar
	close file(3)
	use $P for i=1:1:readtotstr write $ZWIDTH(strr(i)),":",$LENGTH(strr(i)),":",$ZLENGTH(strr(i)),?12,strr(i),!
	write !
	;
	;
	set (rsize,minrsize)=minstrlen-1
	set verbose=1
	if ("UTF-8"'=encoding) if (rsize#2) s rsize=rsize-1
	do open^io(file(4),"NEWVERSION:VARIABLE:NOWRAP:RECORDSIZE="_rsize,encoding)
	close file(4)
	for rsize=minrsize-1,minrsize,maxstrlen,maxstrlen+1 do
	.	if ("UTF-8"'=encoding) if (rsize#2) s rsize=rsize-1
	.	do open^io(file(4),"APPEND:VARIABLE:NOWRAP:RECORDSIZE="_rsize,encoding)
	.	do use^io(file(4),"NOWRAP")
	.	do wrtFixedNOEOL(rsize,rsize,0)
	.	close file(4)
	write !
	write !,"## Now read ##",!
	set verbose=0
	do open^io(file(4),"READONLY:VARIABLE:NOWRAP",encoding)
	do use^io(file(4),"NOWRAP")
	do readVar
	close file(4)
	use $P for i=1:1:readtotstr write $ZWIDTH(strr(i)),":",$LENGTH(strr(i)),":",$ZLENGTH(strr(i)),?12,strr(i),!
	write !
	;
	quit
init
	set totstr=3
	set str(1)="１２３４５６７８９０"
	set str(2)="В чащах юга"
	set str(3)="나는 유리를 먹을 수 있어요"
	set maxstrlen=-1,maxwid=-1
	set minstrlen=99999999,minwid=99999999
	for i=1:1:totstr if maxstrlen<$zlength(str(i)) set maxstrlen=$zlength(str(i))
	for i=1:1:totstr if minstrlen>$zlength(str(i)) set minstrlen=$zlength(str(i))
	for i=1:1:totstr if maxwid<$zwidth(str(i)) set maxwid=$zwidth(str(i))
	for i=1:1:totstr if minwid>$zwidth(str(i)) set minwid=$zwidth(str(i))
	set file(1)=encoding_"_varstr1.txt"
	set file(2)=encoding_"_varstr2.txt"
	set file(3)=encoding_"_varstr3.txt"
	set file(4)=encoding_"_varstr4.txt"
	quit
	;
wrtFixedNOEOL(rsize,wsize,wrap)
	k dollarx,dollary,len,zlen
	if wsize>rsize set wsize=rsize
	set totlen=0
	set verx=0
	set very=0
	set line=0
	set err=0
	for i=1:1:totstr do  quit:err>0
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
	. . if verx'=dollarx(i) use $P zshow "*" set err=1
	. . if very'=dollary(i) use $P zshow "*" set err=2
	quit
	;
readVar
	for i=1:1 do  quit:$ZEOF
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
	set err=0
	set line=0
	set totline=0
	for i=1:1:totstr do  quit:err=1
	. write str(i),!
	. set dollarx(i)=$X
	. set dollary(i)=$Y
	. set len(i)=$length(str(i))
	. set zlen(i)=$zlength(str(i))
	. set line=(len(i)-1)\wsize
	. set totline=totline+line+1
	. set very=totline#66
	. set verx=0
	. if verx'=dollarx(i)  ;use $P zshow "*" set err=1
	. if very'=dollary(i)  ;use $P zshow "*" set err=2
	quit
	;
	;
	;
zterror
	use $PRINCIPAL
	write "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!",!
	write $ZSTATUS,!
	write "continue...",!
	write "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!",!
	zgoto mainlvl
	quit
