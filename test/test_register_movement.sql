-- Prueba de movimiento de tipo ENTRADA
SELECT *
FROM inventory_management.register_movement(
        in_user_id := 1,
        in_product_id := 1,
        in_movement_type_id := 1, -- 'ENTRADA'
        in_product_quantity := 20,
        in_warehouse_origin_id := NULL,
        in_warehouse_dest_id := 1,
        in_movement_observation := 'Prueba de entrada por reposición'
     );

-- Prueba de movimiento de tipo TRASLADO
SELECT *
FROM inventory_management.register_movement(
        in_user_id := 1,
        in_product_id := 1,
        in_movement_type_id := 2, -- 'TRASLADO'
        in_product_quantity := 36,
        in_warehouse_origin_id := 1,
        in_warehouse_dest_id := 2,
        in_movement_observation := 'Prueba de traslado entre almacenes'
     );