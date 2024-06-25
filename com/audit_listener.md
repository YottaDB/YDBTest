 >
 > Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.
 > All rights reserved.
 >
 >	This source code contains the intellectual property
 >	of its copyright holder(s), and is made available
 >	under a license.  If you do not know the terms of
 >	the license, please stop and do not read further.


# Audit Listener

## Purpose

This utility is a test/reference implementation server
for the audit logging facility. See documentation:
http://tinco.pair.com/bhaskar/gtm/doc/books/ao/UNIX_manual/ch03s06.html#audit_principal_device

## Features

- Can receive log requests via TCP, TLS and Unix Socket
- Logs requests to a specified log file
- Upon `HUP` singal, rotates log
- Saves own PID into specified file (this feature is
  added later)

## Origin

In the "Logging" section of the document referenced
above, there's a link to `dm_audit_listener.zip`,
which contains the original version of this utility.

This source has been modified to meet the requirements
of the audit log tests:

- The original package contains three separate
  utilities for TCP, TLS and Unix Socket modes. The
  actual version is a single executable, mode can be
  selected by CLI arg.
- The original package consist of more files. These
  files are now merged to a single `.c` source file,
  it's easier to handle, like compile etc.
- The modified version saves the PID into a file, so
  tests can pick it and can send signals to the
  listener.

## Compile

It requires only a C compiler and *OpenSSL* library:
```
echo "# compile audit_listener utility"
$gt_cc_compiler \
	$gtm_tst/com/audit_listener.c \
	-o $ydb_dist/audit_listener \
	-lssl -lcrypto
```

## Use

Executing the program without args, or with
insufficient number of args, prints a short
help on the usage for the three mode.

### TCP mode

Usage:
```
audit_listener tcp <pidfile> <logfile> <portno>
```

Example:
```
$ ./audit_listener tcp pid.txt log.txt 9999 &
[1] 593945
$ curl -m0.1 http://localhost:9999/
curl: (28) Operation timed out after 102 milliseconds with 0 bytes received
$ cat log.txt
2024-06-25 09:50:30; GET / HTTP/1.1
Host: localhost:9999
User-Agent: curl/7.88.1
Accept: */*

```
It's not designed to receive HTTP requests,
but as the example shows, it captures the HTTP
header and logs it.

For sending some log to the listner, `netcat`
or `telnet` can be also used.

### TLS mode

Usage:
```
audit_listener tls <pidfile> <logfile> <portno> \
  <certfile> <privkeyfile> <passphrase> \
  [-clicert] [-cafile <CAfilepath>] [-capath <CApath>]
```

Example:
```
$ ./audit_listener tls pid.txt log.txt 9999 self.crt self.key wonderful &
$ curl -k -m0.1 https://localhost:9999/secure
curl: (52) Empty reply from server
$ cat log.txt
2024-06-25 10:13:02; GET /secure HTTP/1.1
Host: localhost:9999
User-Agent: curl/7.88.1
Accept: */*

```

### Unix socket mode

Usage:
```
audit_listener unix <pidfile> <logfile> <uxsockfile>
```

Example:
```
$ ./audit_listener unix pid.txt log.txt audit.sock &
$ echo 'hello' | nc -U audit.sock
$ cat log.txt
2024-06-25 10:31:05; hello\n
```
### Log rotate

Sending `HUP` signal to the listener renames the actual
log, and opens a new one with zero size.

Example:
```
$ ls -l log.*
-rw------- 1 ern0 ern0 29 Jun 25 06:31 log.txt
$ kill -HUP `cat pid.txt`
$ ls -l log.*
-rw------- 1 ern0 ern0  0 Jun 25 06:33 log.txt
-rw------- 1 ern0 ern0 29 Jun 25 06:31 log.txt_2024177103307
```

### Graceful exit

Just send `TERM` (or `INT`) signal to the listener.

Example:
```
$ kill `cat pid.txt`
$
[1]+  Exit 1   ./audit_listener tcp pid.txt log.txt 9999
```
