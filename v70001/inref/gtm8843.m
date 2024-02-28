;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                               ;
; Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.       ;
; All rights reserved.                                          ;
;                                                               ;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available 	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;                                                               ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;------------------------------------------------------------------[consts]----
; Constants for testing blocking mode. Sending `longMessage` for `stuckFactor`
; times when the opposite party is not reading occurs stuck (in blocking mode),
; or can be detected (in non-blocking mode) various ways. In normal case, the
; system gets stucked after 20k messages, regardless of the value of
; `stuckFactor`.
;
; The sender sends not only `longMessage` on TCP, but `heartBeatChar` on
; stdout, which the receiver checks. If it's stops coming, it indicates that
; the sender got stuck, and the receiver can report the result.
; There are pair of tests. The same test are performed in both direction,
; first client-as-sender-and-server-as-receiver, then
; server-as-sender-client-as-receiver.
;
; When sender and receiver are piped together, sender is sending heartbeat
; on `stdout`, so only receiver will produce logs, although, if it detects
; other than heartbeat signal from sender, captures and prints it, which
; can be an error message or garbage. Piping is only needed in blocking mode,
; because the sender may got stuck, so TCP connection is not available
; furthermore. Piping is a second channel to communicate with each other.
; Non-blocking mode needs no second channel between parties, none of them
; should get stuck.

constStuck ; Constants for stucking the socket write buffer
        ;
        set stuckFactor=19555000 ; number of messages to _sure_ block socket buffers
        set reportEvery=1000 ; heartbeat rate of sent messages
        set longMessage="01234567890123456789012345678901234567890123456789"
        set heartbeatChar="."
        quit

;----------------------------------------------------------------------[01]----
; gtm8843_01 - Verify that $ZSOCKET reports CLIENT blocking mode and
;              WRITE /WAIT("WRITE") reports nothing in blocking mode
;
; Client must start a connection, only a living connection can be examined
; if it's in blocking or non-blocking mode.
;
; The server starts a listener, only because the client needs a connection.
; After started a listener, the server hangs forever.
;
; The client connects, calls $ZSOCKET() to report mode (default is blocking),
; then turns on non-blocking mode, then calls $ZSOCKET() to report the mode
; again, which should be non-blocking.

srv01 ;
        do procCleanupRegister
        do srvStart
        hang 9999
        quit

cli01 ;
        do procCleanupRegister
        do cliConnect
        do onOff("client")
        quit

;----------------------------------------------------------------------[02]----
; gtm8843_02 - Verify that $ZSOCKET reports SERVER blocking mode
;
; The server must receive a connection, only a living connection can be
; examined if it's in blocking or non-blocking mode.
;
; The server starts a listener, then got a connection from the client. As the
; client sends nothing, the server runs on timeout, but the connection is still
; alive, so it can call $ZSOCKET, turn on non-blocking mode, then report the
; results.
;
; The client is connecting to the server, which requires a connection, then
; hangs forever, sends no request.

srv02 ;
        do procCleanupRegister
        do srvStart
        do srvRecvReq()
        do onOff("server")
        quit

cli02 ;
        do procCleanupRegister
        do cliConnect
        hang 9999
        quit

;----------------------------------------------------------------------[03]----
; gtm8843_03 - Verify that blocking mode CLIENT-side WRITE may hang upon
;              overload
;
; The server and the client are piped together: `client | server`. That's why
; client calls procedures with `mute=1` parameter, the `stdout` is reserved
; for sending heartbeat.
;
; The server starts, then reads `stdin` with a tight timeout, and 5x retry,
; waiting for heartbeats. If nothing is coming from the client, it's in stuck,
; the test passes. If the client sends other than heartbeat character, the
; server collects and prints the message (or garbage) sent from the client.
;
; The client is connecting to the server, then start burst sending
; `longMessage` data `stuckFactor` times on TCP. Every `reportEvery` times it
; sends a heartbeat character on `stdout`. In normal case, the TCP send will
; stuck before the message is sent by `stuckFactor` times. As the program will
; hang on a WRITE instuction, no more heartbeat will be sent. It will be
; detected on the server side, and the test is passed. If the client can send
; the message more than `stuckFactor` times without getting stuck, the test is
; failed, error message is printed to `stdout`, which the server will receive
; and print. If the server receives more than `stuckFactor` messages, it means
; that the client is failed to stuck, the test is also failed.

srv03 ;
        do procCleanupRegister
        do srvStart
        do stuckRecv("server","client")
        quit

cli03 ;
        do procCleanupRegister
        do cliConnect("haltOnTrap",1)
        do stuckSend("client")
        quit

;----------------------------------------------------------------------[04]----
; gtm8843_04 - Verify that blocking mode SERVER-side WRITE may hang upon
;              overload
;
; The server and the client are piped together: `server | client`. That's why
; server calls procedures with `mute=1` parameter, the `stdout` is reserved
; for sending heartbeat.
;
; The server is receiving a connection from the client, then start burst
; replying, sending `longMessage` data `stuckFactor` times on TCP. Every
; `reportEvery` times it sends a heartbeat character on `stdout`. In normal
; case, the TCP send will stuck before the message is sent by `stuckFactor`
; times. As the program will hang on a WRITE instuction, no more heartbeat
; will be sent. It will be detected on the client side, and the test is passed.
; If the server can send the message more than `stuckFactor` times without
; getting stuck, the test is failed, error message is printed to `stdout`,
; which the client will receive and print.
;
; The client connects to the server, and sends a message ("flood me").
; From this point, the client reads `stdin` with a tight timeout, and 5x retry,
; waiting for heartbeats. If nothing is coming from the server, it's in stuck,
; the test passes. If the server sends other than heartbeat character, the
; client collects and prints the message (or garbage) sent from the server.
; If the client receives more than `stuckFactor` messages, it means that the
; server is failed to stuck, the test is also failed.

