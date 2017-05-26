; Open a TCP/IP connection to a GT.CM server
;
; Parameters-
;    ip:	internet address of host machine running GT.CM
;    port:	TCP port the GT.CM server is listening (typically 6100)
;
; Return value
;	0	failure, no connection was established.
;	1	success
;

connect(ip,port,agent,pw)
;	w "ip address is         : ",ip,!
;	w "port number is        : ",port,!
;	w "agent is              : ",agent,!
;	w "pw is                 : ",pw,!
	n msg,rsp
	i $$open^tcp(ip,port)=0 w "Connect request failed.",! q 0
	s msg=$c(Connect("Major Ver"),Connect("Minor Ver"))_$$num2LI^cvt(Connect("Min Value"))
	s msg=msg_$$num2LI^cvt(Connect("Max Value"))_$$num2LI^cvt(Connect("Min Subscript"))
	s msg=msg_$$num2LI^cvt(Connect("Max Subscript"))_$$num2LI^cvt(Connect("Min Reference"))
	s msg=msg_$$num2LI^cvt(Connect("Max Reference"))_$$num2LI^cvt(Connect("Min Message"))
	s msg=msg_$$num2LI^cvt(Connect("Max Message"))_$$num2LI^cvt(Connect("Min Outstand"))
	s msg=msg_$$num2LI^cvt(Connect("Max Outstand"))_$c(Connect("8 bit"),Connect("Char Trans"))
	s msg=msg_$$str2SS^cvt(Connect("Implem ID"))_$$str2SS^cvt(agent)_$$str2SS^cvt(pw)_$c(0)
	s msg=msg_$c(Connect("Ext Count"))
	do send^tcp(OpType("Connect"),msg)
	s rsp=$$receive^tcp()
	i $l(rsp)=0 w "Connect failed: TCP/IP I/O error",! do close^tcp q 0
	i Resp("Class")=1 w "Connect failed: ",Resp("Type"),"- ",Error(Resp("Type")),! do close^tcp q 0

;	w "Connected to GT.CM ",$$SS2str^cvt($E(rsp,16,$L(rsp))),!
	q 1

