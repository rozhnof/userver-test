-- https://mediawiki.okibiteam.ru/index.php/%D0%95%D0%B4%D0%B8%D0%BD%D1%8B%D0%B9_%D1%8F%D0%B7%D1%8B%D0%BA
-- Stage - TECHNO_MAP_STAGES - этап технологической карты

DROP TABLE
    IF EXISTS workshop,
    workshop_map,
    kt_group,
    file_info,
    equipment,
    equipment_instance_on_map,
    serial_numbers,
    commodity_item,
    techno_map,
    techno_map_stages,
    workshop_stage,
    item_for_production,
    input_commodity_items,
    input_item_for_production
    CASCADE;

-- DROP TYPE IF EXISTS measurement_unit; //TODO Добавить enum

-- CREATE TYPE measurement_unit AS ENUM ('штуки', 'кг', 'литры');


CREATE TABLE
    file_info
(
    id   SERIAL PRIMARY KEY,
    file_uuid TEXT NOT NULL
);

CREATE TABLE
    workshop
(
    id   SERIAL PRIMARY KEY,
    name TEXT NOT NULL
);

CREATE TABLE
    equipment
(
    id          SERIAL PRIMARY KEY,
    name        TEXT NOT NULL,
    photo       INT REFERENCES file_info (id),
    description TEXT
);
-- (equipment_instance) - конкретные станки
CREATE TABLE
    serial_numbers
(
    id            SERIAL PRIMARY KEY,
    serial_number TEXT                                            NOT NULL,
    workshop_id   INT REFERENCES workshop (id) ON DELETE CASCADE  NOT NULL, -- TODO: учесть ситуацию существования без workshop
    equipment_id  INT REFERENCES equipment (id) ON DELETE CASCADE NOT NULL
);


CREATE TABLE
    kt_group -- группы товарных позиций
(
    id          SERIAL PRIMARY KEY,
    name        TEXT,
    parent_id   INT REFERENCES kt_group (id) ON DELETE SET NULL,
    create_time TIMESTAMPTZ NOT NULL,
    creator_id  INT         NOT NULL CHECK (creator_id >= 0)
);
-- товарная позиция
CREATE TABLE
    commodity_item
(
    id          SERIAL PRIMARY KEY,
    name        TEXT             NOT NULL,
    article     TEXT,
    photo       INT REFERENCES file_info (id),
    description TEXT,
    measurement TEXT NOT NULL, -- единицы измерения
    create_time TIMESTAMPTZ      NOT NULL,
    creator_id  INT              NOT NULL CHECK (creator_id >= 0),
    group_id  INT REFERENCES kt_group (id) ON DELETE SET NULL
);


CREATE TABLE
    techno_map
(
    id                SERIAL PRIMARY KEY,
    name              TEXT                                                 NOT NULL,
    commodity_item_id INT REFERENCES commodity_item (id) ON DELETE CASCADE NOT NULL -- TODO: учесть ситуацию существования без commodity_item
);

-- (stage) - этап технологической карты
CREATE TABLE
    techno_map_stages
(
    id                         SERIAL PRIMARY KEY,
    name                       TEXT                                             NOT NULL,
    stage_number_in_techno_map INT                                              NOT NULL CHECK (stage_number_in_techno_map > 0),
    description                TEXT,
    time_spent_in_seconds      BIGINT                                           NOT NULL CHECK (time_spent_in_seconds >= 0),
    money_expenses_in_rubles   DECIMAL(19, 2)                                   NOT NULL CHECK (money_expenses_in_rubles >= 0),
    create_time                TIMESTAMPTZ                                      NOT NULL,
    creator_id                 INT                                              NOT NULL CHECK (creator_id >= 0),
    techno_map_id              INT REFERENCES techno_map (id) ON DELETE CASCADE NOT NULL,
    equipment_id               INT REFERENCES equipment (id)  NOT NULL -- TODO: учесть ситуацию существования без equipment
);

CREATE TABLE
    workshop_map
(
    id   SERIAL PRIMARY KEY,
    workshop_id   INT REFERENCES workshop (id) NOT NULL,
    photo       INT REFERENCES file_info (id)
);


CREATE TABLE
    equipment_instance_on_map
(
    id   SERIAL PRIMARY KEY,
    workshop_map_id INT REFERENCES workshop_map (id) ON DELETE CASCADE NOT NULL,
    equipment_instance_id INT REFERENCES serial_numbers (id) ON DELETE CASCADE NOT NULL,
    points               JSONB NOT NULL
);

