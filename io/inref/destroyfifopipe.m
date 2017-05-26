destroyfifopipe  ;Test the DESTROY and NODESTROY deviceparameter for fifo and pipe
        set fifoX="fifonamedpipe"
        set pipeY="unnamedpipe" 
	write "Test 1: Test if the default option is destroy",!
        open fifoX:fifo
        open pipeY:(command="ls")::"PIPE"
	use $p
	write "Before closing fifoX and pipeY: ",!
	do showdev^io(fifoX)
	do showdev^io(pipeY)
        close fifoX
        close pipeY
	write "After closing fifoX and pipeY: ",!
        do showdev^io(fifoX)
        do showdev^io(pipeY)
	write !
	write "Test 2: Test destroy parameter",!
	open fifoX:fifo
	open pipeY:(command="ls")::"PIPE"
	use $p
	write "Before closing fifoX and pipeY: ",!
	do showdev^io(fifoX)
	do showdev^io(pipeY)
	write "After closing fifoX and pipeY: ",!
	close fifoX:(DESTROY)
	close pipeY:(DESTROY)
	use $p
	do showdev^io(fifoX)
	do showdev^io(pipeY)
	write !
	write "Test 3: Test nodestroy parameter",!
   	open fifoX:fifo
   	open pipeY:(command="ls")::"PIPE"
	use $p
	write "Before closing fifoX and pipeY: ",!
	do showdev^io(fifoX)
	do showdev^io(pipeY)
	close fifoX:(NODESTROY)
	close pipeY:(DESTROY)
	write "After closing fifoX and pipeY: ",!
	do showdev^io(fifoX)
	do showdev^io(pipeY)
	open fifoX:fifo
	open pipeY:(command="ls")::"PIPE"
	close fifoX
	close pipeY
        quit

