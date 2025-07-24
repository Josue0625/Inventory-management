ALTER TABLE inventory_management.countries
    ADD PRIMARY KEY (country_id);

ALTER TABLE inventory_management.departments
    ADD PRIMARY KEY (department_id);

ALTER TABLE inventory_management.municipalities
    ADD PRIMARY KEY (municipality_id);

ALTER TABLE inventory_management.warehouses_statuses
    ADD PRIMARY KEY (warehouse_status_id);

ALTER TABLE inventory_management.warehouses
    ADD PRIMARY KEY (warehouse_id);

ALTER TABLE inventory_management.products_types
    ADD PRIMARY KEY (product_type_id);

ALTER TABLE inventory_management.categories
    ADD PRIMARY KEY (category_id);

ALTER TABLE inventory_management.products
    ADD PRIMARY KEY (product_id);

ALTER TABLE inventory_management.users
    ADD PRIMARY KEY (user_id);

ALTER TABLE inventory_management.movements_types
    ADD PRIMARY KEY (movement_type_id);

ALTER TABLE inventory_management.movements
    ADD PRIMARY KEY (movement_id);

ALTER TABLE inventory_management.warehouses_stocks
    ADD PRIMARY KEY (warehouse_stock_id);

ALTER TABLE inventory_management.logs
    ADD PRIMARY KEY (log_id);
