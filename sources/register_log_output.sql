CREATE OR REPLACE FUNCTION inventory_management.register_log_output(
    current_id_logs integer,
    parameters_output text,
    code_error_database character varying,
    message_error_database character varying,
    code_error_checked character varying,
    message_error_checked character varying,
    code_success_checked character varying,
    message_success_checked character varying)
    RETURNS void
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS
$BODY$

DECLARE
codigo_error  TEXT;
    mensaje_error TEXT;

BEGIN

BEGIN

UPDATE inventory_management.logs
SET log_parameters_output          = register_log_output.parameters_output,
    log_code_error_database        = register_log_output.code_error_database,
    log_message_error_database     = register_log_output.message_error_database,
    log_code_error_checked         = register_log_output.code_error_checked,
    log_message_error_checked      = register_log_output.message_error_checked,
    log_code_success_checked       = register_log_output.code_success_checked,
    log_message_success_checked    = register_log_output.message_success_checked,
    log_response_time_milliseconds = (EXTRACT(EPOCH FROM (CLOCK_TIMESTAMP() - log_date_input)) * 1000)::int,
            log_date_output                = CLOCK_TIMESTAMP()
WHERE log_id = register_log_output.current_id_logs;

EXCEPTION

        WHEN OTHERS THEN
            codigo_error := SQLSTATE;
            mensaje_error := SQLERRM;

            RAISE NOTICE 'Se ha producido una excepciÃ³n:';
            RAISE NOTICE 'CÃ³digo de error: %', codigo_error;
            RAISE NOTICE 'Mensaje de error: %', mensaje_error;
END;

END;
$BODY$;


