concat(string1,string2)
	use 0
	write !,"M1(concat.m) in C->M->C->M",!
	write "In M1:concat of ",string1," and ",string2," is : ",string1_string2,!
	write "In M1:length of ",string1," : ",$length(string1),!
	write "In M1:length of ",string2," : ",$length(string2),!
	write "In M1:lenght of concatenated string ",string1_string2," : ",$length(string1_string2),!
	write "In M1:Now <Set length=$&lengthc(string1)> will do external call to C2",!
	set length=$&lengthc(string1,string2)
	use 0
	write !,"In M1:External call routine from M1 returned the length of ",string1," as ",length,!
	write "In M1:Length of ",string1," as reported by $LENGTH is : ",$length(string1),!
	quit 
