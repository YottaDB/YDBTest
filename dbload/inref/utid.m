utid	
nxid	n nxid,idin,idrf l ^cd("id",idtp) s idin=^cd("id",idtp,"in"),idrf=^("rf"),nxid=^mx("lsid",idtp)+1
nxid1	s id=nxid i $e(idrf)="@" x $e(idrf,2,999) i 1
	e  d:idrf'="" @idrf
	i $d(@$p(idin,"\")) s nxid=nxid+1 g nxid1
	d:nxid<$p(idin,"\",2)!(nxid>$p(idin,"\",3)) abort^uter
	s ^mx("lsid",idtp)=nxid l  q
ckid	i $d(id)'[0,'$d(@$p(^cd("id",idtp,"in"),"\")) s idok=1 q
	k:$d(id)'[0 id s idok=0 q
abort	s err="ID" d err h
err	g err^elerec
