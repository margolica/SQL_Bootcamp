-- ex_00
SELECT pizzeria.name, pizzeria.rating
FROM pizzeria
         LEFT OUTER JOIN person_visits ON pizzeria.id = person_visits.pizzeria_id
WHERE person_id IS NULL;
-- ex_01
SELECT missing_date
FROM (SELECT missing_date::date
      FROM generate_series('2022-01-01', '2022-01-10', INTERVAL '1 day') AS missing_date) AS table_0
         LEFT OUTER JOIN
     (SELECT visit_date, COUNT(*)
      FROM (SELECT person_id, visit_date
            FROM person_visits
            WHERE person_id = 1
               OR person_id = 2) AS table_1
      GROUP BY visit_date) AS table_2 ON visit_date = missing_date
WHERE table_2.count IS NULL
   OR table_2.count < 2;
-- ex_02
SELECT COALESCE(table_2.name, '-'), visit_date, COALESCE(pizzeria.name, '-')
FROM ((SELECT visit_date, person_id, pizzeria_id
       FROM person_visits
       WHERE visit_date BETWEEN '2022-01-01' AND '2022-01-03') AS table_1
    FULL JOIN person ON table_1.person_id = person.id) AS table_2
         FULL JOIN pizzeria ON table_2.pizzeria_id = pizzeria.id
ORDER BY 1, 2, 3;
-- ex_03
WITH table_0 AS ((SELECT missing_date::date
                  FROM generate_series('2022-01-01', '2022-01-10', INTERVAL '1 day') AS missing_date)),
     table_1 AS ((SELECT visit_date, COUNT(*)
                  FROM (SELECT person_id, visit_date
                        FROM person_visits
                        WHERE person_id = 1
                           OR person_id = 2) AS table_1
                  GROUP BY visit_date)),
     table_2 AS (SELECT *
                 FROM table_0
                          LEFT OUTER JOIN table_1 ON visit_date = missing_date)

SELECT missing_date
FROM table_2
WHERE table_2.count IS NULL
   OR table_2.count < 2;
-- ex_04
SELECT menu.pizza_name, pizzeria.name, menu.price
FROM pizzeria
         INNER JOIN menu ON pizzeria.id = menu.pizzeria_id
WHERE menu.pizza_name = 'pepperoni pizza'
   OR menu.pizza_name = 'mushroom pizza'
ORDER BY 1, 2;
-- ex_05
SELECT name
FROM person
WHERE age > 25
  AND gender = 'female'
ORDER BY 1;
-- ex_06
WITH table_0 AS
         (SELECT menu.pizza_name, pizzeria.name AS pizzeria_name, menu.id
          FROM menu
                   INNER JOIN pizzeria ON menu.pizzeria_id = pizzeria.id),
     table_1 AS
         (SELECT pizza_name, pizzeria_name, person_id
          FROM table_0
                   INNER JOIN person_order ON table_0.id = person_order.menu_id),
     table_2 AS
         (SELECT pizza_name, pizzeria_name
          FROM table_1
                   INNER JOIN person ON table_1.person_id = person.id
          WHERE person.name = 'Denis'
             OR person.name = 'Anna')
SELECT *
FROM table_2
ORDER BY 1, 2;
-- ex_07
WITH table_0 AS
         (SELECT menu.pizza_name, pizzeria.name AS pizzeria_name, pizzeria.id AS pizzeria_id, menu.price
          FROM menu
                   INNER JOIN pizzeria ON menu.pizzeria_id = pizzeria.id),
     table_1 AS
         (SELECT pizza_name, pizzeria_name, person_id, person_visits.visit_date, price
          FROM table_0
                   INNER JOIN person_visits ON table_0.pizzeria_id = person_visits.pizzeria_id
          WHERE person_visits.visit_date = '2022-01-08'),
     table_2 AS
         (SELECT pizza_name, pizzeria_name, price
          FROM table_1
                   INNER JOIN person ON table_1.person_id = person.id
          WHERE person.name = 'Dmitriy')
SELECT pizzeria_name
FROM table_2
WHERE price < 800;
-- ex_08
WITH table_0 AS
         (SELECT person.name, person_order.menu_id
          FROM person
                   INNER JOIN person_order ON person.id = person_order.person_id
          WHERE (person.address = 'Moscow' OR person.address = 'Samara')
            AND (person.gender = 'male')),
     table_1 AS
         (SELECT table_0.name, menu.pizza_name
          FROM table_0
                   INNER JOIN menu ON table_0.menu_id = menu.id
          WHERE menu.pizza_name = 'pepperoni pizza'
             OR menu.pizza_name = 'mushroom pizza')
SELECT name
FROM table_1
ORDER BY 1 DESC;
-- ex_09
SELECT name
FROM ((person INNER JOIN person_order ON person.id = person_order.person_id) AS table_1
    INNER JOIN menu ON table_1.menu_id = menu.id) table_2
WHERE pizza_name = 'pepperoni pizza'
  AND gender = 'female'
INTERSECT
SELECT name
FROM ((person INNER JOIN person_order ON person.id = person_order.person_id) AS table_1
    INNER JOIN menu ON table_1.menu_id = menu.id) table_2
WHERE pizza_name = 'cheese pizza'
  AND gender = 'female';
-- ex_10
SELECT table_1.name,
       table_2.name,
       table_1.address
FROM person table_1
         INNER JOIN person table_2 ON table_1.id > table_2.id AND table_1.address = table_2.address
ORDER BY 1, 2;
