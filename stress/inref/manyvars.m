manyvars(optype,opname,totname,arrsize);
	; Creates many variables to have names
	SET $ZT="g ERROR^manyvars"          
	s template="zyxwvutsrqponmlkjihgfedcbaZYXWVUTSRQPONMLKJIHGFEDCBA"
	s template="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
	set cnt=0
	set ndx=0
	kill names
	f j=1:1:arrsize  D
	.  f i=1:1:totname  DO
	.  .  s ndx=(i-1)#47+1
        .  .  s x=$e(template,ndx,ndx+25)_i  
        .  .  s y=x_"("_j_")"  
	.  .  if optype="gbl" s z="^"_y
	.  .  else  s z=y
	.  .  set ndx=ndx+1
	.  .  if $data(names(y))=0 s cnt=cnt+1,names(y)=cnt  
	.  .  if cnt#5000=0 w "cnt=",cnt,!
	.  .  if opname="set"  s @z=ndx
	.  .  if opname="kill" k @z
	.  .  if opname="ver"  if $GET(@z)'=ndx  w "Error in:",z," expected=",ndx," found=",$GET(@z),!
	w opname," PASS",!
	w "Total Names = ",cnt,!
	q
ERROR   SET $ZT=""
        ZSHOW "*"
        IF $TLEVEL TROLLBACK
        ZM +$ZS
	q
