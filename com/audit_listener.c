/****************************************************************
 *								*
 * Copyright (c) 2022 Fidelity National Information		*
 * Services, Inc. and/or its subsidiaries. All rights reserved.	*
 *								*
 * Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.      *
 * All rights reserved.                                         *
 *								*
 *	This source code contains the intellectual property	*
 *	of its copyright holder(s), and is made available	*
 *	under a license.  If you do not know the terms of	*
 *	the license, please stop and do not read further.	*
 *								*
 ****************************************************************/

#include <stdio.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <sys/socket.h>
#include <sys/wait.h>
#include <assert.h>
#include <stdlib.h>
#include <netdb.h>
#include <unistd.h>
#include <string.h>
#include <errno.h>
#include <sys/un.h>
#include <fcntl.h>
#include <limits.h>
#include <time.h>
#include <signal.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <openssl/ssl.h>
#include <openssl/err.h>
#include <openssl/bio.h>
#include <openssl/rand.h>

int switch_logfile(char *logfile);

void strip_prognam(char* full);
void save_pidfile();
int about(void);
int main_tcp(int argc, char *argv[]);
int main_tls(int argc, char *argv[]);
int pem_passwd_cb(char *buf, int size, int rwflag, void *userdata);
SSL_CTX *ssl_context_init(char *certfile, char *privkeyfile, char *cafile, char *capath, int req_clicert);
int main_unix (int argc, char *argv[]);
int unix_listen_loop(int fd);
int main(int argc, char* argv[]);

#define	PROGNAME		0
#define MAX_BUF_SIZE		2048		/* For testing/demo purposes. Adjust as per the message size in your environment. */
#define MAX_STR_SIZE		1024
#define	BACKLOG			10		/* Maximum length to which the queue of pending connections for socket may grow */
#define TIME_FORMAT     	"_%Y%j%H%M%S"   /* .yearjuliendayhoursminutesseconds */
#define PROG_VARIATION		1
#define PIDFILE			2
#define	LOGFILE			3
#define EXIT_OK			0
#define EXIT_ERROR		1
#define EXIT_SSL_ERROR		2

/* Unix Socket */
#define	SOCKFILE		4

/* TCP */
#define	PORTNO			4

/* TLS/SSL  */
#define	VERIFY_DEPTH		7		/* TLS certificate verification depth */
#define SESSION_ID_DEFAULT	"audit_logger"	/* Default TLS session ID */
#define	ARG_CLICERT		"CLICERT"
#define	ARG_CAFILE		"CAFILE"
#define	ARG_CAPATH		"CAPATH"
#define	CERTFILE		5
#define	PRIVKEYFILE		6
#define	PASSPHRASE		7
#define	NUM_REQUIRED_ARGS	8		/* Number of required command line arguments for TLS*/

char 	*pass;					/* Used to store the TLS/SSL certificate passphrase */

/* Common */
char 	logfile[PATH_MAX + 1];
int	terminate = 0;				/* Boolean value set by signal handler to let program know to terminate */
int 	logfileswitch = 0;			/* Boolean value set by signal handler to let program know to switch
	        				   the log file */
int	logfd;
char* 	prognam;
char* 	pidfilename;

/* Handler for SIGINT and SIGTERM caused by Ctrl-C and kill (-15) respectively.
 *
 * params:
 * 	@sig signal number
 */
void listener_signal_handler(int sig)
{
	if ((SIGTERM == sig) || (SIGINT == sig))
		terminate = 1;
	if (SIGHUP == sig)
		logfileswitch = 1;
	return;
}

/* Opens a file and dup its file descriptor to stdout and stderr
 *
 * params:
 * 	@where file path of output audit log file
 * returns:
 * 	1 if log file opened and dup'ed successfully
 * 	0 if something went wrong
 */
int open_logfile(char *where)
{
	if (NULL != where)
	{
		memset(logfile, 0, PATH_MAX + 1);
		strncpy(logfile, where, PATH_MAX);
	}
	if (strlen(logfile))
	{
		logfd = open(logfile, O_WRONLY | O_CREAT | O_APPEND, S_IWUSR | S_IRUSR);
		if (0 > logfd)
		{
			fprintf(stderr, "Failed to open output file %s: %s\n", logfile, strerror(errno));
			return EXIT_ERROR;
		}
		dup2(logfd, STDOUT_FILENO);
		dup2(logfd, STDERR_FILENO);
		close(logfd);
		return EXIT_ERROR;
	}
	fprintf(stderr, "No log file specified.");
	return EXIT_ERROR;
}

