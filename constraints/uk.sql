ALTER TABLE inventory_management.countries
    ADD CONSTRAINT uq_country_name UNIQUE (country_name);

ALTER TABLE inventory_management.departments
    ADD CONSTRAINT uq_country_department UNIQUE (country_id, department_name);

ALTER TABLE inventory_management.municipalities
    ADD CONSTRAINT uq_department_municipality UNIQUE (department_id, municipality_name);

ALTER TABLE inventory_management.products
    ADD CONSTRAINT uq_product_code UNIQUE (product_code);

ALTER TABLE inventory_management.products_types
    ADD CONSTRAINT uq_product_type_name UNIQUE (product_type_name);

ALTER TABLE inventory_management.categories
    ADD CONSTRAINT uq_category_name UNIQUE (category_name);

ALTER TABLE inventory_management.movements_types
    ADD CONSTRAINT uq_movement_type_name UNIQUE (movement_type_name);

ALTER TABLE inventory_management.warehouses
    ADD CONSTRAINT uq_warehouse_code UNIQUE (warehouse_code);

ALTER TABLE inventory_management.warehouses_statuses
    ADD CONSTRAINT uq_warehouse_status_name UNIQUE (warehouse_status_name);

ALTER TABLE inventory_management.users
    ADD CONSTRAINT uq_user_code UNIQUE (user_code);

ALTER TABLE inventory_management.warehouses_stocks
    ADD CONSTRAINT uq_warehouse_id_and_product_id UNIQUE (warehouse_id, product_id);
