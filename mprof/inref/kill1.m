kill1	; Test of Kill command - may be incomplete
;	File modified by Hallgarth on 16-APR-1986 08:11:21.83
;	File modified by Hallgarth on 16-APR-1986 08:00:22.32
	s x=1,y=3,z=4,r=6
	s ^bxx(1)="test",^cxxx(2)="tester",^ax(1,1,1)="^ax(1,1,2)"
	s ^ax(1,1,2)="of things",^ax(1,2,3)="blotto",tty=1,tty2=3,^ax(1,2,2)="^ax(1,2,3)"
	k:r>z @^ax(1,1,1)
	k (tty,tty2)
	zwrite
	k
	zwrite
	k ^bxx(1),^cxxx(2)
	k @^ax(1,2,2)
