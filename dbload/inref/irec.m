irec	; Process a patient's demographic record.
	;
	; input:
	;	rec	;buffer containing info information
	;		\1  = record type (should be 'I')
	;		\2  = patient internal id (maxIII fcidn)
	;		\3  = patient primary id (maxIII fcmrn)
	;		\4  = patient name (last, first mi)
	;		\5  = patient sex (M, F, or U)
	;		\6  = patient date of birth (mm/dd/yyyy)
	;		\7  = patient social security #
	;		\8  = patient age
	;		\9  = space filler
	;		\10 = patient street address
	;		\11 = patient apt #, etc.
	;		\12 = patient city
	;		\13 = patient state
	;		\14 = patient zip code
	;		\15 = patient phone #
	;		\16 = patient type code
	;		\17 = patient mobility code
	;		\18 = patient location code
	;		\19 = department code
	;		\20 = referring physician #
	;		\21 = billing # (Nassau ER/BUS #)
	;		\22 = date of last visit (mm/dd/yyyy)
	;		\23 = space filler
	;		\24 = patient comment 1
	;		\25 = patient comment 2
	;		\26 = patient comment 3
	;		\27 = employer's name
	;		\28 = space filler
	;		\29 = employer's address
	;		\30 = guarantor
	;		\31 = primary insurance carrier
	;		\32 = secondary insurance carrier
	;		\33 = primary insurance #
	;		\34 = space filler
	;		\35 = secondary insurance #
	;		\36 = space filler
	;
	; The form of the internal patient id on max3 systems is 9N and/or 6N.
	; The patient hospital number is often the same.
	; Since it has been the practice to start new patients on max4
	; systems with internal id 10000000 we can simply allow the internal
	; id on max4 to be identical to that on max3 for these "old" patients.
	; Then we can use this characteristic to distinguish them.
	;
	; We leave the patient's hospital number the same.
	;
	; If the patient is already on the system (max4) then we assume the
	; data to follow is, in effect, an edit.
	; 
	; For convenience, get things in standard max4 variable names.
	;
	; First, the patient ids and new patient indicator
	;
	;n (rec,ptid,ptido,nwpt)
	;
	s ptido=$tr($p(rec,"\",2)," "),ptid=$$ptid(ptido)
	s pthn1=$tr($p(rec,"\",3)," ")
	s nwpt='$d(^pt(ptid)) s:pthn1="" pthn1=$e(ptid,1,$l(ptid)-1)
	;
	; The patient's hospital id cross reference.
	; Create master jacket ^bc entry if new patient.
	;
	i nwpt s ^bc(ptido_"%000")="000%i:"_ptid
	e  i $p($g(^pt(ptid,"hn")),"\")'=pthn1 k:$p($g(^("hn")),"\")'="" ^ptx("hn1",$p(^pt(ptid,"hn"),"\"))
	i  s ^ptx("hn1",pthn1)=ptid,$p(^pt(ptid,"hn"),"\")=pthn1
	s pthn2=$$sp($p(rec,"\",7)),pthn2=$tr(pthn2,"-")
	i pthn2'="",pthn2'?9N s pthn2=""
	i pthn2'="" s pthn2=$e(pthn2,1,3)_"-"_$e(pthn2,4,5)_"-"_$e(pthn2,6,9),^ptx("hn2",pthn2,ptid)="",$p(^pt(ptid,"hn"),"\",2)=pthn2
	;
	; Patient conversion date if a new patient.
	;
	s:nwpt ^pt(ptid,"cnv")=$h
	;
	; Patient level date of last visit
	;
	s ^pt(ptid,"cnv","lv")=$$dx(22)
	;
	; Patient level department code
	;
	s ^pt(ptid,"cnv","dp")=$$dpcd(19)
	;
	; Patient name
	;
	s s=$$sp($p(rec,"\",4)),l=$l(s)
	f i=1:1:l q:$e(s,i)?1AN
	f j=i+1:1 q:$e(s,j)'?1AN
	s ptnmls=$e(s,i,j-1)
	f i=j+1:1:l q:$e(s,i)?1AN
	f j=i+1:1 q:$e(s,j)'?1AN
	s ptnmfr=$e(s,i,j-1)
	f i=j+1:1:l q:$e(s,i)?1AN
	f j=i+1:1 q:$e(s,j)'?1AN
	s ptnmmd=$e(s,i,j-1),ptnmsf=$e(s,j+1,99)
	;
	; Maintain the patient's name xrf.
	;
	s nm=ptnmls_"\"_ptnmfr_"\"_ptnmmd_"\"_ptnmsf
	i nwpt
	e  i $p($g(^pt(ptid,"nm")),"\",1,2)'=$p(nm,"\",1,2) s j=^pt(ptid,"nm"),i=$$stnm($p(j,"\")),j=$$stnm($p(j,"\",2)) k ^ptx("nm",i,j,ptid),^ptx("sxnm",$$sdnm(i,j),ptid) i 1
	i  s ^ptx("nm",$$stnm(ptnmls),$$stnm(ptnmfr),ptid)="",^ptx("sxnm",$$sdnm(ptnmls,ptnmfr),ptid)="",^pt(ptid,"nm")=nm
	;
	; Patient sex
	;
	s ptsx=$e($tr($p(rec,"\",5)," ")),ptsx=$s(ptsx="":"u","Ff"[ptsx:"f","Mm"[ptsx:"m",1:"u")
	;
	; Patient dob
	; Patient age on associated date.
	;
	s i=$tr($p(rec,"\",6)," ") i $p(i,"/",3)?2N,$p(i,"/",3)>87 s $p(i,"/",3)="18"_$p(i,"/",3),$p(rec,"\",6)=i
	s ptagdt=$$dx(6)
	i ptagdt s ptagon=0 s:ptagdt>$h ptagdt=+$h
	e  s ptagon=+$tr($p(rec,"\",8)," "),ptagdt=^pt(ptid,"cnv","lv") s:'ptagdt ptagdt=+$h
	;
	s ^pt(ptid,"in")=ptsx_"\"_ptagon_"\"_ptagdt
	;
	; Patient's mailing address
	;
	s state=$$ucb($p(rec,"\",13))
	i state'="",$d(^cd("st",state))'[0 s state=""
	s ^pt(ptid,"ad")=$$sp($p(rec,"\",10))_"\"_$$sp($p(rec,"\",11))_"\\"_$$sp($p(rec,"\",12))_"\"_state_"\"_$$sp($p(rec,"\",14))_"\\"_$$sp($p(rec,"\",15))_"\"
	;
	; Store the patient level "pr" node,  consisting of:
	; \1	rec\31	patient insurance type code (Nassau primary carrier)
	; \2	rec\33	patient insurance # (Nassau primary insurance #)
	; \4	rec\21	patient billing no. (Nassau ER/BUS #)
	; \5	rec\18	patient location code
	; \7	rec\16	patient type code
	; \8	rec\17	patient mobility code
	;
	s ^pt(ptid,"pr")=$$itcd(31)_"\"_$$sp($p(rec,"\",33))_"\\"_$$sp($p(rec,"\",21))_"\"_$$lccd(18)_"\\"_$$ptcd(16)_"\"_$$mocd(17)
	;
	; Patient level referring physician number
	;
	s ^pt(ptid,"dr")=$$drno(20)_"\\\"
	;
	; Patient comments.
	;
	s ^pt(ptid,"cm",1)=$$sp($p(rec,"\",24))
	s ^pt(ptid,"cm",2)=$$sp($p(rec,"\",25))
	;
	; Patient employer name
	;
	s ^pt(ptid,"emnm")=$$sp($p(rec,"\",27))
	;
	; Patient site specific items
	;
	s ^pt(ptid,"ss",1)=$$itcd(32)		;secondary insurance carrier
	s ^pt(ptid,"ss",2)=$$sp($p(rec,"\",35))	;secondary insurance #
	;
	; Patient employer address
	;
	s ^pt(ptid,"emad")=$$sp($p(rec,"\",29))
	;
	; Patient guarantor
	;
	s ^pt(ptid,"blnm")=$$sp($p(rec,"\",30))	;guarantor
	s:'$d(^pt(ptid,"blad")) ^("blad")=""
	;
	s ^pt(ptid,"lstkid")=""
	;
	q
	;**********************************************************************
	;
	; Function - return davidson soundex for 2 parameters.
	;	
sdnm(a,b) n i,c,l s a=$$lc(a),l=$s(a="":".",1:$e(a)) f i=2:1:$l(a) s c=$e(a,i) i c?1l,"aeiouhwy"'[c,c'=$e(l,$l(l)) s l=l_c q:$l(l)>3
	s b=b_"." f i=1:1:$l(b) s c=$e(b,i) q:c?1A
	q $e(l_"....",1,4)_$$lc(c)
	;
	; Function - return standardized name of arg.
	;
stnm(s)	n i,j,o s o="" f i=1:1:$l(s) s:$e(s,i)?1AN o=o_$e(s,i)
	q:o="" " "  q $$lc(o)
	;
sp(x)	q $$sp^erec(x)
lc(x)	q $$lc^erec(x)
uc(x)	q $$uc^erec(x)
ucb(x)	q $$ucb^erec(x)
dx(x)	q $$dx^erec(x)
drno(x)	q $$drno^erec(x)
dpcd(x)	q $$dpcd^erec(x)
mocd(x)	q $$mocd^erec(x)
ptcd(x)	q $$ptcd^erec(x)
prcd(x)	q $$prcd^erec(x)
itcd(x)	q $$itcd^erec(x)
lccd(x)	q $$lccd^erec(x)
ptid(x)	s x="00000000"_$tr(x," ") q $e(x,$l(x)-7,999)_"p"
err	g err^dbload
