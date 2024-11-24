-- Создание таблиц базы данных
CREATE TABLE bookings (
    book_ref CHAR(6) PRIMARY KEY,
    book_date TIMESTAMPTZ NOT NULL,
    total_amount NUMERIC(10, 2) NOT NULL
);

CREATE TABLE airports (
    airport_code CHAR(3) PRIMARY KEY,
    airport_name TEXT NOT NULL,
    city TEXT NOT NULL,
    coordinates_lon DOUBLE PRECISION,
    coordinates_lat DOUBLE PRECISION,
    timezone TEXT NOT NULL
);

CREATE TABLE aircrafts (
    aircraft_code CHAR(3) PRIMARY KEY,
    model JSONB NOT NULL,
    range INTEGER NOT NULL
);

CREATE TABLE flights (
    flight_id SERIAL PRIMARY KEY,
    flight_no CHAR(6) NOT NULL,
    scheduled_departure TIMESTAMPTZ NOT NULL,
    scheduled_arrival TIMESTAMPTZ NOT NULL,
    departure_airport CHAR(3) REFERENCES airports(airport_code),
    arrival_airport CHAR(3) REFERENCES airports(airport_code),
    status VARCHAR(20) NOT NULL,
    aircraft_code CHAR(3) REFERENCES aircrafts(aircraft_code),
    actual_departure TIMESTAMPTZ,
    actual_arrival TIMESTAMPTZ
);

CREATE TABLE tickets (
    ticket_no CHAR(13) PRIMARY KEY,
    book_ref CHAR(6) REFERENCES bookings(book_ref),
    passenger_id VARCHAR(20) NOT NULL,
    passenger_name TEXT NOT NULL,
    contact_data JSONB
);

CREATE TABLE ticket_flights (
    ticket_no CHAR(13) REFERENCES tickets(ticket_no),
    flight_id INTEGER REFERENCES flights(flight_id),
    fare_conditions VARCHAR(10),
    amount NUMERIC(10, 2)
);

CREATE TABLE boarding_passes (
    ticket_no CHAR(13) REFERENCES tickets(ticket_no),
    flight_id INTEGER REFERENCES flights(flight_id),
    boarding_no INTEGER,
    seat_no VARCHAR(4)
);

CREATE TABLE seats (
    aircraft_code CHAR(3) REFERENCES aircrafts(aircraft_code),
    seat_no VARCHAR(4) NOT NULL,
    fare_conditions VARCHAR(10) NOT NULL
);


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


-- Создание представления для подсчета пассажиропотока
CREATE VIEW passenger_traffic AS

    WITH fligth_passanger_count as (
        SELECT flight_id, count(ticket_no) as cnt_passangers 
        FROM ticket_flights 
        GROUP BY flight_id
        ),
    arrival_airport_stat as (
        SELECT f.arrival_airport as airport_code, COUNT(f.arrival_airport) as arrival_flights_num, SUM(fp.cnt_passangers) as arrival_psngr_num
        FROM flights f
        LEFT JOIN fligth_passanger_count fp on fp.flight_id = f.flight_id
        GROUP BY f.arrival_airport
        ),
    departure_airport_stat as (
        SELECT f.departure_airport as airport_code, COUNT(f.departure_airport) as departure_flights_num, SUM(fp.cnt_passangers) as departure_psngr_num
        FROM flights f
        LEFT JOIN fligth_passanger_count fp on fp.flight_id = f.flight_id
        GROUP BY f.departure_airport
        )

    SELECT a.airport_code, das.departure_flights_num, das.departure_psngr_num, aas.arrival_flights_num, aas.arrival_psngr_num
    FROM airports a
    LEFT JOIN departure_airport_stat das ON das.airport_code = a.airport_code
    LEFT JOIN arrival_airport_stat aas ON aas.airport_code = a.airport_code
