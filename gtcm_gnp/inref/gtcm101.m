sec	;
	set ^adoes=1
	set ^bthis=2
	set ^cfly=3
	set ^dat=4
	set ^zall="?"
;	test some long globals here
	set ^aforapplecomputers="I never crash & i belong to global ^aforapplecomputers"
	set ^aillruntoolongtobecalledalongna=1002
	set ^aforappl="If this is not ^aforappl you have got the wrong guy"
	set ^beherestaylongtocheck="B file long name & i belong to global ^beherestaylongtocheck"
	set ^beherest="If this is not ^beherest wrong one buddy"
	set ^begintochecklongname31chartruncation="Hi iam too long for even 31 char"
	set ^begintochecklongname31chartrunc="Iam rightly truncated here"
	set ^cmecorrecthere=670
	set ^Cmecorrectthere="New Value me"
	set ^cmecorrecthereagainonemoretime=567
	set ^Dothingsrightthefirsttime="Hi this is correct and i belong to ^Dothingsrightthefirsttime"
	set ^Dothings="If this is not ^Dothings this is wrong"
	set ^DingomeDingo=980
	set ^zeezeetelevision=707
	set ^zeezeete=999
	set ^zeelongmelongmelongme="Hi iam mumps"
;	adding sub-scripts to globals
	set ^BGLOBALFORREGB(1)="^BGLOBALFORREGB(1)"
	set ^BGLOBALFORREGIONB(1)="^BGLOBALFORREGIONB(1)"
	set ^BGLOBALFORREGIONB("some subsc")="^BGLOBALFORREGIONB(str)"
	set ^CGLOBALFORREGC(1)="^CGLOBALFORREGC(1)"
	set ^CGLOBALFORREGIONC(1)="^DGLOBALFORREGIONC(1)"
	set ^BGLOBALFORREGIONC("some subsc")="^BGLOBALFORREGIONC(str)"
	set ^DGLOBALFORREGD(1)="^DGLOBALFORREGD(1)"
	set ^DGLOBALFORREGIOND(1)="^DGLOBALFORREGIOND(1)"
	set ^BGLOBALFORREGIOND("some subsc")="^BGLOBALFORREGIOND(str)"
	set ^ZGLOBALFORREGDEFAULT(1)="^ZGLOBALFORREGDEFAULT(1)"
	set ^ZGLOBALFORREGIONDEFAULT(1)="^ZGLOBALFORREGIONDEFAULT(1)"
	set ^ZGLOBALFORREGIONDEFAULT("some subsc")="^ZGLOBALFORREGIONDEFAULT(str)"
;
	zwrite ^adoes
	zwrite ^bthis
	zwrite ^cfly
	zwrite ^dat
	zwrite ^zall
;	zwrite those long globals as well
	zwrite ^aforapplecomputers
	zwrite ^aillruntoolongtobecalledalongna
	zwrite ^aforappl
	zwrite ^beherestaylongtocheck
	zwrite ^beherest
	zwrite ^begintochecklongname31chartruncation
	zwrite ^begintochecklongname31chartrunc
	zwrite ^cmecorrecthere
	zwrite ^Cmecorrectthere
	zwrite ^cmecorrecthereagainonemoretime
	zwrite ^Dothingsrightthefirsttime
	zwrite ^Dothings
	zwrite ^DingomeDingo
	zwrite ^zeezeetelevision
	zwrite ^zeezeete
	zwrite ^zeelongmelongmelongme
	zwrite ^BGLOBALFORREGB(1)
	zwrite ^BGLOBALFORREGIONB(1)
	zwrite ^BGLOBALFORREGIONB("some subsc")
	zwrite ^CGLOBALFORREGC(1)
	zwrite ^CGLOBALFORREGIONC(1)
	zwrite ^BGLOBALFORREGIONC("some subsc")
	zwrite ^DGLOBALFORREGD(1)
	zwrite ^DGLOBALFORREGIOND(1)
	zwrite ^BGLOBALFORREGIOND("some subsc")
	zwrite ^ZGLOBALFORREGDEFAULT(1)
	zwrite ^ZGLOBALFORREGIONDEFAULT(1)
	zwrite ^ZGLOBALFORREGIONDEFAULT("some subsc")
	q