-- промежуточная таблица для связывания этапов производства и цехов
CREATE TABLE
    workshop_stage
(
    id                   SERIAL PRIMARY KEY,
    techno_map_stages_id INT REFERENCES techno_map_stages (id) ON DELETE CASCADE NOT NULL,
    workshop_map_id          INT REFERENCES workshop_map (id) ON DELETE CASCADE          NOT NULL,
    equipment_instance_on_map_id    INT REFERENCES equipment_instance_on_map (id) ON DELETE CASCADE    NOT NULL
);

CREATE TABLE
    item_for_production
(
    id                           SERIAL PRIMARY KEY,
    name                         TEXT                                                    NOT NULL,
    created_techno_map_stages_id INT REFERENCES techno_map_stages (id) ON DELETE CASCADE NOT NULL, -- id стадии, на которой был создана заготовка
    photo       INT REFERENCES file_info (id)
);

CREATE TABLE
    input_commodity_items
(
    id                   SERIAL PRIMARY KEY,
    commodity_item_id    INT REFERENCES commodity_item (id) ON DELETE CASCADE    NOT NULL,
    count                INT  NOT NULL CHECK (count > 0),
    techno_map_stages_id INT REFERENCES techno_map_stages (id) ON DELETE CASCADE NOT NULL
);

CREATE TABLE
    input_item_for_production
(
    id                     SERIAL PRIMARY KEY,
    item_for_production_id INT REFERENCES item_for_production (id) ON DELETE CASCADE NOT NULL,
    count                INT  NOT NULL CHECK (count > 0),
    techno_map_stages_id   INT REFERENCES techno_map_stages (id) ON DELETE CASCADE   NOT NULL
);


-- INSERT INTO workshop (name)
-- VALUES ('Цех-1'),
--        ('Цех-2')
--     ON CONFLICT DO NOTHING;

-- INSERT INTO equipment (name, description)
-- VALUES ('Станок-1', 'Для резки металла'),
--        ('Станок-2', 'Для резки дерева'),
--        ('Станок-3', 'Для обработки деталей')
--     ON CONFLICT DO NOTHING;

-- INSERT INTO serial_numbers (serial_number,
--                             workshop_id,
--                             equipment_id)
-- VALUES ('XP1224JO3I4G09', 1, 1),
--        ('QW314J312RGG09', 1, 2),
--        ('1DWQ24JO3I4G09', 2, 1),
--        ('B6754HJO3I4G09', 2, 2)
--     ON CONFLICT DO NOTHING;

-- INSERT INTO kt_group(id, name)
-- VALUES (1, 'Детали')
-- ON CONFLICT DO NOTHING;

-- UPDA

-- INSERT INTO commodity_item (name, article, description, measurement, create_time, creator_id)
-- VALUES ('Доски', '231578623', 'Качественно. Сам рубил.', 'штуки', now(), 1),
--        ('Лист металла', '362453212', 'Спер с завода.', 'штуки', now(), 1),
--        ('Масло', '384046895', 'Слл с завода.', 'литры', now(), 1),
--        ('Масло1', '384046895', 'Сил .', 'литры', now(), 1),
--        ('Масло2', '384046895', 'Сил ', 'литры', now(), 1),
--        ('Масло3', '384046895', 'Сл', 'литры', now(), 1)
--     ON CONFLICT DO NOTHING;

-- INSERT INTO techno_map (name, commodity_item_id)
-- VALUES ('Резка метала', 2),
--        ('Распил под ламинат', 1),
--        ('Смазывание деталей', 3)
--     ON CONFLICT DO NOTHING;

-- INSERT INTO techno_map_stages (name, stage_number_in_techno_map, description, time_spent_in_seconds,
--                                money_expenses_in_rubles, create_time, creator_id, techno_map_id, equipment_id)
-- VALUES ('Нарезка деталей', 1, 'Делаем детальки', 5600, 30000.20, now(), 1, 1, 1),
--        ('Спайка листов', 1, 'Соединяем листы', 5600, 30000.20, now(), 1, 1, 1),
--        ('Смазывание деталей', 1, 'Смазываем детальки', 3600, 500, now(), 1, 3, 3)
--     ON CONFLICT DO NOTHING;

