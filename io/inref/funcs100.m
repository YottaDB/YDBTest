; This function writes 100 numbered lines of text to the current device
funcs100
	for i=1:1:100 do
	. write i,":123456789 123456789 123456789 123456789",!
	quit
