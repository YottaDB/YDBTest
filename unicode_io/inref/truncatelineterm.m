truncatelineterm
	set ps=$CHAR(8233) ; Paragraph seperator
	set ls=$CHAR(8232) ; Line seperator
	set nl=$CHAR(133)  ; new line 
	set cr=$CHAR(13)   ; Carraige Return
	set lf=$CHAR(10)   ; Line Feed
	set crlf=cr_lf     ; Carraige Return Line Feed
	write "Create a file with paragraph seperator line terminator",!
	do create("file_ps.txt","AAAAAAAAAA",ps)
	do type("file_ps.txt")
	write "Create a file with line seperator line terminator",!
	do create("file_ls.txt","BBBBBBBBBB",ls)
	do type("file_ls.txt")
	write "Create a file with next line line terminator",!
	do create("file_nl.txt","CCCCCCCCCC",nl)
	do type("file_nl.txt")
	write "Create a file with carraige return line terminator",!
	do create("file_cr.txt","DDDDDDDDDD",cr)
	do type("file_cr.txt")
	write "Create a file with line feed line terminator",!
	do create("file_lf.txt","EEEEEEEEEE",lf)
	do type("file_lf.txt")
	write "Create a file with CRLF line terminator",!
	do create("file_crlf.txt","FFFFFFFFFF",crlf)
	do type("file_crlf.txt")
	write "USE TRUNCATE with file_ps.txt",!
	do truncate("file_ps.txt")
	do type("file_ps.txt")
	write "USE TRUNCATE with file_ls.txt",!
	do truncate("file_ls.txt")
	do type("file_ls.txt")
	write "USE TRUNCATE with file_nl.txt",!
	do truncate("file_nl.txt")
	do type("file_nl.txt")
	write "USE TRUNCATE with file_cr.txt",!
	do truncate("file_cr.txt")
	do type("file_cr.txt")
	write "USE TRUNCATE with file_lf.txt",!
	do truncate("file_lf.txt")
	do type("file_lf.txt")
	write "USE TRUNCATE with file_crlf.txt",!
	do truncate("file_crlf.txt")
	do type("file_crlf.txt")
	halt
create(file,text,lineterm)
	open file:(newversion:OCHSET="UTF-8")
	use file
	write "Line 1",text,lineterm,"Line 2",text,lineterm,"Line 3",text,lineterm
	close file
	quit

truncate(file)
        open file:(ICHSET="UTF-8")
        use file
        read line1,line2
	use file:(TRUNCATE)
	close file
	write line1,"(",$LENGTH(line1),")",!
	write line2,"(",$LENGTH(line2),")",!
	quit

type(file)
	open file:(ICHSET="UTF-8")
	do readfile^filop(file,0)
	close file
	quit