/* Escapes all backslashes ('\\'), null characters ('\0'), and newlines ('\n')
 *
 * params:
 * 	@source original string (contains at most "maxlen" characters) to escape
 * 	@target dest string that must contain enough space for at least 2 * "maxlen" characters (if all characters must be escaped)
 * 	@maxlen length of "source" string
 */
void escape_string(const char* source, char *target, int maxlen)
{
	int	i;
	char	*optr;

	optr = target;
	for (i = 0; i < maxlen; i++)
	{
		if ('\\' == source[i])
		{
			snprintf(optr, 3, "\\\\");
			optr += 2;
		} else if ('\n' == source[i])
		{
			snprintf(optr, 3, "\\n");
			optr += 2;
		} else if ('\0' == source[i])
		{
			snprintf(optr, 3, "\\0");
			optr += 2;
		} else
		{
			*(optr++) = source[i];
		}
	}
}

#define TIME_FORMAT     "_%Y%j%H%M%S"   /* .yearjuliendayhoursminutesseconds */
int switch_logfile(char *logfile)
{
	int			logfile_len, switchlogfile_len, suffix, logfd, timefmtlen = 101;
        char			time_format[timefmtlen],  switchlogfile[PATH_MAX + 1];
	time_t			switchtime;
	struct tm		*timeptr;
	struct stat     	fs;

	errno = 0;
	time(&switchtime);
	if (0 != errno)
	{
		perror("Error determining switch time");
		return EXIT_ERROR;
	}
	timeptr = gmtime(&switchtime);
	memset(time_format, '\0', timefmtlen);
	strftime(time_format, timefmtlen, TIME_FORMAT, timeptr);
	logfile_len = strlen(logfile);
	snprintf(switchlogfile, logfile_len + sizeof(time_format), "%s%s", logfile, time_format);
	switchlogfile_len = strlen(switchlogfile);
	suffix = 1;
	while ((0 == stat(switchlogfile, &fs)) || (ENOENT != errno))  /* This file exists */
	{
		sprintf(&switchlogfile[switchlogfile_len], "_%d", suffix);
		suffix++;
	}
	if ((-1 == rename(logfile, &switchlogfile[0])) || (-1 == (logfd = open(logfile, O_WRONLY | O_CREAT | O_APPEND, S_IWUSR | S_IRUSR))) || (-1 == dup2(logfd, STDERR_FILENO)) || (-1 == dup2(logfd, STDOUT_FILENO)))
	{
		perror("Error switching log file");
		return EXIT_ERROR;
	}
	return EXIT_OK;
}

void strip_prognam(char* full)
{
	prognam = full;
	while ('\0' != *full)
	{
		if (*full == '/')
			prognam = full + 1;
		full++;
	}
}

void save_pidfile()
{
	char tmpnam[MAX_STR_SIZE + 1];
	strncpy(tmpnam, pidfilename, MAX_STR_SIZE);

	FILE* f = fopen(tmpnam, "w");
	if (NULL == f)
	{
		fprintf(stderr, "failed to create file: %s \n", tmpnam);
		exit(EXIT_ERROR);
	}
	fprintf(f, "%d\n", getpid());
	fclose(f);

	if (-1 == rename(tmpnam, pidfilename)) {
		fprintf(stderr, "rename failed: %s -> %s \n", tmpnam, pidfilename);
		exit(EXIT_ERROR);
	}
}

int about()
{
	fprintf(stderr,
		"Usage: \n"
		"  - %s tcp <pidfile> <logfile> <portno> \n"
		"  - %s tls <pidfile> <logfile> <portno> \\ \n"
		"      <certfile> <privkeyfile> <passphrase> \\ \n"
		"      [-clicert] [-cafile <CAfilepath>] [-capath <CApath>] \n"
		"  - %s unix <pidfile> <logfile> <uxsockfile> \n",
		prognam, prognam, prognam);

	return EXIT_ERROR;
}

