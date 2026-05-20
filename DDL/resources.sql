CREATE OR REPLACE FILE FORMAT csv_format
  TYPE = 'CSV' 
  FIELD_DELIMITER = ','
  SKIP_HEADER = 1
  ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE;

CREATE OR REPLACE STAGE snowstage
URL='your_storage_path'
CREDENTIALS=( AZURE_SAS_TOKEN='your_sas_token') 
FILE_FORMAT = csv_format;

COPY INTO CUSTOMERS
FRoM @snowstage
FILES=('customers.csv');

COPY INTO DRIVERS
FRoM @snowstage
FILES=('drivers.csv');
COPY INTO LOCATION
FRoM @snowstage
FILES=('locations.csv');

COPY INTO TRIPS
FRoM @snowstage
FILES=('trips.csv');