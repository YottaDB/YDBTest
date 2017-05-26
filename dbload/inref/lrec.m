lrec	; this routine processes the maxIII film loan record
	;
	; input:
	;	rec	;buffer containing film loan information
	;		\1  = record type (should be 'L')
	;		\2  = patient internal id (maxIII fcidn)
	;		\3  = patient primary id (maxIII fcmrn)
	;		\4  = loan sequence number
	;		\5  = film location (dr #)
	;		\6  = film loan date
	;		\7  = study #
	;		\8  = space fill
	;
	;n (ptid,ptido,rec)
	;
	; Internal patient ids must match
	;
	i $tr($p(rec,"\",2)," ")'=ptido s err="lptid" g err
	;
	; Use ptid-study# index into ^bc to get procedure id.
	;
	s studyno=$tr($p(rec,"\",7)," ") i studyno'?3N s err="studyno" g err
	;
	; Get procedure id.
	;
	s prid=$p($g(^bc(ptido_"%"_studyno)),"p:",2)
	i prid="" s err="tprid" g err
	;
	; Get film location (dr #).
	;
	s fl=$$drno(5) i fl="" s err="drfloc" g err
	s fl=$g(^cdi("dr",fl)) i fl="" s err="drcdfloc" g err
	i '$d(^cd("fl",fl)) s err="lfloc" g err
	;
	; Get transfer date.
	;
	s di=$$dx(6) i di="" s err="date" g err
	;
	; Record film movement (Max3 film loan).
	;
	; To fldr^fmut01 we must send:
	;
	;	ptid	patient internal id
	;	prid	procedure id
	;	aridn	arrival id of procedure
	;	ar\2	film location code
	;	ar\7	transfer time h10
	;	
	;	
	;s aridn=$p($g(^pr(prid,"in")),"\",3) i aridn="" s err="aridn" g err
	;s in=$g(^ar(aridn,"in")) i in="" s err="larin" g err^dbload
	;s ar="",$p(ar,"\",2)=fl,$p(ar,"\",7)=di_"00000"+43200
	;d fldr^fmut01
	s toflcd=fl d fmmvpr^fmut02
	q
	;
sp(x)	q $$sp^erec(x)
lc(x)	q $$lc^erec(x)
dx(x)	q $$dx^erec(x)
tx(x)	q $$tx^erec(x)
drno(x)	q $$drno^erec(x)
err	g err^dbload
