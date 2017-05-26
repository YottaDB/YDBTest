new	; Test of the New command
;	File modified by Hallgarth on  5-JUN-1986 15:38:01.42
;	File modified by Hallgarth on 16-APR-1986 10:42:42.44
;	File modified by Hallgarth on 16-APR-1986 10:30:25.18
	k
	s x=1,y=2,z=3,xx=2,yy=3,zz=5,ind="x",ind2="y"
	zwrite
	w "n (@ind,@ind2,xx,yy)",!
	n:1=1 (@ind,@ind2,xx,yy)
	zwrite
	w !!
	w "n x,y",!
	n x,y
	zwrite
	w !!
	w "n ",!
	n
	zwrite
