basicUnicodeIO;
	SET $ZTRAP="GOTO errorAndCont^errorAndCont"
	do init
	do createIOTestFiles
	do duplicate
	do differentEncodingDiff
	zsystem ("rm -rf ./save; mkdir ./save; cp *.txt ./save")
	do convertEncoding
	quit
	;
	; This is to initialize file names, encoding, range of code points
init;
	write "init",!
	set fileinfo(1)="ascii.txt|M|0|127"
	set fileinfo(2)="extended_ascii.txt|M|128|255"
	set fileinfo(3)="utf8_1B_char.txt|UTF-8|0|127"
	set fileinfo(4)="àáâãäåæçèéêëìíîï.txt|UTF-8|128|2047"
	set fileinfo(5)="ḀḁḂḃḄḅḆḇḈḉḊḋḌḍḎḏ.txt|UTF-8|2048|65500"
	set fileinfo(6)=$CHAR($$FUNC^%HD("10496"))_$CHAR($$FUNC^%HD("10497"))_$CHAR($$FUNC^%HD("10498"))_".txt"
	set fileinfo(6)=fileinfo(6)_"|UTF-8|65536|1114111"
	set fileinfo(7)="utf8.txt|UTF-8|0|1114111"
	set fileinfo(8)="utf16.txt|UTF-16|0|1114111"
	set fileinfo(9)="utf16_BE.txt|UTF-16BE|0|1114111"
	set fileinfo(10)="utf16_LE.txt|UTF-16LE|0|1114111"
	set maxfile=$order(fileinfo(""),-1)
	quit
	; 
	; This creates files as the array of file suggests.
createIOTestFiles;
	write "createIOTestFiles",!
	for fno=1:1:maxfile do
	. set unistr(fno)=$$createStr(fileinfo(fno))
	;fileinfo(1) and fileinfo(3) has same data
	set unistr(1)=unistr(3)
	;fileinfo(7), fileinfo(8), fileinfo(9) and fileinfo(10) contains same data but different encoding.
	set unistr(8)=unistr(7)
	set unistr(9)=unistr(7)
	set unistr(10)=unistr(7)
	for fno=1:1:maxfile do
	. set zlengths(fno)=$$createFile1Line(fileinfo(fno),unistr(fno))
	quit
	;
	; This creates file from the filedesc and unistr
	; filedesc has file name and encoding
	; unistr contains data
createFile1Line(filedesc,unistr)
	new filename,encoding
	set filename=$piece(filedesc,"|",1)
	set encoding=$piece(filedesc,"|",2)
	open filename:(newversion:ochset=encoding)
	use filename
	write unistr
	close filename
	quit $zlength(unistr)
	; 
	; This creates unicode string as code point range
createStr(filedesc)
	new cpfrom,cpto,cnt
	set cpfrom=+$piece(filedesc,"|",3)
	set cpto=+$piece(filedesc,"|",4)
	set range=cpto-cpfrom
	set unistr=""
	view "NOBADCHAR"
	for cnt=1:1:1000 do
	. set tchar=$char(cpfrom+$random(1+range))
	. set unistr=unistr_tchar
	view "BADCHAR"
	; Line terminators (CP = 10, 12, 13, 133, 8232, 8233) will be removed.
	set unistr=$tr(unistr,$CHAR(10,12,13,133,8232,8233),"......")
	if cpto>65536 set unistr=unistr_$C(65538,65539,65536+$random(100))
	quit unistr
	;
	; This just creates new copies and diff old and new files
duplicate;
	write "duplicate",!
	for fno=1:1:maxfile do
	. do copyFile(fileinfo(fno),fno)
	quit
	;
	; This just creates new copy. New name is "duplicate"_oldname
	; Then it compares if the copy is same using unix diff command
