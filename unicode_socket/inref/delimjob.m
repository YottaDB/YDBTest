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
delimu16(host,port)
	set:$data(port)=0 port=6666
	set:$data(host)=0 host="localhost"
	set s="socdev",c="conndev",attachc="conn"
	set delim="|"
	for chset="UTF-16BE","UTF-16LE" do
	. do checkdelim(chset,delim,1,0,0)
	. do checkdelim(chset,delim,0,1,0)
	. do checkdelim(chset,delim,0,0,1)
	. do checkdelim(chset,delim,1,1,0)
	. do checkdelim(chset,delim,1,0,1)
	. do checkdelim(chset,delim,1,1,1)
	if $data(fail)'=0 use 0 write "TEST-E-FAIL checkdelim",! zwrite fail
	quit
checkdelim(chset,delim,onopen,usebefore,useafter)
	open s:(listen=port_":tcp":attach="listen":chset=chset)::"socket"
	set openc="(connect="""_host_":"_port_":tcp"":chset=chset"
	set attach=":attach=attachc"
	set openc2=openc_attach_$select(onopen:":delim="""_delim_"""",1:"")_")"
	open c:@openc2::"socket"
	use s write /wait
	set key=$key,handle=$piece(key,"|",2)
	use s:detach=handle
	set zhandle=$zsocket(,"sockethandle",)		;from socketpool
	if zhandle'=handle do
	. use 0
	. write "TEST-E-mismatch chset="_chset_",onopen="_onopen_",usebefore="_usebefore_",useafter="_useafter
	. write ",zhandle =/"_zhandle_"/ handle =/"_handle_"/",!
	. set fail(chset,onopen,usebefore,useafter,"zhandleinpool")=zhandle_"|"_handle
	. use s
	set ^childready=0
	set input="input=""SOCKET:"_handle_""""
	set output="output=""SOCKET:"_handle_""""
	set jobcmd="delimchild(chset,delim,onopen,usebefore,useafter,handle):("_input_":"_output_")"
	job @jobcmd
	for i=1:1:1000 quit:^childready  hang 1
	use:usebefore c:delim=delim
	use:'usebefore c
	set cdelimb4=$zsocket("","delimiter",0,0)
	if (onopen!usebefore)&(cdelimb4'=delim) do
	. u 0
	. write "TEST-E-mismatch chset="_chset_",onopen="_onopen_",usebefore="_usebefore_",useafter="_useafter
	. write ",cdelimb4 =/"_cdelimb4_"/,delim=/"_delim_"/",!
	. set fail(chset,onopen,usebefore,useafter,"cdelimb4")=cdelimb4
	. u c
	write "beforedelim0=/",!,"/"
	use:useafter c:delim=delim
	set cdelim=$zsocket(c,"delimiter",0,0)
	if cdelim'=delim do
	. u 0
	. write "TEST-E-mismatch chset="_chset_",onopen="_onopen_",usebefore="_usebefore_",useafter="_useafter
	. write ",cdelim =/"_cdelim_"/,delim=/"_delim_"/",!
	. set fail(chset,onopen,usebefore,useafter,"cdelim")=cdelim
	. u c
	write "afterdelim0=/",!,"/\"	;only want child's delimiter on last write
	close c
	close s
	lock ^childactive
	lock -^childactive
	quit
delimchild(chset,delim,onopen,usebefore,useafter,handle)
	new priorIO,zhandle,khandle,ghandle,out,s
	lock ^childactive
	set priorIO=$IO use $p set pkey=$key
	set khandle=$piece(pkey,"|",2)
	set ghandle=$$^gethandle("0",0)
	set zhandle=$zsocket("","sockethandle",0)
	set out="delimchild"_chset_onopen_usebefore_useafter_".mjo"
	open out:new
	set s="childev"
	open s:(chset=chset)::"socket"
	use out zshow "D" zwrite ghandle,handle,pkey,priorIO,zhandle,khandle
	if (ghandle=zhandle)&(zhandle=khandle) do
	. write "TEST-S-same handles for "_onopen_usebefore_useafter_" = "_zhandle,!
	else  do
	. write "TEST-E-diff handles for "_onopen_usebefore_useafter_" khandle = "_khandle_" ghandle = "_ghandle_" zhandle = "_zhandle,!
	. set fail(chset,onopen,usebefore,useafter,"handles")=ghandle_"|"_khandle_"|"_zhandle
	use $p:detach=ghandle
	use out zshow "D"
	use s:attach=ghandle
	set ^childready="1,"_$H_"|"_chset_onopen_usebefore_useafter
	use s:socket=ghandle use s:delim="\" read sdelim
	set b4delim=$piece(sdelim,"/",2),aftdelim=$piece(sdelim,"/",4)
	use out
	if ((onopen=1)!(usebefore=1)),(b4delim'=delim) do
	. write "TEST-E-mismatch chset="_chset_",onopen="_onopen_",usebefore="_usebefore_",useafter="_useafter_",b4delim=/"_$zwrite(b4delim)_"/",!
	. set fail(chset,onopen,usebefore,useafter,"b4delim")=b4delim
	if aftdelim'=delim do
	. write "TEST-E-mismatch chset="_chset_",onopen="_onopen_",usebefore="_usebefore_",useafter="_useafter
	. write ",aftdelim=/"_$zwrite(aftdelim)_"/",!
	. set fail(chset,onopen,usebefore,useafter,"aftdelim")=aftdelim
	use out zshow "D" zwr
	close s
	close out
	quit
