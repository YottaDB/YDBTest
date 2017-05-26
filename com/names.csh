#!/usr/local/bin/tcsh -f
# Return the input string with $ character if it is not a defined environment variable.
# It is used by create_key_file.txt to support database filenames in dollar and profile test
set inpfile = $1
foreach line ( `cat $inpfile` )
        echo echo $line | tcsh -f >&! /dev/null
        if (0 == $status) then
	        echo echo $line | tcsh -f
	else
		echo $line
        endif
end