-- INSERT INTO item_for_production (name, created_techno_map_stages_id)
-- VALUES ('Детали', 1),
--        ('Большой лист', 2);
-- INSERT INTO input_commodity_items (commodity_item_id, techno_map_stages_id)
-- VALUES (2, 1)
--     ON CONFLICT DO NOTHING;

-- INSERT INTO input_item_for_production (item_for_production_id, techno_map_stages_id)
-- VALUES (1, 1)
--     ON CONFLICT DO NOTHING;

----- NEW INSERTS -----


INSERT INTO workshop (name)
VALUES
    ('Цех МеталлоСтанков 1'),
    ('Цех МеталлоСтанков 2'),
    ('Цех Деталей 1'),
    ('Цех Деталей 2'),
    ('Цех Сварки 1'),
    ('Цех Сварки 2'),
    ('Цех МеталлоКонструкций 1'),
    ('Цех МеталлоКонструкций 2'),
    ('Цех Производства 1'),
    ('Цех Производства 2'),
    ('Цех Качества 1'),
    ('Цех Качества 2'),
    ('Цех Инженерии 1'),
    ('Цех Инженерии 2'),
    ('Цех Лазерной Резки 1'),
    ('Цех Лазерной Резки 2'),
    ('Цех Автоматизации 1'),
    ('Цех Автоматизации 2'),
    ('Цех Разработки 1'),
    ('Цех Разработки 2')
ON CONFLICT DO NOTHING;

INSERT INTO equipment (name, description)
VALUES
    ('Станок для фрезеровки', 'Профессиональный станок для фрезеровки металла.'),
    ('Лазерный резак', 'Универсальный лазерный резак для резки металла.'),
    ('Токарный станок', 'Точный токарный станок для металлообработки.'),
    ('Гибочный пресс', 'Гибочный пресс с автоматическим управлением.'),
    ('Станок для сварки', 'Станок для сварки деталей металлоконструкций.'),
    ('Термический резак', 'Термический резак для резки металла.'),
    ('Фрезерный станок', 'Фрезерный станок для обработки металла.'),
    ('Гравировальный станок', 'Гравировальный станок для металлических изделий.'),
    ('Станок с ЧПУ', 'Станок с ЧПУ для автоматизированной обработки металла.'),
    ('Станок для точной резки', 'Станок для точной резки металла с ультраточностью.'),
    ('Станок для фрезеровки 1', 'Профессиональный станок для фрезеровки металла.'),
    ('Лазерный резак 1', 'Универсальный лазерный резак для резки металла.'),
    ('Токарный станок 1', 'Точный токарный станок для металлообработки.'),
    ('Гибочный пресс 1', 'Гибочный пресс с автоматическим управлением.'),
    ('Станок для сварки 1', 'Станок для сварки деталей металлоконструкций.'),
    ('Термический резак 1', 'Термический резак для резки металла.'),
    ('Фрезерный станок 1', 'Фрезерный станок для обработки металла.'),
    ('Гравировальный станок 1', 'Гравировальный станок для металлических изделий.'),
    ('Станок с ЧПУ 1', 'Станок с ЧПУ для автоматизированной обработки металла.')
    ON CONFLICT DO NOTHING;


INSERT INTO serial_numbers (serial_number, workshop_id, equipment_id)
VALUES
    ('XP1224JO3I4G09', 1, 1),
    ('QW314J312RGG09', 1, 2),
    ('1DWQ24JO3I4G09', 2, 1),
    ('B6754HJO3I4G09', 2, 2),
    ('KJ45TGH20RGG01', 3, 3),
    ('LP2356GH9IG701', 3, 4),
    ('MC1223JA2I4G02', 4, 5),
    ('NK3456PO1J4G03', 4, 6),
    ('OL2344UT3J4G04', 5, 7),
    ('PQ2322NV4J4G05', 5, 8),
    ('RS2322WX5J4G06', 6, 9),
    ('TU9876YZ6J4G07', 6, 10),
    ('UV4567KJ7RGG08', 7, 11),
    ('WX9876MN8RGG09', 7, 12),
    ('YZ4567AB9RGG10', 8, 13),
    ('AB6789CD0RGG11', 8, 14),
    ('CD6789EF1RGG12', 9, 15),
    ('EF6789GH2RGG13', 9, 16),
    ('GH6789IJ3RGG14', 10, 17)
ON CONFLICT DO NOTHING;

