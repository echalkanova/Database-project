DROP DATABASE IF EXISTS house_management_books1;
CREATE DATABASE house_management_books1;
USE house_management_books1;

CREATE TABLE users (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(255) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  userType ENUM('house manager', 'administrator') NOT NULL DEFAULT 'house manager'
);

CREATE TABLE buildings (
  id INT PRIMARY KEY AUTO_INCREMENT,
  address VARCHAR(255) NOT NULL,
  totalFloors INT NOT NULL,
  totalApartments INT NOT NULL,
  user_id INT NOT NULL,
  CONSTRAINT FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE apartments (
  id INT PRIMARY KEY AUTO_INCREMENT,
  floor_num INT NOT NULL,
  apartment_num INT NOT NULL,
  area_square DECIMAL(10,2) NOT NULL,
  building_id INT NOT NULL,
  CONSTRAINT FOREIGN KEY (building_id) REFERENCES buildings(id)
);

CREATE TABLE residents (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL,
  phone VARCHAR(20) NOT NULL,
  apartment_number INT NOT NULL
);

CREATE TABLE residents_apartment(
    apartment_id INT NOT NULL,
    resident_id INT NOT NULL,
    PRIMARY KEY (apartment_id, resident_id),
    CONSTRAINT FOREIGN KEY (apartment_id) REFERENCES apartments(id),
    CONSTRAINT FOREIGN KEY (resident_id) REFERENCES residents(id)
);

CREATE TABLE repairs (
  id INT PRIMARY KEY AUTO_INCREMENT,
  repairType VARCHAR(255) NOT NULL,
  description TEXT,
  startDate DATETIME NOT NULL,
  endDate DATETIME,
  /*apartment_id INT NOT NULL,
  CONSTRAINT FOREIGN KEY (apartment_id) REFERENCES apartments(id)*/
  building_id INT NOT NULL,
  CONSTRAINT FOREIGN KEY (building_id) REFERENCES buildings(id)
);

CREATE TABLE taxes (
  id INT PRIMARY KEY AUTO_INCREMENT,
  month TINYINT NOT NULL,
  year YEAR NOT NULL,
  amount DECIMAL(10,2) NOT NULL,
  isPayed BOOLEAN,
  dateOfPayment DATETIME,
  apartment_id INT NOT NULL,
  CONSTRAINT FOREIGN KEY (apartment_id) REFERENCES apartments(id)
);

INSERT INTO users (name, password, userType) VALUES ('Anton Ivanov', 'pass12345', 'house manager'),
('Angel Vasilev', 'password34','administrator'),
('Stoyan Angelov', 'key99', 'house manager'),
('Ekaterina Pavlova', '12334566', 'house manager'),
('Martin Georgiev', 'martin1997', 'house manager'),
('Ivelina Kitova', 'ivelina10', 'house manager'),
('Bozhidar Georgiev', 'georgiev45', 'house manager'),
('Bogdana Ivanova', 'password345', 'house manager');

SELECT * FROM users;

INSERT INTO buildings (address,totalFloors,totalApartments, user_id) VALUES ('ul. Stamboliiski №97', 5, 20,1),
('ul. Ivan Vazov №11', 6, 30, 5),
('ul. Hristo Botev №9', 3, 6, 4),
('ul. Kozqk №1', 4, 12, 5),
('ul. Bqlo More №13', 6, 18, 6),
('ul. Sredna gora №10', 5, 15, 7),
('ul. Velikoknqjevska №3', 4, 13, 8),
('ul. Sava Dobroplodni №15', 10, 30, 3),
('ul. Miladinovi №4', 5, 15, 4),
('ul. Chudotvorna №23', 10, 20, 8),
('bul. Georgi Danchev №33', 5, 15, 4),
('bul. Georgi Rakovski №53', 4, 8, 6);

SELECT * FROM buildings;

SELECT * FROM buildings
WHERE totalApartments BETWEEN 5 AND 20 
AND address LIKE 'ul. %';

INSERT INTO apartments (floor_num, apartment_num, area_square, building_id) VALUES (3, 5, 67.7, 4),
(9, 15, 101.20, 8),
(2, 4, 56.00, 4),
(3, 6, 88.90, 12),
(8, 24, 77.70, 8),
(2, 4, 92.70, 7),
(9, 10, 82.32, 10),
(4, 10, 70.00,11),
(1, 1, 44.00, 6),
(3, 6, 100.00, 3),
(6, 29, 54.90, 2),
(5, 19, 90.00, 1),
(5, 15, 50.00, 5),
(7, 14, 130.24, 10),
(2, 6, 47.00, 9),
(3, 8, 74.00, 9),
(1, 1, 60.70, 2),
(4, 15, 80.00, 1);

SELECT * FROM apartments;

/*INSERT INTO residents (name, email,phone, apartment_number) VALUES ('Ivan Ivanov', 'iivanov@abv.bg', '0897895609', 15),
('Ivana Todorova', 'itodorova@mail.bg', '0887896543', 4),
('Georgi Ivanov', 'givanov@abv.bg', '0886754321', 5),
('Georgi Georgiev', 'ggeorgiev@gmail.com', '0878903214', 10),
('Elisaveta Aleksieva', 'ealeksieva@abv.bg', '0876509870', 24),
('Peter Stoilov', 'pstoilov@yahoo.com', '0876593321', 10),
('Ivaila Grozdova', 'igrozdova@mail.bg', '0889075631', 6),

('Anton Ivanov', 'aivanov@mail.bg', '0897805436', 10),
('Stoyan Angelov', 'angelov@abv.bg', '0886795467', 24),
('Ivelina Kitova', 'ikitova@abv.bg', '0876589090', 19),
('Bozhidar Georgiev', 'bgeorgiev@abv.bg', '0885454329', 6),
('Martin Georgiev', 'mgeorgiev@yahoo.com', '0887900233', 1),
('Bogdana Ivanova', 'bivanova@gmail.com', '0876578900', 15),
('Ekaterina Ivanova', 'eivanova@abv.bg', '0886464356', 1),
('Angel Vasilev', 'avasilev@gmail.com', '0889090659', 15);*/

INSERT INTO residents (name, email,phone) VALUES ('Ivan Ivanov', 'iivanov@abv.bg', '0897895609'),
('Ivana Todorova', 'itodorova@mail.bg', '0887896543'),
('Georgi Ivanov', 'givanov@abv.bg', '0886754321'),
('Georgi Georgiev', 'ggeorgiev@gmail.com', '0878903214'),
('Elisaveta Aleksieva', 'ealeksieva@abv.bg', '0876509870'),
('Peter Stoilov', 'pstoilov@yahoo.com', '0876593321'),
('Ivaila Grozdova', 'igrozdova@mail.bg', '0889075631'),

('Anton Ivanov', 'aivanov@mail.bg', '0897805436'),
('Stoyan Angelov', 'angelov@abv.bg', '0886795467'),
('Ivelina Kitova', 'ikitova@abv.bg', '0876589090'),
('Bozhidar Georgiev', 'bgeorgiev@abv.bg', '0885454329'),
('Martin Georgiev', 'mgeorgiev@yahoo.com', '0887900233'),
('Bogdana Ivanova', 'bivanova@gmail.com', '0876578900'),
('Ekaterina Ivanova', 'eivanova@abv.bg', '0886464356'),
('Angel Vasilev', 'avasilev@gmail.com', '0889090659');

SELECT * FROM residents;

INSERT INTO residents_apartment (resident_id, apartment_id) VALUES (1,1), (2,3), (3,18), (4,15), (5, 13), (6, 14), 
(7,12),  (8,10), (9,3), (10,14), (11,11), (12,13), (13, 9), (14, 2), (15,18);

SELECT * FROM residents_apartment;

SELECT residents.name, residents.phone, apartments.apartment_num, apartments.area_square, buildings.address
FROM residents JOIN residents_apartment ON residents.id = residents_apartment.resident_id
JOIN apartments ON residents_apartment.apartment_id = apartments.id
JOIN buildings ON apartments.building_id = buildings.id;

INSERT INTO repairs (repairType, description, startDate, endDate, building_id) 
VALUES ('Elevator repair', 'The elevator was replaced with a new one.', '2023-12-03', '2023-12-05', 2),
('Renovating the facade', 'New facade of the residential area.', '2025-09-10', '2025-12-29', 5),
('Door repair', 'The old entrance door was replaced with a modern one.', '2023-10-13', '2023-10-13', 10),
('Repainting the entrance of the cooperative', 'The entrance of the cooperative will be repainted in white.', '2026-01-05', '2026-01-29', 7),
('Change the lighting of the entrance', 'The lighting at the entrance will be replaced.', '2024-08-20', '2024-08-22', 4),
('Repairing the roof', 'The roof of the resedential block was repaired due to leaks.', '2022-06-10', '2022-07-02', 1),
('Elevator repair', 'The elevator will be replaced with a new one.', '2025-01-15', '2025-01-17', 8),
('Repainting the entrance of the cooperative', 'The entrance of the cooperative was repainted in yellow.', '2022-03-19', '2022-04-10', 9),
('Repairing the roof', 'The roof of the resedential block was repaired due to leaks.', '2024-03-10', '2024-04-10', 11),
('Change the lighting of the entrance', 'The lighting at the entrance was replaced.', '2021-09-20', '2021-10-01', 12),
('Door repair', 'The old entrance door will be replaced with a modern one.', '2024-05-23', '2024-05-13', 3),
('Renovating the facade', 'New facade of the residential area.', '2026-05-15', '2026-09-29', 6),
('Repairing the roof', 'The roof of the resedential block wil be repaired due to leaks.', '2025-04-20', '2025-05-20', 10),
('Door repair', 'The old entrance door will be replaced with a modern one.', '2024-11-24', '2024-11-24', 7),
('Change the lighting of the entrance', 'The lighting at the entrance will be replaced.', '2024-12-02', '2024-12-03', 11);

SELECT * FROM repairs;

SELECT buildings.id, buildings.address, repairs.*
FROM buildings 
JOIN repairs ON buildings.id = repairs.building_id;