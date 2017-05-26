/****************************************************************
 *								*
 *	Copyright 2014 Fidelity Information Services, Inc	*
 *								*
 *	This source code contains the intellectual property	*
 *	of its copyright holder(s), and is made available	*
 *	under a license.  If you do not know the terms of	*
 *	the license, please stop and do not read further.	*
 *								*
 ****************************************************************/
#include <libconfig.h>
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>

#define DUMP_ERROR_AND_EXIT(P_CFG)										\
{														\
	printf("Error line: %d; Error text: %s\n", config_error_line(P_CFG), config_error_text(P_CFG));		\
	exit(-1);												\
}

#define PRINT_ERROR_AND_EXIT(...)										\
{														\
	printf(__VA_ARGS__);											\
	exit(-1);												\
}

config_setting_t *create_database_section(config_t *p_cfg)
{
	config_setting_t		*root, *database, *keys;

	if (NULL == (root = config_root_setting(p_cfg)))
		DUMP_ERROR_AND_EXIT(p_cfg);
	if (NULL == (database = config_setting_add(root, "database", CONFIG_TYPE_GROUP)))
		DUMP_ERROR_AND_EXIT(p_cfg);
	if (NULL == (keys = config_setting_add(database, "keys", CONFIG_TYPE_LIST)))
		DUMP_ERROR_AND_EXIT(p_cfg);
	return keys;
}

void append_keypair(config_t *p_cfg, config_setting_t *parent, const char *db, const char *key)
{
	config_setting_t	*elem, *dat_setting, *key_setting;

	/* Create the database.keys section if doesn't exist already. */
	if (NULL == parent)
		parent = create_database_section(p_cfg);
	assert(NULL != parent);

	if (NULL == (elem = config_setting_add(parent, NULL, CONFIG_TYPE_GROUP)))
		DUMP_ERROR_AND_EXIT(p_cfg);

	if (NULL == (dat_setting = config_setting_add(elem, "dat", CONFIG_TYPE_STRING)))
		DUMP_ERROR_AND_EXIT(p_cfg);
	if (NULL == (key_setting = config_setting_add(elem, "key", CONFIG_TYPE_STRING)))
		DUMP_ERROR_AND_EXIT(p_cfg);

	if (!config_setting_set_string(dat_setting, db))
		DUMP_ERROR_AND_EXIT(p_cfg);
	if (!config_setting_set_string(key_setting, key))
		DUMP_ERROR_AND_EXIT(p_cfg);
}

void delete_keypair(config_t *p_cfg, config_setting_t *setting, int k)
{
	if (NULL == setting)
		PRINT_ERROR_AND_EXIT("Cannot find database.keys section.");
	if (k < 0 || k > config_setting_length(setting) - 1)
		PRINT_ERROR_AND_EXIT("Index: %d is out of bounds\n", k);
	if (!config_setting_remove_elem(setting, k))
		DUMP_ERROR_AND_EXIT(p_cfg);
}

void usage()
{
	printf("Usage: ./modconfig <config-file> <command> <arguments>\n");
	printf("Command: append-keypair <database file> <key file>\n");
	printf("Command: delete-keypair <index [0..n-1]>\n");
}

int main(int argc, char *argv[])
{
	config_t		cfg, *p_cfg;
	config_setting_t	*setting;
	char			*filename, buf[2048];

	p_cfg = &cfg;
	config_init(p_cfg);
	if (argc < 3)
	{
		usage();
		return -1;
	}
	if (!config_read_file(p_cfg, argv[1]))
		DUMP_ERROR_AND_EXIT(p_cfg);

	setting = config_lookup(p_cfg, "database.keys");
	if (0 == strcasecmp(argv[2], "append-keypair"))
	{
		if (argc < 5)
		{
			usage();
			return -1;
		}
		append_keypair(p_cfg, setting, argv[3], argv[4]);
	} else if (0 == strcasecmp(argv[2], "delete-keypair"))
	{
		if (argc < 4)
		{
			usage();
			return -1;
		}
		delete_keypair(p_cfg, setting, atoi(argv[3]));
	} else
		PRINT_ERROR_AND_EXIT("Unknown command: %s\n", argv[2]);

	if (!config_write_file(p_cfg, argv[1]))
		DUMP_ERROR_AND_EXIT(p_cfg);

	config_destroy(p_cfg);
	return 0;
}