int main_tcp(int argc, char *argv[])
{
	int			    listen_sockfd, client_sockfd, logfile_len, switchlogfile_len, suffix, timefmtlen = 101;
	int			    accepted = 0, bytes_recv, msg_size = 0;
	char			date[timefmtlen], time_format[timefmtlen], buf[MAX_BUF_SIZE], escaped[2 * MAX_BUF_SIZE];
	struct sockaddr_in6	src, servaddr;
	socklen_t		srclen;
	time_t			curtime;
	struct tm		*timeptr;
	struct sigaction	listener_term_handler;

	/* Open log file for logging */
	if (1 != open_logfile(argv[LOGFILE]))
		return EXIT_ERROR;	/* Something went wrong when opening log file */

	/* Set signal handler */
	memset(&listener_term_handler, 0, sizeof(struct sigaction));
	listener_term_handler.sa_handler = listener_signal_handler;
	listener_term_handler.sa_flags = 0;
	sigaction(SIGINT, &listener_term_handler, NULL);
	sigaction(SIGTERM, &listener_term_handler, NULL);
	sigaction(SIGHUP, &listener_term_handler, NULL);

	/* Create socket to start listening */
	listen_sockfd = socket(AF_INET6, SOCK_STREAM, 0);
	if (-1 == listen_sockfd)
	{
		perror("socket");
		return EXIT_ERROR;
	}

	/* Initialize address to bind the socket to */
	memset(&servaddr, 0, sizeof(servaddr));
	servaddr.sin6_family = AF_INET6;
	servaddr.sin6_port = htons(atoi(argv[PORTNO]));
	memcpy(&servaddr.sin6_addr, &in6addr_any, sizeof(in6addr_any));
	if (0 != bind(listen_sockfd, (struct sockaddr *)&servaddr, sizeof(servaddr)))
	{
		perror("bind");
		return EXIT_ERROR;
	}

	if (0 != listen(listen_sockfd, BACKLOG))
	{
		perror("listen");
		return EXIT_ERROR;
	}

	save_pidfile();

	while (!terminate)
	{
		if ((0 < logfileswitch) && (0 == switch_logfile(logfile)))
			logfileswitch = 0;

		if (!accepted)
		{	/* If we have not accepted a connection, then attempt to accept one */
			srclen = sizeof(src);
			client_sockfd = accept(listen_sockfd, (struct sockaddr *)&src, &srclen);
			if (0 > client_sockfd)
			{
				if (EINTR != errno)
					perror("accept");
				continue;
			}
			accepted = 1;
		}

		msg_size = 0;

		/* TCP sockets may take several recv's to get the entire message */
		while (1)
		{
			bytes_recv = recv(client_sockfd, buf + msg_size, MAX_BUF_SIZE - msg_size - 1, 0);
			if (-1 == bytes_recv)
			{
				if (EINTR == errno)
					continue;
				else
					perror("recv");
			}
			if (0 == bytes_recv)
				break;
			if (0 < bytes_recv)
				msg_size += bytes_recv;
		}

		if (0 < msg_size)
		{	/* We've received message from client, log it */
			buf[msg_size] = '\0';
			time(&curtime);
			timeptr = gmtime(&curtime);
			strftime(date, 100, "%Y-%m-%d %H:%M:%S", timeptr);
			memset(escaped, 0, sizeof(escaped));
			escape_string(buf, escaped, msg_size);
			fprintf(stderr, "%s; %s\n", date, buf);
		}

		/* Client disconnected or closed socket */
		if (-1 == close(client_sockfd))
		{
			if (EINTR != errno)
				perror("close");
		}
		accepted = 0;
	}

	if (-1 == close(listen_sockfd))
		perror("Failed to close listener socket");
	return EXIT_ERROR;
}

/* Set default password for certificate/key (More info on this function can be found in OpenSSL documentation) */
int pem_passwd_cb(char *buf, int size, int rwflag, void *userdata)
{
	assert(NULL != buf);
	strncpy(buf, pass, size);
	buf[size - 1] = '\0';
	return(strlen(buf));
}