INSERT INTO kt_group (id, name, create_time, creator_id)
VALUES
    (1, 'Металлическая деталь', NOW(), 1),
    (2, 'Запчасть для сварки', NOW(), 1),
    (3, 'Специализированная металлическая деталь', NOW(), 1),
    (4, 'Запчасть высокого качества', NOW(), 1),
    (5, 'Специализированная металлическая деталь', NOW(), 1),
    (6, 'Запчасть высокого качества', NOW(), 1)
ON CONFLICT DO NOTHING;


INSERT INTO commodity_item (name, article, description, measurement, create_time, creator_id)
VALUES
    ('Деталь №1', 'ART101', 'Металлическая деталь для конструкций', 'Единица', NOW(), 1),
    ('Деталь №2', 'ART102', 'Запасная часть для сварки', 'Единица', NOW(), 2),
    ('Деталь №3', 'ART103', 'Специализированная металлическая деталь', 'Единица', NOW(), 3),
    ('Деталь №4', 'ART104', 'Запасная часть высокого качества', 'Единица', NOW(), 4),
    ('Деталь №5', 'ART105', 'Металлическая деталь для конструкций', 'Единица', NOW(), 1),
    ('Деталь №6', 'ART106', 'Запасная часть для сварки', 'Единица', NOW(), 2),
    ('Деталь №7', 'ART107', 'Специализированная металлическая деталь', 'Единица', NOW(), 3),
    ('Деталь №8', 'ART108', 'Запасная часть высокого качества', 'Единица', NOW(), 4),
    ('Деталь №9', 'ART109', 'Металлическая деталь для конструкций', 'Единица', NOW(), 1),
    ('Деталь №10', 'ART110', 'Запасная часть для сварки', 'Единица', NOW(), 2),
    ('Деталь Альфа', 'ART001', 'Металлическая деталь для конструкций', 'Единица', NOW(), 1),
    ('Деталь Браво', 'ART002', 'Запасная часть для сварки', 'Метр', NOW(), 2),
    ('Деталь Чарли', 'ART003', 'Специализированная металлическая деталь', 'Единица', NOW(), 3),
    ('Деталь Дельта', 'ART004', 'Запасная часть высокого качества', 'Единица', NOW(), 4),
    ('Деталь Эхо', 'ART005', 'Металлическая деталь для конструкций', 'Единица', NOW(), 1),
    ('Деталь Фокстрот', 'ART006', 'Запасная часть для сварки', 'Единица', NOW(), 2),
    ('Деталь Гольф', 'ART007', 'Специализированная металлическая деталь', 'Единица', NOW(), 3),
    ('Деталь Хотел', 'ART008', 'Запасная часть высокого качества', 'Единица', NOW(), 4),
    ('Деталь Индия', 'ART009', 'Металлическая деталь для конструкций', 'Единица', NOW(), 1),
    ('Деталь Жульетта', 'ART010', 'Запасная часть для сварки', 'Единица', NOW(), 2),
    ('Деталь Кило', 'ART011', 'Специализированная металлическая деталь', 'Единица', NOW(), 3),
    ('Деталь Лима', 'ART012', 'Запасная часть высокого качества', 'Единица', NOW(), 4),
    ('Деталь Майк', 'ART013', 'Металлическая деталь для конструкций', 'Единица', NOW(), 1),
    ('Деталь Новембер', 'ART014', 'Запасная часть для сварки', 'Единица', NOW(), 2),
    ('Деталь Оскар', 'ART015', 'Специализированная металлическая деталь', 'Единица', NOW(), 3),
    ('Деталь Папа', 'ART016', 'Запасная часть высокого качества', 'Единица', NOW(), 4),
    ('Деталь Ромео', 'ART017', 'Металлическая деталь для конструкций', 'Единица', NOW(), 1)
    ON CONFLICT DO NOTHING;

UPDATE commodity_item
SET group_id = (
    CASE
        WHEN description ILIKE '%Металлическая деталь%' THEN 1
        WHEN description ILIKE '%Запасная часть для сварки%' THEN 2
        WHEN description ILIKE '%Специализированная металлическая деталь%' THEN 3
        WHEN description ILIKE '%Запасная часть высокого качества%' THEN 4
        WHEN description ILIKE '%Специализированная металлическая деталь%' THEN 5
        WHEN description ILIKE '%Запасная часть высокого качества%' THEN 6
    END
);

update kt_group set parent_id = 1 where id = 6;
update commodity_item set group_id = 6 where id = 26;
update commodity_item set group_id = 6 where id = 27;

