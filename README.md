**Исправил ошибка и доработал код**

1. Теперь репликация правильно заводиться после 1 команды - docker-compose up (использовал https://github.com/peter-evans/docker-compose-healthcheck/tree/master)
   Проверял с помощью select * from pg_stat_replication; и select * from pg_stat_wal_receiver;
2. Исправил формирование sql-таблицы - теперь поток рейсов отображается так, как нужно (для этого нарастил тестовые данные, вшитые в init.sql)

Тестовые данные:

INSERT INTO airports (airport_code, airport_name, city, coordinates_lon, coordinates_lat, timezone)
VALUES 
('SVO', 'Международный аэропорт Шереметьево', 'Москва', 37.4146, 55.9726, 'Europe/Moscow'),
('LED', 'Аэропорт Пулково', 'Санкт-Петербург', 30.2625, 59.8003, 'Europe/Moscow');

INSERT INTO aircrafts (aircraft_code, model, range)
VALUES
('SU9', '{"en": "Sukhoi Superjet 100"}', 3000),
('A32', '{"en": "Airbus A320"}', 6150);

INSERT INTO bookings (book_ref, book_date, total_amount)
VALUES
('000001', NOW(), 5000.00),
('000002', NOW(), 7500.00),
('000003', NOW(), 12000.00),
('000004', NOW(), 15000.00);

INSERT INTO tickets (ticket_no, book_ref, passenger_id, passenger_name, contact_data)
VALUES
('0000000000001', '000001', 'P001', 'Иван Иванов', '{"phone": "+79161234567"}'),
('0000000000002', '000001', 'P002', 'Мария Петрова', '{"email": "maria@example.com"}'),
('0000000000003', '000003', 'P003', 'Алексей Смирнов', '{"phone": "+79161234568"}'),
('0000000000004', '000003', 'P004', 'Ольга Сидорова', '{"email": "olga@example.com"}'),
('0000000000005', '000004', 'P005', 'Дмитрий Кузнецов', '{"phone": "+79161234569"}'),
('0000000000006', '000004', 'P006', 'Елена Васильева', '{"email": "elena@example.com"}');

INSERT INTO flights (flight_id, flight_no, scheduled_departure, scheduled_arrival, departure_airport, arrival_airport, status, aircraft_code)
VALUES
(1, 'SU100', NOW() + INTERVAL '1 day', NOW() + INTERVAL '1 day' + INTERVAL '2 hours', 'SVO', 'LED', 'Scheduled', 'SU9'),
(2, 'SU101', NOW() + INTERVAL '2 days', NOW() + INTERVAL '2 days' + INTERVAL '2 hours', 'LED', 'SVO', 'Scheduled', 'A32');

INSERT INTO ticket_flights (ticket_no, flight_id, fare_conditions, amount)
VALUES
('0000000000001', 1, 'Economy', 2500.00),
('0000000000002', 1, 'Economy', 2500.00),
('0000000000003', 2, 'Business', 6000.00),
('0000000000004', 2, 'Business', 6000.00),
('0000000000005', 1, 'Economy', 2500.00),
('0000000000006', 1, 'Economy', 2500.00);