srv04
        do procCleanupRegister
        do constStuck
        do srvStart("haltOnTrap",1)
        do srvRecvReq(2,1)
        if timeout do
        .use $principal
        .write "server: timeout on waiting for request"
        .halt
        ;
        do stuckSend("server")
        quit

cli04 ;
        do procCleanupRegister
        do constStuck
        do cliConnect
        do cliSendReq("flood me")
        do stuckRecv("client","server")
        quit

;----------------------------------------------------------------------[05]----
; gtm8843_05 - Verify non-blocking mode CLIENT-side WRITE,
;              upon overload error variables are set

srv05 ;
        do procCleanupRegister
        do srvCliWrt(1)
        quit

cli05 ;
        do procCleanupRegister
        do cliCliWrt(1)
        quit

;----------------------------------------------------------------------[06]----
; gtm8843_06 - Verify non-blocking mode SERVER-side WRITE,
;              upon overload error variables are set

srv06 ;
        do procCleanupRegister
        do srvSrvWrt(1)
        quit

cli06 ;
        do procCleanupRegister
        do cliSrvWrt(1)
        quit

;----------------------------------------------------------------------[07]----
; gtm8843_07 - Verify non-blocking mode CLIENT-side WRITE,
;              upon overload trap happens
; See explanation at `srvCliWrt` and `cliCliWrt`

srv07 ;
        do procCleanupRegister
        do srvCliWrt(2)
        quit

cli07 ;
        do procCleanupRegister
        do cliCliWrt(2)
        quit

;----------------------------------------------------------------------[08]----
; gtm8843_08 - Verify non-blocking mode SERVER-side WRITE,
;              upon overload trap happens
; See explanation at `srvSrvWrt` and `cliSrvWrt`

srv08 ;
        do procCleanupRegister
        do srvSrvWrt(2)
        quit

cli08 ;
        do procCleanupRegister
        do cliSrvWrt(2)
        quit

;;----------------------------------------------------------------------[09]----
; gtm8843_09 - Verify non-blocking mode CLIENT-side,
;              WRITE /WAIT("WRITE") reports non-blocking write possible
; See explanation at `srvCliWrt` and `cliCliWrt`

srv09 ;
        do procCleanupRegister
        do srvCliWrt(3)
        quit

cli09 ;
        do procCleanupRegister
        do cliCliWrt(3)
        quit

;----------------------------------------------------------------------[10]----
; gtm8843_10 - Verify non-blocking mode SERVER-side,
;              WRITE /WAIT("WRITE") reports non-blocking write possible
; See explanation at `srvSrvWrt` and `cliSrvWrt`

srv10 ;
        do procCleanupRegister
        do srvSrvWrt(3)
        quit

cli10 ;
        do procCleanupRegister
        do cliSrvWrt(3)
        quit

;----------------------------------------------------------------------[11]----
; gtm8843_11 - Verify non-blocking mode CLIENT-side,
;              WRITE /WAIT("READWRITE") reports non-blocking write possible
; See explanation at `srvCliWrt` and `cliCliWrt`

srv11 ;
        do procCleanupRegister
        do srvCliWrt(4)
        quit

cli11 ;
        do procCleanupRegister
        do cliCliWrt(4)
        quit

;----------------------------------------------------------------------[12]----
; gtm8843_12 - Verify non-blocking mode SERVER-side,
;              WRITE /WAIT("READWRITE") reports non-blocking write possible
; See explanation at `srvSrvWrt` and `cliSrvWrt`

srv12 ;
        do procCleanupRegister
        do srvSrvWrt(4)
        quit

cli12 ;
        do procCleanupRegister
        do cliSrvWrt(4)
        quit

;----------------------------------------------------------------------[13]----
; gtm8843_13 - Verify non-blocking mode retry count on client side,
;              no environment variables set

srv13 ;
        do procCleanupRegister
        do srvStart
        hang 9999
        quit

cli13 ;
        do procCleanupRegister
        do cliCliWrt(5)
        write "client channel stuck done"
        quit

;----------------------------------------------------------------------[14]----
; gtm8843_13 - Verify non-blocking mode retry count on server side,
;              no environment variables set

srv14 ;
        do procCleanupRegister
        do srvSrvWrt(5)
        write "server channel stuck done"
        quit

cli14 ;
        do procCleanupRegister
        do cliSrvWrt(5)
        quit

;----------------------------------------------------------------------[15]----
; gtm8843_15 -  Verify non-blocking mode can be set once,
;               second attempt reports error, both client and server side

srv15 ;
        do procCleanupRegister
        set $ztrap="set x=1 goto t15"
        do constStuck
        do srvStart("haltOnTrap",1)
        do srvRecvReq(2)
        if timeout do
        .use $principal
        .write "server: timeout on waiting for request"
        .halt
        ;
        do doubleSet("server")
        use $principal
        write "server is alive",!
        quit

cli15 ;
        do procCleanupRegister
        set $ztrap="set x=2 goto t15"
        do constStuck
        do cliConnect
        do doubleSet("client")
        do cliSendReq("ping")
        write "client is alive",!
        hang 9999
        quit

t15 ; common trap handler
        set error=$piece($zstatus,",",3,4)
        use $principal
        if x=1 write "server"
        if x=2 write "client"
        write ": ",error,!
        quit

;----------------------------------------------------------------------[16]----
; gtm8843_16 - Verify non-blocking mode WRITE /WAIT("READ")
;              reports non-blocking read possible
;
; This test performs a simple request-reply, and meanwile it checks a
; WRITE /WAIT("READ") on the socket, when there's something to read,
; on both sides.

