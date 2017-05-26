srec	; this routine processes the maxIII special interest record
	;
	; input:
	;	rec	;buffer containing film loan information
	;		\1  = record type (should be 'S')
	;		\2  = patient internal id (maxIII fcidn)
	;		\3  = patient primary id (maxIII fcmrn)
	;		\4  = study #
	;		\5  = space fill
	;		\6  = special interest # (nnnnn.nnnnn)
	;		\7  = special interest comment line 1
	;		\8  = space fill
	;		\9  = special interest comment line 2
	;		\10 = special interest comment line 3
	;		\11 = study #
	;
	;n (ptid,rec)
	;
	; Internal patient ids must match
	;
	n arid,spinum,anat,path,arin,ardt,ptnm
	i $tr($p(rec,"\",2)," ")'=ptido s err="ptid" g err
	;
	; Use ptid-study# index into ^bc to get procedure id.
	;
	s studyno=$tr($p(rec,"\",4)," ") i studyno'?3N s err="studyno" g err
	;
	; Get procedure id.
	;
	s prid=$p($g(^bc(ptido_"%"_studyno)),"p:",2)
	i prid="" s err="tprid" g err
	s prin=$g(^pr(prid,"in")),arid=$p(prin,"\",3)
	i arid="" s err="noarid" g err
	s arin=$g(^ar(arid,"in")),ardt=$e($p(arin,"\",1),1,5)
	i ardt="" s err="noardt" g err
	;
	; Get special interest #
	;
	s spinum=$tr($p(rec,"\",5),".")
	i spinum'?10N s err="spinum" g err
	s anat=$e(spinum,1,5),path=$e(spinum,6,10)
	s ptnm=$$lc($p(^pt(ptid,"nm"),"\",1))
	s ^prx("sp",anat_"\",path_"\",$e(ptnm,1,3),ardt,prid)=""
	;special interest comments
	s ^pr(prid,"sp",anat_"\"_path,"cm",1)=$$sp($p(rec,"\",6))
	s ^pr(prid,"sp",anat_"\"_path,"cm",2)=$$sp($p(rec,"\",8))
	s ^pr(prid,"sp",anat_"\"_path,"cm",3)=$$sp($p(rec,"\",9))
	q
	;
sp(x)	q $$sp^erec(x)
lc(x)	q $$lc^erec(x)
dx(x)	q $$dx^erec(x)
tx(x)	q $$tx^erec(x)
drno(x)	q $$drno^erec(x)
ptid(x)	q $$ptid^erec(x)
err	g err^dbload