SSL_CTX *ssl_context_init(char *certfile, char *privkeyfile, char *cafile, char *capath, int req_clicert)
{
	SSL_CTX		*context;

	ERR_clear_error();	/* Empty the current thread's SSL error queue */
	/* Create a new SSL context */
#if OPENSSL_VERSION_NUMBER >= 0x10100000L
	context = SSL_CTX_new(TLS_method());
#else
	context = SSL_CTX_new(SSLv23_server_method());
#endif

	if (NULL == context)
	{
		ERR_print_errors_fp(stderr);
		return NULL;
	}

	/* Set desired SSL options */
	SSL_CTX_set_options(context, SSL_OP_NO_SSLv2 | SSL_OP_NO_SSLv3 | SSL_OP_NO_COMPRESSION);

	if (req_clicert)
	{	/* Set to request for client certificate during handshake */

		SSL_CTX_set_verify_depth(context, VERIFY_DEPTH);
		SSL_CTX_set_verify(context, SSL_VERIFY_PEER | SSL_VERIFY_FAIL_IF_NO_PEER_CERT, NULL);

		ERR_clear_error();
		if (1 != SSL_CTX_set_session_id_context(context, (unsigned char*)SESSION_ID_DEFAULT, strlen(SESSION_ID_DEFAULT)))
		{
			ERR_print_errors_fp(stderr);
			SSL_CTX_free(context);
			return NULL;
		}
	}

	if ((NULL != cafile) || (NULL != capath))
	{
		ERR_clear_error();
		if(1 != SSL_CTX_load_verify_locations(context, cafile, capath))
		{
			ERR_print_errors_fp(stderr);
			SSL_CTX_free(context);
			return NULL;
		}
	}

	ERR_clear_error();
	/* Give OpenSSL our certificate and private key */
	if (1 != SSL_CTX_use_certificate_file(context, certfile, SSL_FILETYPE_PEM))
	{
		ERR_print_errors_fp(stderr);
		SSL_CTX_free(context);
		return NULL;
	}

	SSL_CTX_set_default_passwd_cb(context, pem_passwd_cb);

	ERR_clear_error();
	if (1 != SSL_CTX_use_PrivateKey_file(context, privkeyfile, SSL_FILETYPE_PEM))
	{
		ERR_print_errors_fp(stderr);
		SSL_CTX_free(context);
		return NULL;
	}

	ERR_clear_error();
	/* Check that the certificate (public key) and private key match */
	if (1 != SSL_CTX_check_private_key(context))
	{
		ERR_print_errors_fp(stderr);
		SSL_CTX_free(context);
		return NULL;
	}
	SSL_CTX_set_mode(context, SSL_MODE_AUTO_RETRY);		/* To avoid having to code the retries of
								 * OpenSSL calls which are sometimes required
								 */
	return context;
}

/* Creates listener TLS socket, starts listening for connections,
 * opens log file for logging, and finally starts accepting connections.
 * Run program with:
 * 	./program tls <logfile> <portno> <certfile> <privkeyfile> <passphrase> [-clicert] [-cafile <CAfilepath>] [-capath <CApath>]
 *
 * params:
 * 	@logfile file path of output audit log
 * 	@portno port number to listen on
 * 	@certfile file path of TLS/SSL certificate to use
 * 	@privkeyfile file path of private key to use
 * 	@passphrase password or passphrase for certificate/key
 * 	@clicert (optional) if "-clicert" is present, then logger requests for client certificate when performing the
 * 			TLS handshake with GT.M
 * 	@CAfilepath (optional) path to file of CA certificates in PEM format (specifies the locations for SSL context,
 * 			at which CA certificates for verification purposes are located)
 * 	@CApath (optional) path to directory containing CA certificates in PEM format (specifies the locations for SSL context,
 * 			at which CA certificates for verification purposes are located)
 * returns:
 * 	1 if program executed successfully and exited (terminated)
 * 	0 if something went wrong and program exited
 */
