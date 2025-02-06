-- ex_00
CREATE INDEX idx_menu_pizzeria_id ON menu (pizzeria_id);
CREATE INDEX idx_person_order_person_id ON person_order (person_id)
CREATE INDEX idx_person_order_menu_id ON person_order (menu_id);
CREATE INDEX idx_person_visits_person_id ON person_visits (person_id);
CREATE INDEX idx_person_visits_pizzeria_id ON person_visits (pizzeria_id);
-- ex_01
SET
enable_seqscan = OFF;

EXPLAIN
ANALYZE
SELECT menu.pizza_name, pizzeria.name
FROM menu
         JOIN pizzeria ON menu.pizzeria_id = pizzeria.id;
-- ex_02
CREATE INDEX idx_person_name ON person (UPPER(name));

SET
enable_seqscan = OFF;

EXPLAIN
ANALYZE
SELECT name
FROM person
WHERE UPPER(name) = 'DENIS';
-- ex_03
CREATE INDEX idx_person_order_multi ON person_order (person_id, menu_id);

SET
enable_seqscan = OFF;

EXPLAIN
ANALYZE
SELECT person_id, menu_id, order_date
FROM person_order
WHERE person_id = 8
  AND menu_id = 19;
-- ex_04
CREATE UNIQUE INDEX idx_menu_unique ON menu (pizzeria_id, pizza_name);

SET
enable_seqscan = OFF;

EXPLAIN
ANALYZE
SELECT pizzeria_id, pizza_name
FROM menu EXPLAIN ANALYZE
INSERT
INTO menu (id, pizzeria_id, pizza_name, price)
VALUES (21, 1, 'greek pizza', 600);

EXPLAIN
ANALYZE
INSERT INTO menu (id, pizzeria_id, pizza_name, price)
VALUES (21, 1, 'cheese pizza', 600);

SELECT *
FROM menu;
-- ex_05
CREATE UNIQUE INDEX idx_person_order_order_date ON person_order (person_id, menu_id) WHERE order_date = '2022-01-01'

SET enable_seqscan = OFF;

EXPLAIN
ANALYZE
SELECT person_id, menu_id
FROM person_order
WHERE order_date = '2022-01-01' EXPLAIN ANALYZE
INSERT
INTO person_order (person_id, menu_id, order_date)
VALUES (10, 10, 2022-01-01);
-- ex_06
SET
enable_seqscan = ON;

EXPLAIN
ANALYZE
SELECT m.pizza_name AS pizza_name,
       max(rating)     OVER (PARTITION BY rating ORDER BY rating ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS k
FROM menu m
         INNER JOIN pizzeria pz ON m.pizzeria_id = pz.id
ORDER BY 1, 2;

CREATE INDEX idx_1 ON pizzeria (rating) SET enable_seqscan = OFF;

EXPLAIN
ANALYZE
SELECT m.pizza_name AS pizza_name,
       max(rating)     OVER (PARTITION BY rating ORDER BY rating ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS k
FROM menu m
         INNER JOIN pizzeria pz ON m.pizzeria_id = pz.id
ORDER BY 1, 2;

DROP INDEX idx_1;