Title: Automatic periodic backups from PostgreSQL to S3 using Cron
Published: 01/29/2022
Tags:

 - postgresql
 - s3
 - devops
 - cron
---

If you're managing your own databases you'll need to make sure you database is backed up properly. A good option is to store your backups in an S3-compatible object storage.

1. Install `s3cmd`:

```
sudo apt install s3cmd
```

2. Configure it:
```
s3cmd --configure
```

It will ask you several questions, consult your S3 providers docs for more information.

3. Write a bash script to create a postgresql dump and upload it to S3:

```bash
DIR=$(dirname "${BASH_SOURCE[0]}")
DB_NAME=bixwene
DUMP_PATH="$DIR/$DB_NAME_$(date +"%Y-%m-%d@%H-%M").dump"

# DUMP the database
pg_dump --encoding utf8 --format c --compress 9 --file $DUMP_PATH $DB_NAME

DUMP_KEY=$DUMP_PATH | cut -c 3- # Remove the ./ from the path

# Upload the dump file to S3
s3cmd put $DUMP_PATH s3://$DB_NAME-db-backups/$DB_NAME/$DUMP_KEY

# Remove the dump file from disk
rm $DUMP_PATH
```

For more information about taking PostgreSQL backups, checkout [my previous post](https://mazeez.dev/posts/backup-and-restore-in-postgres).

4. Write a crontab job to run your script periodically:

```
crontab -e
```

```
0 */3 * * * path/to/your/script/job.sh
```

**Note:** This expression means the job will be run every 3 hours. You can change it to whatever your want.