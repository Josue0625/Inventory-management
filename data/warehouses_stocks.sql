-- Insertar stock de almacenes
INSERT INTO inventory_management.warehouses_stocks (warehouse_id, product_id, product_quantity, warehouse_stock_minimum)
VALUES (1, 1, 40, 5),
       (2, 1, 10, 4),
       (2, 2, 20, 3),
       (1, 3, 100, 2);
