-- ex_00
CREATE TABLE person_discounts
(
    id          BIGINT PRIMARY KEY,
    person_id   BIGINT  NOT NULL,
    pizzeria_id BIGINT  NOT NULL,
    discounts   NUMERIC NOT NULL,
    CONSTRAINT fk_person_discounts_person_id FOREIGN KEY (person_id) REFERENCES person (id),
    CONSTRAINT fk_person_discounts_pizzeria_id FOREIGN KEY (pizzeria_id) REFERENCES pizzeria (id)
);


SELECT id AS object_id, name AS object_name
FROM person
UNION ALL
SELECT id AS object_id, pizza_name AS object_name
FROM menu
ORDER BY object_id, object_name;
-- ex_01
INSERT INTO person_discounts (id, person_id, pizzeria_id, discounts)
SELECT ROW_NUMBER()        OVER () AS id, person_order.person_id AS person_id,
       menu.pizzeria_id AS pizzeria_id,
       CASE
           WHEN (COUNT(*) = 1) THEN 10.5
           WHEN (COUNT(*) = 2) THEN 22
           ELSE 30
           END          AS discount
FROM person_order
         INNER JOIN menu ON menu.id = person_order.menu_id
GROUP BY person_id, pizzeria_id;
-- ex_02
SELECT person.name,
       menu.pizza_name,
       price,
       (price - (price * discounts / 100)) AS price_on_discounts,
       pizza_name
FROM person_order
         INNER JOIN person ON person_order.person_id = person.id
         INNER JOIN menu ON person_order.menu_id = menu.id
         INNER JOIN pizzeria ON menu.pizzeria_id = pizzeria.id
         INNER JOIN person_discounts ON person_order.person_id = person_discounts.person_id AND
                                        person_discounts.pizzeria_id = pizzeria.id
ORDER BY 1, 2;
-- ex_03
CREATE UNIQUE INDEX idx_person_discounts_unique ON person_discounts (person_id, pizzeria_id);

SET
enable_seqscan = OFF;

EXPLAIN
ANALYZE
SELECT person_id, pizzeria_id
FROM person_discounts;
-- ex_04
ALTER TABLE person_discounts
    ADD CONSTRAINT ch_nn_person_id CHECK (person_id IS NOT NULL);
ALTER TABLE person_discounts
    ADD CONSTRAINT ch_nn_pizzeria_id CHECK (pizzeria_id IS NOT NULL);
ALTER TABLE person_discounts
    ADD CONSTRAINT ch_nn_discount CHECK (discounts IS NOT NULL);
ALTER TABLE person_discounts
    ALTER COLUMN discounts SET DEFAULT 0;
ALTER TABLE person_discounts
    ADD CONSTRAINT ch_range_discount CHECK (discounts < 100 AND discounts >= 0);
-- ex_05
COMMENT
ON COLUMN person_discounts.id IS 'Суперключ';
COMMENT
ON COLUMN person_discounts.person_id IS 'Человек';
COMMENT
ON COLUMN person_discounts.pizzeria_id IS 'Суперключ шаурмы';
COMMENT
ON COLUMN person_discounts.discounts IS 'Бесполезная скидка';
COMMENT
on table person_discounts is 'qwerty';
-- ex_06
CREATE SEQUENCE seq_person_discounts START WITH 1;

ALTER TABLE person_discounts
    ALTER COLUMN id SET DEFAULT nextval('seq_person_discounts')

SELECT setval('seq_person_discounts', (SELECT COUNT(*) + 1 FROM person_discounts));
