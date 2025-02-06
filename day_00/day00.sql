-- ex_00
SELECT name, age
FROM person
WHERE address = 'Kazan';
-- ex_01
SELECT name, age
FROM person
WHERE gender = 'female'
  AND address = 'Kazan'
ORDER BY name;
-- ex_02
SELECT name, rating
FROM pizzeria
WHERE rating <= 5
  AND rating >= 3.5
ORDER BY rating;

SELECT name, rating
FROM pizzeria
WHERE rating BETWEEN 3.5 AND 5
ORDER BY rating;
-- ex_03
SELECT DISTINCT person_id
FROM person_visits
WHERE (visit_date BETWEEN '2022-01-06' AND '2022-01-09')
   OR pizzeria_id = '2'
ORDER BY person_id DESC;
-- ex_04
SELECT name || ' (age:' || age || ',gender:''' || gender || ''',address''' || address || ''')' person_information
FROM person
ORDER BY person_information;
-- ex_05
SELECT (SELECT name FROM person WHERE person.id = person_order.person_id) AS name
FROM person_order
WHERE (menu_id = 13 OR menu_id = 14 OR menu_id = 18)
  AND (order_date = '2022-01-07');
-- ex_06
SELECT (SELECT name FROM person WHERE person.id = person_order.person_id) AS name,
       CASE
           WHEN (SELECT name FROM person WHERE person.id = person_order.person_id) = 'Denis' THEN 'true'
           ELSE 'false'
           END                                                            AS check_name
FROM person_order
WHERE (menu_id = 13 OR menu_id = 14 OR menu_id = 18)
  AND (order_date = '2022-01-07');
-- ex_07
SELECT id,
       name,
       CASE
           WHEN age >= 10 AND age <= 20
               THEN 'interval #1'
           ELSE CASE
                    WHEN age > 20 AND age < 24
                        THEN 'interval #2'
                    ELSE 'interval #3'
               END
           END AS interval_info
FROM person
-- ex_08
SELECT id, person_id, menu_id, order_date
FROM person_order
WHERE MOD(id, 2) = 0;
-- ex_09
SELECT (SELECT name FROM person WHERE person.id = p.person_id)       AS person_name,
       (SELECT name FROM pizzeria WHERE pizzeria.id = p.pizzeria_id) AS pizzeria_name
FROM (SELECT person_id, pizzeria_id FROM person_visits WHERE visit_date BETWEEN '2022-01-07' AND '2022-01-09') AS p
ORDER BY person_name, pizzeria_name DESC