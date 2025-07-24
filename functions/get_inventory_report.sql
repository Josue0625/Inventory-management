CREATE OR REPLACE FUNCTION inventory_management.get_inventory_report(
    in_user_id INTEGER,
    in_start_date DATE,
    in_end_date DATE
)
    RETURNS TABLE
            (
                status_process   BIT,
                message          TEXT,
                inventory_report JSON
            )
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS
$BODY$
DECLARE
    code_error             TEXT DEFAULT ''; -- variable para almacenar códigos de errores
    message_error          TEXT DEFAULT ''; -- variable para almacenar mensajes de errores

    id_log                 INTEGER; -- variable para log

    in_parameters          TEXT DEFAULT ''; -- variable para almacenar los parámetros de entrada y registrarlos en log
    out_parameters         TEXT DEFAULT ''; -- variable para almacenar los parámetros de salida y registrarlos en log

    success_code           VARCHAR(20) DEFAULT 'P0000'; -- variable para asignar código de proceso exitoso
    success_message        TEXT DEFAULT 'Transacción exitosa.'; -- variable para asignar mensaje de proceso exitoso
    error_code_checked     VARCHAR(20) DEFAULT 'P0001'; -- código de error controlado por validación de parámetros

    -- variables locales
    local_isSuccessProcess BIT DEFAULT 0;
    local_user_code        TEXT;
    report                 JSON;

BEGIN
    -- asignación de parámetros de entrada
    in_parameters := 'in_user:' ||
                     inventory_management.any_element_to_string(in_user_id) || '|'
                         || 'in_start_date:' ||
                     inventory_management.any_element_to_string(in_start_date) || '|'
                         || 'in_end_date:' ||
                     inventory_management.any_element_to_string(in_end_date);

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

        -- Validar que no vengan vacías las fechas
        IF in_start_date IS NULL OR in_end_date IS NULL THEN
            RAISE EXCEPTION 'Debe proporcionar un rango de fechas válido.' USING ERRCODE = error_code_checked;
        END IF;

        -- Construir el JSON del reporte
        SELECT JSON_AGG(ROW_TO_JSON(report_row))
        INTO report
        FROM (SELECT ws.product_id,
                     p.product_name,
                     ws.warehouse_id,
                     w.warehouse_code,
                     w.capacity,
                     ws.product_quantity        AS current_stock,
                     ws.warehouse_stock_minimum,
                     CASE
                         WHEN ws.product_quantity < ws.warehouse_stock_minimum THEN 'STOCK BAJO'
                         ELSE 'OK' END          AS product_stock,
                     COALESCE(e.total_entry, 0) AS total_entries,
                     COALESCE(o.total_out, 0)   AS total_outs
              FROM inventory_management.warehouses_stocks ws
                       INNER JOIN inventory_management.products p ON p.product_id = ws.product_id
                       INNER JOIN inventory_management.warehouses w ON w.warehouse_id = ws.warehouse_id
                       LEFT JOIN (SELECT m.product_id,
                                         m.warehouse_dest_id     AS warehouse_id,
                                         SUM(m.product_quantity) AS total_entry
                                  FROM inventory_management.movements m
                                           JOIN inventory_management.movements_types mt
                                                ON mt.movement_type_id = m.movement_type_id
                                  WHERE mt.movement_type_name IN ('ENTRADA', 'TRASLADO')
                                    AND m.movement_register_date::DATE BETWEEN in_start_date AND in_end_date
                                  GROUP BY m.product_id, m.warehouse_dest_id) e
                                 ON e.product_id = ws.product_id AND e.warehouse_id = ws.warehouse_id

                       LEFT JOIN (SELECT m.product_id,
                                         m.warehouse_origin_id   AS warehouse_id,
                                         SUM(m.product_quantity) AS total_out
                                  FROM inventory_management.movements m
                                           JOIN inventory_management.movements_types mt
                                                ON mt.movement_type_id = m.movement_type_id
                                  WHERE mt.movement_type_name IN ('SALIDA', 'TRASLADO')
                                    AND m.movement_register_date::DATE BETWEEN in_start_date AND in_end_date
                                  GROUP BY m.product_id, m.warehouse_origin_id) o
                                 ON o.product_id = ws.product_id AND o.warehouse_id = ws.warehouse_id
              WHERE ws.warehouse_stock_creation_date::DATE BETWEEN in_start_date AND in_end_date
              ORDER BY ws.product_id) report_row;

        --** Fin del proceso

        success_message := 'Reporte generado exitosamente.';

        -- parámetros de salida para log
        out_parameters := 'status_process:' ||
                          inventory_management.any_element_to_string(local_isSuccessProcess) || '|'
                              || 'message:' ||
                          inventory_management.any_element_to_string(success_message) || '|'
                              || 'inventory_report:' ||
                          inventory_management.any_element_to_string(report);

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

        RETURN QUERY SELECT local_isSuccessProcess, success_message, report;

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

            RETURN QUERY SELECT local_isSuccessProcess, message_error, report;

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

            RETURN QUERY SELECT local_isSuccessProcess, message_error, report;
    END;
END;
$BODY$;