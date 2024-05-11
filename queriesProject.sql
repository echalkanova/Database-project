USE house_management_books;

/*SELECT  с ограничаващо условие*/
SELECT * FROM buildings
WHERE totalApartments BETWEEN 5 AND 20 
AND address LIKE 'ul. %';

/*GROUP BY + агрегатна функция*/
SELECT building_id, COUNT(repairs.id) AS total_repairs
FROM repairs
GROUP BY building_id;

SELECT buildings.id AS building_id, buildings.address, 
	   COUNT(repairs.id) AS total_repairs
FROM buildings
JOIN repairs ON buildings.id = repairs.building_id
GROUP BY buildings.id, buildings.address;

/*INNER JOIN*/
SELECT owners.name AS owner, owners.countOfApartments, 
	   apartments.apartment_num AS Apartment_№, 
	   area_square AS area_square
FROM owners
JOIN apartments ON owners.id = apartments.owner_id;

/*OUTER JOIN*/
SELECT buildings.id, buildings.address, buildings.town, repairs.repairType
FROM repairs
RIGHT OUTER JOIN buildings ON repairs.building_id = buildings.id;

/*вложен SELECT*/
SELECT owners.name, buildings.address
FROM owners JOIN buildings
ON owners.id IN (SELECT owner_id FROM apartments 
				 WHERE apartments.building_id = buildings.id);
                 

/*JOIN + агрегатна функция*/
SELECT t.id, t.name, COUNT(rp.id) AS countRents, 
	   SUM(rp.amount) AS sumOfPaidRents
FROM tenants AS t
JOIN rentalPayments AS rp ON t.id = rp.tenant_id
WHERE isPaid = TRUE
GROUP BY t.id
HAVING sumOfPaidRents > 6000
ORDER BY t.name
LIMIT 4;

SELECT t.name AS tenant_name, COUNT(rp.month) AS totalMonths, SUM(rp.amount) AS totalUnpaidRent
FROM tenants t
JOIN rentalPayments rp ON t.id = rp.tenant_id
WHERE rp.isPaid = FALSE
AND (rp.year = YEAR(CURRENT_DATE) AND rp.month >= MONTH(CURRENT_DATE) - 2
       OR rp.year = YEAR(CURRENT_DATE) - 1 AND rp.month >= 10)
GROUP BY t.id 
ORDER BY totalUnpaidRent DESC, t.name;


/*тригер*/ 
DELIMITER |
CREATE TRIGGER before_rentalpayments_insert BEFORE INSERT ON rentalPayments
FOR EACH ROW
BEGIN
    DECLARE is_negative_amount BOOLEAN DEFAULT FALSE;
    DECLARE is_future_payment BOOLEAN DEFAULT FALSE;

    IF (NEW.amount < 0) 
    THEN
        SET is_negative_amount = TRUE;
    END IF;

    IF (NEW.isPaid != 0 AND NEW.dateOfPayment > CURRENT_DATE) 
    THEN
        SET is_future_payment = TRUE;
    END IF;

    IF is_negative_amount 
    THEN
        SET NEW.amount = 0;
    END IF;

    IF is_future_payment 
    THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Not a valid date!';
    END IF;
END;
|
DELIMITER ;

INSERT INTO rentalPayments (month, year, amount, isPaid, dateOfPayment, tenant_id)
VALUES #(9, 2023, -1200.00, TRUE, '2023-09-05', 1),
(10,2025, 2300, TRUE, '2025-07-08', 13 );
SELECT *  FROM rentalPayments;

DELIMITER |
CREATE TRIGGER before_insert_user
BEFORE INSERT ON users
FOR EACH ROW
BEGIN
    IF NEW.userType != 'house manager' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Only house managers can be added.' ;
    END IF;
END;
|
DELIMITER ;

INSERT INTO users (username, password, userType) VALUES ('house_manager', 'house_password', 'house manager');
INSERT INTO users (username, password, userType) VALUES ('manager_user', 'manager_password', 'manager');
SELECT * FROM users;



/*triger s daden  naematel  da ne moje da kupuva dr imot */

DELIMITER |
CREATE TRIGGER before_insert_user BEFORE INSERT ON monthlyTaxes
FOR EACH ROW
BEGIN
	IF OLD.isPaid != TRUE AND dateOfPayment > CURRENT_DATE()
    THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot buy other apartment because of old unpaid taxes!';
END IF;
	
END;
|
DELIMITER ;




/*процедура, в която се демонстрира използване на курсор*/
CREATE TEMPORARY TABLE IF NOT EXISTS UnpaidTaxesResults (
    tenant_ID INT,
    tenant_Name VARCHAR(255),
    apartment_ID INT,
    total_Amount DECIMAL(10,2),
    paid_Amount DECIMAL(10,2),
    unpaid_Amount DECIMAL(10,2)
);

DELIMITER |

CREATE PROCEDURE CheckUnpaidTaxes()
BEGIN
    DECLARE done BOOLEAN DEFAULT FALSE;
    DECLARE tenant_id INT;
    DECLARE tenant_name VARCHAR(255);
    DECLARE apartment_id INT;
    DECLARE total_amount DECIMAL(10,2);
    DECLARE paid_amount DECIMAL(10,2);
    DECLARE unpaid_amount DECIMAL(10,2);
    DECLARE is_paid_all BOOLEAN DEFAULT TRUE;

    DECLARE unpaidTaxesCursor CURSOR FOR
        SELECT t.id, t.name, mt.apartment_id,
               SUM(mt.amount) AS total_amount,
               COALESCE(SUM(CASE WHEN mt.isPaid THEN mt.amount ELSE 0 END), 0) AS paid_amount
        FROM tenants t
        LEFT JOIN monthlyTaxes mt ON t.apartment_id = mt.apartment_id
        GROUP BY t.id, t.name, mt.apartment_id;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN unpaidTaxesCursor;

    SELECT 'Tenant ID', 'Tenant Name', 'Apartment ID', 'Total Amount', 'Paid Amount', 'Unpaid Amount';

    unpaidTaxesCursor: LOOP
        FETCH unpaidTaxesCursor INTO tenant_id, tenant_name, apartment_id, total_amount, paid_amount;
        
        IF done THEN
            LEAVE unpaidTaxesCursor;
        END IF;

        SET unpaid_amount = total_amount - paid_amount;
        
        IF unpaid_amount > 0 THEN
            SET is_paid_all = FALSE;
            INSERT INTO UnpaidTaxesResults (tenant_ID, tenant_Name, apartment_ID, total_Amount, paid_Amount, unpaid_Amount)
            VALUES (tenant_id, tenant_name, apartment_id, total_amount, paid_amount, unpaid_amount);
        END IF;
    END LOOP;

    IF is_paid_all THEN
        SELECT 'All tenants have paid their monthly taxes.';
    END IF;

    CLOSE unpaidTaxesCursor;
END |
DELIMITER ;

CALL CheckUnpaidTaxes();

SELECT * FROM UnpaidTaxesResults;

DROP TEMPORARY TABLE IF EXISTS UnpaidTaxesResults;