int main_tls(int argc, char *argv[])
{
	int			pass_len, arg, req_clicert = 0, listen_sockfd, client_sockfd, accepted = 0, status, logfile_len, timefmtlen = 101;
	char			buf[MAX_BUF_SIZE], escaped[2 * MAX_BUF_SIZE], date[timefmtlen], time_format[timefmtlen];
	char			*opt_str = NULL, *val_str = NULL, *cafile = NULL, *capath = NULL;
	SSL_CTX			*ssl_ctx;
	SSL			*ssl_conn;
	socklen_t		srclen;
	struct stat     	fs;
	time_t			curtime, switchtime;
	struct tm		*timeptr;
	struct sockaddr_in6 	src, servaddr;
	struct sigaction	listener_term_handler;
	struct sigaction	ignore;

	/* Initialize the SSL/TLS library, the algorithms/cipher suite and error strings. */
#if OPENSSL_VERSION_NUMBER >= 0x10100000L
	/* The following options are initialzied by default:
	 * 	OPENSSL_INIT_LOAD_CRYPTO_STRINGS
	 * 	OPENSSL_INIT_ADD_ALL_CIPHERS
	 * 	OPENSSL_INIT_ADD_ALL_DIGESTS
	 *	OPENSSL_INIT_LOAD_CONFIG as of 1.1.1 - second parameter is path to file; NULL means OS default
	 *	OPENSSL_INIT_ASYNC
	 *
	 * The following are manually added:
	 * 	OPENSSL_INIT_NO_ATEXIT - suppress OpenSSL's "atexit" handler (new OpenSSL 3.0)
	 */
#	ifndef OPENSSL_INIT_NO_ATEXIT
#	define OPENSSL_INIT_NO_ATEXIT 0
#	endif
#	define GTMTLS_STARTUP_OPTIONS	(OPENSSL_INIT_NO_ATEXIT)
	if (!OPENSSL_init_ssl(GTMTLS_STARTUP_OPTIONS, NULL))
	{
		perror("OpenSSL library initialization failed");
		return EXIT_SSL_ERROR;
	}
#else
	/* Initialize the SSL/TLS library, the algorithms/cipher suite and error strings. */
	SSL_library_init();
	SSL_load_error_strings();
	ERR_load_BIO_strings();
	OpenSSL_add_all_algorithms();
#endif
	/* Initialize passphrase string */
	pass_len = strlen(argv[PASSPHRASE]);
	pass = (char *)malloc(pass_len + 1);
	strncpy(pass, argv[PASSPHRASE], pass_len);
	pass[pass_len] = '\0';
	if (NUM_REQUIRED_ARGS < argc)
	{	/* Optional arguments provided - parse them */
		arg = NUM_REQUIRED_ARGS;
		while (argc > arg)
		{
			opt_str = argv[arg];
			if ((NULL == opt_str) || ('-' != *opt_str))
			{	/* No '-' was found - parse error */
				about();
				free(pass);
				return EXIT_ERROR;
			}
			opt_str++;	/* Increment pass the '-' */
			if ((NULL == opt_str) || ('\0' == *opt_str))
			{
				about();
				free(pass);
				return EXIT_ERROR;
			}
			if (0 == strcasecmp(ARG_CLICERT, opt_str))
			{
				req_clicert = 1;
				arg++;
				continue;
			}
			val_str = argv[++arg];	/* Grab value of option */
			if ((argc <= arg) || (NULL == val_str) || ('\0' == *val_str))
			{	/* A value for the option is not provided */
				about();
				free(pass);
				return EXIT_ERROR;
			}
			else if (0 == strcasecmp(ARG_CAFILE, opt_str))
				cafile = val_str;
			else if (0 == strcasecmp(ARG_CAPATH, opt_str))
				capath = val_str;
			else
			{	/* Parse error */
				about();
				free(pass);
				return EXIT_ERROR;
			}
			arg++;
		}
	}

	/* Create SSL context */
	ssl_ctx = ssl_context_init(argv[CERTFILE], argv[PRIVKEYFILE], cafile, capath, req_clicert);
	if (NULL == ssl_ctx)
	{	/* Could not create SSL context - no need to throw error because ssl_context_init() already did */
		free(pass);
		return EXIT_SSL_ERROR;
	}
	/* Open logfile for logging */
	if (1 != open_logfile(argv[LOGFILE]))
	{
		free(pass);
		return EXIT_ERROR;	/* Something went wrong when opening log file */
	}
	terminate = 0;

	/* Ignore signals as needed */
	memset(&ignore, 0, sizeof(struct sigaction));
	ignore.sa_handler = SIG_IGN;
	ignore.sa_flags = 0;
	sigaction(SIGPIPE, &ignore, NULL);			/* Handle SIGPIPE */

	/* Set signal handler */
	memset(&listener_term_handler, 0, sizeof(struct sigaction));
	listener_term_handler.sa_handler = listener_signal_handler;
	listener_term_handler.sa_flags = 0;
	sigaction(SIGINT, &listener_term_handler, NULL);	/* Handle Ctrl + C */
	sigaction(SIGTERM, &listener_term_handler, NULL);	/* Handle kill -15 */
	sigaction(SIGHUP, &listener_term_handler, NULL);	/* Handle kill -1  */

	/* Create socket to start listening */
	listen_sockfd = socket(AF_INET6, SOCK_STREAM, 0);
	if (-1 == listen_sockfd)
	{
		perror("socket");
		SSL_CTX_free(ssl_ctx);
		free(pass);
		return EXIT_SSL_ERROR;
	}

	/* Initialize the address to bind our socket to */
	memset(&servaddr, 0, sizeof(servaddr));
	servaddr.sin6_family = AF_INET6;
	servaddr.sin6_port = htons(atoi(argv[PORTNO]));
	memcpy(&servaddr.sin6_addr, &in6addr_any, sizeof(in6addr_any));
	if (0 != bind(listen_sockfd, (struct sockaddr *)&servaddr, sizeof(servaddr)))
	{
		perror("bind");
		SSL_CTX_free(ssl_ctx);
		close(listen_sockfd);
		free(pass);
		return EXIT_ERROR;
	}
	if (0 != listen(listen_sockfd, BACKLOG))
	{
		perror("listen");
		SSL_CTX_free(ssl_ctx);
		close(listen_sockfd);
		free(pass);
		return EXIT_ERROR;
	}

	save_pidfile();

	while (!terminate)
	{
		if ((0 < logfileswitch) && (0 == switch_logfile(logfile)))
			logfileswitch = 0;
		if (!accepted)
		{	/* If we have not accepted a connection, then attempt to accept one */
			srclen = sizeof(src);
			client_sockfd = accept(listen_sockfd, (struct sockaddr *)&src, &srclen);
			if (0 > client_sockfd)
			{
				if (EINTR != errno)
					perror("accept");
				continue;
			}
#			if DEBUG
			time(&curtime);
			timeptr = gmtime(&curtime);
			strftime(date, 100, "%Y-%m-%d %H:%M:%S", timeptr);
			fprintf(stderr, "%s; attempting to accept\n", date);
#			endif
			ERR_clear_error();
			/* Create a new SSL connection object */
			ssl_conn = SSL_new(ssl_ctx);
			if (NULL == ssl_conn)
			{
				ERR_print_errors_fp(stderr);
				close(client_sockfd);
				fprintf(stderr, "%s; failed at SSL_new\n", date);
				continue;
			}
			ERR_clear_error();
			/* Attach the SSL connection object to our socket */
			if (1 != SSL_set_fd(ssl_conn, client_sockfd))
			{
				ERR_print_errors_fp(stderr);
				SSL_free(ssl_conn);
				close(client_sockfd);
				fprintf(stderr, "%s; failed at SSL_set_fd\n", date);
				continue;
			}
			ERR_clear_error();
			/* Try to complete the SSL/TLS handshake */
			if (1 != SSL_accept(ssl_conn))
			{
				ERR_print_errors_fp(stderr);
				SSL_free(ssl_conn);
				close(client_sockfd);
				fprintf(stderr, "%s; failed at SSL_accept\n", date);
				continue;
			}
			accepted = 1;
#			if DEBUG
			time(&curtime);
			timeptr = gmtime(&curtime);
			strftime(date, 100, "%Y-%m-%d %H:%M:%S", timeptr);
			fprintf(stderr, "%s; connection accepted\n", date);
#			endif
		}
		if (0 < (status = SSL_read(ssl_conn, buf, MAX_BUF_SIZE - 1)))
		{	/* Received message from client */
			buf[status] = '\0';
			time(&curtime);
			timeptr = gmtime(&curtime);
			strftime(date, 100, "%Y-%m-%d %H:%M:%S", timeptr);
			memset(escaped, 0, sizeof(escaped));
			escape_string(buf, escaped, status);
			fprintf(stderr, "%s; %s\n", date, buf);
		}
		SSL_shutdown(ssl_conn);
		/* Free the SSL connection and close socket */
		SSL_free(ssl_conn);
		close(client_sockfd);
		accepted = 0;
	}
#	if DEBUG
	time(&curtime);
	timeptr = gmtime(&curtime);
	strftime(date, 100, "%Y-%m-%d %H:%M:%S", timeptr);
	fprintf(stderr, "%s; exiting\n", date);
#	endif
	SSL_CTX_free(ssl_ctx);
	close(listen_sockfd);
	free(pass);
	return EXIT_OK;
}

