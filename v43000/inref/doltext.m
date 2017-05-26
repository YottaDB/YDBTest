doltext ;
 For i=1:1 Set x=$Text(+i) Quit:x=""  Do
 . Write !,$Justify(i,2),": ",$Justify($Length(x),2),": "
 . For p=1:1:$Length(x) Do
 . . Set a=$ASCII(x,p)
 . . If a=9 Write "<tab>" Quit
 . . If a<32 Write "<",a,">" Quit
 . . Write $Char(a)
 . . Quit
 . Quit
 ;
 ; This routine contains a number of lines
 ; that have special considerations when presented
 ; through $TEXT.
 w !
 ; The next line starts with three spaces:
   w "Three spaces",!
 ; The next line starts with space - tab - space
 	 w "Space Tab Space",!
 ; The next line starts with tab - space - tab
	 	w "Tab space Tab",!
 ; The next line starts with ine space,
 ; and contains a tab later in the line
 W "Here is a tab",! ;	and a tab
 ; The next line is only a "line-start"
 
 ; The next line is completely empty

 ; According to the ANSI standard, this would mean
 ; that this line is not part of the program anymore.
 ; An extension to the standard in GT.M allows empty
 ; lines in source files, so these lines are still
 ; part of the program.
 ; The value of $TEXT for the empty line, however,
 ; does conform to the ANSI standard, i.e., the line
 ; shows up as if it contains one space character.
 q