srv16 ;
        do procCleanupRegister
        do srvRwTest("read")
        quit

cli16 ;
        do procCleanupRegister
        do cliRwTest("read")
        quit

;----------------------------------------------------------------------[17]----
; gtm8843_17 - Verify non-blocking mode WRITE /WAIT("READWRITE")
;              reports non-blocking read possible
;
; This test performs a simple request-reply, and meanwile it checks a
; WRITE /WAIT("READWRITE") on the socket, when there's something to read,
; on both sides.

srv17 ;
        do procCleanupRegister
        do srvRwTest("readwrite")
        quit

cli17 ;
        do procCleanupRegister
        do cliRwTest("readwrite")
        quit

;-------------------------------------------------------------------[18-21]----
; gtm8843_18..21 - Verify behaviour of optional third argument to WRITE /WAIT,
;                  check only a specified single socket
;
; At startup, the client send a request to the server, which replies them.
; So, the server have a living connection with the client.
; Server stucks case 18 (1) and 19 (2) so WRITE will be not an option on them.
; Client-2 and client-3 send another request, which the server ignore, so
; READ can apply on them.

srv18 ;
        do srv18split(1)
        quit
srv19 ;
        do srv18split(2)
        quit
srv20 ;
        do srv18split(3)
        quit
srv21 ;
        do srv18split(4)
        quit

