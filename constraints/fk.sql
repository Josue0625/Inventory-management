ALTER TABLE inventory_management.departments
    ADD CONSTRAINT fk_departments_country FOREIGN KEY (country_id)
        REFERENCES inventory_management.countries (country_id);

ALTER TABLE inventory_management.municipalities
    ADD CONSTRAINT fk_municipalities_department FOREIGN KEY (department_id)
        REFERENCES inventory_management.departments (department_id);

ALTER TABLE inventory_management.warehouses
    ADD CONSTRAINT fk_warehouses_status FOREIGN KEY (warehouse_status_id)
        REFERENCES inventory_management.warehouses_statuses (warehouse_status_id),
    ADD CONSTRAINT fk_warehouses_city FOREIGN KEY (city_id)
        REFERENCES inventory_management.municipalities (municipality_id);

ALTER TABLE inventory_management.products
    ADD CONSTRAINT fk_products_type FOREIGN KEY (product_type_id)
        REFERENCES inventory_management.products_types (product_type_id),
    ADD CONSTRAINT fk_products_category FOREIGN KEY (category_id)
        REFERENCES inventory_management.categories (category_id);

ALTER TABLE inventory_management.movements
    ADD CONSTRAINT fk_movements_product FOREIGN KEY (product_id)
        REFERENCES inventory_management.products (product_id),
    ADD CONSTRAINT fk_movements_type FOREIGN KEY (movement_type_id)
        REFERENCES inventory_management.movements_types (movement_type_id),
    ADD CONSTRAINT fk_movements_warehouse_origin FOREIGN KEY (warehouse_origin_id)
        REFERENCES inventory_management.warehouses (warehouse_id),
    ADD CONSTRAINT fk_movements_warehouse_dest FOREIGN KEY (warehouse_dest_id)
        REFERENCES inventory_management.warehouses (warehouse_id),
    ADD CONSTRAINT fk_movements_user FOREIGN KEY (user_id)
        REFERENCES inventory_management.users (user_id);

ALTER TABLE inventory_management.warehouses_stocks
    ADD CONSTRAINT fk_warehouse_stock_warehouse FOREIGN KEY (warehouse_id)
        REFERENCES inventory_management.warehouses (warehouse_id),
    ADD CONSTRAINT fk_warehouse_stock_product FOREIGN KEY (product_id)
        REFERENCES inventory_management.products (product_id);
