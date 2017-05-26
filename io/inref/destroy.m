destroy  ;Test the DESTROY and NODESTROY deviceparameter
        set file="DESTROY.TXT" ; Note here file name must be of captical letter to pass vms test
	write "Test 1: Test if the default option is destroy",!
        open file:(NEWVERSION)
        use file
        write "1st test",!
	use $p
	write "Before closing file: ",!
	do showdev^io(file)
        close file
	write "After closing file: ",!
        do showdev^io(file)
	write !
	write "Test 2: Test destroy parameter",!
	open file:(APPEND)
	use file
	write "2nd test",!
	use $p
	write "Before closing file",!
	do showdev^io(file)
	write "After closing file",!
	close file:(DESTROY)
	use $p
	do showdev^io(file)
	write !
	write "Test 3: Test nodestroy parameter",!
   	open file:(APPEND)
	use file
	write "3rd time",!
	use $p
	write "Before closing file",!
	do showdev^io(file)
	close file:(NODESTROY)
	write "After closing file",!
	do showdev^io(file)	
	close file
        q

