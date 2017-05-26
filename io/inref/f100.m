; This function writes 100 numbered lines of text to the current device
f100
	for i=1:1:100 do
	. write i,":abcdefghijklmnopqrstuvwxyz abcdefghijklmnopqrstuvwxyz",!
	quit
