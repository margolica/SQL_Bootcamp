-- ex_00
CREATE TABLE person_audit
(
    created    timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    type_event char(1)                  DEFAULT 'I'               NOT NULL,
    row_id     bigint                                             NOT NULL,
    name       varchar,
    age        integer,
    gender     varchar,
    address    varchar
);

ALTER TABLE person_audit
    ADD CONSTRAINT ch_type_event
        CHECK (type_event = 'I' OR type_event = 'U' OR type_event = 'D');

CREATE
OR REPLACE FUNCTION fnc_trg_person_insert_audit() RETURNS TRIGGER AS $person_audit$
BEGIN
IF
(TG_OP = 'INSERT') THEN
    INSERT INTO person_audit
SELECT CURRENT_TIMESTAMP, 'I', NEW.*;
END IF;
RETURN NULL;
END;
$person_audit$
LANGUAGE plpgsql;
-- $person_audit$ Тело функции

CREATE TRIGGER trg_person_insert_audit
    AFTER INSERT
    ON person
    FOR EACH ROW EXECUTE FUNCTION fnc_trg_person_insert_audit();

INSERT INTO person(id, name, age, gender, address)
VALUES (10, 'Damir', 22, 'male', 'Irkutsk');
-- ex_01
CREATE
OR REPLACE FUNCTION fnc_trg_person_update_audit() RETURNS TRIGGER AS $person_audit$
BEGIN
IF
(TG_OP = 'UPDATE') THEN
    INSERT INTO person_audit
SELECT CURRENT_TIMESTAMP, 'U', NEW.*;
END IF;
RETURN NULL;
END;
$person_audit$
LANGUAGE plpgsql;
-- $person_audit$ Тело функции

CREATE TRIGGER trg_person_update_audit
    AFTER UPDATE
    ON person
    FOR EACH ROW EXECUTE FUNCTION fnc_trg_person_update_audit();

UPDATE person
SET name = 'Bulat'
WHERE id = 10;
UPDATE person
SET name = 'Damir'
WHERE id = 10;
-- ex_02
CREATE
OR REPLACE FUNCTION fnc_trg_person_delete_audit() RETURNS TRIGGER AS $person_audit$
BEGIN
IF
(TG_OP = 'DELETE') THEN
    INSERT INTO person_audit
SELECT CURRENT_TIMESTAMP, 'D', OLD.*;
END IF;
RETURN NULL;
END;
$person_audit$
LANGUAGE plpgsql;
-- $person_audit$ Тело функции

CREATE TRIGGER trg_person_delete_audit
    AFTER DELETE
    ON person
    FOR EACH ROW EXECUTE FUNCTION fnc_trg_person_delete_audit();

DELETE
FROM person
WHERE id = 10;
-- ex_03
drop trigger trg_person_delete_audit on person cascade;
drop trigger trg_person_update_audit on person cascade;
drop trigger trg_person_delete_audit on person cascade;

drop function fnc_trg_person_delete_audit() cascade;
drop function fnc_trg_person_insert_audit() cascade;
drop function fnc_trg_person_update_audit() cascade;

TRUNCATE TABLE person_audit;

CREATE
OR REPLACE FUNCTION fnc_trg_person_audit() RETURNS TRIGGER AS $person_audit$
BEGIN
IF
(TG_OP = 'INSERT') THEN
    INSERT INTO person_audit
SELECT CURRENT_TIMESTAMP, 'I', NEW.*;
ELSEIF
(TG_OP = 'UPDATE') THEN
    INSERT INTO person_audit
SELECT CURRENT_TIMESTAMP, 'U', NEW.*;
ELSEIF
(TG_OP = 'DELETE') THEN
    INSERT INTO person_audit
SELECT CURRENT_TIMESTAMP, 'D', OLD.*;
END IF;
RETURN NULL;
END;
$person_audit$
LANGUAGE plpgsql;

CREATE TRIGGER trg_person_audit
    AFTER INSERT OR
UPDATE OR
DELETE
ON person
    FOR EACH ROW EXECUTE FUNCTION fnc_trg_person_audit();

INSERT INTO person(id, name, age, gender, address)
VALUES (10, 'Damir', 22, 'male', 'Irkutsk');
UPDATE person
SET name = 'Bulat'
WHERE id = 10;
UPDATE person
SET name = 'Damir'
WHERE id = 10;
DELETE
FROM person
WHERE id = 10;
-- ex_04
CREATE FUNCTION fnc_persons_female()
    RETURNS TABLE
            (
                id      bigint,
                name    varchar,
                age     integer,
                gender  varchar,
                address varchar
            ) AS
$$
SELECT id, name, age, gender, address
FROM person
WHERE gender = 'female';
$$
LANGUAGE SQL;

SELECT *
FROM fnc_persons_female();

CREATE FUNCTION fnc_persons_male()
    RETURNS TABLE
            (
                id      bigint,
                name    varchar,
                age     integer,
                gender  varchar,
                address varchar
            ) AS
$$
SELECT id, name, age, gender, address
FROM person
WHERE gender = 'male';
$$
LANGUAGE SQL;

SELECT *
FROM fnc_persons_male();
-- ex_05
DROP FUNCTION fnc_persons_female CASCADE;
DROP FUNCTION fnc_persons_male CASCADE;

CREATE FUNCTION fnc_persons(IN pgender varchar DEFAULT 'female')
    RETURNS TABLE
            (
                id      bigint,
                name    varchar,
                age     integer,
                gender  varchar,
                address varchar
            ) AS
$$
SELECT id, name, age, person.gender, address
FROM person
WHERE person.gender = $1;
$$
LANGUAGE SQL;

select *
from fnc_persons('male');

select *
from fnc_persons();
-- ex_06
CREATE FUNCTION fnc_person_visits_and_eats_on_date(IN pperson varchar DEFAULT 'Dmitriy',
                                                   IN pprice numeric DEFAULT 500, IN pdate date DEFAULT '2022-01-08')
    RETURNS TABLE
            (
                name varchar
            ) AS
$$
SELECT pizzeria.name
FROM person_visits
         INNER JOIN menu ON person_visits.pizzeria_id = menu.pizzeria_id
         INNER JOIN pizzeria ON person_visits.pizzeria_id = pizzeria.id
         INNER JOIN person ON person_visits.person_id = person.id
WHERE person.name = $1
  AND price < $2
  AND visit_date = $3;
$$
LANGUAGE SQL;

select *
from fnc_person_visits_and_eats_on_date(pprice := 800);

select *
from fnc_person_visits_and_eats_on_date(pperson := 'Anna', pprice := 1300, pdate := '2022-01-01');

-- ex_07
CREATE FUNCTION func_minimum(IN arr numeric []) RETURNS numeric AS
    $$
SELECT MIN(value) AS min_value
FROM UNNEST(arr) AS value;
$$
LANGUAGE SQL;

SELECT func_minimum(VARIADIC arr => ARRAY[10.0, -1.0, 5.0, 4.4]);
