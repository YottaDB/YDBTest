; Set up local variables
init(env)
; Control operations
	w "In the init routine",!
	s OpType("Connect")=1
	s OpType("Status")=2
	s OpType("Disconnect")=3
; Global update operations
	s OpType("Set")=10
	s OpType("Set Piece")=11
	s OpType("Kill")=13

; Global fetch operations
	s OpType("Get")=20
	s OpType("Define")=21
	s OpType("Order")=22
	s OpType("Next")=23
	s OpType("Query")=24

; Lock operations
	s OpType("Lock")=30
	s OpType("Unlock")=31
	s OpType("Unlock client")=32
	s OpType("Unlock all")=33

; Size of basic types
	s SizeOf("SI")=1
	s SizeOf("LI")=2
	s SizeOf("VI")=4

	s Error(1)="User not authorized"
	s Error(2)="No such environment"
	s Error(3)="Global reference content not valid"
	s Error(4)="Global reference too long"
	s Error(5)="Value too long"
	s Error(6)="Unrecoverable error"
	s Error(10)="Global reference format not valid"
	s Error(11)="Message format not valid"
	s Error(12)="Operation type not valid"
	s Error(13)="Service temporarily suspended"
	s Error(14)="Sequence number error"
	s Error(20)="OMI version not supported"
	s Error(21)="Agent min length > server max length"
	s Error(22)="Agent max length < server min length"
	s Error(23)="Connect request received during session"
	s Error(24)="OMI session not established"

	s GTMERR("GTM-E-GVUNDEF")=150372994
	s GTMERR("GTM-E-GVINVALID")=150372628
	s GTMERR("GTM-E-NOTGBL")=150372604
	s GTMERR("GTM-E-OPENCONN")=150376394
	s GTMERR("GTM-E-IOEOF")=150373082

	s Connect("Major Ver")=1
	s Connect("Minor Ver")=0
	s Connect("Min Value")=1
	s Connect("Max Value")=8096
	s Connect("Min Subscript")=1
	s Connect("Max Subscript")=255
	s Connect("Min Reference")=1
	s Connect("Max Reference")=255
	s Connect("Min Message")=1
	s Connect("Max Message")=16384
	s Connect("Min Outstand")=1
	s Connect("Max Outstand")=5
	s Connect("8 bit")=1
	s Connect("Char Trans")=1
	s Connect("Implem ID")="GTC GT.CM client"
	s Connect("Ext Count")=0

	s Server("Environment")=env
	q