srv18split(sub) ;
        do setPort
        do procCleanupRegister
        do constStuck
        do srvStart
        ;
        for  do srvRecvReq(6,1) quit:(""'=request)&'timeout
        ;
        use "server":(socket=conn)
        write /block("off")
        do srvSendResp("welcome, client"_$char(13)_$char(11))
        ;
        if sub=1 do nonBlkBurst("server",6,0)
        if sub=2 do nonBlkBurst("server",6,0)
        ;
        lock +(^clientready(port))
        lock -(^clientready(port))
        ;
        use "server":(socket=conn)
        ; wait for message, but keep some chars in the buffer
        if sub=2!(sub=3) read r#1:(5)
        ;
        write /wait(0,"readwrite",conn)
        set k=$key
        use $principal
        write "result: ",$p(k,"|",1),!
        lock +(^clientfinished(port))
        lock -(^clientfinished(port))
        ;
        quit

cli18 ;
        do cli18split(1)
        quit
cli19 ;
        do cli18split(2)
        quit
cli20 ;
        do cli18split(3)
        quit
cli21 ;
        do cli18split(4)
        quit

cli18e ; error
        use $principal
        if d="" write "client: timeout",!
        if $length(d) write "client error: ",$piece(d,",",2),!
        halt

cli18split(client) ;
        do procCleanupRegister
        do constStuck
        do cliConnect("",0,50)
        do cliSendReq(client)
        set response=""
        lock +(^clientready(port))
        lock +(^clientfinished(port))
xc18 ;
        use "client"
        read r#1:(1)
        set d=$device
        if $piece(d,",",1)=1 goto cli18e
        if r="" goto fc18
        set response=response_r
        if $length(response)<40 goto xc18
fc18 ;
        if response="" goto cli18e
        set response=$piece(response,$char(13),1)
        use $principal
        write "client-recv: ",response,!
        ;
        if client=2 do
        .do cliSendReq("one")
        .do cliSendReq("one more")
        ;
        if client=3 do
        .do cliSendReq("three")
        .do cliSendReq("three again")
        ;
        lock -(^clientready(port))
        use $principal
        write "hang",!
        lock -(^clientfinished(port))
        hang 9999
        quit

;-------------------------------------------------------------------[22]----
; gtm8843_22 - Verify non-blocking mode retry count on client side,
;              with `gtm_non_blocked_write_retries` env var is set

srv22 ;
        do srv13 quit
cli22 ;
        do cli13 quit

;-------------------------------------------------------------------[23]----
; gtm8843_23 - Verify non-blocking mode retry count on client side,
;              with `ydb_non_blocked_write_retries` env var is set

srv23 ;
        do srv13 quit
cli23 ;
        do cli13 quit

;-------------------------------------------------------------------[24]----
; gtm8843_24 - Verify non-blocking mode retry count on server side,
;              with `gtm_non_blocked_write_retries` env var is set

srv24 ;
        do srv13 quit
cli24 ;
        do cli13 quit

;-------------------------------------------------------------------[25]----
; gtm8843_25 - Verify non-blocking mode retry count on server side,
;              with `ydb_non_blocked_write_retries` env var is set

srv25 ;
        do srv13 quit
cli25 ;
        do cli13 quit

;----------------------------------------------------------------------[26]----
; After setting TCP channel to TLS mode, attempt to set it to non-blocking
; mode should fail, server side

srv26 ;
        do bgProcStarted
        do server
        use $principal
        write "# set mode to TLS",!
        use s write /tls("server",,"server")
        use $principal
        write "# set mode to non-blocking (should fail)",!
        set $ztrap="goto s26e"
        use s write /block("off")
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
        use s write /tls("client",,"client")
        do checkpoint("client",2,"wait for finishing server-side test")
        do waitForBgProc
        quit

;----------------------------------------------------------------------[27]----
; After setting TCP channel to TLS mode, attempt to set it to non-blocking
; mode should fail, client side

srv27 ;
        do bgProcStarted
        do server
        use $principal
        write "# set mode to TLS",!
        use s write /tls("server",,"server")
        do checkpoint("server",2,"wait for finishing client-side test")
        quit

cli27 ;
        do client
        use s write /tls("client",,"client")
        use $principal
        write "# set mode to non-blocking (should fail)",!
        set $ztrap="goto c27e"
        use s write /block("off")
        do checkpoint("server",2,"test failed")
        do waitForBgProc
        quit
c27e ;
        set error=$piece($zstatus,",",3,4)
        use $principal
        write error,!
        do checkpoint("client",2,"test finished")
        do waitForBgProc
        quit

;----------------------------------------------------------------------[28]----
; After setting TCP channel to non-blocking mode, attempt to set it to
; TLS mode should not fail, server side

srv28 ;
        do bgProcStarted
        do server
        use $principal
        write "# set mode to non-blocking",!
        use s write /block("off")
        use $principal
        write "# set mode to TLS, no fail",!
        use s write /tls("server",,"server")
        do printZshowTls
        do checkpoint("server",2,"test finished")
        quit

cli28 ;
        do client
        use s write /tls("client",,"client")
        do printZshowTls
        do checkpoint("client",2,"wait for finishing server-side test")
        do waitForBgProc
        quit

;----------------------------------------------------------------------[29]----
; After setting TCP channel to non-blocking mode, attempt to set it to
; TLS mode should not fail, client side

srv29 ;
        do bgProcStarted
        do server
        use $principal
        write "# set mode to TLS",!
        use s write /tls("server",,"server")
        do printZshowTls
        do checkpoint("server",2,"wait for finishing server-side test")
        quit

cli29 ;
        do client
        use $principal
        write "# set mode to non-blocking",!
        use s write /block("off")
        use $principal
        write "# set mode to TLS, no fail",!
        do printZshowTls
        use s write /tls("client",,"client")
        do checkpoint("client",2,"test finished")
        do waitForBgProc
        quit

;------------------------------------------------------------------------------
; These code snippets are from sr_port/iosocket_iocontrol.c, the tests above
; should trigger them, also there're tests for happy path
;
; See discussion:
;   https://gitlab.com/YottaDB/DB/YDBTest/-/issues/538#note_1775432482

; --------
; 506: rts_error_csa(CSA_ARG(NULL) VARLSTCNT(4) ERR_SOCKBLOCKERR, 2,
;       LEN_AND_LIT("already non blocking"));
;
; This error is already triggered by subtest gtm8843_15

; --------
; 516: rts_error_csa(CSA_ARG(NULL) VARLSTCNT(4) ERR_SOCKBLOCKERR,
; 517-  2, LEN_AND_LIT("TLS enabled before non blocking"));
;
; This error is already triggered by subtest gtm8843_26 and gtm8843_27

; --------
; 522: rts_error_csa(CSA_ARG(NULL) VARLSTCNT(4) ERR_SOCKBLOCKERR,
; 523-  2, LEN_AND_LIT("OFF does not take an argument"));

srv30 ;
        do bgProcStarted
        do server
        do checkpoint("server",2)
        quit

cli30 ;
        do client
        use $principal
        write "command: ",$$trim($text(c30t+1)),!
        set $ztrap="goto err30"
        use s
c30t ;
        write /block("off",0)
        do checkpoint("client",2)
        do waitForBgProc
        quit
err30 ;
        set error=$piece($zstatus,",",3,4)
        use $principal
        write error,!
        do checkpoint("client",2)
        do waitForBgProc
        halt

; --------
; 585: rts_error_csa(CSA_ARG(NULL) VARLSTCNT(4) ERR_SOCKBLOCKERR, 2,
;       LEN_AND_LIT("unknown option"));

srv31	;
        do bgProcStarted
        do server
        do checkpoint("server",2)
        quit

cli31 ;
        do client
        use $principal
        write "command: ",$$trim($text(c31t+1)),!
        set $ztrap="goto err31"
        use s
c31t ;
        write /block("attack-decay-sustain-release")
        do checkpoint("client",2)
        do waitForBgProc
        quit
err31 ;
        set error=$piece($zstatus,",",3,4)
        use $principal
        write error,!
        do checkpoint("client",2)
        do waitForBgProc
        quit

; --------
; 260: RTS_ERROR_CSA_ABT(NULL, VARLSTCNT(4) ERR_SOCKBLOCKERR, 2,
; 261-  LEN_AND_LIT("at least one option must be provided"));

srv32 ;
        do bgProcStarted
        do server
        do checkpoint("server",2)
        quit

cli32 ;
        do client
        use $principal
        write "command: ",$$trim($text(c32t+1)),!
        set $ztrap="goto err32"
        use s
c32t ;
        write /block
        do checkpoint("client",2)
        do waitForBgProc
        quit
err32 ;
        set error=$piece($zstatus,",",3,4)
        use $principal
        write error,!
        do checkpoint("client",2)
        do waitForBgProc
        quit

; --------
; 511: rts_error_csa(CSA_ARG(NULL) VARLSTCNT(4) ERR_SOCKBLOCKERR, 2,
;       LEN_AND_LIT("must be connected"));

test33 ;
        do setPort
        set $ztrap="goto err33"
        set socket="server"
        open socket:(ioerror="trap")::"SOCKET"
        use socket:(listen=port_":TCP":ioerror="trap")
        write /block("off")
        ;
        use $principal
        write "no error, test failed",!
        quit
err33 ;
        set st=$zstatus
        use $principal
        write $piece(st,",",3,4),!
        quit

; --------
; sr_port/iosocket_iocontrol.c:
;
; 563: rts_error_csa(CSA_ARG(NULL) VARLSTCNT(4) ERR_SOCKBLOCKERR,
; 564-  2, LEN_AND_LIT("COUNT requires local variable passed by reference"));
;
; 551: rts_error_csa(CSA_ARG(NULL) VARLSTCNT(4) ERR_SOCKBLOCKERR,
; 552-  2, LEN_AND_LIT("CLEAR does not take an argument"));
;
; 576: rts_error_csa(CSA_ARG(NULL) VARLSTCNT(4) ERR_SOCKBLOCKERR,
; 577-  2, LEN_AND_LIT("SENT requires local variable passed by reference"));

srv34 ;
        do bgProcStarted
        do server
        do checkpoint("server",2)
        quit

cli34 ;
        do client
        use s
        write /block("off")
        new a,b,c
        use $principal
        ;
        write "# COUNT without local var ref"
        do c34test("write /block(""count"")",1)
        ;
        write "# COUNT with local var ref"
        do c34test("write /block(""count"",.a)",0)
        write "value of a=",$get(a,"<undef>"),!
        ;
        write "# CLEAR with argument"
        do c34test("write /block(""clear"",b)",1)
        write "value of b=",$get(b,"<undef>"),!
        ;
        write "# CLEAR without argument"
        do c34test("write /block(""clear"")",0)
        ;
        write "# SENT without local var ref"
        do c34test("write /block(""sent"")",1)
        ;
        write "# SENT with local var ref"
        do c34test("write /block(""sent"",.c)",0)
        write "value of c=",$get(c,"<undef>"),!
        ;
        do checkpoint("client",2)
        do waitForBgProc
        quit

c34test(cmd,shoulderr) ;
        new once
        use $principal
        write " ",$select(shoulderr=1:"should",shoulderr=0:"shouldn't")
        write " produce error",!
        write "executing command: ",cmd,!
        set once=0
        set $ztrap="set once=1+once"
        use s xecute "if once=0 "_cmd
        ;
        if once=0 do  quit
        . use $principal
        . write "no error, test "
        . write $select(shoulderr=1:"failed",shoulderr=0:"passed"),!
        ;
        set error=$piece($zstatus,",",3,4)
        use $principal
        write "error caught, test "
        write $select(shoulderr=1:"passed",shoulderr=0:"failed")
        write ": ",error,!
        quit

; --------
; sr_port/iosocket_wait.c:
;
;    119  if (strstr(wait_for_string, READ))
;    120    wait_for_what |= WAIT_FOR_READ;
;    121  if (strstr(wait_for_string, WRITE))
;    122    wait_for_what |= WAIT_FOR_WRITE;
;    123  if (0 == wait_for_what)
;    124  {   /* no valid value found */
;    125      rts_error_csa(CSA_ARG(NULL) VARLSTCNT(6) ERR_SOCKWAITARG,
;             4, RTS_ERROR_LITERAL("Second"),
;    126      RTS_ERROR_LITERAL("value is not valid"));
;    127    return FALSE;
;    128  }
;
; See discussion:
;   https://gitlab.com/YottaDB/DB/YDBTest/-/issues/538#note_1775450187

srv35 ;
        do bgProcStarted
        do server
        do checkpoint("server",2)
        quit

cli35 ;
        do client
        use $principal
        write "command: ",$$trim($text(c35t+1)),!
        use s write /block("off")
        set $ztrap="goto c35e"
        use s
c35t ;
        write /wait(0,"flatearth")
        use $principal
        write "no error, test failed"
        do checkpoint("client",2)
        do waitForBgProc
        quit
c35e ;
        set error=$piece($zstatus,",",3,4)
        use $principal
        write "error caught, test passed: ",error,!
        do checkpoint("client",2)
        do waitForBgProc
        halt

; --------
; sr_port/iosocket_iocontrol.c:
;
; 483  if (0 >= dsocketptr->n_socket)
; 484  {
; 485       rts_error_csa(CSA_ARG(NULL) VARLSTCNT(1) ERR_NOSOCKETINDEV);
; 486       return;
; 487  }

test36 ;
        set $ztrap="goto err36"
        set socket="server"
        open socket:::"SOCKET"
        use socket
        write /block("off")
        ;
        use $principal
        write "no error, test failed",!
        quit
err36 ;
        set st=$zstatus
        use $principal
        write $piece(st,",",3,4),!
        quit

; --------
; sr_port/iosocket_iocontrol.c:
;
; 493  if (dsocketptr->mupintr)
; 494  {
; 495      rts_error_csa(CSA_ARG(NULL) VARLSTCNT(1) ERR_ZINTRECURSEIO);
; 496      return;
; 497  }
;
; See discussion:
;   https://gitlab.com/YottaDB/DB/YDBTest/-/issues/538#note_1775448700

srv37 ;
        do bgProcStarted
        do server
        set ^pid(port)=$job
        set $zinterrupt="do int37"
        set $ztrap="goto err37"
        do checkpoint("server",2)
        use $principal
        write "# waiting to be interupted",!
        use s read x
        quit
        ;
int37 ;
        set once=0
        use $principal
        write "# attempt to use socket in interrupt handler",!
        use s write /block("off")
        use $principal
        write "no error: test failed",!
        halt
        ;
err37 ;
        set once=1+once
        if once>1 quit
        set st=$zstatus
        use $principal
        write "error caught: ",$piece(st,",",3,4),!
        quit
        ;
cli37 ;
        do client
        do checkpoint("client",2)
        use $principal
        write "# send interrupt to server",!
        zsystem "$gtm_dist/mupip intrpt "_^pid(port)
        do waitForBgProc
        quit

; --------
; sr_port/iosocket_wait.c:
;
; 130  if (NULL != handle)
; 131  {
; 132      MV_FORCE_STR(handle);
; 133      /* WARNING inline assignment below */
; 134      if (0 > (handle_index = iosocket_handle(handle->str.addr, &handle->str.len, FALSE, dsocketptr)))
; 135      {
; 136          rts_error_csa(CSA_ARG(NULL) VARLSTCNT(4) ERR_SOCKNOTFND, 2, handle->str.len, handle->str.addr);
; 137          return FALSE;           /* for compiler and analyzers */
; 138      }
; 139      which_socketptr = dsocketptr->socket[handle_index];
; 140  }

test38	;
        set $ztrap="goto err38"
        set socket="server"
        open socket:::"SOCKET"
        use socket
        write /wait(5,,"abcd")
        quit
        ;
        use $principal
        write "no error, test failed",!
        quit
err38	;
        set st=$zstatus
        use $principal
        write $piece(st,",",3,4),!
        quit

;##############################################################################
; srvRwTest - Verify non-blocking mode WRITE /WAIT(parm) server side

srvRwTest(verb) ;
        do srvStart("haltOnTrap")
        do srvRecvReq(2)
        use "server":(socket=conn)
        write /block("off")
        if timeout do
        .use $principal
        .write "server: timeout on waiting for request"
        .halt
        do srvSendResp("bar!")
        use "server":(socket=conn)
        do waitRw("server",verb)
        hang 9999
        quit

;##############################################################################
; cliRwTest - Verify non-blocking mode WRITE /WAIT client side

cliRwTest(verb) ;
        do cliConnect
        use "client"
        write /block("off")
        do cliSendReq("foo?")
        use "client"
        do waitRw("client",verb)
        do cliSendReq("zeex")
        hang 0.5 ; give some time for message delivery
        quit

;##############################################################################
; waitRw - Verify non-blocking mode WRITE /WAIT

waitRw(side,verb) ;
        hang 0.5 ; wait some time for message delivery
        write /wait(0,verb)
        set d=$device
        set code=$piece(d,",",1)
        set message=$piece(d,",",2)
        set k=$key
        ;
        use $principal
        if code'=0 do
        .write side_": query fail: ",message,!
        .halt
        ;
        write side_": non-blocking ",$char(34)
        if verb="read" write "READ"
        if verb="readwrite" write "READWRITE"
        write $char(34)," query: ",$piece(k,"|",1),!
        quit

;##############################################################################
; `doubleSet` is tries to set non-blocking mode twice

doubleSet(sender) ; set non-blocking mode twice
        if sender="server" use "server":(socket=conn)
        if sender="client" use "client"
        write /block("off")
        write /block("off")
        quit

;##############################################################################
; `srvCliWrt` is a simple server for the cases when client is burst writing.
; It starts a server and does nothing, so the client can get stuck.
; For op=4, it sends a message to the client, to produce "READWRITE" result
; on channel query.

srvCliWrt(op) ; server for client WRITE tests
        do constStuck
        do srvStart("haltOnTrap")
        hang 9999
        quit

;##############################################################################
; `cliCliWrt` is the client for client-side non-blocking tests. The `op`
; parameter is the mode of the check:
; 1 - check special variable after WRITE
; 2 - set up trap for blocking detection
; 3 - check if write is possible before WRITE, with "WRITE" query
; 4 - check if write is possble before WRITE, with "READWRITE" query
; 5 - don't check, only stuck the channel
; This routine calls `cliConnect` (with trap set when op=2).
; The `nonBlkBurst` sends messages on the TCP socket, and checks error
; with the method specified by `op` parameter. If the error is detected,
; the test is passed. The op=3 and op=4 modes don't send messages, only
; performs the check.

cliCliWrt(op) ; CLIENT-side non-blocking WRITE test, `op` detection
        do constStuck
        if op=2 do cliConnect("nbtrap")
        if op'=2 do cliConnect
        do nonBlkBurst("client",op)
        quit

;##############################################################################
; `srvSrvWrt` is the server for server-side non-blocking tests. The `op`
; parameter describes the error checking method, see above at `cliCliWrt`.
; This routine calls the srvStart (with trap set when op=2), then waits
; for a client connection, it's required because only living connections
; can be set to non-blocking mode. If the client is connected, the server
; starts sending messages.

srvSrvWrt(op) ; SERVER-side non-blocking WRITE test, `op` detection
        do constStuck
        set sender="server"
        if op=2 do srvStart("nbtrap")
        if op'=2 do srvStart
        do srvRecvReq(2,1)
        if timeout do
        .use $principal
        .write "server: timeout on waiting for request",!
        .halt
        do nonBlkBurst("server",op)
        quit

;##############################################################################
; `cliSrvWrt` is the client for server-side non-blocking tests. It connects
; to the server, and sends a request. This is required by the server, to have
; a living TCP connection which can be tested. After the request is sent, the
; client hangs forever.

cliSrvWrt(op) ; client for server WRITE tests
        do constStuck
        do cliConnect
        if op'=3&(op'=4) do cliSendReq("flood me")
        hang 9999
        quit

