; This script is used by GTM6813 subtest to extract a specific part of an error message. 
error(str)
	quit $piece(str,",",3,100)
