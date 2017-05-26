# increase the flush_timer field to an hour, add a record
# this changes the timers pending field of fileheader
# restore the above field back by flushing the buffer



find -reg=DEFAULT
change -fi -flu=1:0:0:0
add -bl=3 -re=2 -key="^aglobal(""acde"")" -data="abcd"
dump -fi
buffer_flush
dump -fi

-------------

change -fi -flu=1:0:0:0
add -bl=3 -re=2 -key="^aglobal(""acde"")" -data="abcd"

# now kill from outside and ipc.sh
dump -bl=3 -fi

change -fi -flu=1:0:0:0
add -bl=3 -re=2 -key="^aglobal(""acde"")" -data="abcd"
buffer_flush

# now kill from outside and ipc.sh
dump -bl=3 -fi

----------------------- should show the difference
