
SET VERIFY OFF
ALTER SESSION SET NLS_DATE_FORMAT = 'DD/MM/YYYY';

PROMPT ============================================================
PROMPT CASO 1: ANALISIS DE PROPIEDADES
PROMPT Ingrese el monto minimo de gasto comun total solicitado
PROMPT ============================================================

SELECT
    UPPER(tp.desc_tipo_propiedad) AS "TIPO PROPIEDAD",
    TO_CHAR(COUNT(p.nro_propiedad), '999G999') AS "CANTIDAD PROPIEDADES",
    TO_CHAR(MAX(p.valor_arriendo), '$999G999G999') AS "MAXIMO ARRIENDO",
    TO_CHAR(MIN(p.valor_arriendo), '$999G999G999') AS "MINIMO ARRIENDO",
    TO_CHAR(ROUND(AVG(p.valor_arriendo)), '$999G999G999') AS "PROMEDIO ARRIENDO",
    CASE
        WHEN MAX(p.valor_arriendo) > 1000000 THEN 'PREMIUM'
        ELSE 'ESTANDAR'
    END AS "CLASIFICACION",
    TO_CHAR(SUM(NVL(p.valor_gasto_comun, 0)), '$999G999G999') AS "TOTAL GASTO COMUN"
FROM propiedad p
JOIN tipo_propiedad tp
    ON tp.id_tipo_propiedad = p.id_tipo_propiedad
GROUP BY
    tp.desc_tipo_propiedad
HAVING SUM(NVL(p.valor_gasto_comun, 0)) > &VALOR_TOTAL_GASTO_COMUN
ORDER BY
    SUM(NVL(p.valor_gasto_comun, 0)) DESC;


PROMPT ============================================================
PROMPT CASO 2: ANALISIS DE ANTIGUEDAD DE EMPLEADOS
PROMPT Ingrese el codigo de sucursal que se debe excluir
PROMPT ============================================================

SELECT
    UPPER(e.appaterno_emp || ' ' || e.apmaterno_emp || ' ' || e.nombre_emp) AS "NOMBRE EMPLEADO",
    TO_CHAR(e.fecing_emp, 'DD/MM/YYYY') AS "FECHA INGRESO",
    TRUNC(MONTHS_BETWEEN(SYSDATE, e.fecing_emp) / 12) AS "ANIOS SERVICIO",
    TO_CHAR(e.sueldo_emp, '$999G999G999') AS "SUELDO",
    CASE
        WHEN e.sueldo_emp > 2000000 THEN 'ALTO'
        ELSE 'MEDIO'
    END AS "NIVEL SUELDO",
    TO_CHAR(
        ROUND(
            e.sueldo_emp *
            CASE
                WHEN TRUNC(MONTHS_BETWEEN(SYSDATE, e.fecing_emp) / 12)
                     BETWEEN 5 AND 10 THEN 0.05
                WHEN TRUNC(MONTHS_BETWEEN(SYSDATE, e.fecing_emp) / 12)
                     BETWEEN 11 AND 20 THEN 0.10
                WHEN TRUNC(MONTHS_BETWEEN(SYSDATE, e.fecing_emp) / 12)
                     > 20 THEN 0.15
                ELSE 0
            END
        ),
        '$999G999G999'
    ) AS "BONO ANTIGUEDAD"
FROM empleado e
WHERE e.id_categoria_emp = 3
  AND TRUNC(MONTHS_BETWEEN(SYSDATE, e.fecing_emp) / 12) > 5
  AND e.id_sucursal <> &CODIGO_SUCURSAL
ORDER BY
    e.sueldo_emp DESC;


PROMPT ============================================================
PROMPT CASO 3: LISTA Y CLASIFICACION DE CLIENTES
PROMPT ============================================================

SELECT
    CASE
        WHEN c.renta_cli >= 1000000 THEN 'PREMIUM'
        WHEN c.renta_cli >= 600000 THEN 'ALTA'
        WHEN c.renta_cli >= 300000 THEN 'MEDIA'
        ELSE 'BAJA'
    END AS "CLASIFICACION RENTA",
    COUNT(*) AS "CANTIDAD CLIENTES",
    TO_CHAR(ROUND(AVG(c.renta_cli)), '$999G999G999') AS "PROMEDIO RENTA",
    CASE
        WHEN SUM(
            CASE
                WHEN c.fonofijo_cli IS NOT NULL
                  OR c.celular_cli IS NOT NULL THEN 1
                ELSE 0
            END
        ) > 0
        THEN 'Clientes con Telefono'
        ELSE 'Clientes sin Telefono'
    END AS "DISPONIBILIDAD TELEFONO"
FROM cliente c
GROUP BY
    CASE
        WHEN c.renta_cli >= 1000000 THEN 'PREMIUM'
        WHEN c.renta_cli >= 600000 THEN 'ALTA'
        WHEN c.renta_cli >= 300000 THEN 'MEDIA'
        ELSE 'BAJA'
    END
HAVING AVG(c.renta_cli) > 200000
ORDER BY
    "CLASIFICACION RENTA";

PROMPT ============================================================
PROMPT FIN DEL SCRIPT
PROMPT ============================================================
