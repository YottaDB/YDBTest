;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2023-2024 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
ATTACH128;
	set socket="server"
	open socket:(ioerror="trap")::"SOCKET"
	use socket:(ATTACH="Bitzp4SXlljTzhQwA7Io8RcH8iMjTjQ5TJiujOtBlKwomHIYZo4pRsF57IwbtXSmAOjIONc4FuVv5usbpftPCAyIQhFpOOVSL65KAV4yWQhUF2IymzZFvkxqRAcUMrbi")
	q
	;
DETACH128;
	set socket="server"
	open socket:(ioerror="trap")::"SOCKET"
	use socket:(DETACH="Bitzp4SXlljTzhQwA7Io8RcH8iMjTjQ5TJiujOtBlKwomHIYZo4pRsF57IwbtXSmAOjIONc4FuVv5usbpftPCAyIQhFpOOVSL65KAV4yWQhUF2IymzZFvkxqRAcUMrbi")
	q
	;
CONNECT128;
	set socket="server"
	open socket:(ioerror="trap")::"SOCKET"
	use socket:(CONNECT="Bitzp4SXlljTzhQwA7Io8RcH8iMjTjQ5TJiujOtBlKwomHIYZo4pRsF57IwbtXSmAOjIONc4FuVv5usbpftPCAyIQhFpOOVSL65KAV4yWQhUF2IymzZFvkxqRAcUMrbi")
	q
	;
SOCKET128;
	set socket="server"
	open socket:(ioerror="trap")::"SOCKET"
	use socket:(SOCKET="Bitzp4SXlljTzhQwA7Io8RcH8iMjTjQ5TJiujOtBlKwomHIYZo4pRsF57IwbtXSmAOjIONc4FuVv5usbpftPCAyIQhFpOOVSL65KAV4yWQhUF2IymzZFvkxqRAcUMrbi")
	q
	;
ZLISTEN128;
	set socket="server"
	open socket:(ioerror="trap")::"SOCKET"
	use socket:(ZLISTEN="Bitzp4SXlljTzhQwA7Io8RcH8iMjTjQ5TJiujOtBlKwomHIYZo4pRsF57IwbtXSmAOjIONc4FuVv5usbpftPCAyIQhFpOOVSL65KAV4yWQhUF2IymzZFvkxqRAcUMrbi")
	q
