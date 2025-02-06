-- ex_00
CREATE VIEW v_persons_female AS
SELECT *
FROM person
WHERE gender = 'female';

CREATE VIEW v_persons_male AS
SELECT *
FROM person
WHERE gender = 'male';
-- ex_01
(SELECT name
 FROM v_persons_female)
UNION
(SELECT name
 FROM v_persons_male)
ORDER BY 1;
-- ex_02
CREATE VIEW v_generated_dates AS
(
SELECT DATE (day) FROM generate_series('2022-01-01', '2022-01-31', INTERVAL '1 day') as day);
-- ex_03
(SELECT *
 FROM v_generated_dates)
EXCEPT
(SELECT visit_date FROM person_visits)
ORDER BY 1;
-- ex_04
CREATE VIEW v_symmetric_union AS
((SELECT person_id
  FROM person_visits
  WHERE visit_date = '2022-01-02')
 EXCEPT
 (SELECT person_id
  FROM person_visits
  WHERE visit_date = '2022-01-06'))
UNION
((SELECT person_id
  FROM person_visits
  WHERE visit_date = '2022-01-06')
 EXCEPT
 (SELECT person_id
  FROM person_visits
  WHERE visit_date = '2022-01-02'))
ORDER BY 1;
-- ex_05
CREATE VIEW v_price_with_discount AS
SELECT *
FROM (SELECT name,
             pizza_name,
             price,
             round(price - price * 0.1) AS discount_price
      FROM (SELECT person.name AS name, person_order.menu_id
            FROM person
                     INNER JOIN person_order ON person.id = person_order.person_id) AS table_1
               INNER JOIN menu ON menu.id = table_1.menu_id
      ORDER BY name, pizza_name) AS table_2;
-- ex_06
CREATE
MATERIALIZED VIEW mv_dmitriy_visits_and_eats AS
SELECT *
FROM (SELECT pizzeria_name
      FROM (SELECT select_1.name, select_1.visit_date, pizzeria.name AS pizzeria_name, pizzeria.id
            FROM (SELECT name, visit_date, pizzeria_id
                  FROM person
                           INNER JOIN person_visits ON person.id = person_visits.person_id
                  WHERE visit_date = '2022-01-08'
                    AND name = 'Dmitriy') AS select_1
                     INNER JOIN pizzeria ON pizzeria.id = select_1.pizzeria_id) AS select_2
               INNER JOIN menu ON menu.pizzeria_id = select_2.id
      WHERE price < 800) AS select_3;
-- ex_07
INSERT INTO person_visits(id, person_id, pizzeria_id, visit_date)
VALUES ((SELECT MAX(id) FROM person_visits) + 1, (SELECT id FROM person WHERE name = 'Dmitriy'),
        (SELECT id FROM pizzeria WHERE name = 'DoDo Pizza'), '2022-01-08');

REFRESH
MATERIALIZED VIEW mv_dmitriy_visits_and_eats;
-- ex_08
DROP
MATERIALIZED VIEW mv_dmitriy_visits_and_eats;
DROP VIEW v_generated_dates;
DROP VIEW v_persons_female;
DROP VIEW v_persons_male;
DROP VIEW v_price_with_discount;
DROP VIEW v_symmetric_union;
