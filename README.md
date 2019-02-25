# mysql-helper

Import, export and make backups of MySQL/MariaDB databases.


## Installing

### Easy with [Basher](https://github.com/basherpm/basher)

```sh
basher install nelson6e65/bash-mysql-helper
```
Done!


### Configuring

`mysql-helper` uses a `.env` file to read database credentials.

Example of a `.env` file content:

```sh
# Optional
DB_HOST='localhost'
DB_PORT=3306

# Mandatory
DB_DATABASE=
DB_USERNAME=
DB_PASSWORD=

# Other stuffs not used by `mysql-helper`...
```


## Usage

### Backup Database

It creates a backup file: `{database}_{date}.sql.gz` file.

```sh
mysql-helper b
mysql-helper backup
```

You can ignore backup creation by using `--no-backup`

### Exporting Database to SQL

Exports DB to `{database}.sql` file.

```sh
mysql-helper e
mysql-helper export
# mysql-helper -e # DEPRECATED
# mysql-helper --export # DEPRECATED
```


### Importing SQL to Database

Import a database content from `{database}.sql` file.

```sh
mysql-helper i
mysql-helper import
# mysql-helper -i # DEPRECATED
# mysql-helper --import # DEPRECATED
```

> Note: By default it will run `backup` automatically. To avoid this, pass `--no-auto-backup`.

### Customize target dir

By default, it will use the working directory to search files. In order to use a different target-dir:

```sh
mysql-helper (i|e|b) <target-dir>
mysql-helper (i|e|b) --target <target-dir> # DEPRECATED
```

### More options

Use --help to see more options.

```sh
mysql-helper --help
```
