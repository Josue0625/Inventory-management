@echo off
set PGPASSWORD=12345

psql -U postgres -d inventory -f ./script.sql

SET PGCLIENTENCODING=utf8

REM CONSTRAINTS
psql -U postgres -d inventory -f ./constraints/pk.sql
psql -U postgres -d inventory -f ./constraints/uk.sql
psql -U postgres -d inventory -f ./constraints/fk.sql

REM DATA
psql -U postgres -d inventory -f ./data/categories.sql
psql -U postgres -d inventory -f ./data/countries.sql
psql -U postgres -d inventory -f ./data/departments.sql
psql -U postgres -d inventory -f ./data/movements_types.sql
psql -U postgres -d inventory -f ./data/municipalities.sql
psql -U postgres -d inventory -f ./data/products_types.sql
psql -U postgres -d inventory -f ./data/products.sql
psql -U postgres -d inventory -f ./data/users.sql
psql -U postgres -d inventory -f ./data/warehouses_statuses.sql
psql -U postgres -d inventory -f ./data/warehouses.sql
psql -U postgres -d inventory -f ./data/warehouses_stocks.sql
psql -U postgres -d inventory -f ./data/movements.sql

REM FUNCTIONS
psql -U postgres -d inventory -f ./sources/register_log_entry.sql
psql -U postgres -d inventory -f ./sources/register_log_output.sql
psql -U postgres -d inventory -f ./functions/utils/any_element_to_string.sql
psql -U postgres -d inventory -f ./functions/register_movement.sql
