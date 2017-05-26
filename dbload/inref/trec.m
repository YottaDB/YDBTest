trec	; this routine processes the maxIII film transfer record
	;
	; input:
	;	rec	;buffer containing film transfer information
	;		\1  = record type (should be 'T')
	;		\2  = patient internal id (maxIII fcidn)
	;		\3  = patient primary id (maxIII fcmrn)
	;		\4  = study number
	;		\5  = film location code
	;		\6  = film transfer date
	;		\7  = film transfer time
	;		\8  = space filler
	;
	;
	; Internal patient ids must match
	;
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
	;
	; Get film location.
	;
	s fl=$$flcd(5) i fl="" s err="floc" g err
	;
	; Get transfer date.
	;
	s di=$$dx(6) i di="" s err="date" g err
	;
	; Get transfer time.
	;
	s ti=$$tx(7) i ti="" s err="time" g err
	;
	; Record film movement (Max3 transfer).
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
	;s in=$g(^ar(aridn,"in")) i in="" s err="tarin" g err^dbload
	;s ar="",$p(ar,"\",2)=fl,$p(ar,"\",7)=di_"00000"+ti
	;d fldr^fmut01
	;
	s toflcd=fl d fmmvpr^fmut02
	;
	q
	;
sp(x)	q $$sp^erec(x)
lc(x)	q $$lc^erec(x)
dx(x)	q $$dx^erec(x)
tx(x)	q $$tx^erec(x)
flcd(x)	q $$flcd^erec(x)
err	g err^dbload