/* Loops infinitely, accepts all connections, and logs received messages
 *
 * params:
 * 	@fd file descriptor of socket to accept connections on
 * returns:
 *	1 if finished listening (terminated)
 *	0 if something went wrong
 */
int unix_listen_loop(int fd)
{
	int			clifd, length, logfile_len, switchlogfile_len, suffix, timefmtlen = 101, tempfd;
	char			buf[MAX_BUF_SIZE], escaped[2 * MAX_BUF_SIZE], date[timefmtlen], time_format[timefmtlen];
	struct sockaddr_un	client = {0};
	struct tm		*timeptr;
	struct stat     	fs;
	time_t			curtime;
	socklen_t		cli_len;

	while (!terminate)
	{
		cli_len = sizeof(client);
		clifd = accept(fd, (struct sockaddr *) &client, &cli_len);
		if (0 > clifd)
		{
			if (EINTR != errno)
			{
				perror("accept");
				continue;
			}
		}
		if (0 < logfileswitch)
		{
			if ((0 < logfileswitch) && (0 == switch_logfile(logfile)))
				logfileswitch = 0;
		} else
		{
			length = recv(clifd, buf, sizeof(buf) - 1, 0);
			if (-1 == length)
			{
				if (EINTR == errno)
					continue;
				else if (EBADF != errno)
					perror("recv");
			}
			if (0 < length)
			{	/* Received message from client, so log it */
				time(&curtime);
				timeptr = gmtime(&curtime);
				strftime(date, 100, "%Y-%m-%d %H:%M:%S", timeptr);
				memset(escaped, 0, sizeof(escaped));
				escape_string(buf, escaped, length);
				fprintf(stderr, "%s; %s\n", date, escaped);
			}
			close(clifd);
		}
	}
	return EXIT_OK;
}

