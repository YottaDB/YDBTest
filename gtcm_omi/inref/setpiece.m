; Perform "Set $PIECE(..)=value"
;
;	Parameter
;	  gvn		global variable to set.
;	  val		value to assign to the global variable.
;	  start		beginning piece to return.
;	  end		last piece to return.
;	  delim		string determining the piece "boundaries"
;
;	Return value
;	  1		success
;	  0		failure
;
setpiece(gvn,val,start,end,delim)
	new data,rval
	i $E(gvn,1,1)'="^" zm GTMERR("GTM-E-NOTGBL"):gvn
	s data=$$^get(gvn)
	s $P(data,delim,start,end)=val
	s rval=$$^set(gvn,data)
	q rval


