;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available 	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;----------------------------------------------------------------------[26]----
; After setting TCP channel to TLS mode, attempt to set it to non-blocking
; mode should fail, server side

srv26 ;
	do server
	use $principal
	write "# set mode to TLS",!
	use s	write /tls("server",,"server")
	use $principal
	write "# set mode to non-blocking (should fail)",!
	set $ztrap="goto s26e"
	use s	write /block("off")
	do checkpoint("server",2,"test failed")
	quit
s26e ;
	set error=$piece($zstatus,",",3,4)
	use $principal
	write error,!
	do checkpoint("server",2,"test finished")
	quit

cli26 ;
	do client
	use s	write /tls("client",,"client")
	do checkpoint("client",2,"wait for finishing server-side test")
	quit

;----------------------------------------------------------------------[27]----
; After setting TCP channel to TLS mode, attempt to set it to non-blocking
; mode should fail, client side

srv27 ;
	do server
	use $principal
	write "# set mode to TLS",!
	use s	write /tls("server",,"server")
	do checkpoint("server",2,"wait for finishing client-side test")
	quit

cli27 ;
	do client
	use s	write /tls("client",,"client")
	use $principal
	write "# set mode to non-blocking (should fail)",!
	set $ztrap="goto s27e"
	use s	write /block("off")
	do checkpoint("server",2,"test failed")
	quit
s27e ;
	set error=$piece($zstatus,",",3,4)
	use $principal
	write error,!
	do checkpoint("client",2,"test finished")
	quit

;----------------------------------------------------------------------[28]----
; After setting TCP channel to non-blocking mode, attempt to set it to
; TLS mode should not fail, server side

srv28 ;
	do server
	use $principal
	write "# set mode to non-blocking",!
	use s	write /block("off")
	use $principal
	write "# set mode to TLS, no fail",!
	use s	write /tls("server",,"server")
	do printZshowTls
	do checkpoint("server",2,"test finished")
	quit

cli28 ;
	do client
	use s	write /tls("client",,"client")
	do printZshowTls
	do checkpoint("client",2,"wait for finishing server-side test")
	quit

;----------------------------------------------------------------------[29]----
; After setting TCP channel to non-blocking mode, attempt to set it to
; TLS mode should not fail, client side

srv29 ;
	do server
	use $principal
	write "# set mode to TLS",!
	use s	write /tls("server",,"server")
	do printZshowTls
	do checkpoint("server",2,"wait for finishing server-side test")
	quit

cli29 ;
	do client
	use $principal
	write "# set mode to non-blocking",!
	use s	write /block("off")
	use $principal
	write "# set mode to TLS, no fail",!
	do printZshowTls
	use s	write /tls("client",,"client")
	do checkpoint("client",2,"test finished")
	quit

;##############################################################################

server ;
	do setPort^gtm8843
	do procCleanupRegister^gtm8843
	use $principal
	set s="socket"
	write "# server: waiting for client",!
	open s:(LISTEN=port_":TCP":delim=$char(13))::"SOCKET"
	do checkpoint("server",1,"client connected")
	;
	use s	write /wait
	use $principal
	quit

;##############################################################################

client ;
	do setPort^gtm8843
	do procCleanupRegister^gtm8843
	set s="socket"
	use $principal
	write "# client: connecting to server",!
	open s:(CONNECT="127.0.0.1:"_port_":TCP":delim=$char(13))::"SOCKET"
	do checkpoint("client",1,"connected to server")
	quit

;##############################################################################

checkpoint(actor,id,comment) ;
	set comment=$get(comment,"")
	if comment'="" set comment=" - "_comment
	use $principal
	write "# ",actor," entered checkpoint ",id,comment,!
	lock +(^checkpoint(port))
	set ^checkpoint(port,id)=1+$get(^checkpoint(port,id),0)
	lock -(^checkpoint(port))
	for  quit:^checkpoint(port,id)=2  hang 0.1
	write "# ",actor," left checkpoint ",id,comment,!
	quit

;##############################################################################

printZshowTls ; report if TLS info found in `ZSHOW "D"` output
	new output,lineIndex,line,length,wordIndex,word
	use $principal
	zshow "d":output
	set lineIndex=""
	set found=0
	for  set lineIndex=$order(output("D",lineIndex)) quit:lineIndex=""  do
	. set line=output("D",lineIndex)
	. if line[" TLS " set found=1+found
	write "# Check that the TLS is enabled in the socket",!
	write "Number of lines with word ""TLS"" found in ZSHOW ""D"" output: ",found,!
	quit

;##############################################################################
