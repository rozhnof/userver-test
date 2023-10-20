-- Заполним таблицу production_line данными
INSERT INTO production_line (money_cost_per_hour)
SELECT floor(random() * 901 + 100)::integer FROM generate_series(1, 5);

-- Заполним таблицу item данными
INSERT INTO item (name, time_cost_hour)
SELECT
  'GTX ' || (1080 + (row_number() over (order by random())) * 100),
  floor(random() * 47 + 2)::integer
FROM generate_series(1, 20);

-- Заполним таблицу orders данными
INSERT INTO orders (start_date, end_date, total_cost)
SELECT
  current_timestamp - floor(random() * 30 + 1)::integer * interval '1 day',
  current_timestamp + floor(random() * 30 + 1)::integer * interval '1 day',
  floor(random() * 1000 + 100)::integer
FROM generate_series(1, 20);

-- Заполним таблицу order_item данными
INSERT INTO order_item (order_id, item_id, count, production_line_id, start_date, end_date)
SELECT
  floor(random() * 20 + 1)::integer,
  floor(random() * 20 + 1)::integer,
  floor(random() * 46 + 5)::integer,
  floor(random() * 5 + 1)::integer,
  current_timestamp - floor(random() * 30 + 1)::integer * interval '1 day',
  current_timestamp + floor(random() * 30 + 1)::integer * interval '1 day'
FROM generate_series(1, 20);


SELECT pl.id, pl.money_cost_per_hour, COALESCE(MAX(oi.end_date), '2000-1-1'::TIMESTAMP) AS end_date
FROM production_line pl
LEFT JOIN order_item oi ON oi.production_line_id = pl.id
GROUP BY pl.id, pl.money_cost_per_hour
ORDER BY pl.id;



SELECT COALESCE(MAX(id) + 1, 0) FROM orders
