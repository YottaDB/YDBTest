randfill(act,pno,iter)	;
        ; act="set"  fills data in
	; act="ver"  verifies that the data is in data base
	; act="kill" kills the data from the database
	new i
	for i=1:1:10 SET root(i)=^root(i)
	SET prime=^prime
	do filling^randfill(act,prime,root(pno),iter)
	q

filling(act,prime,root,iter)
	new ndx,obj,ERR,MAXERR,i
	SET ERR=0,MAXERR=10
	SET ndx=1
	IF act="set" DO
	.  FOR i=0:1:prime-2 D  Q:ERR>MAXERR
	.  .  SET obj=^cust(ndx,^instance)
	.  .  SET ^afill(ndx,obj,iter)=ndx
	.  .  SET ^e(ndx,obj,iter)=ndx
	.  .  SET ^cfill(ndx,obj,iter)=ndx
	.  .  SET ^dfill(ndx,obj,iter)=ndx
	.  .  SET efill(ndx)=$GET(^efill(ndx,obj,^PID(jobno,^instance),iter))
	.  .  SET efill(ndx)=efill(ndx)+prime
	.  .  SET ^efill(ndx,obj,^PID(jobno,^instance),iter)=efill(ndx)
	.  .  SET ^ffill(ndx,obj,iter)=ndx
	.  .  SET %1(ndx)=$GET(^%1(ndx,obj,^PID(jobno,^instance),iter))
	.  .  SET %1(ndx)=%1(ndx)+prime
	.  .  SET ^%1(ndx,obj,^PID(jobno,^instance),iter)=%1(ndx)
	.  .  SET b(ndx)=$GET(^b(ndx,obj,^PID(jobno,^instance),iter))
	.  .  SET b(ndx)=b(ndx)+prime
	.  .  SET ^b(ndx,obj,^PID(jobno,^instance),iter)=b(ndx)
	.  .  SET bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb(ndx)=$GET(^bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb(ndx,obj,^PID(jobno,^instance),iter))
	.  .  SET bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb(ndx)=bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb(ndx)+prime
	.  .  SET ^bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb(ndx,obj,^PID(jobno,^instance),iter)=bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb(ndx)
	.  .  SET ndx=(ndx*root)#prime
	.  .  if (i=(prime\2))&(jobno=1) do 
	.  .  .  write "Doing ZWR test with different encoding to file",!
	.  .  .  do ^zwr("^cust","cust_M.txt","M")
	.  .  .  do ^zwr("^cust","cust_utf8.txt","UTF-8")
	.  .  .  do ^zwr("^cust","cust_utf16.txt","UTF-16")
	.  .  .  do ^zwr("^cust","cust_utf16le.txt","UTF-16LE")
	.  .  .  do ^zwr("^cust","cust_utf16be.txt","UTF-16BE")
	IF act="kill" DO
	.  FOR i=0:1:prime-2 D  Q:ERR>MAXERR
	.  .  SET obj=^cust(ndx,^instance)
	.  .  KILL ^afill(ndx,obj,iter)
	.  .  KILL ^e(ndx,obj,iter)
	.  .  KILL ^cfill(ndx,obj,iter)
	.  .  KILL ^dfill(ndx,obj,iter)
	.  .  KILL ^efill(ndx,obj,^PID(jobno,^instance),iter)
	.  .  KILL ^ffill(ndx,obj,iter)
	.  .  KILL ^%1(ndx,obj,^PID(jobno,^instance),iter)
	.  .  KILL ^b(ndx,obj,^PID(jobno,^instance),iter)
	.  .  KILL ^bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb(ndx,obj,^PID(jobno,^instance),iter)
	.  .  SET ndx=(ndx*root)#prime
	IF act="ver" DO
	.  FOR i=0:1:prime-2 D  Q:ERR>MAXERR
	.  .  SET obj=^cust(ndx,^instance)
	.  .  do EXAM("^afill("_ndx_","_obj_","_iter_")",ndx,^afill(ndx,obj,iter))
	.  .  do EXAM("^e("_ndx_","_obj_","_iter_")",ndx,^e(ndx,obj,iter))
	.  .  do EXAM("^cfill("_ndx_","_obj_","_iter_")",ndx,^cfill(ndx,obj,iter))
	.  .  do EXAM("^dfill("_ndx_","_obj_","_iter_")",ndx,^dfill(ndx,obj,iter))
	.  .  do EXAM("^efill("_ndx_","_obj_","_^PID(jobno,^instance)_","_iter_")",prime,^efill(ndx,obj,^PID(jobno,^instance),iter))
	.  .  do EXAM("^ffill("_ndx_","_obj_","_iter_")",ndx,^ffill(ndx,obj,iter))
	.  .  do EXAM("^%1("_ndx_","_obj_","_^PID(jobno,^instance)_","_iter_")",prime,^%1(ndx,obj,^PID(jobno,^instance),iter))
	.  .  do EXAM("^b("_ndx_","_obj_","_^PID(jobno,^instance)_","_iter_")",prime,^b(ndx,obj,^PID(jobno,^instance),iter))
	.  .  do EXAM("^bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb("_ndx_","_obj_","_^PID(jobno,^instance)_","_iter_")",prime,^bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb(ndx,obj,^PID(jobno,^instance),iter))
	.  .  SET ndx=(ndx*root)#prime
	i ERR'=0 w act," FAIL",!
	q

EXAM(pos,vcorr,vcomp)
	i vcorr=vcomp  q
	w " ** FAIL verifying global ",pos,!
	w ?10,"CORRECT  = ",vcorr,!
	w ?10,"COMPUTED = ",vcomp,!
	SET ERR=ERR+1
	q
