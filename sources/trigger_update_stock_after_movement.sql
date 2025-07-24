CREATE OR REPLACE FUNCTION inventory_management.update_stock_after_movement()
    RETURNS TRIGGER AS
$$
DECLARE
    local_movement_type TEXT;
    local_stock_minimum INTEGER;
BEGIN
    -- Obtener el tipo de movimiento
    SELECT movement_type_name
    INTO local_movement_type
    FROM inventory_management.movements_types
    WHERE movement_type_id = NEW.movement_type_id;

    -- Si es salida o traslado: disminuir stock del almacén origen
    IF local_movement_type IN ('SALIDA', 'TRASLADO') THEN
        UPDATE inventory_management.warehouses_stocks
        SET product_quantity            = product_quantity - NEW.product_quantity,
            warehouse_stock_update_date = CURRENT_TIMESTAMP
        WHERE warehouse_id = NEW.warehouse_origin_id
          AND product_id = NEW.product_id;
    END IF;

    -- Si es entrada o traslado: aumentar stock del almacén destino
    IF local_movement_type IN ('ENTRADA', 'TRASLADO') THEN

        -- Intentar heredar el mínimo del almacén origen si es TRASLADO
        IF local_movement_type = 'TRASLADO' THEN
            SELECT warehouse_stock_minimum
            INTO local_stock_minimum
            FROM inventory_management.warehouses_stocks
            WHERE warehouse_id = NEW.warehouse_origin_id
              AND product_id = NEW.product_id;
        ELSE
            -- Valor por defecto si es ENTRADA
            local_stock_minimum := 10;
        END IF;

        INSERT INTO inventory_management.warehouses_stocks (warehouse_id, product_id, product_quantity,
                                                            warehouse_stock_minimum)
        VALUES (NEW.warehouse_dest_id, NEW.product_id, NEW.product_quantity, local_stock_minimum)
        ON CONFLICT (warehouse_id, product_id) DO UPDATE
            SET product_quantity            = warehouses_stocks.product_quantity + NEW.product_quantity,
                warehouse_stock_update_date = CURRENT_TIMESTAMP;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger que ejecuta la función después de insertar en movements
CREATE OR REPLACE TRIGGER trigger_update_stock_after_movement
    AFTER INSERT
    ON inventory_management.movements
    FOR EACH ROW
EXECUTE FUNCTION inventory_management.update_stock_after_movement();
