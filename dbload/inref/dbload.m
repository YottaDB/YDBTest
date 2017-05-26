dbload	;;DMI;10/10/1988;10:00;rrp,mjn;Max3 to Max4 db xfer via tape/tape file
	;;GST;10/29/1997;15:19;rpl;comment out (re-)definitions of $zgbldir
	;							and $zroutines
	;
	;s cmd=$s($zversion["VMS":$zcmdline,1:$p($p($zcmdline,"-r",2,99)," ",3,99))
	; S/W is changed so it excludes the workd "-run" 
	SET cmd=$zcmdline
	;
	; Tape format:
	;
	; The tape format is normally 80 char records, 10 records per block.
	; The tape can be mounted/foreign/bl=800/rec=80 and and then read
	; from mumps by doing the following open in mumps:
	;	o max$tape:(read:fixed:bl=800:rec=80)
	; and then doing normal reads.  In this case only one tape at a time
	; can be processed unless there is more than 1 tape drive.  A more
	; convenient procedure is to mount the tape /foreign/bl=800/rec=80
	; and then issue the VMS command:
	; 	copy msa0:  tapen.dat
	; and then process the tape.dat file, opening it :(read) in mumps and
	; doing normal reads.  Several tape.dat files can be processed at the
	; same time, usually increasing throughput.
	; If you have a good bit of cpu to spare during the conversion you
	; can use the foreground "copy" option to copy a tape's data to
	; a disk variable record sequential file (one you can type) with
	; the padding blanks removed and then process these files exactly
	; like the image copy files.  The depadded sequential files are
	; usually about 1/3 to 1/4 the size of the tape image files.
	;
	;----------------------------------------------------------------------
	;
	; Set up to get maxdumps.
	;
	;s $zgbldir="dbload_gbl.dat"
	;s $zroutines="$gtm_dist ."
	s $zt=$g(^mibg("zt"),"u 0 zshow ""svildb"" h")
	;b
	;
	; If we run from the terminal we can do special stuff.
	;
	g batch:$zmode="BATCH"!1
	;
option	s mm="quit,batch,restart,scan,spec,count,lastp,check,copy,ireca,esearch"
	; In case we have come back.
	c:$g(ifl)'="" ifl
	w !,"DBLOAD MENU",!
	f i=1:1:$l(mm,",") w !,$j(i,2),". ",$p(mm,",",i)
	r !!,"Option: ",i s i=$p(mm,",",i) g option:'$l(i),@i
quit	q
	;
	;----------------------------------------------------------------------
	; Open the tape.  If we are batch then we must be reading from a tape
	; image file on disk, pointed to by the logical name "dbtape".  Else
	; ask for the tape.  If "max$tape" do the mount from here.  Otherwise
	; assume that it is tape image file or sequential file both of which
	; can be opened without specifiying record or block lengths.
	;
open	i $zmode="BATCH"!1 d
	.i $l(cmd) s ifl=$p(cmd," ")
	.e  s ifl=$g(^test("dbtape"))+1,^("dbtape")=ifl,ifl="$gtm_test/big_files/dbload/tape"_ifl_".dat"
	e  r !,"Input file: ",ifl s ifl=$tr(ifl," ") g quit:ifl="" s ifl=$$lc(ifl)
	s (rbuf,rbufz,zeof,rec,recn)=""
	i ifl="max$tape" zsy "mount/foreign/block=800/rec=80 max$tape" o ifl:(read:fixed:bl=800:rec=80)
	e  o ifl:(read)
	q
	;
	;----------------------------------------------------------------------
	; Read the tape or file, setting the eof flag (zeof) and incrementing
	; the record counter recn.
	;
	; input:
	;	ifl		input file name or tape device
	;	rbuf		record buffer
	;	rbufz		eof flag
	;	recn		record counter
	; output:
	;	rbuf		
	;	rbufz
	;	zeof		set to $zeof of read if $zeof was true
	;	rec		set to record read if not zeof
	;	recn		add 1 if record read
	;
	; $IO is redirected to the principal device upon exit.
	;
read	i rbufz s:'$l(rbuf) zeof=1 s:'zeof rec=rbuf,rbuf="" u 0 q
	s rec=rbuf
read1	u ifl r rbuf i $zeof s rbufz=1 s zeof='$l(rec) s:'zeof recn=recn+1 u 0 q
	i $e(rbuf)="[" s rbuf=$e(rbuf,2,999) g:'$l(rec) read u 0 s recn=recn+1 q
	s rec=rec_rbuf g read1
	;----------------------------------------------------------------------
	; Select records and call external sp
	;
ireca	s err="" d open g option:ifl="",err:err'=""
	d skip g err:err'=""
	f  d:$p(rec,"\")="I" ireca1 q:zeof  d read q:err'=""
	w !,"Tape processed: ",ifl,!
	g option
ireca1	s i=$p(rec,"\",6)  q:$p(i,"/",3)>10  q:$p(i,"/",3)=""
	w !,i
	s $p(i,"/",3)=1900+$p(i,"/",3),$p(rec,"\",6)=i
	w ?10,i
	s ptido=$tr($p(rec,"\",2)," ")
	s ptid=$$ptid(ptido)
	q:'$d(^pt(ptid))
	s i=$$dx(6) i i s $p(^pt(ptid,"in"),"\",2,3)="0\"_i w ?22,ptid
	q
	;
spec	s err="" d open g option:ifl="",err:err'="" s:$d(^spec)[0 ^spec=0
	d skip g option:err'=""
	f  d:$p(rec,"\")="E" spec1 q:zeof  d read q:err'=""
	d skipe
	g option
spec1	s ^spec=^spec+1
	f i=6,7,9,10,13,14,15,16 s v=$tr($p(rec,"\",i)," ") s:v="" v="?" s ^spec(i,v)=$g(^spec(i,v))+1
	q
	;
	; Check record items against database.
	;
check	s err="" d open g option:ifl="",err:err'="" s:$d(^check)[0 ^check=0
	d skip g option:err'=""
	f  d:$p(rec,"\")="E" check1 q:zeof  d read q:err'=""
	d skipe
	g option
check1	s ckn=^check+1,^check=ckn,bad=0
	w !,recn,": "
	w:$$dx(4)="" ",edate"
	w:$$tx(5)="" ",etime"
	s prcd=$$prcd(6) w:prcd="" ",prcd"
	w:$$stno(7)="" ",stno"
	;w:$$ptcd(8)="" ",ptcd"
	;w:$$lccd(9)="" ",lccd"
	;w:$$mocd(10)="" ",lccd"
	s dpcd=$$dpcd(13) w:dpcd="" ",dpcd"
	i dpcd'="",prcd'="",$d(^cd("dp",dpcd,"pr",prcd))
	e  w ",prdp"
	;w:$$rmcd(14)="" ",rmcd"
	;w:$$drno(15)="" ",drno"
	q
	;
lastp	s err="" d open g option:ifl="",err:err'=""
	d skip g option:err'=""
	s ptidn=""
lastp1	i $p(rec,"\")="I" s ptidn=ptidn+1,ptido=$tr($p(rec,"\",2)," "),ptid=$$ptid(ptido) w !,recn,":",ptidn,":",ptid q:'$d(^pt($e(ptid,2,9)_"p"))
	e  i $p(rec,"\")="E" w ",",$tr($p(rec,"\",6)," ")
	e  i $p(rec,"\")="L" w " L ",$tr($p(rec,"\",5)," ")
	e  i $p(rec,"\")="S" w " S ",$tr($p(rec,"\",5)," ")
	e  i $p(rec,"\")="T" w " T ",$tr($p(rec,"\",5)," ")
	e  w !,"****************","Skipping record...","*******************",! d recdis
	g skipe:zeof d read g skipe:err'="",lastp1
	;
	; Copy the a max3 tape to the disk, deleting trailing blanks.
	;
copy	s err="" d open g option:ifl=""
	r !,"Output file: ",outf i outf="" c ifl k ifl g option
	o outf:(newv)
	d skip g option:zeof
	s firstrec=rec
	s (nirec,nerec,nlrec,nsrec,ntrec,nzrec)=""
	f  s i=$p(rec,"\") w i d count1 u outf w "[",$$sqz(rec),! d read q:zeof
	c ifl,outf zsy:ifl="max$tape" "dism max$tape"
	d logstat
	h
	;
	; Count the record types in a file.
	;
count	w !,"Count record types..."
	s err="" d open g option:ifl=""
	d skip
	s firstrec=rec
	s (nirec,nerec,nlrec,nsrec,ntrec,nzrec)=""
	f  q:zeof  s i=$p(rec,"\") w i d count1 q:zeof  d read
	d logstat
	h
	;
count1	i i="I" s nirec=nirec+1 q
	i i="E" s nerec=nerec+1 q
	i i="L" s nlrec=nlrec+1 q
	i i="S" s nsrec=nsrec+1 q
	i i="T" s ntrec=ntrec+1 q
	s nzrec=nzrec+1 q
	;
logstat	w !,"Totals: ",!,"IREC: ",nirec,!,"EREC: ",nerec,!,"LREC: ",nlrec,!,"SREC: ",nsrec,!,"TREC: ",ntrec,!,"?REC: ",nzrec,!,"First rec: ",$$sqz(firstrec),!,"Last  rec: ",$$sqz(rec)
	o "max$dir:count.log":newv u "max$dir:count.log"
	w "Stats for tape: ",ifl,"  to ",outf,!
	w !,"Totals: ",!,"IREC: ",nirec,!,"EREC: ",nerec,!,"LREC: ",nlrec,!,"SREC: ",nsrec,!,"TREC: ",ntrec,!,"?REC: ",nzrec,!,"First rec: ",$$sqz(firstrec),!,"Last  rec: ",$$sqz(rec)
	u 0 c ifl,$g(outf)
	q
	;
dppr	s err="" d open g option:ifl="",err:err'="" ;k ^dppr s ^dppr=0
	f  q:zeof  d read q:err'=""  d:$p(rec,"\")="E" dppr1
	q
dppr1	s ^dppr=^dppr+1 s pr=$tr($p(rec,"\",6)," "),dp=$tr($p(rec,"\",13)," ") i pr'="",dp'="",$d(^cd("dp",dp)) s pr=$$lc(pr) i $d(^cd("pr",pr)) s:'$d(^cd("dp",dp,"pr",$$lc(pr))) ^dppr(pr,dp)=$g(^dppr(pr,dp))+1
	q
	;
	; Dump the tape to the terminal.
	;
scan	s err="" d open g option:ifl="",err:err'=""
	d skip g err:err'=""
	f  r !,"Record type: ",rtype#1 q:"IELST"[rtype
	f  r !,"Display which field: ",field q:field=""  s field=+field q:field
	f  d:$p(rec,"\")[rtype scandis q:zeof  d read q:err'=""
	g option
	;
scandis	w !,"Rec #",recn,?11,"Type: ",$p(rec,"\")
	i field w " f",field," \" n i s i=$$sp($p(rec,"\",field)) w i,"\" ;s ^ncpr(i)=""
	e  w !,"fields" f j=2:1 q:$p(rec,"\",j,j+1)=""  w ?8,$j(j,3),": \",$$sp($p(rec,"\",j)),"\",!
	q
	;
	;----------------------------------------------------------------------
	; Start at a particular absolute file record number or first record
	; belonging to a particular patient.
	;
skip	f  r !,"Start at 1)patient, 2)absolute record: ",skip q:skip=""  i skip=+skip g skipp:skip=1,skipl:skip=2
	;
	; Get first record if no skip.
	;
	i skip="" d read,skips
	q
	;
	; Start at a particular patient.
	;
skipp	f  r !,"Internal patient id: ",ptid s:$e(ptid,$l(ptid))="p" ptid=$e(ptid,1,$l(ptid)-1) g skip:ptid="" q:ptid?1N.N
	w !,"Skipping patients...",!
	f  g skipe:zeof d read i $p(rec,"\")="I" s i=$tr($p(rec,"\",2)," ") w *13,recn,":",i,$j("",9-$l(i)) g:i=ptid skips
	;
	; Error message from skip.
	;
skipe	w ! i zeof w "End of file.  "
	w:$g(err)'=""!'$t "Tape error - """,$g(err),"""" q
	;
	; Start at a particular logical record.
	;
skipl	f  r !,"Logical record number: ",i g skip:i="" i i,i?1N.N s i=+i q:i'<recn  w "  Already at logical record ",recn
	w !,"Skipping logical records...",!
	f  g skipe:zeof d read w *13,$p(rec,"\"),":",recn g skipe:err'="" q:i=recn
	d skips
	s ptido=$tr($p(rec,"\",2)," "),ptid=$$ptid(ptido)
	q:$p(rec,"\")="I"
	q:$d(^pt(ptid))
	;
	; Here we have skipped to a non I-rec with a ptid not yet on the system.
	; Our only choice is give 'em an error message.
	;
	s err="Skip past non patient." g skipe
	;
	; Say what record we have skipped to.
	;
skips	w !,"Starting at..." d recdis w !,"...",! q
	;
	;**********************************************************************
	;
esearch	; look for erec stuff to pull out of the error logs
	r !,"For real (1/0): ",foreal
	s errfg=0
	i $zmode="INTERACTIVE" f  r !,"Run #: ",run h:run=""  q:run="all"  d:$d(^cnv("run",run)) errn
	s run=$g(^cnv("erun")) i run'="" d errn q
	f  s run=$o(^cnv("run",run)) q:run=""  d errn
	q
errn	w !,"Now on run ",run s errn="" f  s errn=$o(^cnv("run",run,"err",errn)) q:errn=""  d:^(errn,"err")'="" act
	q
act	;
	q:$p(^("rec"),"\")'="E"
	i ^("err")="dppr"
	e  i ^("err")="prcd"
	s rec=^("rec")
	e  g noel
	s ptid=^("ptid"),ptido=^("ptido")
	;q:$p($p(rec,"\",4),"/",3)<86
	s prcd=$$prcd^erec(6)
	s dpcd=$$dpcd^erec(13) s:'$l(dpcd) dpcd="dx1"
	g:prcd="" noel
	g:$d(^cd("dp",dpcd,"pr",prcd)) esearch1
	s prtp=$e(prcd,1,2)
	s dpcd=$s("ha,sp,pe,mj,sk,sh,lu,ba"[prtp:"dx1",prtp="us":"us",prtp="nm":"nm",prtp="nu":"nu",prtp="ct":"ct",prtp="cs":"ct",1:"dx1")
	g:$d(^cd("dp",dpcd,"pr",prcd)) esearch1
	s dpcd="" f  s dpcd=$o(^cd("dp",dpcd)) q:'$l(dpcd)  g:$d(^(dpcd,"pr",prcd)) esearch1
noel	w !,"Nope: ",ptid,":",dpcd,":",prcd
	q
esearch1 s $p(rec,"\",13)=dpcd
	w !,run,":",errn,":",ptid,":",dpcd,":",prcd
	q:'foreal
	d ^erec
	i errfg w " *error" q
	k ^cnv("run",run,"err",errn)
	q
	;**********************************************************************
	;
	; Start load after skipping records on tape (file).
	;
restart	s err="" d open g option:ifl=""
	f  r !,"Run number: ",run g:'$l(run) option q:run=+run
	d skip g option:err'=""
	b
	g batch1
	;f  r !,"Record type: ",rectype q:rectype=""
	;g restart
	;s (ptidl,ptidn)="" f  d write q:zeof  d read g err:err'=""
	;g restart
	;
batch	;
	; Init.
	;
	k err d err
	d open,read
	;
	; Process records (rec) until we are finished with this file.
	;
batch1	s (ptidl,ptidn,ptido)="" f  q:zeof  d write,read
	q
write	s ^cnv("run",run,"recn")=recn
	i $p(rec,"\")="I" d:$g(^cnv("run",run,"ab")) ab s ptidn=ptidn+1,ptidl=$g(ptid) w !,recn,":",ptidn,":" d ^irec w ptid," " q		;info
	i $p(rec,"\")="E" g:$g(ptid)="" batch2 w "E" d ^erec q	;exam
	i $p(rec,"\")="S" w "S" d ^srec q			;special int
	i $p(rec,"\")="L" w "L" d ^lrec q			;film loan
	i $p(rec,"\")="T" w "T" d ^trec q			;film xfer
	u 0 w !,"****************","Skipping record...","*******************",!
recdis	w !,"Logical record ",recn,".  Record type: ",$p(rec,"\"),"  ",$zd($h,"MM/DD 2460.SS"),!,"\"
	f i=2:1:$l(rec,"\") w $$sp($p(rec,"\",i)),"\"
	q
batch2	s ptido=$p(rec,"\",2),ptid=$$ptid(ptido) i $d(^pt(ptid)) s ptidn=ptidn+1,ptidl="" w !,recn,":",ptidn,":",ptid,"?E" d ^erec q
	w "-" s err="No irec",ptid="" d err q
	;
ab	q:'^cnv("run",run,"ab")  i ^cnv("run",run,"ab")=10 h 60 g ab
	u 0 w !,"*** Abort signal at record """,rec,"""" s zeof=2 x $zt h
	;
	; Log error entries.
	;
	; Structure of error log is:
	; ^cnv("run")= last run number
	;	    ,run)
	;		,"start")= run start time $h
	;		,"err")= error sequence number
	;		      ,errno,"rec")=rec
	;		             ,"ptid")=ptid (max4)
	;			     ,"ptido")=ptido (max3 ptid)
	;			     ,"err")=err
	;
err	n i i '$g(run) l ^cnv("run") s run=$g(^cnv("run"))+1,^("run")=run l
	s:$d(rec)[0 rec=""
	s errseq=$g(^cnv("run",run,"err"))+1,^("err")=errseq
	s ^cnv("run",run,"err",errseq)=$h
	s ^cnv("run",run,"err",errseq,"err")=$g(err)
	s ^cnv("run",run,"err",errseq,"recn")=$g(recn)
	s ^cnv("run",run,"err",errseq,"rec")=$$sqz(rec)
	s ^cnv("run",run,"err",errseq,"ptid")=$g(ptid)
	s ^cnv("run",run,"err",errseq,"ptido")=$g(ptido)
	s i=$io u 0 w !,"ERROR LOG ENTRY #",errseq,": """,$g(err),"""",! u i
	s err=""
	q
	;
sp(x)	q $$sp^erec(x)
lc(x)	q $$lc^erec(x)
dx(x)	q $$dx^erec(x)
tx(x)	q $$tx^erec(x)
prcd(x)	q $$prcd^erec(x)
stno(x)	q $$stno^erec(x)
ptcd(x)	q $$ptcd^erec(x)
lccd(x)	q $$lccd^erec(x)
mocd(x)	q $$mocd^erec(x)
itcd(x)	q $$itcd^erec(x)
dpcd(x)	q $$dpcd^erec(x)
rmcd(x)	q $$rmcd^erec(x)
ptid(x)	q $$ptid^irec(x)
	;
sqz(x)	n i,j,k,t,s s s=$tr(x," ") f i=1:1:$l(s,"\") i $l($p(s,"\",i)) s j=$p(x,"\",i) f k=$l(j):-1 i $e(j,k)'=" " s $p(t,"\",i)=$e(j,1,k) q
	q $g(t)
