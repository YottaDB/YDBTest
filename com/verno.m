	; GT.M Version - gtm_ver is set by sr_unix/setactive.{csh,com}
verno()
	new version,gtmverno
	set gtmverno=$select($zversion["VMS":"gtm$verno",1:"gtm_verno")
	set version=+$tr($ztrnlnm(gtmverno),"V.-ABCDEFG","")
	if version=0 set version=+$tr($piece($zversion,$char(32),2),"V.-ABCDEFG","")
	if version<1000 set version=version*100  ; development versions are considered the highest
	quit version
