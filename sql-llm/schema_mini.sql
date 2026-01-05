-- Minimal schema for LLM-to-SQL prompting (PostgreSQL)

CREATE TABLE location (
  location_id   integer PRIMARY KEY,
  state_code    smallint NOT NULL,
  county_code   smallint,
  msamd         integer,
  census_tract  text
);

CREATE TABLE agency (
  agency_code smallint PRIMARY KEY,
  agency_name text NOT NULL
);

CREATE TABLE action_taken (
  action_taken smallint PRIMARY KEY,
  action_name  text NOT NULL
);

CREATE TABLE application (
  id                    bigint PRIMARY KEY,
  as_of_year             smallint NOT NULL,
  agency_code            smallint NOT NULL REFERENCES agency(agency_code),
  action_taken           smallint NOT NULL REFERENCES action_taken(action_taken),
  location_id            integer  NOT NULL REFERENCES location(location_id),
  loan_amount_000s       integer,
  applicant_income_000s  integer
);

-- a few tiny inserts (optional but helpful)
INSERT INTO agency VALUES (1, 'Example Agency');
INSERT INTO action_taken VALUES (1, 'Loan originated'), (3, 'Loan denied');
INSERT INTO location VALUES (10, 34, 23, 35620, '000100');
INSERT INTO application VALUES (1001, 2017, 1, 1, 10, 250, 90);
