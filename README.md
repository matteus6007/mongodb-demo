# MongoDB Demo

Demo for importing data into a Mongo Database.

* [Installation](#installation)
  * [Docker](#docker)
  * [Docker Compose](#docker-compose)
* [MongoDB GUI](#mongodb-gui)
* [Importing Data](#importing-data)
  * [Locally](#locally)
  * [Fix Extended JSON format issues](#fix-extended-json-format-issues)

## Installation

### Docker

Read https://www.mongodb.com/compatibility/docker for full details on how to setup Docker locally.

Install Docker image https://hub.docker.com/r/mongodb/mongodb-community-server:

```shell
docker pull mongodb/mongodb-community-server:6.0-ubi8
```

Running MongoDB version `6.0` locally running on port `27017`:

```shell
docker run --name mongodb -d -p 27017:27017 mongodb/mongodb-community-server:6.0-ubi8
```

Optional parameters:

* `-v $(pwd)/data:/data/db` - persist data on local machine to `/data` directory
* `--network mongodb` - connect to other containers on the same network
* `-e MONGO_INITDB_ROOT_USERNAME=root -e MONGO_INITDB_ROOT_PASSWORD=p@ssw0rd` - environment variables for creating a user with root permissions

You can access MongoDB instance on `mongodb://localhost:27017`.

Stopping MongoDB:

```shell
docker stop mongodb && docker rm mongodb
```

### Docker Compose

Running MongoDB version `6.0` locally running on port `27017`:

```shell
docker-compose up
```

Stopping MongoDB:

```shell
docker-compose down -v --rmi local --remove-orphans
```

## MongoDB GUI

To view databases and query data locally, install [MongoDB Compass](https://www.mongodb.com/docs/compass/current/).

Connect to `mongodb://localhost:27017`.

## Importing Data

Inspired by https://www.mongodb.com/developer/products/mongodb/mongoimport-guide/.

Use [mongoimport](https://www.mongodb.com/docs/database-tools/mongoimport/) to import data from CSV and [Extended JSON](https://www.mongodb.com/docs/manual/reference/mongodb-extended-json/) - _note this differs from JSON_.

### Locally

* Download from [Database Tools](https://www.mongodb.com/docs/database-tools/installation/installation/)
* Add `/bin` folder to `PATH`

#### Import Single file

```shell
mongoimport --collection=mobiledevices --file='sample-data/mobile-devices.json' --uri mongodb://localhost:27017
```

Optional parameters:

* `db:<database_name>` - name of database, default `test`
* `legacy` - use Extended JSON v1
* `drop` - drop collection before inserting documents
* `mode:[insert|upsert|merge|delete]` - insert: insert only, skips matching documents. upsert: insert new documents or replace existing documents. merge: insert new documents or modify existing documents. delete: deletes matching documents only. If upsert fields match more than one document, only one document is deleted. (default: insert)

Run `mongoimport --help` for full list.

#### Import multiple files

```shell
cat ./sample-data/*.json | mongoimport --legacy --collection=mobiledevices --uri mongodb://localhost:27017
```

#### Import JSON array

```shell
mongoimport --collection=mobiledevices --file='sample-data/json-array/export.json' --uri mongodb://localhost:27017 --jsonArray
```

_Note: There is a limit of 16MB._

#### Import specific JSON array field

```shell
jq '.docs' | mongoimport --collection=mobiledevices --file='sample-data/json-array/export2.json' --uri mongodb://localhost:27017 --jsonArray
```

### Fix Extended JSON format issues

Use a command-line JSON processor [jq](https://jqlang.github.io/jq/) to format fields to match Extended JSON.

Installation:

```shell
choco install jq
```

Optionally install the VS Code extension [jq syntax highlighting](https://marketplace.visualstudio.com/items?itemName=jq-syntax-highlighting.jq-syntax-highlighting).

Example [json_fixes.jq](./json_fixes.jq) fixes following issues:

* `createdOn` and `updatedOn` fields saved in date format
* Set `_id` field from existing `id` field

Echo output:

```shell
jq -f json_fixes.jq ./sample-data/mobile-devices.json
```

Outputs:

```json
{
  "name": "Galaxy S24",
  "family": "Samsung",
  "storage": "128GB",
  "colour": "Black",
  "createdOn": {
    "$date": "2023-01-01T09:00:00Z"
  },
  "updatedOn": {
    "$date": "2023-01-01T09:00:00Z"
  },
  "_id": "1234"
}
```

#### Fix and import single file

```shell
jq -f json_fixes.jq ./sample-data/mobile-devices.json | mongoimport  --collection=mobiledevices --uri mongodb://localhost:27017 --mode upsert
```

#### Fix and import multiple files

```shell
cat ./sample-data/*.json | jq -f json_fixes.jq | mongoimport  --collection=mobiledevices --uri mongodb://localhost:27017 --mode upsert
```
