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

```bash
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

Default option if no argument passed. It creates a backup file: `{database}_{date}.sql.gz` file.

```sh
mysql-helper
```

You can ignore backup creation by using `--no-backup`

### Exporting Database to SQL

```sh
mysql-helper -e
mysql-helper --export
mysql-helper export
```

Creates a `{database}.sql` file

### Importing SQL to Database
```sh
mysql-helper -i
mysql-helper --import
mysql-helper import
```

Import a database content from `{database}.sql` file

### Options
- **`-t|--target [dir]`**: Customize the target directory.
- **`--no-backup`**: Ignore the auto-creation of backup file before `import`/`export`.
