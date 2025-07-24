CREATE OR REPLACE FUNCTION inventory_management.register_movement(
    in_user_id INTEGER,
    in_product_id INTEGER,
    in_movement_type_id INTEGER,
    in_product_quantity INTEGER,
    in_movement_observation TEXT,
    in_warehouse_origin_id INTEGER DEFAULT NULL,
    in_warehouse_dest_id INTEGER DEFAULT NULL
)
    RETURNS TABLE
            (
                status_process BIT,
                message        TEXT
            )
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS
$BODY$
DECLARE
    code_error                TEXT DEFAULT ''; -- variable para almacenar códigos de errores
    message_error             TEXT DEFAULT ''; -- variable para almacenar mensajes de errores

    id_log                    INTEGER; -- variable para log

    in_parameters             TEXT DEFAULT ''; -- variable para almacenar los parámetros de entrada y registrarlos en log
    out_parameters            TEXT DEFAULT ''; -- variable para almacenar los parámetros de salida y registrarlos en log

    success_code              VARCHAR(20) DEFAULT 'P0000'; -- variable para asignar código de proceso exitoso
    success_message           TEXT DEFAULT 'Transacción exitosa.'; -- variable para asignar mensaje de proceso exitoso
    error_code_checked        VARCHAR(20) DEFAULT 'P0001'; -- código de error controlado por validación de parámetros
    error_code_checked_select VARCHAR(20) DEFAULT 'P0002'; -- código de error por selects sin registros

    -- variables locales
    local_current_stock       INTEGER;
    local_isSuccessProcess    BIT DEFAULT 0;
    local_user_code           TEXT;
    local_movement_type_name  TEXT;
    local_warehouse_code      TEXT;
    local_warehouse_stock_id  INTEGER;
    local_product_quantity    INTEGER;


