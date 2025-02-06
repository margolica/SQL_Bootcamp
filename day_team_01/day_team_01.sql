-- ex_00
WITH c AS (SELECT currency.id, currency.name, currency.rate_to_usd
           FROM (SELECT id, MAX(updated)
                 FROM currency
                 GROUP BY id) AS d
                    JOIN currency ON currency.id = d.id AND currency.updated = d.max)
SELECT COALESCE("user".name, 'not defined')     AS name,
       COALESCE("user".lastname, 'not defined') AS lastname,
       balance.type,
       SUM(balance.money) AS value,
COALESCE(c.name, 'not defined') AS currency_name,
COALESCE(c.rate_to_usd, '1') AS last_rate_to_usd,
SUM(COALESCE(balance.money, '1'))*COALESCE(c.rate_to_usd, '1') AS total_volume_in_usd
FROM "user"
    FULL JOIN balance
ON "user".id = balance.user_id
    FULL JOIN c ON balance.currency_id = c.id
GROUP BY "user".name, "user".lastname, balance.type, c.name,
    last_rate_to_usd,
    c.rate_to_usd
ORDER BY name DESC, lastname, balance.type;
-- ex_01
insert into currency
values (100, 'EUR', 0.85, '2022-01-01 13:29');
insert into currency
values (100, 'EUR', 0.79, '2022-01-08 13:29');

CREATE VIEW table_1 AS
(
WITH table_0 AS
         (SELECT "user".name                                                                  AS name,
                 lastname                                                                     AS lastname,
                 (SELECT DISTINCT name FROM currency WHERE currency.id = balance.currency_id) AS name_currency,
                 balance.updated                                                              AS now_updated,
                 money                                                                        AS now_money,
                 currency_id
          FROM balance
                   LEFT JOIN "user" ON user_id = "user".id
          WHERE currency_id IN (SELECT id FROM currency))
SELECT *
FROM table_0
    );


SELECT COALESCE(name, 'not defined'),
       COALESCE(lastname, 'not defined'),
       name_currency,
       now_updated,
       COALESCE
       (
               now_money * (SELECT rate_to_usd
                            FROM currency
                            WHERE currency.updated = (SELECT MAX(currency.updated)
                                                      FROM currency
                                                      WHERE updated < now_updated
                                                        AND currency.name = name_currency))
           ,
               (SELECT now_money * rate_to_usd
                FROM currency
                WHERE currency.updated = (SELECT MIN(currency.updated)
                                          FROM currency
                                          WHERE updated > "now_updated"
                                            AND currency.name = name_currency)
                ORDER BY 1 DESC LIMIT 1 )
    )
FROM table_1
ORDER BY 1 DESC, 2, 3;