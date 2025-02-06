-- ex_00
SELECT person_id, COUNT(*)
FROM (SELECT person_id
      FROM person_visits
               INNER JOIN person ON person_visits.person_id = person.id) AS table_1
GROUP BY person_id
ORDER BY 2 DESC, 1 ASC;
-- ex_01
SELECT name, COUNT(*)
FROM (SELECT name
      FROM person_visits
               INNER JOIN person ON person_visits.person_id = person.id) AS table_1
GROUP BY name
ORDER BY 2 DESC, 1 ASC LIMIT 4;
-- ex_02
WITH table_1 AS
         ((SELECT pizzeria_id, COUNT(*) AS count, 'order' AS action_type
           FROM person_order INNER JOIN menu
           ON person_order.menu_id = menu.id
           GROUP BY pizzeria_id
           ORDER BY 2 DESC
               LIMIT 3)
          UNION ALL
          (SELECT pizzeria_id, COUNT(*) AS count, 'visit' AS action_type
           FROM person_visits
           GROUP BY pizzeria_id
           ORDER BY 2 DESC
               LIMIT 3));

SELECT (SELECT name FROM pizzeria WHERE pizzeria.id = table_1.pizzeria_id), count, action_type
FROM table_1;
-- ex_03
WITH table_1 AS
         ((SELECT pizzeria_id, COUNT(*) AS count, 'order' AS action_type
           FROM person_order INNER JOIN menu
           ON person_order.menu_id = menu.id
           GROUP BY pizzeria_id
           ORDER BY 2 DESC)
          UNION ALL
          (SELECT pizzeria_id, COUNT(*) AS count, 'visit' AS action_type
           FROM person_visits
           GROUP BY pizzeria_id
           ORDER BY 2 DESC));

SELECT (SELECT name FROM pizzeria WHERE pizzeria.id = table_1.pizzeria_id), SUM(count) AS total_count
FROM table_1
GROUP BY pizzeria_id
ORDER BY 2 DESC;
-- ex_04
SELECT (SELECT name FROM person WHERE id = person_visits.person_id), COUNT(*) AS count
FROM person_visits
GROUP BY person_visits.person_id
HAVING COUNT (*) > 3;
-- ex_05
SELECT DISTINCT person.name
FROM person_order
         INNER JOIN person ON person_order.person_id = person.id
ORDER BY 1;
-- ex_06
SELECT name, COUNT(*), ROUND(AVG(price), 2), MAX(price), MIN(price)
FROM person_order
         INNER JOIN menu ON person_order.menu_id = menu.id
         INNER JOIN pizzeria ON menu.pizzeria_id = pizzeria.id
GROUP BY name
ORDER BY 1;
-- ex_07
SELECT ROUND(AVG(rating), 4)
FROM pizzeria;
-- ex_08
SELECT address, pizzeria.name, COUNT(*)
FROM person_order
         INNER JOIN menu ON person_order.menu_id = menu.id
         INNER JOIN person ON person_order.person_id = person.id
         INNER JOIN pizzeria ON menu.pizzeria_id = pizzeria.id
GROUP BY address, pizzeria.name
ORDER BY 1, 2;
-- ex_09
SELECT address,
       MAX(age) - (MIN(age) / MAX(age)) AS formul,
       ROUND(AVG(age), 2) AS avg,
       CASE
       WHEN MAX(age) - (MIN(age) / MAX(age)) > AVG(age) THEN true
       ELSE false
END
FROM person
GROUP BY address
ORDER BY 1;
