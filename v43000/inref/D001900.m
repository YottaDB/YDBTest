D001900;
        set where="labelasalongvariablename5+2^D001900"
	set labelasalongvariablename5678901="labelasalongvariablename5"
	set offsetasalongvariablename67890="2"
        set fst456789012345="offsetasalongvariablename67890"
        set routine890123456789012345678901="D001900"

	set labelasalongvariable="labelasadifferentvariable" 
	set offsetasalongvariable="99"
        set fst456789="offsetasalongvariable"
        set routine89012345="ThisRoutinewillnotexist"

        write $TEXT(@labelasalongvariablename5678901+@fst456789012345^@routine890123456789012345678901),!
        write $TEXT(@labelasalongvariablename5678901^@routine890123456789012345678901),!
        write $TEXT(+@fst456789012345^@routine890123456789012345678901),!
        write $TEXT(@labelasalongvariablename5678901+@fst456789012345),!
        write $TEXT(@where),!
        q
labelasalongvariablename5	;
	;line1
	;line2
	;line3