;##############################################################################
; `nonBlkBurst` is testing WRITE on an already opened socket. The testing
; method is described by the `op` parameter, for explanation, see `cliCliWrt`
; or the code below.
;
; First, the routine sets the socket to non-blocking mode. The core of the
; routine is a loop, using `counter` as loop variable, it goes from 0 to
; `stuckFactor`, which is the number of message to send, which amount
; should cause stuck. The core of the loop is a WRITE instuction, which
; sends `longMessage` on the socket. When op=1, the routine post-checks
; the result of this WRITE, when op=3 or op=4, a pre-check runs, and no
; stuck happens, only query check. Else, when the active check detects stuck
; error, the test is passed. When op=2, a trap routine runs upon error, which
; checks it and reports test pass. If the loop is over, the test is failed,
; because it means that no stuck is detected with the required method.

nonBlkBurst(sender,op,mute) ; test WRITE on opened socket, ANY side, `op` detection
        set mute=$get(mute,0)
        if mute=0 do
        .use $principal
        .write sender_": non-blocking test, method: "
        .if op=1 write "flood, variable check"
        .if op=2 write "flood, trap"
        .if op=3 write "write query reports write"
        .if op=4 write "readwrite query reports write"
        .if op=5 write "flood, don't check"
        .if op=6 write "flood, don't set non-blocking, don't check"
        .write " (op=",op,")",!
        ;
        if sender="server" use "server":(socket=conn)
        if sender="client" use "client"
        if op'=6 write /block("off")
        ;
        set counter=0
