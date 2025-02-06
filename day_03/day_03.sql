-- ex_00
WITH table_1 AS (SELECT menu.price       AS price,
                        menu.pizza_name  AS pizza_name,
                        pizzeria.name    AS pizzeria_name,
                        menu.pizzeria_id AS pizzeria_id
                 FROM menu
                          INNER JOIN pizzeria ON menu.pizzeria_id = pizzeria.id
                 WHERE menu.price BETWEEN 800 AND 1000),
     table_2 AS (SELECT pizzeria_name, price, pizza_name, visit_date, person_id
                 FROM table_1
                          INNER JOIN person_visits ON person_visits.pizzeria_id = table_1.pizzeria_id),
     table_3 AS (SELECT *
                 FROM table_2
                          INNER JOIN person ON person.id = person_id
                 WHERE person.name = 'Kate');

SELECT pizza_name, price, pizzeria_name, visit_date
FROM table_3
ORDER BY 1, 2;
-- ex_01
SELECT menu.id AS menu_id
FROM menu
         LEFT OUTER JOIN person_order ON menu.id = person_order.menu_id
WHERE person_id IS NULL
ORDER BY menu_id;
-- ex_02
WITH table_1 AS (SELECT *
                 FROM person
                          INNER JOIN person_order ON person_order.person_id = person.id),
     table_2 AS (SELECT *
                 FROM table_1
                          RIGHT JOIN menu ON menu.id = table_1.menu_id);

SELECT pizza_name, price, pizzeria.name
FROM table_2
         INNER JOIN pizzeria ON pizzeria.id = table_2.pizzeria_id
WHERE person_id IS NULL
ORDER BY 1;
-- ex_03
WITH table_1 AS (SELECT pizzeria_id, gender
                 FROM person_visits
                          INNER JOIN person ON person.id = person_visits.person_id),
     table_2 AS (SELECT pizzeria_id, gender, pizzeria.name AS name
                 FROM table_1
                          INNER JOIN pizzeria ON pizzeria.id = table_1.pizzeria_id),
     table_female AS (SELECT pizzeria_id, COUNT(*) AS all
FROM (SELECT pizzeria_id, gender FROM table_2 WHERE gender = 'female') AS temp_1
GROUP BY pizzeria_id),
    table_male AS (
SELECT pizzeria_id, COUNT (*) AS all
FROM (SELECT pizzeria_id, gender FROM table_2 WHERE gender = 'male') AS temp_2
GROUP BY pizzeria_id);

SELECT pizzeria.name AS pizzeria_name
FROM pizzeria
         INNER JOIN table_female ON pizzeria.id = table_female.pizzeria_id
         INNER JOIN table_male ON table_male.pizzeria_id = pizzeria.id
WHERE (table_male.all - table_female.all) > 0
   OR (table_male.all - table_female.all) < 0
ORDER BY 1;
-- ex_04
WITH table_1 AS (SELECT person_id, pizzeria_id
                 FROM person_order
                          INNER JOIN menu ON person_order.menu_id = menu.id),
     table_2 AS (SELECT person_id, name AS pizza_name
                 FROM table_1
                          INNER JOIN pizzeria ON table_1.pizzeria_id = pizzeria.id),
     table_3 AS (SELECT name, gender, pizza_name
                 FROM table_2
                          INNER JOIN person ON table_2.person_id = person.id),
     table_4 AS (SELECT pizza_name FROM table_3 WHERE gender = 'male'),
     table_5 AS (SELECT pizza_name FROM table_3 WHERE gender = 'female');


(SELECT *
 FROM table_4
 EXCEPT
 SELECT *
 FROM table_5)
UNION
(SELECT *
 FROM table_5
 EXCEPT
 SELECT *
 FROM table_4);