BEGIN
    -- asignación de parámetros de entrada
    in_parameters := 'in_user:' ||
                     inventory_management.any_element_to_string(in_user_id) || '|'
                         || 'in_product_id:' ||
                     inventory_management.any_element_to_string(in_product_id) || '|'
                         || 'in_movement_type_id:' ||
                     inventory_management.any_element_to_string(in_movement_type_id) || '|'
                         || 'in_warehouse_origin_id:' ||
                     inventory_management.any_element_to_string(in_warehouse_origin_id) || '|'
                         || 'in_warehouse_dest_id:' ||
                     inventory_management.any_element_to_string(in_warehouse_dest_id) || '|'
                         || 'in_product_quantity:' ||
                     inventory_management.any_element_to_string(in_product_quantity);

    -- Consultar el código de usuario
    SELECT user_code
    INTO local_user_code
    FROM inventory_management.users
    WHERE user_id = in_user_id;

    -- registrar inicio de transacción
    id_log := inventory_management.register_log_entry(local_user_code, 'register_movement_function', in_parameters);

    BEGIN
        -- Validar que no venga vacío el usuario
        IF in_user_id IS NULL THEN
            RAISE EXCEPTION 'El usuario no puede ir vacío' USING ERRCODE = error_code_checked;
        END IF;

        -- validar el id del producto
        IF in_product_id IS NULL THEN
            RAISE EXCEPTION 'El id del producto no puede ir vacío.' USING ERRCODE = error_code_checked;
        END IF;

        IF in_movement_type_id IS NULL THEN
            RAISE EXCEPTION 'El tipo de movimiento no puede ir vacío.' USING ERRCODE = error_code_checked;
        END IF;

        IF in_product_quantity IS NULL OR in_product_quantity <= 0 THEN
            RAISE EXCEPTION 'La cantidad debe ser mayor que cero.' USING ERRCODE = error_code_checked;
        END IF;

        IF in_movement_observation IS NULL OR in_movement_observation = '' THEN
            RAISE EXCEPTION 'La observación no puede estar vacía.' USING ERRCODE = error_code_checked;
        END IF;

        -- Consultar el nombre del tipo de movimiento
        SELECT movement_type_name
        INTO local_movement_type_name
        FROM inventory_management.movements_types
        WHERE movement_type_id = in_movement_type_id;

        -- Validar almacenes según tipo de movimiento
        IF local_movement_type_name = 'TRASLADO' THEN
            IF in_warehouse_origin_id IS NULL OR in_warehouse_dest_id IS NULL THEN
                RAISE EXCEPTION 'Para un traslado, se requieren los IDs de almacén de origen y destino.'
                    USING ERRCODE = error_code_checked;
            END IF;

        ELSIF local_movement_type_name = 'SALIDA' THEN
            IF in_warehouse_origin_id IS NULL THEN
                RAISE EXCEPTION 'Para una salida, se requiere EL ID del almacén de origen.'
                    USING ERRCODE = error_code_checked;
            ELSIF in_warehouse_dest_id IS NOT NULL THEN
                RAISE EXCEPTION 'Una salida no debe tener almacén de destino asignado.'
                    USING ERRCODE = error_code_checked;
            END IF;

        ELSIF local_movement_type_name = 'ENTRADA' THEN
            IF in_warehouse_dest_id IS NULL THEN
                RAISE EXCEPTION 'Para una entrada, se requiere EL ID del almacén de destino.'
                    USING ERRCODE = error_code_checked;
            ELSIF in_warehouse_origin_id IS NOT NULL THEN
                RAISE EXCEPTION 'Una entrada no debe tener almacén de origen asignado.'
                    USING ERRCODE = error_code_checked;
            END IF;
        END IF;

        --** Inicio de proceso

        -- Consultar el código de la bodega
        SELECT warehouse_code
        INTO local_warehouse_code
        FROM inventory_management.warehouses
        WHERE warehouse_id = in_warehouse_origin_id;

        -- validar stock en salidas o traslados
        IF local_movement_type_name IN ('SALIDA', 'TRASLADO') THEN
            SELECT product_quantity
            INTO local_current_stock
            FROM inventory_management.warehouses_stocks
            WHERE product_id = in_product_id
              AND warehouse_id = in_warehouse_origin_id;

            IF local_current_stock IS NULL OR local_current_stock < in_product_quantity THEN
                RAISE EXCEPTION 'Stock insuficiente en almacén de origen "%", disponible: %, requerido: %',
                    local_warehouse_code, COALESCE(local_current_stock, 0), in_product_quantity
                    USING ERRCODE = error_code_checked_select;
            END IF;

            -- actualizar stock del almacén origen
            UPDATE inventory_management.warehouses_stocks
            SET product_quantity            = product_quantity - in_product_quantity,
                warehouse_stock_update_date = CURRENT_TIMESTAMP
            WHERE product_id = in_product_id
              AND warehouse_id = in_warehouse_origin_id
            RETURNING warehouse_stock_id, product_quantity INTO local_warehouse_stock_id, local_product_quantity;

            IF local_product_quantity = 0 THEN
                DELETE
                FROM inventory_management.warehouses_stocks
                WHERE warehouse_stock_id = local_warehouse_stock_id;
            END IF;

        END IF;

        -- actualizar stock del almacén destino si aplica
        IF local_movement_type_name IN ('ENTRADA', 'TRASLADO') THEN
            INSERT INTO inventory_management.warehouses_stocks (warehouse_id, product_id, product_quantity)
            VALUES (in_warehouse_dest_id, in_product_id, in_product_quantity)
            ON CONFLICT (warehouse_id, product_id) DO UPDATE
                SET product_quantity            = inventory_management.warehouses_stocks.product_quantity +
                                                  EXCLUDED.product_quantity,
                    warehouse_stock_update_date = CURRENT_TIMESTAMP;
        END IF;

        -- registrar movimiento
        INSERT INTO inventory_management.movements (product_id, movement_type_id, warehouse_origin_id,
                                                    warehouse_dest_id, product_quantity, movement_observation, user_id)
        VALUES (in_product_id, in_movement_type_id, in_warehouse_origin_id, in_warehouse_dest_id,
                in_product_quantity, in_movement_observation, in_user_id);

        --** Fin del proceso

        success_message := 'Movimiento realizado con éxito.';

        -- parámetros de salida para log
        out_parameters := 'status_process:' || inventory_management.any_element_to_string(local_isSuccessProcess) || '|'
                              || 'message:' || inventory_management.any_element_to_string(success_message);

        -- registrar fin exitoso
        PERFORM inventory_management.register_log_output(
                id_log,
                out_parameters,
                '',
                '',
                '',
                '',
                success_code,
                success_message
                );

        RETURN QUERY SELECT local_isSuccessProcess, success_message;

    EXCEPTION
        WHEN SQLSTATE 'P0001' OR SQLSTATE 'P0002' THEN
            code_error := SQLSTATE;
            message_error := SQLERRM;
            RAISE NOTICE 'Excepción controlada: Código: %, Mensaje: %', code_error, message_error;

            PERFORM inventory_management.register_log_output(
                    id_log,
                    out_parameters,
                    '',
                    '',
                    code_error,
                    message_error,
                    '',
                    ''
                    );

            RETURN QUERY SELECT local_isSuccessProcess, message_error;

        WHEN OTHERS THEN
            code_error := SQLSTATE;
            message_error := SQLERRM;
            RAISE NOTICE 'Excepción general: Código: %, Mensaje: %', code_error, message_error;

            PERFORM inventory_management.register_log_output(
                    id_log,
                    out_parameters,
                    code_error,
                    message_error,
                    '',
                    '',
                    '',
                    ''
                    );

            RETURN QUERY SELECT local_isSuccessProcess, message_error;
    END;
END;
$BODY$;