xnbb ;
        use $principal
        if sender="server" use "server":(socket=conn)
        if sender="client" use "client"
        ;
        if op=3 write /wait(0,"write")
        if op=4 write /wait(0,"readwrite")
        set d=$device
        if counter=0 set k=$key
        if op=3!(op=4) do
        .set message=$piece(d,",",2)
        .use $principal
        .write sender_": non-blocking ",$char(34)
        .if op=3 write "WRITE"
        .if op=4 write "READWRITE"
        .write $char(34)," query: ",$piece(k,"|",1),!
        .halt
        ;
        if sender="server" use "server":(socket=conn)
        if sender="client" use "client"
        ;
        write longMessage,!
        set d=$device
        if op=1!(op=5)!(op=6) goto postOp1x5x6
cnbb ;
        set counter=1+counter
        if counter<stuckFactor goto xnbb
        ;
        use $principal
        write sender_": test failed, no stuck detected after "_stuckFactor_" messages",!
        halt
        ;
postOp1x5x6 ;
        set code=$piece(d,",",1)
        if code=0 goto cnbb
        set message=$piece(d,",",2)
        if op=5!(op=6) quit
        ;
        write longMessage,!
        set d=$device
        use $principal
        write sender_": first WRITE: "_$piece(message," ",1,3),"...",!
        write sender_": next WRITE: "_$piece(d,",",2),!
        write sender_": test passed",!
        quit
        ;
