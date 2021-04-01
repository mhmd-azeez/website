Title: Backing up and restoring databases in Postgres
Published: 04/01/2021
Tags:

 - postgresql
 - pg_dump
 - pg_restore
 - psql
---

To get a dump of a database you can use `pg_dump` or `pg_dumpall` for dumping an entire cluster. It [supports 4 formats](https://www.postgresql.org/docs/9.1/app-pgdump.html):

| Format      | Description                                                  | Restore via  |
| ----------- | ------------------------------------------------------------ | ------------ |
| `plain`     | Output a plain-text SQL script file (the default).           | `psql`       |
| `custom`    | Output a custom-format archive suitable for input into pg_restore. Together with the directory output format, this is the most flexible output format in that it allows manual selection and reordering of archived items during restore. This format is also compressed by default. | `pg_restore` |
| `directory` | Output a directory-format archive suitable for input into pg_restore. This will create a directory with one file for each table and blob being dumped, plus a so-called Table of Contents file describing the dumped objects in a machine-readable format that pg_restore can read. A directory format archive can be manipulated with standard Unix tools; for example, files in an uncompressed archive can be compressed with the gzip tool. This format is compressed by default. | `pg_restore` |
| `tar`       | Output a `tar`-format archive suitable for input into pg_restore. The tar format is compatible with the directory format: extracting a tar-format archive produces a valid directory-format archive. However, the tar format does not support compression. Also, when using tar format the relative order of table data items cannot be changed during restore. | `pg_restore` |

### How to backup a database

#### Custom Format

```bash
pg_dump -U postgres --encoding utf8 -F c -f sample-db.dump sample-db
```

This creates a dump of `sample-db` in `custom` format and names the file `sample-db.dump`.

#### Plain Format

```bash
pg_dump -U postgres --encoding utf8 -F p -f stoplist.sql stoplist
```
This creates a dump of `sample-db` in `custom` format and names the file `sample-db.sql`.

### How to restore a database dump

First create an empty database to restore the dump to.

```bash
# Create a new database using template0 called restored-db. We use template0 is empty and it doesn't conflict with the schemas and tables in the dump.
createdb -U postgres restored-db --template=template0
```

#### Custom Format

```bash
# Restore the database using pg_restore. As you can see, the name of the restored database doesn't have to match the name of the original database.
pg_restore -U postgres -d restored-db < ./sample-db.dump
```

> **Note:** In Powershell the `<` operator doesn't work. So you'll have to use `cmd` on Windows.

#### Plain Format

```bash
# Restore the database using psql. As you can see, the name of the restored database doesn't have to match the name of the original database.
psql -U postgres -d restored-db < ./sample-db.sql
```

> **Note:** In Powershell the `<` operator doesn't work. So you'll have to use `cmd` on Windows.

### Errors you might come across:

```
pg_restore: [archiver] found unexpected block id (x) when reading data -- expected y
```

```
pg_restore: error unrecognized data block type
```

This might mean the dump is corrupted. One possible reason is the database contained Unicode data and the dump was not encoded in utf8. Use `--encoding utf8` when running `pg_dump` to fix that.

```
pg_restore: [archiver] did not find magic string in file header
```

This happens if you run `pg_restore` with `--format=c` on a `plain` format dump. Use `psql` to restore it instead.

```
pg_restore: [archiver] input file does not appear to be a valid archive
```

This happens if you try to restore a `plain` format dump using `pg_restore`. Use `psql` to restore it instead.