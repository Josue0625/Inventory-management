-- Test de activar una cuenta
DO
$$
    DECLARE
        --salidas
        ----------------------------------
local_process_status BOOLEAN;
        activate_account BOOLEAN;
        message        TEXT;
BEGIN
BEGIN
SELECT *
INTO local_process_status, activate_account, message
FROM agro_web.activate_account(
        in_auth_id := 1,
        in_activate_code := 'va3e'
     );

RAISE NOTICE 'status_process: %' , local_process_status::TEXT;
            RAISE NOTICE 'message: %' , message::TEXT;
            RAISE NOTICE 'activate_account: %' , activate_account::TEXT;

            IF local_process_status::BOOLEAN = FALSE THEN
                RAISE EXCEPTION 'PROCESO FALLO.';
END IF;


EXCEPTION
            WHEN OTHERS THEN
                RAISE NOTICE 'Se ha producido una excepción realizando test';

                RAISE NOTICE 'Se ha producido una excepción:';
                RAISE NOTICE 'Código de error: %', SQLSTATE;
                RAISE NOTICE 'Mensaje de error: %', SQLERRM;
END;
END;
$$;