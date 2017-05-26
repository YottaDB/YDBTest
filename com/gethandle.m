;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2014, 2015 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; get handle for index socket in socdev
gethandle(socdev,index) ;performs a ZSHOW device to get socket handle
	quit $$getinfo(socdev,index,"]=")		; SOCKET[index]=handle
	; get descriptor for index socket in socdev
getdesc(socdev,index) ;performs a ZSHOW device to get socket descriptor
	quit $$getinfo(socdev,index,"DESC=")
getchset(socdev,index) ;performs a ZSHOW device to get CHSET (just ICHSET)
	quit $$getinfo(socdev,index,"CHSET=")		; SOCKET[index]=handle
getkeyword(socdev,index,word,line)
	set line=$get(line,0)
	quit $$getinfo(socdev,index,word_" ",line)
getinfo(socdev,index,findarg,line)
	new lindex,showtmp,thandle,tmp,tmp1,where,i
	set lindex=$get(index),line=$get(line,0),thandle=""
	set:$zversion["VMS" socdev=$$FUNC^%UCASE(socdev)
	ZSHOW "D":showtmp
	set tmp="showtmp"
	for  quit:tmp=""  set tmp=$QUERY(@tmp) quit:tmp=""  do:(@tmp["OPEN SOCKET")&(socdev=$zpiece(@tmp," ",1))
	. for  set tmp=$QUERY(@tmp) quit:(tmp="")  quit:(@tmp[("SOCKET["_lindex_"]"))!($zextract(@tmp,1,1)'=" ")
	. if tmp="" quit
	. if line>0 for i=1:1:line set tmp=$QUERY(@tmp) if tmp="" quit
	. if $zextract(@tmp,1,1)'=" " set tmp="" quit	; end of socdev
	. set tmp1=@tmp
	. Set where=$zfind(tmp1,findarg)
	. If where=0 Set tmp="" Quit
	. If $zfind(findarg,"=")=0 Do
	. . If $zfind(tmp1,"NO"_findarg) Set thandle="NO"_findarg
	. . Else  Set thandle=findarg
	. . If $zextract(thandle,$zlength(thandle))=" " Set thandle=$zextract(thandle,0,$zlength(thandle)-1)
	. Else  Do
	. . Set thandle=$zextract(tmp1,where,$zlength(tmp1))
	. . Set thandle=$zpiece(thandle," ")		; just until space
	. Set tmp="" ; exit for loop since found
	quit thandle