INSERT INTO techno_map (name, commodity_item_id)
VALUES
    ('Резка метала', 2),
    ('Распил под ламинат', 1),
    ('Смазывание деталей', 3),
    ('Термическая обработка', 1),
    ('Лазерная резка', 2),
    ('Сварка', 3),
    ('Гравировка', 1),
    ('Токарная обработка', 2),
    ('Фрезеровка', 3),
    ('Покраска', 1),
    ('Полировка', 2),
    ('Монтаж', 3),
    ('Упаковка', 1),
    ('Травление', 2),
    ('Термообработка', 3),
    ('Раскрой материала', 1),
    ('Резка пластика', 2),
    ('Сверление', 3),
    ('Зачистка', 1),
    ('Металлообработка', 2)
ON CONFLICT DO NOTHING;

INSERT INTO techno_map_stages (name, stage_number_in_techno_map, description, time_spent_in_seconds, money_expenses_in_rubles, create_time, creator_id, techno_map_id, equipment_id)
VALUES
    ('Нарезка деталей', 1, 'Делаем детальки', 5600, 30000.20, now(), 1, 1, 1),
    ('Спайка листов', 1, 'Соединяем листы', 5600, 30000.20, now(), 1, 1, 1),
    ('Смазывание деталей', 1, 'Смазываем детальки', 3600, 500, now(), 1, 3, 3),
    ('Термическая обработка', 2, 'Обработка при высокой температуре', 7200, 1000, now(), 1, 4, 4),
    ('Лазерная резка', 2, 'Резка лазером', 3000, 800, now(), 1, 5, 5),
    ('Сварка', 2, 'Соединяем детали', 4800, 600, now(), 1, 6, 6),
    ('Гравировка', 3, 'Гравируем на детали', 2400, 300, now(), 1, 7, 7),
    ('Токарная обработка', 3, 'Точная обработка', 6600, 900, now(), 1, 8, 8),
    ('Фрезеровка', 3, 'Обработка фрезой', 7200, 1100, now(), 1, 9, 9),
    ('Покраска', 4, 'Окрашиваем', 5400, 800, now(), 1, 10, 10),
    ('Полировка', 4, 'Полируем поверхность', 7200, 1000, now(), 1, 11, 11),
    ('Монтаж', 4, 'Сборка деталей', 3600, 600, now(), 1, 12, 12),
    ('Упаковка', 5, 'Упаковываем товар', 4800, 700, now(), 1, 13, 13),
    ('Травление', 5, 'Травим металл', 6000, 900, now(), 1, 14, 14),
    ('Термообработка', 5, 'Обработка при высокой температуре', 7200, 1100, now(), 1, 15, 15),
    ('Раскрой материала', 6, 'Раскрой сырья', 4800, 700, now(), 1, 16, 16),
    ('Резка пластика', 6, 'Резка листов', 7200, 1000, now(), 1, 17, 17),
    ('Сверление', 6, 'Сверлим детали', 3600, 600, now(), 1, 18, 1),
    ('Зачистка', 7, 'Очищаем от брака', 4800, 700, now(), 1, 19, 1),
    ('Металлообработка', 7, 'Обработка металла', 6000, 900, now(), 1, 20, 1)
ON CONFLICT DO NOTHING;

INSERT INTO item_for_production (name, created_techno_map_stages_id)
VALUES
    ('Заготовка-1', 1),
    ('Заготовка-2', 1),
    ('Заготовка-3', 1),
    ('Заготовка-4', 1),
    ('Заготовка-5', 1),
    ('Заготовка-6', 6),
    ('Заготовка-7', 7),
    ('Заготовка-8', 8),
    ('Заготовка-9', 9),
    ('Заготовка-10', 10),
    ('Заготовка-11', 11),
    ('Заготовка-12', 12),
    ('Заготовка-13', 13),
    ('Заготовка-14', 14),
    ('Заготовка-15', 15),
    ('Заготовка-16', 16),
    ('Заготовка-17', 17),
    ('Заготовка-18', 18),
    ('Заготовка-19', 19),
    ('Заготовка-20', 20)
ON CONFLICT DO NOTHING;