nbtrap ;
        use $principal
        set s=$zstatus
        set error=$piece(s,",",3)
        if error="%YDB-E-SOCKWRITE" set result="passed"
        else  set result="failed"
        if op'=2 set result="failed"
        write sender_": test "_result_", trap caught, error: "_error,!
        halt

;##############################################################################

onOff(sock) ; reports $ZSOCKET()
        if sock="client" use "client" set ch=0
        if sock="server" use "server":(socket=conn) set ch=1
        ;
        write /wait(0,"write")
        set k1=$piece($key,"|",1)
        ;
        set on=$zsocket(sock,"blocking",ch)
        ;
        write /block("off")
        set off=$zsocket(sock,"blocking",ch)
        ;
        write /wait(0,"write")
        set k2=$piece($key,"|",1)
        ;
        use $principal
        write sock_" block on = ",on,!
        write sock_" block off = ",off,!
        write sock_" report blocking = ",$char(34),k1,$char(34),!
        write sock_" report nonblocking = ",$char(34),k2,$char(34),!
        quit

;##############################################################################

setPort ; set port value specified by CLI arg or die
        ;
        if $data(port) quit
        set port=$zcmdline
        if $length(port) quit
        use $principal
        write "TEST-E-ERROR: internal error: no port arg is provided by the shell script",!
        halt

;##############################################################################

srvStart(trap,mute) ; start server
        do setPort
        set trap=$g(trap,"")
        set mute=$get(mute,0)
        if $length(trap)>0 do  quit
        .open "server":(listen=port_":tcp":attach="server":delimiter=$char(13,10):ioerror="trap":exception="goto "_trap):1:"socket"
        .use $principal
        .if 'mute write "server-listen-trap-",trap,!
        ;
        open "server":(listen=port_":tcp":attach="server":delimiter=$char(13,10)):1:"socket"
        use $principal
        if 'mute write "server-listen",!
        quit

;##############################################################################

srvRecvReq(to,mute) ; receive request
        set request=""
        set timeout=0
        set mute=$get(mute,0)
        use $principal
        if 'mute write "server-recv-start",!
        ;
        use "server"
        write /wait($get(to,1),"read")
        if '$test do  quit
        .use $principal
        .if 'mute write "server-recv-timeout",!
        .set timeout=1
        ;
sconn ; server received a connection
        set conn=$piece($key,"|",2)
        use $principal
        if 'mute write "server-recv-connect",!
        ;
        set request=""
        use "server":(socket=conn)
        read /wait($get(to,0.1),"read")
        set emptyCounter=0
xsread ; next read
        use "server":(socket=conn)
        read r#1:(timeout)
        set d=$device
        if $piece(d,",",1)=1 do  quit
        .use $principal
        .write "server-recv-error: ",$p(d,",",2),!
        .set request=""
        ;
        if r'="" do  goto xsread
        .set emptyCounter=0
        .set request=request_r
        ;
srempty ; read empty
        if emptyCounter=3 do  quit
        .use $principal
        .if mute quit
        .if $length(request) do spr(request) quit
        .else  write "server-recv-timeout",!
        ;
        set emptyCounter=1+emptyCounter
        hang 0.01 ; provide some idle for TCP
        goto xsread
        ;
spr(p)  ; print request
        set p=$tr(p,$char(13),"")
        set p=$tr(p,$char(10),"^")
        write "server-recv-data: ",p,!
        quit
        ;
srvClose ; (not used so far)
        use $principal
        write "server-recv-close",!
        close "server":(socket=conn)
        quit

;##############################################################################

