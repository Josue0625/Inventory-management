CREATE OR REPLACE FUNCTION inventory_management.register_log_entry(
    in_user_id CHARACTER VARYING,
	name_object CHARACTER VARYING,
	parameters_input TEXT)
    RETURNS integer
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$

DECLARE
    code_error         TEXT;
    message_error      TEXT;
    id_log_output	   INTEGER;

BEGIN

    BEGIN

    INSERT INTO inventory_management.logs(user_code, log_name_object, log_parameters_input, log_date_input )
    VALUES  (in_user_id, name_object, parameters_input, clock_timestamp())
        RETURNING log_id INTO id_log_output;

    EXCEPTION

            WHEN OTHERS  THEN

                code_error := SQLSTATE;
                message_error := SQLERRM;

                RAISE NOTICE 'Se ha producido una excepciÃ³n:';
                RAISE NOTICE 'CÃ³digo de error: %', code_error;
                RAISE NOTICE 'Mensaje de error: %', message_error;
    END;

    RETURN  id_log_output;

END;
$BODY$;