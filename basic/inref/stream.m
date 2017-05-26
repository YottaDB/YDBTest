stream	; Test of stream IO.
	New
	Do begin^header($TEXT(+0))

	Set file="temp1.dat",args="(newversion:stream:nowrap)"
	Do make(file,args)
	Do ^examine($$size(file),100001,args)

	Set file="temp2.dat",args="(newversion:stream:nowrap:record=8000)"
	Do make(file,args)
	Do ^examine($$size(file),100001,args)

	Set file="temp3.dat",args="(newversion:stream:nowrap:record=16000)"
	Do make(file,args)
	Do ^examine($$size(file),100001,args)

	Set file="temp4.dat",args="(newversion:stream:nowrap:record=32000)"
	Do make(file,args)
	Do ^examine($$size(file),100001,args)

	Set file="temp5.dat",args="(newversion:stream:wrap:record=32000)"
	Do make(file,args)
	Do ^examine($$size(file),100004,args)

	Set file="temp6.dat",args="(newversion:stream)"
	Do make(file,args)
	Do ^examine($$size(file),100004,args)

	Set file="temp7.dat",args="(newversion:nowrap)"
	Do make(file,args)
	Do ^examine($$size(file),32768,args)

	Set file="temp8.dat",args="(newversion:nowrap:record=8000)"
	Do make(file,args)
	Do ^examine($$size(file),8001,args)

	Set file="temp9.dat",args="(newversion:nowrap:record=16000)"
	Do make(file,args)
	Do ^examine($$size(file),16001,args)

	Set file="temp10.dat",args="(newversion:nowrap:record=32000)"
	Do make(file,args)
	Do ^examine($$size(file),32001,args)

	Set file="temp11.dat",args="(newversion:wrap:record=32000)"
	Do make(file,args)
	Do ^examine($$size(file),100004,args)

	If errcnt=0 Write "   PASS",!

	Do end^header($TEXT(+0))
	Quit

make(file,arg)	; Write out 100,000 bytes.
	Open @("file:"_arg)  Use file
	For i=1:1:1000  Write $JUSTIFY(i,100)
	Close file
	Quit

size(file)	; Return the number of bytes in the file.
	Set scratch="scratch.dat"
	ZSYSTEM "wc -c "_file_" > "_scratch_"; $convert_to_gtm_chset "_scratch
	Open scratch  Use scratch
	Read n
	Close scratch:delete
	ZSYSTEM "\rm "_file
	Set x=""
	For i=1:1  Set c=$EXTRACT(n,i)  Quit:c'=" "
	For j=i:1  Set c=$EXTRACT(n,j)  Quit:c?1N'=1  Set x=x_c
	Quit x
