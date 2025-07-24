-- Insertar movimientos
INSERT INTO inventory_management.movements (product_id, movement_type_id, warehouse_origin_id, warehouse_dest_id,
                                            product_quantity, movement_observation, user_id)
VALUES (1, 1, NULL, 1, 50, 'INGRESO INICIAL DE LAPTOS', 1),
       (2, 1, NULL, 2, 20, 'INGRESO DE IMPRESORAS NUEVAS', 2),
       (3, 1, NULL, 1, 100, 'COMPRA DE RESMAS', 1),
       (1, 3, 1, 2, 10, 'TRASLADOS A BOGOTÁ', 1);
