CREATE OR REPLACE TABLE Customers (
    customer_id INT PRIMARY KEY,

    first_name VARCHAR(100),

    last_name VARCHAR(100),

    email VARCHAR(255),

    phone_number VARCHAR(50),

    city VARCHAR(100),

    signup_date DATE,

    last_updated_timestamp TIMESTAMP
);

CREATE OR REPLACE TABLE Drivers
(
    driver_id INT PRIMARY KEY,

    first_name VARCHAR(100),

    last_name VARCHAR(100),

    phone_number VARCHAR(50),

    vehicle_id INT,

    driver_rating DECIMAL(3,2),

    city VARCHAR(100),

    last_updated_timestamp TIMESTAMP
);

CREATE OR REPLACE TABLE Location
(
    location_id INT PRIMARY KEY,

    city VARCHAR(100),

    state VARCHAR(100),

    country VARCHAR(100),

    latitude DECIMAL(10,6),

    longitude DECIMAL(10,6),

    last_updated_timestamp TIMESTAMP
);

CREATE OR REPLACE TABLE Trips
(
    trip_id INT PRIMARY KEY,

    driver_id INT,

    customer_id INT,

    vehicle_id INT,

    trip_start_time TIMESTAMP,

    trip_end_time TIMESTAMP,

    start_location VARCHAR(100),

    end_location VARCHAR(100),

    distance_km DECIMAL(10,2),

    fare_amount DECIMAL(10,2),

    payment_method VARCHAR(50),

    trip_status VARCHAR(50),

    last_updated_timestamp TIMESTAMP,

    CONSTRAINT fk_driver
        FOREIGN KEY (driver_id)
        REFERENCES Drivers(driver_id),

    CONSTRAINT fk_customer
        FOREIGN KEY (customer_id)
        REFERENCES Customers(customer_id)
);