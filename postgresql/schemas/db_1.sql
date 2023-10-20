-- Active: 1697528686418@@172.17.0.1@54321@test_db


CREATE TABLE item (
    id INT PRIMARY KEY,
    name VARCHAR,
    time_cost_hour INT
);

CREATE TABLE production_line (
    id serial PRIMARY KEY,
    money_cost_per_hour INT
);

CREATE TABLE orders (
    id serial PRIMARY KEY,
    start_date TIMESTAMP,
    end_date TIMESTAMP,
    total_cost INT
);

CREATE TABLE order_item (
    id serial PRIMARY KEY,
    order_id INT REFERENCES orders(id),
    item_id INT REFERENCES item(id),
    count INT,
    production_line_id INT REFERENCES production_line(id),
    start_date TIMESTAMP,
    end_date TIMESTAMP
);