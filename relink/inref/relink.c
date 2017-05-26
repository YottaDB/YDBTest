/****************************************************************
 *								*
 * Copyright (c) 2014, 2015 Fidelity National Information	*
 * Services, Inc. and/or its subsidiaries. All rights reserved.	*
 *								*
 *	This source code contains the intellectual property	*
 *	of its copyright holder(s), and is made available	*
 *	under a license.  If you do not know the terms of	*
 *	the license, please stop and do not read further.	*
 *								*
 ****************************************************************/

/* This file contains implementations of external call functions used in the relink test suite. */

#ifdef __linux__
#	define _XOPEN_SOURCE 500	/* For the nftw() function. */
#	define LINUX_ONLY(X) X
#else
#	define LINUX_ONLY(X)
#endif

#include "gtm_common_defs.h"
#include "gtm_unistd.h"
#include "gtm_string.h"
#include "gtm_stdio.h"
#include "gtm_fcntl.h"

#include "mdef.h"
#include "mmrhash.h"

#include <sys/types.h>
#include <sys/stat.h>
#include <sys/ipc.h>
#include <sys/shm.h>

#include <dirent.h>
#include <errno.h>
#include <glob.h>
#include <assert.h>
#include <ftw.h>
#include "gtmxc_types.h"

static char		buffer[131072];
static gtm_string_t	result;

/* Select the index-th file from the specified directory, looping through the list more than once, if needed.
 * Return an error if no files are found.
 */
gtm_status_t choose_file_by_index(int argc, gtm_char_t *directory, gtm_int_t index, gtm_char_t *file)
{
	DIR		*dp;
	struct dirent	*dirp;
	int		i;

	i = 1;
	while (i <= index)
	{
		if (NULL == (dp = opendir(directory)))
			return (gtm_status_t)errno;
		while (NULL != (dirp = readdir(dp)))
		{
			if (!strcmp(dirp->d_name, ".") || !strcmp(dirp->d_name, ".."))
				continue;
			if (index == i)
			{
				strcpy(file, dirp->d_name);
				closedir(dp);
				return (gtm_status_t)0;
			}
			i++;
		}
		closedir(dp);
		/* We started with i==1, so if it is still 1, the above WHILE loop did not find a single file, which
		 * means that there is no point re-reading the directory, since i will never be incremented to index.
		 */
		if (1 == i)
			break;
	}
	return (gtm_status_t)-1;
}

/* Rename (move) the file as specified. */
gtm_status_t rename_file(int argc, gtm_char_t *old_name, gtm_char_t *new_name)
{
	if (-1 == rename(old_name, new_name))
		return (gtm_status_t)errno;
	else
		return (gtm_status_t)0;
}

/* Remove the specified file. */
gtm_status_t remove_file(int argc, gtm_char_t *file)
{
	if (-1 == unlink(file))
		return (gtm_status_t)errno;
	else
		return 0;
}

/* Make the specified directory readable or remove the specified file (invoked by nftw() from remove_directory()). */
int rm(const char *path, const struct stat *sb, int typeflag, struct FTW *ftwbuf)
{
	if (FTW_DP == typeflag)
		return rmdir(path);
	else if (S_ISDIR(sb->st_mode))
		return chmod(path, (mode_t)0777);
	else
		return unlink(path);
}

/* Remove the directory with all its contents. */
gtm_status_t remove_directory(int argc, gtm_char_t *directory)
{
	if (-1 == nftw(directory, rm, 1024, FTW_PHYS))
		return (gtm_status_t)errno;
	else if (-1 == nftw(directory, rm, 1024, FTW_DEPTH | FTW_PHYS))
		return (gtm_status_t)errno;
	else
		return 0;
}

/* Do wildcard search of files based on the provided pattern. In case errors are encountered
 * when accessing particular directories or files, the function attempts to continue. The
 * result is a $char(1)-delimited string of matching file names.
 */
gtm_string_t *match_files(int argc, gtm_char_t *pattern)
{
	glob_t			globbuf;
	int			i, count, status, length;
	char			*pos, *match;

	result.address = buffer;
	result.length = 0;
	if (0 == (status = glob(pattern, LINUX_ONLY(GLOB_PERIOD | )GLOB_NOSORT, (int (*)(const char *, int))NULL, &globbuf)))
	{
		pos = buffer;
		for (i = 0, count = 0; i < globbuf.gl_pathc; i++)
		{
			match = globbuf.gl_pathv[i];
			length = strlen(match);
			if ((length > 1)
				&& ('.' == match[length - 1])
				&& (('/' == match[length - 2])
					|| ((length > 2)
						&& ('.' == match[length - 2])
						&& ('/' == match[length - 3]))))
				continue;
			strcpy(pos, match);
			*(pos + length) = '\1';
			pos += length + 1;
			count++;
		}
		result.length = (pos - buffer);
		if (count > 0)
			result.length--;
		globfree(&globbuf);
	} else if (GLOB_NOMATCH)
	{
		globfree(&globbuf);
	}
	return &result;
}

/* Return a hexadecimal string containing the 128-bit murmur hash of the specified file. */
gtm_string_t *murmur_hash(int argc, gtm_char_t *source)
{
	int			fd, size, read_count;
	gtm_uint16		hash_value;
	struct stat		stat_info;

	result.length = 0;
	result.address = buffer;

	if (0 <= (fd = open(source, O_RDONLY)))
	{
		if (-1 == fstat(fd, &stat_info))
			return &result;

		size = (int)stat_info.st_size;
		read_count = read(fd, buffer, size);

		assert(read_count == size);

		close(fd);

		gtmmrhash_128(buffer, size, 0, &hash_value);
		gtmmrhash_128_hex(&hash_value, (unsigned char *)result.address);
		result.length = 32;
	}

	return &result;
}

/* Change permissions of the specified shared memory segment to those corresponding to mode. */
gtm_status_t ch_shm_mod(int argc, gtm_int_t shmid, gtm_int_t mode)
{
	struct shmid_ds	buf;

	if (-1 == shmctl(shmid, IPC_STAT, &buf))
		return errno;

	buf.shm_perm.mode = mode;

	if (-1 == shmctl(shmid, IPC_SET, &buf))
		return errno;
	return 0;
}

/* Truncate a file to the specified size. */
gtm_status_t truncate_file(int argc, gtm_char_t *file, gtm_int_t size)
{
	if (-1 == truncate(file, size))
		return errno;
	else
		return 0;
}
