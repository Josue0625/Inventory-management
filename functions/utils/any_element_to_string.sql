CREATE OR REPLACE FUNCTION inventory_management.any_element_to_string(
    in_parameter anyelement
    )
    RETURNS TEXT
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS
$BODY$
    --
------------------------------------------------------------------------
--Objetivo: Convertir cualquier elemento en tipo text
------------------------------------------------------------------------
DECLARE

BEGIN
   IF in_parameter IS NULL THEN
       RETURN 'null';
ELSE
        RETURN in_parameter:: TEXT;
END IF;
END;
$BODY$;