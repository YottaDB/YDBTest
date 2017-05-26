/****************************************************************
 *								*
 * Copyright (c) 2002-2015 Fidelity National Information	*
 * Services, Inc. and/or its subsidiaries. All rights reserved.	*
 *								*
 *	This source code contains the intellectual property	*
 *	of its copyright holder(s), and is made available	*
 *	under a license.  If you do not know the terms of	*
 *	the license, please stop and do not read further.	*
 *								*
 ****************************************************************/
#include "shrenv.h"
GTM64_ONLY(void *gtm_malloc(unsigned long);)

#ifdef NeedInAddrPort
typedef unsigned int in_addr_t;
#endif
/* this function implements host/directory to global directory
translation
 * for GTM */

/* assume we're under Unix unless we're explicitly under VMS */
#ifndef __vms
#ifndef unix
#define unix
#endif
#endif

#include "gtm_stdio.h"
#include "gtm_stdlib.h"
#include <unistd.h>
#include "gtm_string.h"
#ifndef __vms
#include "gtm_strings.h"
#endif

#ifdef __vms
# ifdef MULTINET
typedef unsigned long in_addr_t;
#  include "multinet_root:[multinet.include.sys]types.h"
#  include "multinet_root:[multinet.include.sys]socket.h"
#  include "multinet_root:[multinet.include.netinet]in.h"
#  include "multinet_root:[multinet.include]netdb.h"
# else   /* not MultiNet == UCX */
#  include <types.h>
#  include <socket.h>
#  include <in.h>
#  include <netdb.h>
# endif  /* MULTINET */
#else   /* not VMS == Unix */
# include <sys/types.h>
# include <sys/socket.h>
# include <netinet/in.h>
# include <netdb.h>
# include <arpa/inet.h>
#endif  /* __vms */

#ifdef unix
# include <sys/stat.h>
#endif

#ifdef NEED_VARARGS
# include <varargs.h>
#else
# include <stdarg.h>
#endif

#if defined(__vms) || defined(__MVS__)
# define MAXPATHLEN       FILENAME_MAX
# define MAXHOSTNAMELEN   256
# ifdef __vms
#  if __VMS_VER < 70000000
#   define bcopy(src,dst,len)   (void)memmove(dst,src,len)
#  endif
# endif
#else
# include <sys/param.h>
#endif

#include <errno.h>

#ifndef STANDALONE
# include "gtmxc_types.h"
#endif

/* C really needs a boolean type ... */
typedef unsigned char boolean;

#ifndef FALSE
# define FALSE   (boolean)0
#endif

#ifndef TRUE
# define TRUE    (boolean)(! FALSE)
#endif

/* for str[n][case]cmp() */
#define EQUAL   0

#ifndef NULL
# define NULL   0
#endif

/* a minimum "function" */
#define min(a, b)   ((a) < (b) ? (a) : (b))