/* Creates listener UNIX socket, starts listening for connections,
 * opens log file for logging, and finally starts accepting connections.
 */
int main_unix(int argc, char *argv[])
{
	int			fd;
	struct sockaddr_un	addr = {0};
	struct sigaction	listener_term_handler;

	/* Open log file for logging */
	if (1 != open_logfile(argv[LOGFILE]))
		return EXIT_ERROR;	/* Something went wrong when opening log file */
	terminate = 0;

	/* Set signal handler */
	memset(&listener_term_handler, 0, sizeof(struct sigaction));
	listener_term_handler.sa_handler = listener_signal_handler;
	listener_term_handler.sa_flags = 0;
	sigaction(SIGINT, &listener_term_handler, NULL);	/* Handle Ctrl + C */
	sigaction(SIGTERM, &listener_term_handler, NULL);	/* Handle kill -15 */
	sigaction(SIGHUP, &listener_term_handler, NULL);	/* Handle kill -1  */

	/* Create socket to start listening */
	fd = socket(AF_UNIX, SOCK_STREAM, 0);
	if (-1 == fd)
	{
		perror("Failed to create socket");
		return EXIT_ERROR;
	}
	addr.sun_family = AF_UNIX;
	strncpy(addr.sun_path, argv[SOCKFILE], sizeof(addr.sun_path) - 1);
	unlink(argv[SOCKFILE]);
	if (-1 == bind(fd, (struct sockaddr *)&addr, sizeof(addr)))
	{
		fprintf(stderr, "Failed to bind socket %s: %s\n", argv[SOCKFILE], strerror(errno));
		return EXIT_ERROR;
	}
	chmod(argv[SOCKFILE], 0666);
	if (-1 == listen(fd, BACKLOG))
	{
		perror("Failed to listen");
		return EXIT_ERROR;
	}

	save_pidfile();

	if (1 != unix_listen_loop(fd))
		return EXIT_ERROR;

	if (-1 == close(fd))
	{
		perror("Failed to close");
		return EXIT_ERROR;
	}

	return EXIT_OK;
}

int main(int argc, char* argv[])
{
	int exit_code = 0;
	strip_prognam(argv[PROGNAME]);
	pidfilename = argv[PIDFILE];

	if (argc < 2)
	{
		exit_code = about();
	}
	else if (0 == strcasecmp(argv[PROG_VARIATION], "tcp"))
	{
		if (5 > argc)
		{
			exit_code = about();
		}
		else
		{
			exit_code = main_tcp(argc, argv);
		}
	}
	else if (0 == strcasecmp(argv[PROG_VARIATION], "tls"))
	{
		if (NUM_REQUIRED_ARGS > argc)
		{
			exit_code = about();
		}
		else
		{
			exit_code = main_tls(argc, argv);
		}
	}
	else if (0 == strcasecmp(argv[PROG_VARIATION], "unix"))
	{
		if (5 > argc)
		{
			exit_code = about();
		}
		else
		{
			exit_code = main_unix(argc, argv);
		}
	} else {
		exit_code = about();
	}

	return exit_code;
}