copyFile(filedesc,fno)
	new filename,encoding,newfilename,zlen
	set filename=$piece(filedesc,"|",1)
	set encoding=$piece(filedesc,"|",2)
	set zlen=0
	set newfilename="duplicate"_filename
	write "copyFile(",filename,",",newfilename,")",!
	open newfilename:(newversion:ochset=encoding:stream:nowrap)
	open filename:(readonly:ichset=encoding)
	use filename
	for  quit:$ZEOF  do
	. read x
	. set zlen=zlen+$zlength(x)
	. use newfilename
	. write x
	. use filename
	close filename
	close newfilename
	do ^examine(zlen,zlengths(fno),"zlength("_filename_")")
	do fileDiff(filename,newfilename)
	quit
	;
	; This does file diff
fileDiff(file1,file2)
	set cmpstring="cmps "_file1_" "_file2
	if $$^cmps(file1,file2) do
	. use $p write cmpstring," FAIL",!
	else  do
	. use $p write cmpstring," PASS",!
	quit
	; 
	; 
	; This verifies if files are encoded as expected.
	; fileinfo(1) and fileinfo(3) must be exactly same
	; fileinfo(7), fileinfo(8), fileinfo(9) and fileinfo(10) are different copies but same data.
	; Because of encodings fileinfo(7) must be different than others.
differentEncodingDiff
	write "differentEncodingDiff",!
	do testFileDiff(1,3,0)
	do testFileDiff(7,8,1)
	do testFileDiff(7,9,1)
	do testFileDiff(7,10,1)
	quit
testFileDiff(fno1,fno2,status)
	set file1=$piece(fileinfo(fno1),"|",1)
	set file2=$piece(fileinfo(fno2),"|",1)
	set cmpstring=" from cmps "_file1_" "_file2
	set ret=$$^cmps(file1,file2)
	if status'=0 set ret='ret	; reverse status
	if ret do
	. write "fail"_cmpstring,!
	else  do
	. write "pass"_cmpstring,!
	quit
	;
	; Append every file to every other files
	; So at the end they should be same
convertEncoding
	write "convertEncoding",!
	do appendFiles(fileinfo(7),fileinfo(8))
	do appendFiles(fileinfo(7),fileinfo(9))
	do appendFiles(fileinfo(7),fileinfo(10))
	set fileinfo("dup7")="duplicate"_fileinfo(7)
	;
	do appendFiles(fileinfo(8),fileinfo("dup7"))
	do appendFiles(fileinfo(8),fileinfo(9))
	do appendFiles(fileinfo(8),fileinfo(10))
	set fileinfo("dup8")="duplicate"_fileinfo(8)
	;
	do appendFiles(fileinfo(9),fileinfo("dup7"))
	do appendFiles(fileinfo(9),fileinfo("dup8"))
	do appendFiles(fileinfo(9),fileinfo(10))
	set fileinfo("dup9")="duplicate"_fileinfo(9)
	;
	do appendFiles(fileinfo(10),fileinfo("dup7"))
	do appendFiles(fileinfo(10),fileinfo("dup8"))
	do appendFiles(fileinfo(10),fileinfo("dup9"))
	set fileinfo("dup10")="duplicate"_fileinfo(10)
	;
	do testFileDiff(7,8,1)
	do testFileDiff(7,9,1)
	do testFileDiff(7,10,1)
	quit
	; 
	; Append fileinfo2 into fileinfo1.
appendFiles(fileinfo1,fileinfo2)
	new filename1,encoding1,filename2,encoding2
	set filename1=$piece(fileinfo1,"|",1)
	set encoding1=$piece(fileinfo1,"|",2)
	set filename2=$piece(fileinfo2,"|",1)
	set encoding2=$piece(fileinfo2,"|",2)
	open filename1:(append:ochset=encoding1:stream:nowrap)
	open filename2:(readonly:ichset=encoding2)
	use filename2
	for  quit:$ZEOF  do
	. read x
	. use filename1
	. write x
	. use filename2
	close filename1
	close filename2
	quit
