-- ex_00
SELECT id AS object_id, pizza_name AS object_name
FROM menu
UNION
SELECT id AS object_id, name AS object_name
FROM person
ORDER BY object_id, object_name;
-- ex_01
(SELECT name AS object_name
 FROM person
 ORDER BY name)
UNION ALL
(SELECT pizza_name AS object_name
 FROM menu
 ORDER BY pizza_name);
-- ex_02
SELECT pizza_name
FROM menu
UNION
SELECT pizza_name
FROM menu
ORDER BY pizza_name DESC;
-- ex_03
SELECT order_date AS action_date, person_id
FROM person_order
INTERSECT
SELECT visit_date AS action_date, person_id
FROM person_visits
ORDER BY action_date, person_id DESC;
-- ex_04
(SELECT person_id
 FROM person_order
 WHERE person_order.order_date = '2022-01-07')
EXCEPT ALL
(SELECT person_id
 FROM person_visits
 WHERE person_visits.visit_date = '2022-01-07');
-- ex_05
SELECT *
FROM person
         CROSS JOIN pizzeria
ORDER BY person.id, pizzeria.id;
-- ex_06
SELECT order_date                                                         AS action_date,
       (SELECT name FROM person WHERE person_order.person_id = person.id) AS person_name
FROM person_order
INTERSECT
SELECT order_date                                                         AS action_date,
       (SELECT name FROM person WHERE person_order.person_id = person.id) AS person_name
FROM person_order
ORDER BY action_date, person_name DESC;
-- ex_07
SELECT order_date,
       (SELECT name || ' (age:' || age || ')'
        FROM person
        WHERE person_order.person_id = person.id) AS person_information
FROM person_order
ORDER BY order_date, person_information;
-- ex_08
SELECT order_date,
       (SELECT name || ' (возраст:' || age || ')'
        FROM person
        WHERE person_order.person_id = person.id) AS person_information
FROM person_order
         NATURAL LEFT JOIN person
ORDER BY order_date, person_information;
-- ex_09
SELECT name
FROM pizzeria
WHERE pizzeria.id NOT IN (SELECT pizzeria_id FROM person_visits);

SELECT name
FROM pizzeria
WHERE NOT EXISTS(SELECT pizzeria_id
                 FROM person_visits
                 WHERE pizzeria.id = person_visits.pizzeria_id);
-- ex_10
SELECT person.name, menu.pizza_name, pizzeria.name
FROM person_order
         INNER JOIN person ON person_order.person_id = person.id
         INNER JOIN menu ON person_order.menu_id = menu.id
         INNER JOIN pizzeria ON menu.pizzeria_id = pizzeria.id
ORDER BY person.name;