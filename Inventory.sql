--para que busque en cc_user sino sale error,lo aprendi a las malas
SET
	SEARCH_PATH TO CC_USER;
-- Probar los 10 primeros registros
SELECT
	*
FROM
	PARTS
LIMIT
	10;

-- Mejorando el Seguimiento de Piezas
--1
--A
ALTER TABLE PARTS
ALTER COLUMN CODE
SET NOT NULL;

--B
ALTER TABLE PARTS
ADD CONSTRAINT UNIQUE_CODE UNIQUE (CODE);

--2(a y b) actualizar las descripciones
--A
UPDATE PARTS
SET
	DESCRIPTION = 'Sin descripción'
WHERE
	DESCRIPTION IS NULL;

--B
UPDATE PARTS
SET
	DESCRIPTION = 'Descripción de la pieza ' || CODE
WHERE
	DESCRIPTION IS NULL
	OR TRIM(DESCRIPTION) = '';

--3 restriccion para que no sea null o cadenas vacias
ALTER TABLE PARTS
ADD CONSTRAINT CHK_DESC_NOT_EMPTY CHECK (
	DESCRIPTION IS NOT NULL
	AND TRIM(DESCRIPTION) <> ''
);

--4(a y b) prueba de codigo
--A
INSERT INTO
	PARTS (CODE, MANUFACTURER_ID)
VALUES
	('TEST1', 1);

--B
INSERT INTO
	PARTS (CODE, DESCRIPTION, MANUFACTURER_ID)
VALUES
	('TEST01', 'Pieza de prueba con descripción', 1);

-- Mejorando las Opciones de Reordenamiento
-- 1 restriccion para que el precio no sea 0
ALTER TABLE REORDER_OPTIONS
ALTER COLUMN PRICE_USD
SET NOT NULL;

ALTER TABLE REORDER_OPTIONS
ALTER COLUMN QUANTITY
SET NOT NULL;

-- 2(a y b)  Restricciones check para valores mayores a 0
--A
ALTER TABLE REORDER_OPTIONS
ADD CONSTRAINT CHK_PRICE_AND_QTY_POSITIVE CHECK (
	PRICE_USD > 0
	AND QUANTITY > 0
);

--B
ALTER TABLE REORDER_OPTIONS
ADD CONSTRAINT CHK_PRICE_POSITIVE CHECK (PRICE_USD > 0);

ALTER TABLE REORDER_OPTIONS
ADD CONSTRAINT CHK_QUANTITY_POSITIVE CHECK (QUANTITY > 0);

-- 3 restricciones para el precio por unidad
ALTER TABLE REORDER_OPTIONS
ADD CONSTRAINT CHK_PRICE_PER_UNIT_RANGE CHECK (PRICE_USD / QUANTITY BETWEEN 0.02 AND 25.00);

--4 añadir llave foranea
ALTER TABLE CC_USER.REORDER_OPTIONS
ADD CONSTRAINT FK_REORDER_PARTS FOREIGN KEY (PART_ID) REFERENCES CC_USER.PARTS (ID);

--Mejorando el Seguimiento de Ubicaciones
--1 lo mismo que la 2(pasada)
ALTER TABLE CC_USER.LOCATIONS
ADD CONSTRAINT CHECK_QTY_POSITIVE CHECK (QTY > 0);

--2 restriccion unique compuesta
ALTER TABLE CC_USER.LOCATIONS
ADD CONSTRAINT UNIQUE_LOCATION_PART UNIQUE (LOCATION, PART_ID);

--3 añadir llave foranea
ALTER TABLE CC_USER.LOCATIONS
ADD CONSTRAINT FK_LOCATIONS_PARTS FOREIGN KEY (PART_ID) REFERENCES CC_USER.PARTS (ID);

--Mejorando el Seguimiento de Fabricantes
--1 llave foranea
ALTER TABLE CC_USER.PARTS
ADD CONSTRAINT FK_PARTS_MANUFACTURERS FOREIGN KEY (MANUFACTURER_ID) REFERENCES CC_USER.MANUFACTURERS (ID);

--2 agregar nuevo fabricante
INSERT INTO
	MANUFACTURERS (ID, NAME)
VALUES
	(11, 'Pip-NNC Industrial');

--3  actualizacion de relaciones
UPDATE PARTS
SET
	MANUFACTURER_ID = 11
WHERE
	MANUFACTURER_ID IN (1, 2);