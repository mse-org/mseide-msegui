#!/bin/sh

# DB SERVER = PostgreSQL

# dbname = serious_matters

dropdb -Upostgres serious_matters

createdb -Upostgres -E UNICODE serious_matters

psql -Upostgres -f ./tables.sql -d serious_matters

exit 0