#ifdef STANDALONE
typedef struct { int length; char *address; } xc_string_t;
# ifdef __vms
#  include <types.h>
# else
#  include <sys/types.h>
# endif
GTM64_ONLY(#define GTM_MALLOC   gtm_malloc)
NON_GTM64_ONLY(#define GTM_MALLOC  malloc)
# define GTM_FREE     free
#endif

/* localhost in convenient xc_string_t garb */
static xc_string_t localhost = { sizeof("localhost") - 1, "localhost" };

/* where to find the translation table file (in Unix, this is an environment
 * variable - in VMS, this is a logical name) */
#define XLATE_FILE   "gtm_gblxlate"

/*
 * structure to hold translation table entries:
 *
 * the way our customer uses this mechanism, the first argument is a directory
 * path and the second argument is a host name.  the translation table specifies
 * the GTM global directory that is specific to the combination of
 * the given arguments.
 *
 * generally, host names are short, while directories are rather longer.
 * isolating the host name allows a small number of relatively short comparisons
 * to eliminate a large percentage of the total entries fairly
 * quickly (assuming each host has roughly similar numbers of directories).
 * this also allows us to use the IP address to sort out different forms of
 * the same host name ("foo" vs. "foo.com", e. g., or CNAMEs).
 *
 * we then locate the directory with a binary tree search.  the rationale
 * here is that the hosts may tend to have the same directory structure,
 * which means that a hash table would have frequent collisions.  we could
 * avoid this by making the host be part of the hash, but we need to look
 * for the host separately in order to unambiguously identify hosts by
 * their IP address.
 *
 * note that, while we organize the database by host, we do not require
 * the external data file to be so ordered.
 *
 * the data file format is:
 *
 * directory	host	<global directory file>
 *
 * columns are delimited by any number of spaces and/or tabs.
 */

/* the directory binary tree entries */
struct tblent
{
	struct tblent *left, *right;
	xc_string_t directory;
	xc_string_t gbldir;
};

/* the binary tree of host names (organized by host name, but the IP address
 * is the real key) */
static struct hosts
{
	struct hosts *left, *right;
	xc_string_t hostname;
	in_addr_t ipaddr;
	struct tblent *dirtable;
} *host_tree = (struct hosts *)NULL;

/* our own entry in the hosts tree */
static struct hosts *our_host = (struct hosts *)NULL;

/* flag whether we are permanently and irretrievably broken or not */
static boolean broken_flag = FALSE;

/* buffer to format response or error text */
#define MSGBUFSIZE   4096
static char msgbuf[MSGBUFSIZE + 1];

/* an xc_string_t that points to the output buffer */
static xc_string_t outbuff = { MSGBUFSIZE, msgbuf };

/* current working directory */
static char curdir[MAXPATHLEN + 1];
static xc_string_t curdir_xc = { 0, curdir };

#ifndef STANDALONE
/* get the correct addresses for GTM_MALLOC and GTM_FREE */
# define CALLIN_ENV_VAR   "GTM_CALLIN_START"
GTM64_ONLY(typedef long  (*int_fptr)();)
NON_GTM64_ONLY(typedef int (*int_fptr)();)
static int_fptr GTM_MALLOC;
static int_fptr GTM_FREE;
#endif

/* forward declarations */
static int initialize(xc_string_t *);
#ifndef STANDALONE
static int init_functable(xc_string_t *);
#endif
static boolean read_dir_table(xc_string_t *);
static boolean save_table_entry(char *, in_addr_t, char *, char *, xc_string_t *);
static struct hosts *save_host(char *, in_addr_t, struct tblent *, xc_string_t *);
static boolean dir_tree_insert(struct tblent *, struct tblent *);
static struct hosts *lookup_host_xc(xc_string_t *, struct hosts *);
static struct hosts *lookup_host(char *, struct hosts *);
static struct hosts *find_host_by_ip(in_addr_t, struct hosts *);
static boolean host_tree_insert(struct hosts *, struct hosts *);
static struct tblent *dir_tree_search(struct tblent *, xc_string_t *);
static in_addr_t get_ip_addr(char *);
static boolean is_file(xc_string_t *);
static int stringcmp(xc_string_t *, xc_string_t *);
static int stringcasecmp(xc_string_t *, xc_string_t *);
static xc_string_t *stringcpy(xc_string_t *, xc_string_t *);
static size_t msg(xc_string_t *, char *, ...);

#ifdef STANDALONE
/* response buffer descriptor */
static xc_string_t response;
int gtm_env_xlate(xc_string_t *, xc_string_t *, xc_string_t *, xc_string_t *);

/* ARGSUSED */

main(argc, argv)

int argc;
char *argv[];

{
	xc_string_t host, dir;
	int retval;

	host.length = strlen(argv[1]);
	host.address = argv[1];

	dir.length = strlen(argv[2]);
	dir.address = argv[2];

	retval = gtm_env_xlate(&dir, &host, &host, &response);

	if (retval == 0)
		if (response.length == 0)
			PRINTF("translation of %s:%s returns empty string\n", argv[1], argv[2]);
		else
			PRINTF("location of %s:%s is %s\n", argv[1], argv[2], response.address);
	else
		PRINTF("translation error %d:  %s\n", retval, response.address);

	exit(0);
}
#endif

/* translate a directory and node into a path to a global directory (a
file) */

int gtm_env_xlate(dir, host, zdir, outptr)
xc_string_t *dir, *host, *zdir;
xc_string_t *outptr;
{
#ifdef notdef
	int i;
	xc_string_t tmparg;
#endif
	struct hosts *hoststr;
	boolean our_host_flag;
	struct tblent *node;
	char *char_res;
/* set up the output pointer */
	*outptr = outbuff;
/* if we're permanently broken, do nothing */
	if (broken_flag)
	{
		/* return with an error */
		(void)msg(outptr, "Environment translation service is broken");
		return -1;
	}
/* if we don't know our host name, this must be the first call, so do a
 * bunch of initialization */
	if (our_host == (struct hosts *)NULL)
		if (initialize(outptr) < 0)
			return -1;

#ifdef notdef
/* if the second string is NULL, watch out for the possibility that the first
 * string is a comma-delimited pair */
	if (host == (xc_string_t *)NULL)
		for (i = 0; i < dir->length; i++)
			if (dir->address[i] == ',')
			{
				/* generate the second argument from the remainder of the string */
				tmparg.address = &dir->address[i + 1];
				tmparg.length = dir->length - (i + 1);
				host = &tmparg;
				/* cut off the first string before the comma */
				dir->length = i;
				break;
			}
#endif

/* an empty or NULL directory means the current directory */
	if ((dir == (xc_string_t *)NULL) || (dir->length == 0))
		if (getcwd(curdir, sizeof(curdir)) == (char *)NULL)
		{
			(void)msg(outptr, "Failed to get current working directory");
			return -1;
		} else
		{
			curdir_xc.length = strlen(curdir);
			dir = &curdir_xc;
		}

#ifdef unix
	/* strip a trailing slash, if any (but not the root slash) */
	if ((dir->length > 1) && (dir->address[dir->length - 1] == '/'))
		dir->address[--(dir->length)] = '\0';
#endif

/*
 * the next bit of logic requires some explanation - if the host is unspeci-
 * fied, or is an empty string, we default to our own host (which may or may
 * not have any entries in the translation table).  the given hostname may
 * be "localhost", which we treat as a synonym for our host name. otherwise,
 * we use the given host name (which, to complicate things still farther,
 * might just be a CNAME, whether for our host or some other host, which is
 * why we build the host tree using IP addresses)
 *
 * if the host name is our own (or "localhost"), the first argument may be a
 * global directory file already, so that no translation is needed
 */

	/* see if the hostname is defaulted */
	hoststr = (struct hosts *)NULL;
	if ((host == (xc_string_t *)NULL) || (host->length == 0))
	{
		/* we have met the enemy and he is us */
		hoststr = our_host;
		our_host_flag = TRUE;
	} else
	{
		/* this might be "localhost" */
		if (stringcasecmp(host, &localhost) == EQUAL)
			/* it is; change it to our own host name */
			host = &our_host->hostname;

		/* find this host and check its IP address to see if it is us */
		hoststr = lookup_host_xc(host, host_tree);
		if (hoststr == (struct hosts *)NULL) {
			/* this host is not in the translation table - fail */
			(void)msg(outptr, "No translation available");
			return -1;
		} else
			if (hoststr->ipaddr == our_host->ipaddr)
				our_host_flag = TRUE;
			else
				our_host_flag = FALSE;
	}

/* if this request is for the local node, check the path to see if it is a
 * file already */
	if (our_host_flag)
		if (is_file(dir))
		{
			/* it's a file - presume it is a global directory already */
			(void)stringcpy(outptr, dir);
			return 0;
		} else
			/* if our host has no directory entries, this reference fails */
			if (our_host->dirtable == (struct tblent *)NULL)
			{
				(void)msg(outptr, "No local host translation available");
				return -1;
			}

/* find the matching directory entry for this host */
	node = dir_tree_search(hoststr->dirtable, dir);

/* if we found an entry, return it; otherwise, return in error */
	if (node == (struct tblent *)NULL)
	{
		(void)msg(outptr, "No translation available");
		return -1;
	} else
	{
		(void)stringcpy(outptr, &node->gbldir);
		return 0;
	}

/* NOTREACHED */
}



/* initialize ourself on the first call */

static int initialize(msgptr)

xc_string_t *msgptr;

{
	char hostname[MAXHOSTNAMELEN + 1];
	in_addr_t host_ipaddr;
	int int_res;

#ifndef STANDALONE
/* get the GTM_MALLOC and GTM_FREE function addresses */
	if (init_functable(msgptr) < 0)
	{
		/* flag that we are permanently broken */
		broken_flag = TRUE;
		return -1;
	}
#endif
/* get our host name */
	if (gethostname(hostname, MAXHOSTNAMELEN) < 0)
	{
		/* flag that we are permanently broken */
		broken_flag = TRUE;
		/* return with an error */
		(void)msg(msgptr, "Failed to get our host name (%d) - %s",
			  errno, STRERROR(errno));
		return -1;
	}
/* get our IP address */
	if ((host_ipaddr = get_ip_addr(hostname)) == (in_addr_t)0)
	{
		/* flag that we are permanently broken */
		broken_flag = TRUE;
		/* return with an error */
		(void)msg(msgptr, "Failed to get our IP address for our host name %s", hostname);
		return -1;
	}
	/* chop the host at the first dot (we do this for consistency, since some
	 * machines will return a hostname and others an FQDN; this way, regard-
	 * less of the contents of the translation file, the non-FQDN host name
	 * always appears in our internal database) */
	(void)strtok(hostname, ".");
/* seed the translation database with our own host name, so "localhost"
 * always has something to match */
	if ((our_host = save_host(hostname, host_ipaddr, (struct tblent *)NULL, msgptr)) == (struct hosts *)NULL)
	{
		/* flag that we are permanently broken */
		broken_flag = TRUE;
		/* return in error */
		return -1;
	}
/* we don't have a translation table yet, so read it in */
	if (read_dir_table(msgptr))
		;
	else
	{
		/* flag that we are permanently broken */
		broken_flag = TRUE;
		/* return in error */
		return -1;
	}
/* gosh, everything worked ... */
	return 0;
}

/* read in the directory/host translation table */

static char tblbuf[BUFSIZ];
static char recbuf[BUFSIZ];


static boolean read_dir_table(errmsg)

xc_string_t *errmsg;

{
	char *pathptr;
	FILE *dirfile;
	char *dirptr;
	char *host;
	in_addr_t ip_addr;
	char *gblptr;
	char *char_res;

#ifdef __vms
/* point to the translation file specification */
	pathptr = XLATE_FILE;
#else
/* translate the requisite environment variable to find the file */
	if ((pathptr = GETENV(XLATE_FILE)) == (char *)NULL)
	{
		(void)msg(errmsg, "Cannot translate environment variable %s", XLATE_FILE);
		return FALSE;
	}
#endif

/* open the translation file read-only */
	Fopen(dirfile, pathptr, "r");
	if ((FILE *)NULL == dirfile)
	{
		(void)msg(errmsg, "Cannot open translation file %s (%d) - %s", pathptr, errno, STRERROR(errno));
		return FALSE;
	}

/* loop reading the translation file entries */
	while (fgets(tblbuf, (int)sizeof(tblbuf), dirfile) != (char *)NULL)
	{
		/* skip comment lines */
		if (tblbuf[0] == '#')
			continue;

/* get the directory, being wary of blank lines */
		if ((dirptr = strtok(tblbuf, " \t\n")) == (char *)NULL)
			/* must be a blank line - just ignore it */
			continue;

		/* save the record for error messages */
		strcpy(recbuf, tblbuf);

/* get the host */
		if ((host = strtok((char *)NULL, " \t")) == (char *)NULL)
		{
			(void)msg(errmsg, "No host in translation table record %s", recbuf);
			return FALSE;
		}

		/* to ensure validity, get its IP address */
		if ((ip_addr = get_ip_addr(host)) == (in_addr_t)0)
		{
			(void)msg(errmsg, "Can't get IP address for host in %s", recbuf);
			return FALSE;
		}

/* get the global directory filename */
		if ((gblptr = strtok((char *)NULL, " \t\n")) == (char *)NULL)
		{
			(void)msg(errmsg, "No global directory file in translation table record %s", recbuf);
			return FALSE;
		}

/* save the table entry in the database */
		if (save_table_entry(host, ip_addr, dirptr, gblptr, errmsg))
			;
		else
			return FALSE;
	}

/* if we really got an EOF, we're fine */
	if (feof(dirfile))
		return TRUE;
	else
	{
		(void)msg(errmsg, "Error reading translation file %s", pathptr);
		return FALSE;
	}

/* NOTREACHED */
}



/* save the given table entry in our in-core database - the only tricky bit
 * here is that if the host name does not translate to an IP address, we fake
 * success rather than yielding an error; this is so that a bogus hostname in
 * the translation file doesn't prevent all MUMPS programs from working
*/

static boolean save_table_entry(hostname, ip_addr, dir, gblpath, errmsg)

char *hostname;
in_addr_t ip_addr;
char *dir;
char *gblpath;
xc_string_t *errmsg;

{
	struct hosts *host;
	struct hosts *althost;
	struct tblent *dirtable;
	struct tblent *direntry;
	size_t len;

/* if the host name is "localhost", use our name instead */
	if (STRCASECMP(hostname, "localhost") == EQUAL)
		hostname = our_host->hostname.address;

/* find the host node in the host list */
	host = lookup_host(hostname, host_tree);

/* if we don't have this name, add it to the host tree */
	if (host == (struct hosts *)NULL)
	{
		/* if we already know about this IP address, add this entry to the
		 * existing directory table */
		althost = find_host_by_ip(ip_addr, host_tree);
		if (althost == (struct hosts *)NULL)
			dirtable = (struct tblent *)NULL;
		else
			dirtable = althost->dirtable;

		/* add this host to the tree */
		if ((host = save_host(hostname, ip_addr, dirtable, errmsg)) == (struct hosts *)NULL)
			return FALSE;
	}
/* if this is a dummy entry, skip adding it to the directory tree */
	if (STRCASECMP(dir, "dummy") == EQUAL)
		/* return success, of a sort */
		return TRUE;
/* allocate space for this table entry */
	if ((direntry = (struct tblent *)GTM_MALLOC(sizeof(struct tblent))) == (struct tblent *)NULL)
	{
		(void)msg(errmsg, "Failed to allocate %d bytes for table memory", sizeof(struct tblent));
		return FALSE;
	}
	/* it's guaranteed to be a leaf node ... */
	direntry->left = direntry->right = (struct tblent *)NULL;
/* get the directory name length */
	len = strlen(dir);

	/* strip a trailing slash, if any (but not the root slash) */
	if ((len > 1) && (dir[len - 1] == '/'))
		dir[--len] = '\0';
/* save the directory in the table entry */
	if ((direntry->directory.address = (char *)GTM_MALLOC(len + 1)) == (char *)NULL)
	{
		(void)msg(errmsg, "Failed to allocate %d bytes for directory from %s", len + 1, recbuf);
		/* free the partially-filled directory entry */
		(void)GTM_FREE(direntry);
		return FALSE;
	} else
	{
		strcpy(direntry->directory.address, dir);
		direntry->directory.length = (int)len;
	}
/* save the global directory file in the table entry */
	len = strlen(gblpath);
	if ((direntry->gbldir.address = (char *)GTM_MALLOC(len + 1)) == (char *)NULL)
	{
		(void)msg(errmsg, "Failed to allocate %d bytes for filename from %s", len + 1, recbuf);
		/* free the partially-filled directory entry */
		(void)GTM_FREE(direntry->directory.address);
		(void)GTM_FREE(direntry);
		return FALSE;
	} else
	{
		strcpy(direntry->gbldir.address, gblpath);
		direntry->gbldir.length = (int)len;
	}
/* add this entry to the host's directory tree */
	if (host->dirtable == (struct tblent *)NULL)
	{
		/* the tree is currently empty */
		host->dirtable = direntry;
		return TRUE;
	} else if (dir_tree_insert(host->dirtable, direntry))
		return TRUE;
	else
	{
		(void)msg(errmsg, "Conflicting entry %s:%s in translation file", hostname, direntry->directory.address);
		return FALSE;
	}

/* NOTREACHED */
}



/* add the given host name to the host tree */

static struct hosts *save_host(hostname, ipaddr, dirtable, errmsg)

char *hostname;
in_addr_t ipaddr;
struct tblent *dirtable;
xc_string_t *errmsg;

{
	struct hosts *host;
	size_t hostlen;

/* get a host structure for this name */
	if ((host = (struct hosts *)GTM_MALLOC(sizeof(struct hosts))) == (struct hosts *)NULL)
	{
		(void)msg(errmsg, "Failed to allocate %d bytes for host node", sizeof(struct hosts));
		return (struct hosts *)NULL;
	}

/* this will definitely be a leaf node */
	host->left = host->right = (struct hosts *)NULL;

/* save the host name */
	hostlen = strlen(hostname);
	if ((host->hostname.address = (char *)GTM_MALLOC(hostlen + 1)) == (char *)NULL)
	{
		(void)msg(errmsg, "Failed to allocate %d bytes for host name %s", hostlen + 1, hostname);
		(void)GTM_FREE(host);
		return (struct hosts *)NULL;
	} else
	{
		strcpy(host->hostname.address, hostname);
		host->hostname.length = (int)hostlen;
	}

/* save the IP address and the directory table address */
	host->ipaddr = ipaddr;
	host->dirtable = dirtable;

/* add the new host to the host tree */
	if (host_tree == (struct hosts *)NULL)
		/* adding to an empty tree is easy */
		host_tree = host;
	else
		if (host_tree_insert(host_tree, host))
			;
		else
		{
			/* this can't have failed */
			(void)msg(errmsg, "Impossible duplicate host %s in host tree", hostname);
			return (struct hosts *)NULL;
		}

/* success! */
	return host;
}

/* add this entry to the host tree */

static boolean host_tree_insert(root, entry)

struct hosts *root, *entry;

{
	int direction;

/* figure out where this entry belongs, relative to the current root */
	direction = stringcasecmp(&root->hostname, &entry->hostname);

/* insert the entry in the tree */
	if (direction < EQUAL)
		/* this node belongs in the left subtree - if it's empty, insert
		   here */
		if (root->left == (struct hosts *)NULL)
		{
			root->left = entry;
			return TRUE;
		} else
			/* left subtree not empty; keep looking for a spot */
			return host_tree_insert(root->left, entry);
	else if (direction > EQUAL)
		/* this node belongs in the right subtree - if it's empty, insert
		   here */
		if (root->right == (struct hosts *)NULL)
		{
			root->right = entry;
			return TRUE;
		} else
			/* right subtree not empty; keep looking for a spot */
			return host_tree_insert(root->right, entry);
	else
		/* matching entry is an error */
		return FALSE;

/* NOTREACHED */
}

/* add this entry to the host node's directory tree */

static boolean dir_tree_insert(root, entry)

struct tblent *root, *entry;

{
	int direction;

/* figure out where this entry belongs, relative to the current root */
#ifdef __vms
	direction = stringcasecmp(&root->directory, &entry->directory);
#else
	direction = stringcmp(&root->directory, &entry->directory);
#endif

/* insert the entry in the tree */
	if (direction < EQUAL)
		/* this node belongs in the left subtree - if it's empty, insert here */
		if (root->left == (struct tblent *)NULL)
		{
			root->left = entry;
			return TRUE;
		} else
			/* left subtree not empty; keep looking for a spot */
			return dir_tree_insert(root->left, entry);
	else if (direction > EQUAL)
		/* this node belongs in the right subtree - if it's empty, insert here */
		if (root->right == (struct tblent *)NULL)
		{
			root->right = entry;
			return TRUE;
		} else
			/* right subtree not empty; keep looking for a spot */
			return dir_tree_insert(root->right, entry);
	else
		/* matching entry is OK if the global directory is also identical */
#ifdef __vms
		if (stringcasecmp(&root->gbldir, &entry->gbldir) == EQUAL)
#else
		if (stringcmp(&root->gbldir, &entry->gbldir) == EQUAL)
#endif
			return TRUE;
		else
			return FALSE;

/* NOTREACHED */
}



/* find the host name in the host binary tree (preorder traversal) */

static struct hosts *lookup_host_xc(hostname, root)

xc_string_t *hostname;
struct hosts *root;

{
	int direction;

/* if the tree is empty, we ain't gonna find it */
	if (root == (struct hosts *)NULL)
		return (struct hosts *)NULL;
/* figure out where this entry belongs, relative to the current root */
	direction = stringcasecmp(&root->hostname, hostname);

	if (direction < EQUAL)
		/* this host must be in the left subtree */
		return lookup_host_xc(hostname, root->left);
	else if (direction > EQUAL)
		/* this host must be in the right subtree */
		return lookup_host_xc(hostname, root->right);
	else
		/* we found it! */
		return root;

/* NOTREACHED */
}



/* find the host name in the host binary tree */

static struct hosts *lookup_host(hostname, root)

char *hostname;
struct hosts *root;

{
	xc_string_t hoststr;

/* build an xc_string_t from the hostname */
	hoststr.length = strlen(hostname);
	hoststr.address = hostname;

/* search the tree for this host */
	return lookup_host_xc(&hoststr, root);
}



/* find the given IP address in the host binary tree (preorder traversal) */

static struct hosts *find_host_by_ip(addr, root)

in_addr_t addr;
struct hosts *root;

{
	struct hosts *node;

/* searching an empty tree is easy */
	if (root == (struct hosts *)NULL)
		return (struct hosts *)NULL;

/* see if the root has the correct address */
	if (root->ipaddr == addr)
		return root;

/* check the left subtree */
	node = find_host_by_ip(addr, root->left);
	if (node != (struct hosts *)NULL)
		return node;

/* check the right subtree */
	return find_host_by_ip(addr, root->right);
}

/* find the directory in the given directory tree */

static struct tblent *dir_tree_search(root, directory)

struct tblent *root;
xc_string_t *directory;

{
	int direction;

/* if the tree is empty, we ain't gonna find it */
	if (root == (struct tblent *)NULL)
		return (struct tblent *)NULL;

/* figure out where this entry belongs, relative to the current root */
#ifdef __vms
	direction = stringcasecmp(&root->directory, directory);
#else
	direction = stringcmp(&root->directory, directory);
#endif

	if (direction < EQUAL)
		/* the directory must be in the left subtree */
		return dir_tree_search(root->left, directory);
	else if (direction > EQUAL)
		/* the directory must be in the right subtree */
		return dir_tree_search(root->right, directory);
	else
		/* we found it! */
		return root;

/* NOTREACHED */
}

/* get the IP address of the given host in host byte order */
static in_addr_t get_ip_addr(hostname)

char *hostname;

{
	struct hostent *hp;
	in_addr_t addr;

/* look up the host name */
	hp = gethostbyname(hostname);
	if (hp == (struct hostent *)NULL)
		return (in_addr_t)0;

/* get the IP address */
	bcopy(hp->h_addr, (char *)&addr, sizeof(addr));

/* return the address in host byte order */
	return ntohl(addr);
}



/* return FALSE if the given path is a directory, TRUE otherwise (a
file) */

static boolean is_file(path)

xc_string_t *path;

{
	char pathname[MAXPATHLEN + 1];
	struct stat statblk;

/* make a real string from the fake one */
	strncpy(pathname, path->address, (size_t)path->length);
	pathname[path->length] = '\0';

#ifdef __vms
/* if the filespec ends in ']', it's a directory */
	if (pathname[path->length - 1] == ']')
		return FALSE;
	else
		return TRUE;
#else
/* stat the path to figure out what it is */
	if (stat(pathname, &statblk) < 0)
		/* it probably doesn't exist, in which case we pretend it's a
		   directory */
		return FALSE;

/* check the directory bit - return FALSE if this is a directory */
	if ((statblk.st_mode & S_IFDIR) == 0)
		return TRUE;
	else
		return FALSE;
#endif

/* NOTREACHED */
}



/* compare two xc_string_t strings in the manner of strcmp() */

static int stringcmp(s1, s2)

xc_string_t *s1, *s2;

{
/* if the strings are identical in length, return the result of strcmp() */
	if (s1->length == s2->length)
		return strncmp(s1->address, s2->address, (size_t)s1->length);
	else
/* otherwise, the shorter string is less than the longer one */
		return s1->length - s2->length;

/* NOTREACHED */
}



/* compare two xc_string_t strings in the manner of strcasecmp() */

static int stringcasecmp(s1, s2)

xc_string_t *s1, *s2;

{
/* if the strings are identical in length, return the result of strcasecmp() */
	if (s1->length == s2->length)
		return STRNCASECMP(s1->address, s2->address, (size_t)s1->length);
	else
/* otherwise, the shorter string is less than the longer one */
		return s1->length - s2->length;

/* NOTREACHED */
}



/* copy one xc_string_t to another */

static xc_string_t *stringcpy(dest, src)

xc_string_t *dest, *src;

{
	size_t len;

/* copy as much of the source as will fit into the destination */
	len = min(src->length, dest->length);
	strncpy(dest->address, src->address, len);
	dest->length = len;

/* a la strcpy(), return the destination pointer */
	return dest;
}



#ifdef NEED_VARARGS
static size_t msg(va_alist)

va_dcl
#else
static size_t msg(xc_string_t *buff, char *fmt, ...)
#endif

{
	va_list args;
	int rc;
#ifdef NEED_VARARGS
	xc_string_t *buff;
	char *fmt;

/* step to the start of the argument list */
	va_start(args);

	/* capture the arguments */
	buff = va_arg(args, char *);
	fmt = va_arg(args, char *);
#else

/* step to the variable part of the argument list */
	va_start(args, fmt);
#endif

/* start the message with the routine name */
	strcpy(buff->address, "gtm_env_xlate:  ");

/* format the message into the caller's buffer, which we've guaranteed to be
 * way too big */
	VSPRINTF(&buff->address[strlen(buff->address)], fmt, args, rc);

	/* set the actual length of the error message */
	buff->length = strlen(buff->address);

/* finish off the argument list */
	va_end(args);

/* return the message length in case it's useful */
	return buff->length;
}



#ifndef STANDALONE

/* build the function address lookup table */

static int init_functable(errbuf)

xc_string_t *errbuf;

{
	char *pcAddress;
	void **functable;

	pcAddress = GETENV(CALLIN_ENV_VAR);
	if (pcAddress == (char *)NULL)
	{
		(void)msg(errbuf, "gtm_env_xlate:  Failed to get environment variable %s", CALLIN_ENV_VAR);
		return -1;
	}
	functable = (void **)STRTOUL(pcAddress, NULL, 10);
	if (functable == (void **)0)
	{
		(void)msg(errbuf, "gtm_env_xlate:  Failed to convert %s to a valid address", pcAddress);
		return -1;
	}
	GTM_MALLOC = (int_fptr) functable[4];
	GTM_FREE = (int_fptr) functable[5];

	return 0;
}

#endif