srvSendResp(msg,quiet) ; send server response message
        set quiet=$g(quiet,0)
        if 'quiet do
        .use $principal
        .write "server-send: ",$piece(msg,$char(13),1),!
srvskiplog ; skip logging
        use "server":(socket=conn)
        write /wait(0,"read")
        ;
        use "server":(socket=conn)
        write msg,!
        ;
        set d=$device
        use $principal
        quit

;##############################################################################

cliConnect(trap,quiet,retryNum) ; connect as client
        new opened
        set trap=$g(trap,"")
        set quiet=$g(quiet,0)
        set retryNum=$g(retryNum,10)
        do setPort
        if trap'="" do  quit
        .use $principal
        .if 'quiet write "client-connect-trap",!
        .open "client":(connect="127.0.0.1:"_port_":tcp":attach="handle":ioerror="trap":exception="goto "_trap):1:"socket"
        ;
        ; cli connect, no trap
        use $principal
        if 'quiet write "client-connect",!
        ;
        set retry=0
        for  do cliOpen quit:opened  do
        .if retry>retryNum do
        ..use $principal
        ..write "client-connect-fail: ",d,!
        ..zshow "d"
        ..halt
        .set retry=1+retry
        .hang 0.1  ; avoid burst retry
        quit
        ;
cliOpen ;
        open "client":(connect="127.0.0.1:"_port_":tcp":attach="handle"):1:"socket"
        set opened=$test
        set d=$device
        quit
;##############################################################################

cliSendReq(msg,quiet) ; send request
        set quiet=$g(quiet,0)
        if 'quiet do
        .use $principal
        .write "client-send: ",msg,!
        ;
        use "client"
        write msg,!
        set d=$device
        if $piece(d,",",1)=1 do
        .use $principal
        .write "client error: ",$piece(d,",",2),!
        .halt
        ;
        use $principal
        quit

;##############################################################################

stuckRecv(sender,receiver) ; stuck receiver test
        set retry=0
        do constStuck
        set toStuck=$justify(stuckFactor/reportEvery,0,0)
xstuck ;
        read stdin#1:(0.01)
        if stdin="" do  goto xstuck
        .if retry=5 do
        ..write sender_": test passed, "_receiver_" hangs, it stopped sending heartbeat",!
        ..halt
        .set retry=1+retry
        .hang 0.1 ; low freq loop, provide some idle
        ;
        set toStuck=toStuck-1
        if toStuck=0 do
        .write sender_": test failed, "_receiver_" is still running",!
        .halt
        ;
        set retry=0
        if stdin=heartbeatChar goto xstuck
        ;
        write sender_": "_receiver_" sent some message (or garbage), see below",!
        write stdin
        read stdin:(1)
        write stdin,!
        halt

;##############################################################################

stuckSend(receiver) ; stuck sender test
        do constStuck
        set counter=0
        ;
        for  do
        .if receiver="client" do cliSendReq(longMessage,1)
        .if receiver="server" do srvSendResp(longMessage,1)
        .use $principal
        .set counter=1+counter
        .if counter#reportEvery=0 write heartbeatChar
        .if counter>stuckFactor quit
        ;
        write receiver_": test failed, should be blocked by now",!
        halt

;##############################################################################

haltOnTrap ; dummy trap: supress M system error
        halt

;##############################################################################
;
; These subroutines call `setPort`, which returns `port`, and use this
; variable as session ID. If more instances are running on the same host,
; the TCP port should be distinct, so it's a good session ID

procCleanupPrepare ; clear data for post-test process cleanup
        ;
        use $principal
        do setPort
        kill ^procs(port)
        use $principal
        write "prepared cleanup: ",port,!
        quit

procCleanupRegister ; register process ID for post-test process cleanup
        ;
        do setPort
        set ^procs(port,$job)=$horolog
        quit

procCleanupPerform ; kill remaining processes
        ;
        do setPort
        if $data(^procs(port))=0 quit
        ;
        set process=""
        for  set process=$order(^procs(port,process)) quit:process=""  do
        .write "kill gently: ",process,!
        .zsystem "kill "_process
        ;
        for  set process=$order(^procs(port,process)) quit:process=""  do ^waitforproctodie(process)
        quit

;##############################################################################
; Simple server for subtests for gtm8843_26..gtm8843_38

server	;
        do setPort
        do procCleanupRegister
        use $principal
        set s="socket"
        write "# server: waiting for client",!
        open s:(LISTEN=port_":TCP":delim=$char(13))::"SOCKET"
        do checkpoint("server",1,"client connected")
        ;
        use s write /wait
        use $principal
        quit

;##############################################################################
; Simple client for subtests for gtm8843_26..gtm8843_38

client	;
        do setPort
        do procCleanupRegister
        set s="socket"
        use $principal
        write "# client: connecting to server",!
        open s:(CONNECT="127.0.0.1:"_port_":TCP":delim=$char(13))::"SOCKET"
        do checkpoint("client",1,"connected to server")
        quit

;##############################################################################
; Checkpoint mechanism for server and client to wait each other

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
; ZSHOD "D" without IDs

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
; Mechanism to wait for the background process

bgProcStarted ; acquire the lock indicates that background process is running
        do setPort
        lock +(^bgprocrun(port))
        quit

waitForBgProc ; wait for the lock indicates background process is running
        do setPort
        lock +(^bgprocrun(port))
        lock -(^bgprocrun(port))
        quit

;##############################################################################
; Trim spaces from a string
;
trim(x) ;
        new i,j
        for i=1:1:$length(x) quit:" "'=$extract(x,i)
        for j=$length(x):-1:1 quit:" "'=$extract(x,j)
        quit $extract(x,i,j)