INSERT INTO input_commodity_items (commodity_item_id, techno_map_stages_id)
VALUES
    (2, 1),
    (3, 2),
    (4, 3),
    (5, 4),
    (6, 5),
    (7, 6),
    (8, 7),
    (9, 8),
    (10, 9),
    (11, 10),
    (12, 11),
    (13, 12),
    (14, 13),
    (15, 14),
    (16, 15),
    (17, 16),
    (18, 17),
    (19, 18),
    (20, 19),
    (21, 20)
ON CONFLICT DO NOTHING;

INSERT INTO kt_group (name, parent_id, create_time, creator_id)
VALUES
    ('Станки', NULL, NOW(), 1),
    ('Металлоконструкции', NULL, NOW(), 1),
    ('Сверлильные станки', 1, NOW(), 1),
    ('Фрезерные станки', 1, NOW(), 1),
    ('Токарные станки', 1, NOW(), 1),
    ('Плазменные станки', 1, NOW(), 1),
    ('Гибочные станки', 1, NOW(), 1),
    ('Термические резаки', 1, NOW(), 1),
    ('Гравировальные станки', 1, NOW(), 1),
    ('Столы для сварки', 1, NOW(), 1),
    ('Стальные конструкции', 2, NOW(), 1),
    ('Арочные конструкции', 2, NOW(), 1),
    ('Стеллажи', 2, NOW(), 1),
    ('Кованые изделия', 2, NOW(), 1),
    ('Лазерная резка', 2, NOW(), 1),
    ('Сварочные работы', 2, NOW(), 1),
    ('Специальные конструкции', 2, NOW(), 1),
    ('Лестницы', 2, NOW(), 1),
    ('Перила', 2, NOW(), 1),
    ('Ограждения', 2, NOW(), 1)
ON CONFLICT DO NOTHING;



-- INSERT INTO workshop_map (workshop_id, photo)
-- VALUES
--     (1, 1),
--     (2, 2),
--     (3, 3),
--     (4, 4),
--     (5, 5),
--     (6, 6),
--     (7, 7),
--     (8, 8),
--     (9, 9),
--     (10, 10),
--     (11, 11),
--     (12, 12),
--     (13, 13),
--     (14, 14),
--     (15, 15),
--     (16, 16),
--     (17, 17),
--     (18, 18),
--     (19, 19),
--     (20, 20)
-- ON CONFLICT DO NOTHING;

-- INSERT INTO equipment_instance_on_map (workshop_map_id, equipment_instance_id, points)
-- VALUES
--     (1, 1, '{"x": 10, "y": 20}'),
--     (2, 2, '{"x": 30, "y": 40}'),
--     (3, 3, '{"x": 50, "y": 60}'),
--     (4, 4, '{"x": 70, "y": 80}'),
--     (5, 5, '{"x": 90, "y": 100}'),
--     (6, 6, '{"x": 110, "y": 120}'),
--     (7, 7, '{"x": 130, "y": 140}'),
--     (8, 8, '{"x": 150, "y": 160}'),
--     (9, 9, '{"x": 170, "y": 180}'),
--     (10, 10, '{"x": 190, "y": 200}'),
--     (11, 11, '{"x": 210, "y": 220}'),
--     (12, 12, '{"x": 230, "y": 240}'),
--     (13, 13, '{"x": 250, "y": 260}'),
--     (14, 14, '{"x": 270, "y": 280}'),
--     (15, 15, '{"x": 290, "y": 300}'),
--     (16, 16, '{"x": 310, "y": 320}'),
--     (17, 17, '{"x": 330, "y": 340}'),
--     (18, 18, '{"x": 350, "y": 360}'),
--     (19, 19, '{"x": 370, "y": 380}'),
--     (20, 20, '{"x": 390, "y": 400}')
-- ON CONFLICT DO NOTHING;

-- INSERT INTO workshop_stage (techno_map_stages_id, workshop_map_id, equipment_instance_on_map_id)
-- VALUES
--     (1, 1, 1),
--     (2, 2, 2),
--     (3, 3, 3),
--     (4, 4, 4),
--     (5, 5, 5),
--     (6, 6, 6),
--     (7, 7, 7),
--     (8, 8, 8),
--     (9, 9, 9),
--     (10, 10, 10),
--     (11, 11, 11),
--     (12, 12, 12),
--     (13, 13, 13),
--     (14, 14, 14),
--     (15, 15, 15),
--     (16, 16, 16),
--     (17, 17, 17),
--     (18, 18, 18),
--     (19, 19, 19),
--     (20, 20, 20)
-- ON CONFLICT DO NOTHING;