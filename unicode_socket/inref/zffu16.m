;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
zffu16(host,port)	; check proper conversion of ZFF= for UTF-16*
	set port=$get(port,6666),host=$get(host,"localhost")
	set s="socdev",c="conndev",attachc="conn",delim=$c(10,13)
	for chset="M","UTF-8","UTF-16","UTF-16BE","UTF-16LE" do
	. do checkzff(chset,"zff",1,0,0)
	. do checkzff(chset,"zff",1,1,0)
	. do checkzff(chset,"zff",1,0,1)
	. do checkzff(chset,"zff",1,1,1)
	. do checkzff(chset,"zff",0,1,0)
	. do checkzff(chset,"zff",0,0,1)
	. do checkzff(chset,"zff",0,1,1)
	if $data(fail)'=0 do
	. write "TEST-E-zffu16 had at least one failure",!
	. zwrite fail
	else  write "zffu16 PASSed",!
	quit
checkzff(chset,zff,onopen,usebefore,useafter)
	open s:(listen=port_":tcp":attach="listen":chset=chset:delim=delim)::"socket"
	set openc="(connect="""_host_":"_port_":tcp"":chset=chset:delim=delim"
	set attach=":attach=attachc"
	set openc2=openc_attach_$select(onopen:":zff="""_zff_"""",1:"")_")"
	open c:@openc2::"socket"
	use s write /wait
	set key=$key,handle=$piece(key,"|",2)
	use:usebefore c:zff=zff
	use:'usebefore c
	set czffb4=$zsocket("","zff",0)
	if (onopen!usebefore)&(czffb4'=zff) do
	. use 0
	. write "TEST-E-mismatch chset="_chset_",onopen="_onopen_",usebefore="_usebefore_",useafter="_useafter
	. write ",$zsocket czffb4=/"_czffb4_"/,zff=/"_zff_"/",!
	. set fail(chset,onopen,usebefore,useafter,"czffb4")=czffb4
	. use c
	write "beforeff=/",#,"/"
	use:useafter c:zff=zff
	set czff=$zsocket("","zff",0)
	if czff'=zff do
	. use 0
	. write "TEST-E-mismatch chset="_chset_",onopen="_onopen_",usebefore="_usebefore_",useafter="_useafter
	. write ",$zsocket czff=/"_czff_"/,zff=/"_zff_"/",!
	. set fail(chset,onopen,usebefore,useafter,"czff")=czff
	. use c
	write "afterff=/",#,"/",!
	use s:socket=handle read szff
	set b4zff=$piece(szff,"/",2),aftzff=$piece(szff,"/",4)
	use 0
	if ((onopen=1)!(usebefore=1)),(b4zff'=zff) do
	. write "TEST-E-mismatch chset="_chset_",onopen="_onopen_",usebefore="_usebefore_",useafter="_useafter
	. write ",b4zff=/"_$zwrite(b4zff)_"/",!
	. set fail(chset,onopen,usebefore,useafter,"b4zff")=b4zff
	if aftzff'=zff do
	. write "TEST-E-mismatch chset="_chset_",onopen="_onopen_",usebefore="_usebefore_",useafter="_useafter
	. write ",afterff=/"_$zwrite(aftzff)_"/",!
	. set fail(chset,onopen,usebefore,useafter,"aftzff")=aftzff
	close c
	close s
	quit
