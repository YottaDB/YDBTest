erec	; this routine processes the maxIII exam record
	;
	; input:
	;	rec	;buffer containing exam information
	;		\1  = record type (should be 'E')
	;		\2  = patient internal id (maxIII fcidn)
	;		\3  = patient primary id (maxIII fcmrn)
	;		\4  = exam date (mm/dd/yyyy)
	;		\5  = exam time (.e.g, 12:45pm)
	;		\6  = procedure code
	;		\7  = study #
	;		\8  = patient type code
	;		\9  = patient location code
	;		\10 = patient mobility code
	;		\11 = billing # (Nassau ER/BUS #)
	;		\12 = space filler
	;		\13 = department code
	;		\14 = room code
	;		\15 = referring physician #
	;		\16 = arrival time (.e.g., 12:45pm)
	;		\17 = clerk code
	;		\18 = exam comment 1
	;		\19 = space filler
	;		\20 = exam status
	;		\21 = space filler
	;
	;n (rec,ptid,ptido)
	;
	; Internal patient ids must match
	;
erec1	;
	s errfg=0
	;
	i $tr($p(rec,"\",2)," ")'=ptido s err="eptid" g err
	;
	; Must have valid exam date
	;
	s di=$$dx(4) i 'di s err="edate" g err
	;
	; Must have valid exam time.
	;
	s ti=$$tx(5) i ti="" s err="etime" g err
	;
	; Must have valid procedure code
	;
	s prcd=$$prcd(6) i prcd="" s err="prcd" g err
	;
	; Must have valid department code
	;
	s dpcd=$$dpcd(13) i dpcd="" s err="dpcd" g err
	;
	; Must have valid patient type, location, and mobility codes.
	;
erec2	;
	s ptcd=$$ptcd(8) ;i ptcd="" s err="ptcd" g err
	s lccd=$$lccd(9) ;i lccd="" s err="lccd" g err
	s mocd=$$mocd(10) ;i mocd="" s err="mocd" g err
	s rmcd=$$rmcd(14) ;i rmcd="" s err="rmcd" g err
	s prdr1=$$drno(15) ;i prdr1="" s err="prdr1" g err
	;
	; Procedure must belong to department.
	;
	i '$d(^cd("dp",dpcd,"pr",prcd)) s err="dppr" g err
	;
	; Procedure status.
	;
	; s3(max3) chr		st(max4) piece
	; 1	rcomp		\1
	; 2	pcomp		\2
	; 3	billed		\3
	; 4	arrived		^ar(arid,"st")\1
	; 5	departed	?
	; 6	lprnted		\6
	; 7	pnprint		\5
	;
erec3	;
	;s s3=$tr($p(rec,"\",20)," "),st=''$e(s3)_"\"_''$e(s3,2)_"\"_''$e(s3,3)_"\"_0_"\"_''$e(s3,7)_"\"_''$e(s3,6)
	;
	; Converted patients will initially have no reports on max4.
	;
	s s3=$tr($p(rec,"\",20)," "),st="0\"_''$e(s3,2)_"\"_''$e(s3,3)_"\"_0_"\"_''$e(s3,7)_"\"_''$e(s3,6)
	;
	;
	; If arrival time, must be useable.
	;
	s artmi=$$tx(16) s:artmi'="" ti=artmi
	;
	; Use ptid-study# index into ^bc to determine whether this is
	; a new procedure here.
	;
	s studyno=$tr($p(rec,"\",7)," ") i studyno'?3N s err="studyno" g err
	s nwpr='$d(^bc(ptido_"%"_studyno))
	;
	; If we've made it to here then we will either create the
	; procedure, generating a new arid and prid, or treat the input
	; record as a procedure edit.
	;
	; Since we put each procedure in a different arrival, we must
	; ensure that each arrival time for this patient is different.
	;
	f  q:'$d(^arx("lg",di,dpcd,ti,ptid))  s ti=ti+60 s:ti'<86400 ti=0,di=di+1
	;
	; Get the (probably new) arrival and procedure ids.
	;
erec4	;
	i 'nwpr s prid=$p(^bc(ptido_"%"_studyno),"p:",2),arid=$p(^pr(prid,"in"),"\",3)
	e  s idtp="arid" d nxid s arid=id
	;
	; If new, get new procedure id and make barcode entry.
	;
	i nwpr s idtp="prid" d nxid s prid=id,^bc(ptido_"%"_studyno)="p:"_prid
	;
	; If new procedure, make ^ar, ^arx entries.
	;
erec5	;
	i nwpr s ^ar(arid,"pr",prid)="",^ar(arid,"in")=(di*1E5+ti)_"\\\\"_dpcd,^arx("lg",di,dpcd,ti,ptid)=arid,^arx("rv",ptid,1E10-(di*1E5+ti),arid)=""
	i artmi="" s ^arx("ar",ptid,di,dpcd,ti,arid)=""
	i nwpr s i="0\0\0\0",$p(i,"\")=''$e(s3,4) s:'i $p(i,"\",2)=$e(s3)!$e(s3,2) s $p(i,"\",4)='i&'$p(i,"\",2),^ar(arid,"st")=i
	e  s $p(^ar(arid,"st"),"\")=''$e(s3,4)
	;
	; Other info.
	;
erec6	;
	s ^pr(prid,"st")=st
	s blno=$tr($p(rec,"\",11)," ")
	s ^pr(prid,"in")=prcd_"\"_ptid_"\"_arid_"\"_rmcd
	s ^pr(prid,"pt")="\\\"_blno_"\"_lccd_"\\"_ptcd_"\"_mocd
	;s ^pr(prid,"ss",1)=$$sp($p(rec,"\",18))
	;s ^pr(prid,"ss",2)=$$sp($p(rec,"\",19))
	;s ^pr(prid,"ss",3)=""
	;
	; Fill in the procedure "pr" node.
	;
erec7	;
	s:nwpr ^pr(prid,"pr")=$p($g(^cd("pr",prcd,"mo",$s(mocd="":"amb",mocd="norml":"amb",1:mocd))),"\")_"\"_$p($g(^cd("pr",prcd,"in")),"\",2,6)
	;
	; Put in the doctor.
	;
	s $p(^pr(prid,"dr"),"\")=prdr1
	;
	; How many procedure comments do they have?
	;
	s ^pr(prid,"cm",1)=$$sp($p(rec,"\",18))
	s ^pr(prid,"cm",2)=""	;$$sp($p(rec,"\",22))
	s ^pr(prid,"cm",3)=""	;$$sp($p(rec,"\",23))
	;
	; Record film movement
	;
	i nwpr s ar="",$p(ar,"\",2)=dpcd,$p(ar,"\",7)=di_"00000"+ti,aridn=arid d fldr^fmut01
	q

	; F U N C T I O N S ..........................

	;
	; Function sp - return de-blank-padded form of arg.
	;
sp(x)	q:x?0." " "" n i f i=$l(x):-1 q:$e(x,i)'=" "
	q $e(x,1,i)
	;
	; Function - return lower case of arg.
	;
lc(x)	q $tr(x,"ABCDEFGHIJKLMNOPQRSTUVWXYZ","abcdefghijklmnopqrstuvwxyz")
	;
	; Function - return upper case of arg.
	;
uc(x)	q $tr(x,"abcdefghijklmnopqrstuvwxyz","ABCDEFGHIJKLMNOPQRSTUVWXYZ")
	;
	; Function lcb - return de-blanked lower case form of arg.
	;
lcb(x)	q $tr(x,"ABCDEFGHIJKLMNOPQRSTUVWXYZ ","abcdefghijklmnopqrstuvwxyz")
	;
	; Function ucb - return de-blanked upper case form of arg.
	;
ucb(x)	q $tr(x,"abcdefghijklmnopqrstuvwxyz ","ABCDEFGHIJKLMNOPQRSTUVWXYZ")
	;
	; Function - return internal dr id of drhn1 arg.
	;
drno(x)	s x=$tr($p(rec,"\",x)," ") q:x="" x  q:$d(^cdix("dr","hn1",x))'[0 ^(x)
	q:x'?4N ""
	n drid
	;
	; First, get the new drid.  We already have drhn1 (x).
	;
	l ^mx("lsid","drid") s drid=^mx("lsid","drid") f  s drid=drid+1 i '$d(^cdi("dr",drid_"d")) s ^mx("lsid","drid")=drid,drid=drid_"d" l  q
	;
	; Record the fact of doctor creation.
	;
	s ^cnv("run",run,"dr",x)=drid
	;
	; Now make the doctor.
	;
	s ^cd("dr",x)="1\Conversion, Unknown "_x,^(x,"id")=drid,^cd("gdr","all",x)="",^cd("fl",x)="1\Conversion, Unknown "_x,^(x,"in")="0\\0\5\"_drid
	s ^cdi("dr",drid)=x,^(drid,"ad")="",^("hn")=x_"\",^("in")="u\\\",^("nm")="Conversion\Unknown\"_x_"\\"
	s ^cdix("dr","hn1",x)=drid,^cdix("dr","nm","conversion","unknown",drid)="",^cdix("dr","sxnm","cnvru",drid)=""
	q drid
	;
	; Function - return department code of field arg.
	; Return "ww" if you can't return anything else.
	;
dpcd(x)	s x=$$lcb($p(rec,"\",x)) i x'="" q:$d(^cd("dp",x)) x
	;q:x="dc" "ac"
	;q:x="e1" "e"
	;q:x="e2" "e"
	;q:x="e3" "e"
	q "ww"
	;
	; Function - return insurance code of field arg.
	; Null 'em if they're not defined.
	;
itcd(x)	s x=$$lcb($p(rec,"\",x)) i x'="" q:$d(^cd("it",x)) x
	q ""
	;
	; Function - return patient location code of field arg.
	; Take care of common character transposition.
	;
lccd(x)	s x=$$lcb($p(rec,"\",x)) i x'="" q:$d(^cd("lc",x)) x
	q ""
	;
	; Function - return mobility code of field arg.
	; Null 'em if not defined.
	;
mocd(x)	s x=$$lcb($p(rec,"\",x)) i x'="" q:$d(^cd("mo",x)) x
	q ""
	;
	; Function - return film location code of field arg.
	; Null 'em if not defined.
	;
flcd(x)	s x=$$lcb($p(rec,"\",x)) i x'="" q:$d(^cd("fl",x)) x
	q ""
	;
	; Function - return patient type code of field arg.
	; Null 'em out if not defined.
	;
ptcd(x)	s x=$$lcb($p(rec,"\",x)) i x'="" q:$d(^cd("pt",x)) x
	q ""
	;
	; Function - return procedure code pointed to by arg.
	; Null 'em out if not defined.
	;
prcd(x)	s x=$$lcb($p(rec,"\",x))
	i x?2A1.3N s x=$e(x,1,2)_(+$e(x,3,5))
	e  i $l(x)
	i  q:$d(^cd("pr",x)) x
	i $e(x,1,2)="sp",$p(x,"sp",2),$p(x,"sp",2)'>28 s x="cv"_$e(x,3,5) q:$d(^cd("pr",x)) x
	q ""
	;
	; Function - return room code pointed to by arg.
	; Null 'em out if not defined.
	;
rmcd(x)	s x=$$lcb($p(rec,"\",x)) i x'="" q:$d(^cd("rm",x)) x
	q ""
stno(x)	s x=$tr($p(rec,"\",7)," ") q:x?3N x  q ""
	;
	; Function dx - return internal date form of arg.
	;
	; check for "today+-" form - this input mode is probably a general
	; non-site-specific one
	;
dx(dx)	s dx=$$lcb($p(rec,"\",dx)) ;s dx=$p(dx,"/")_"/"_$p(dx,"/",3)_"/"_$p(dx,"/",2)
dx1	q:$g(dx)="" "" n y,m,d i "Tt+-"[$e(dx) s d=$s("TODAY\Today\today"[$e(dx,1,5):$e(dx,6,99),"Tt"[$e(dx):$e(dx,2,99),1:dx) g:d'=""&(d'?1"+"1N.N) dxy:d'?1"-"1N.N s di=$h+d g dxy:di'?1.5N q di
	;* ok, a little trickier, use a local variable
	n t
	;
	; replace separators " ,-/" with "/".
	;
	i dx?1.2N."/".2N."/".4N s y="/"_dx
	e  s y="" f d=1:1:$l(dx) i " ,-/"'[$e(dx,d) f m=d+1:1 i " ,-/"[$e(dx,m) s y=y_"/"_$e(dx,d,m-1),d=m q
	;
	; assume mm/dd/yy format unless there is only one number
	;
	s y=$e(y,2,$l(y))
	; a lone number is probably always a date and not site-specific
	i y?1.2N s d=y,(y,m)=""
	; the treatment of more than one number IS site-specific
	e  s m=$p(y,"/"),d=$p(y,"/",2),y=$p(y,"/",3)
	; from here on it ain't site specific, pal
	; check for bs day, month, or year numbers
	i d?1.2N,d s d=+d i m=""!(m?1.2N&+m) s:m'="" m=+m i y=""!(y?1.4N&+y) s:y'="" y=+y
	e  g dxy
	;
	; fill out partial date
	;
	i m'="",y?4N
	e  i m'="",y?2N,$h<94599 s y=$s($h<21550:18,$h<58074:19,1:21)_y
	e  s t=y_"/"_m_"/"_d s di=+$h s y=$zd(di,"YEAR/MM/DD"),m=+$p(y,"/",2),d=+$p(y,"/",3),y=$e(+y,1,4-$l($p(t,"/")))_$p(t,"/"),d=$p(t,"/",3) s:$p(t,"/",2)'="" m=$p(t,"/",2)
	;
	; got y, m, d - now calc. internal date.
	;
	g:$e("*312931303130313130313031",m*2,m*2+1)<d dxy
	s t=$s(y#100:y#4=0,1:y#400=0)
	i d=29,m=2,'t g dxy
	s y=y-1841
	g:y<0 dxy
	s di=y*365+(y\4)-(y+40\100)+(y+240\400)+$p("0,31,59,90,120,151,181,212,243,273,304,334",",",m)+d,y=y+1841
	i m>2 s di=di+t
	q di
	;
	; failure exit
	;
dxy	q ""
	;
	; Function - return $h time for external time pointed to by arg.
	;
	; check for "now+-" form - this input mode is probably a general
	; non-site-specific one
	;
	; PATCH - if the external time got truncated, add a 0.
tx(tx)	s tx=$$lcb($p(rec,"\",tx)) s:$l(tx)=3 tx=tx_0
	n s i "Nn+-"[$e(tx) s s=$s("NOW\Now\now"[$e(tx,1,3):$e(tx,4,99),"Nn"[$e(tx):$e(tx,2,99),1:tx) q:s'=""&(s'?1"+"1N.N)&(s'?1"-"1N.N) "" s ti=s*60+$p($h,",",2) q:ti'?1.5N "" q:ti>86399 "" q ti
	;
	; ok maybe nnn or nnnn or nn:nn or nn:nn:nn
	;
	n h,m i tx?3.4N s h=+$e(tx,1,$l(tx)-2),m=+$e(tx,$l(tx)-1,$l(tx)),s=0
	e  i tx?1.2N1":"2N s h=+$p(tx,":"),m=+$p(tx,":",2),s=0
	e  i tx?1.2N1":"2N1":"2N s h=+$p(tx,":"),m=+$p(tx,":",2),s=$p(tx,":",3)
	e  i tx?1.2N1":"2N1.2A s h=$p(tx,":"),m=$e($p(tx,":",2),1,2),s=$p(tx,h_":"_m,2) i "AMPMAmPmampmaMpM"[s s h=$s("AMAmamaM"[s:+h,h=12:h,1:h+12),m=+m,s=0
	e  i tx?3.4N1.2A s s=$e(tx,1,$s(tx?3N.A:3,1:4)),h=$e(s,1,$l(s)-2),m=$e(s,$l(s)-1,$l(s)),s=$p(tx,h_m,2) i "AMPMAmPmampmaMpM"[s s h=$s("AMAmamaM"[s:+h,h=12:h,1:h+12),m=+m,s=0
	i  i h<25,m<60,s<60 s ti=h*3600+(m*60)+s s:ti'<86400 h=0,ti=ti#86400
	e  q ""
	q ti
	;
	;
	;
nxid	g nxid^utid
	;
	; Error log entry.
	;
err	s errfg=1 q  ;g err^dbload
