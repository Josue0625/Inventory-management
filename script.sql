DROP SCHEMA IF EXISTS inventory_management CASCADE;
CREATE SCHEMA inventory_management;

-- Tabla countries
CREATE TABLE inventory_management.countries
(
    country_id   SERIAL,
    country_name VARCHAR(100) NOT NULL
);

-- Tabla departments
CREATE TABLE inventory_management.departments
(
    department_id   SERIAL,
    country_id      INTEGER,
    department_name VARCHAR(100) NOT NULL
);

-- Tabla municipalities
CREATE TABLE inventory_management.municipalities
(
    municipality_id   SERIAL,
    department_id     INTEGER,
    municipality_name VARCHAR(100) NOT NULL
);

-- Tabla warehouses_statuses
CREATE TABLE inventory_management.warehouses_statuses
(
    warehouse_status_id   SERIAL,
    warehouse_status_name VARCHAR(100) NOT NULL
);

-- Tabla warehouses
CREATE TABLE inventory_management.warehouses
(
    warehouse_id        SERIAL,
    warehouse_code      VARCHAR(50)  NOT NULL,
    warehouse_name      VARCHAR(100) NOT NULL,
    warehouse_status_id INTEGER,
    city_id             INTEGER,
    capacity            INTEGER
);

-- Tabla products_types
CREATE TABLE inventory_management.products_types
(
    product_type_id   SERIAL,
    product_type_name VARCHAR(100) NOT NULL
);

-- Tabla categories
CREATE TABLE inventory_management.categories
(
    category_id   SERIAL,
    category_name VARCHAR(100) NOT NULL
);

-- Tabla products
CREATE TABLE inventory_management.products
(
    product_id          SERIAL,
    product_code        VARCHAR(100) NOT NULL,
    product_name        VARCHAR(100) NOT NULL,
    product_description TEXT,
    product_type_id     INTEGER,
    category_id         INTEGER
);

-- Tabla users
CREATE TABLE inventory_management.users
(
    user_id   SERIAL,
    user_name VARCHAR(100) NOT NULL,
    user_code VARCHAR(100) NOT NULL
);

-- Tabla movements_types
CREATE TABLE inventory_management.movements_types
(
    movement_type_id   SERIAL,
    movement_type_name VARCHAR(100) NOT NULL
);

-- Tabla movements
CREATE TABLE inventory_management.movements
(
    movement_id            SERIAL,
    product_id             INTEGER,
    movement_type_id       INTEGER,
    warehouse_origin_id    INTEGER,
    warehouse_dest_id      INTEGER,
    product_quantity       INTEGER                             NOT NULL,
    movement_observation   TEXT,
    movement_register_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    user_id                INTEGER
);

-- Tabla warehouses_stocks
CREATE TABLE inventory_management.warehouses_stocks
(
    warehouse_stock_id            SERIAL,
    warehouse_id                  INTEGER,
    product_id                    INTEGER,
    product_quantity              INTEGER                             NOT NULL,
    warehouse_stock_creation_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    warehouse_stock_update_date   TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- Tabla logs
CREATE TABLE inventory_management.logs
(
    log_id                         SERIAL,
    user_code                      VARCHAR(100)           NOT NULL,
    log_name_object                character varying(250) NOT NULL,
    log_parameters_input           TEXT,
    log_parameters_output          TEXT,
    log_code_error_database        character varying(250),
    log_message_error_database     character varying(250),
    log_code_error_checked         character varying(250),
    log_message_error_checked      character varying(250),
    log_code_success_checked       character varying(250),
    log_message_success_checked    character varying(250),
    log_response_time_milliseconds integer,
    log_date_input                 timestamp WITHOUT TIME ZONE,
    log_date_output                timestamp WITHOUT TIME ZONE

);