zascii ;
		; Identify the $ZCHSET value and set corresponding local vars to proceed appropriately
		; since the steps and the M-arrays used from unicodesampledata.m will vary based on that
		if ("UTF-8"=$ZCHSET) set arr="^ucp"
		else  set arr="^utf8"
		write !,"Testing ZASCII,ASCII for the entire unicode sample data range",!
		for cnti=1:1:^cntstr do
		. for xi=1:1:^ucplen(cnti) do
		. . do ^examine($ASCII(^str(cnti),xi),$PIECE(@arr@(cnti),",",xi),"ASCII test failed for "_^str(cnti)_" which is "_^comments(cnti))
		. for xi=1:1:^utf8len(cnti) do
		. . do ^examine($ZASCII(^str(cnti),xi),$PIECE(^utf8(cnti),",",xi),"ZASCII test failed for in "_^str(cnti)_" which is "_^comments(cnti))
basic ;
		; this is just the replica from ascii.m with all $ASCII calls replaced by $ZASCII, it should work
		write !,"Testing ZASCII basic",!
		set x=""
		for i=1:1:255 set x=x_$ZCHAR(i)
		for i=1:1:255 if $ZASCII(x,i)'=(i) w "ERROR 1 i = ",i,!
		for i=1:1:255 if $ZASCII(x,i_"BUG")'=(i) w "ERROR 2 i = ",i,!
		for i=1:1:255 if $ZASCII(x,i+.9)'=(i) w "ERROR 3 i = ",i,!
		for i=1:1:255 if $ZASCII(x,i)'=$ZASCII($ZEXTRACT(x,i)) w "ERROR 4 i = ",i,!
		set x="" for i=1:10:255 if $ZASCII(x,i)'=-1 w "ERROR 5 i = ",i,!
		if $ZASCII("")'=-1 w "ERROR $ZASCII("""""""")'=-1",!
indirection;
		write !,"Testing ZASCII for indirection",!
		if ("UTF-8"=$ZCHSET) do
		. set var="unicode"
		. set str="unicode"
		. set i=1,j=1
		. set unicode(1)="▛▜▶◀◮◘"
		. set unicode="▛▜▶◀◮◘"
		. set val=""
		. for i=1:1:$ZLENGTH(@var) set val=val_$ZASCII(@var,i)_","
		. if val'="226,150,155,226,150,156,226,150,182,226,151,128,226,151,174,226,151,152," write "ERROR 1 UNICODE string = ",unicode,!
		. if $ZASCII($PIECE(@str@(j),"◀",1),1)'=226 write "ERROR 2 UNICODE string = ",unicode,!
		. if $ZASCII($PIECE(@str@(j),"◀",2),2)'=151 write "ERROR 3 UNICODE string = ",unicode,!
		quit