-- ex_05
WITH table_1 AS (SELECT name, pizzeria_id
                 FROM person_visits
                          INNER JOIN person ON person_visits.person_id = person.id
                 WHERE name = 'Andrey'),
     table_1_1 AS (SELECT pizzeria.name AS pizza_name
                   FROM table_1
                            INNER JOIN pizzeria ON table_1.pizzeria_id = pizzeria.id),

     table_2 AS (SELECT name, menu_id
                 FROM person_order
                          INNER JOIN person ON person_order.person_id = person.id
                 WHERE name = 'Andrey'),
     table_2_1 AS (SELECT menu.pizzeria_id
                   FROM table_2
                            INNER JOIN menu ON menu.id = table_2.menu_id),
     table_2_2 AS (SELECT name
                   FROM table_2_1
                            INNER JOIN pizzeria ON table_2_1.pizzeria_id = pizzeria.id);


SELECT *
FROM table_1_1
EXCEPT
SELECT *
FROM table_2_2
ORDER BY 1;
-- ex_06
WITH table_1 AS (SELECT pizzeria_id, pizzeria.name AS pizzaria_name, pizza_name, price
                 FROM menu
                          INNER JOIN pizzeria ON menu.pizzeria_id = pizzeria.id
                 ORDER BY 2);

SELECT select_1.pizza_name,
       select_1.pizzaria_name AS pizzeria_name_1,
       select_2.pizzaria_name AS pizzeria_name_2,
       select_1.price
FROM (SELECT *
      FROM table_1) AS select_1
         INNER JOIN
     (SELECT *
      FROM table_1) AS select_2
     ON select_1.price = select_2.price AND select_1.pizzaria_name != select_2.pizzaria_name AND
        select_1.pizza_name = select_2.pizza_name AND select_1.pizzeria_id > select_2.pizzeria_id
ORDER BY 1;
-- ex_07
INSERT INTO menu (id, pizzeria_id, pizza_name, price)
SELECT 19, 2, 'greek pizza', 800;

SELECT *
FROM menu
-- ex_08
    INSERT
INTO menu (id, pizzeria_id, pizza_name, price)
SELECT (SELECT MAX(id) FROM menu) + 1, (SELECT id FROM pizzeria WHERE name = 'Dominos'), 'sicilian pizza', 900;

SELECT *
FROM menu
-- ex_09
    INSERT
INTO person_visits(id, person_id, pizzeria_id, visit_date)
VALUES ((SELECT MAX (id) FROM person_visits) + 1, (SELECT id FROM person WHERE name = 'Denis'), (SELECT id FROM pizzeria WHERE name = 'Dominos'), '2022-02-24');


INSERT INTO person_visits(id, person_id, pizzeria_id, visit_date)
VALUES ((SELECT MAX(id) FROM person_visits) + 1, (SELECT id FROM person WHERE name = 'Irina'),
        (SELECT id FROM pizzeria WHERE name = 'Dominos'), '2022-02-24');

SELECT *
FROM person_visits;
-- ex_10
INSERT INTO person_order(id, person_id, menu_id, order_date)
VALUES ((SELECT MAX(id) FROM person_order) + 1, (SELECT id FROM person WHERE name = 'Denis'),
        (SELECT id FROM menu WHERE pizza_name = 'sicilian pizza'), '2022-02-24');

INSERT INTO person_order(id, person_id, menu_id, order_date)
VALUES ((SELECT MAX(id) FROM person_order) + 1, (SELECT id FROM person WHERE name = 'Irina'),
        (SELECT id FROM menu WHERE pizza_name = 'sicilian pizza'), '2022-02-24');


SELECT *
FROM person_order;
-- ex_11
UPDATE menu
SET price = price * 0.9
WHERE pizza_name = 'greek pizza';

SELECT *
FROM menu;
-- ex_12
INSERT INTO person_order (id, person_id, menu_id, order_date)
SELECT p_id + (SELECT MAX(id) FROM person_order) AS id,
       p_id,
       (SELECT id FROM menu WHERE menu.pizza_name = 'greek pizza'),
       '2022-02-25'                              AS order_date
FROM person
         INNER JOIN generate_series(1, 9, 1) AS p_id ON p_id = person.id;

SELECT *
FROM person_order;
-- ex_13
DELETE
FROM person_order
WHERE order_date = '2022-02-25';

DELETE
FROM menu
WHERE id = 19;

SELECT *
FROM person_order;

SELECT *
FROM menu;