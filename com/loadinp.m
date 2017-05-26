loadinp	;

	; -----------------------------------------------------------------------

	s ^waittestnum=1				; don't remove this line
	s ^cpucur=0			s ^iocur=0	; don't remove this line

	; -----------------------------------------------------------------------

	s ^cpumax=2			s ^iomax=2

	s ^cpumax("beowulf")=3		s ^iomax("beowulf")=3
	
	s ^cpu=1			s ^io=1
	s ^cpu("compil")=0		s ^io("compil")=0
	s ^cpu("gde")=0			s ^io("gde")=0
	s ^cpu("mpt")=0			s ^io("mpt")=0
	s ^cpu("mugj")=0		s ^io("mugj")=0
	s ^cpu("v234")=0		s ^io("v234")=0

	s ^cpu("tpresil")=2		s ^io("tpresil")=1
	s ^cpu("mupip")=2		s ^io("mupip")=2
	s ^cpu("tcpip")=0		s ^io("tcpip")=0
	
	s ^cpu("tpresil","sol")=2	s ^io("tpresil")=2
	s ^cpu("mupip","sol")=2		s ^io("mupip")=2
