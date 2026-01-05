DROP TABLE IF EXISTS applicant_race, co_applicant_race, location, application CASCADE;
DROP TABLE IF EXISTS agency, loan_type, property_type, loan_purpose, owner_occupancy, preapproval, action_taken, msamd, state, county, ethnicity, sex, race, denial_reason, purchaser_type, hoepa_status, lien_status, edit_status CASCADE;


CREATE TABLE agency (
  agency_code SMALLINT PRIMARY KEY,
  agency_name TEXT NOT NULL,
  agency_abbr TEXT
);

CREATE TABLE loan_type (
  loan_type SMALLINT PRIMARY KEY,
  loan_type_name TEXT NOT NULL
);

CREATE TABLE property_type (
  property_type SMALLINT PRIMARY KEY,
  property_type_name TEXT NOT NULL
);

CREATE TABLE loan_purpose (
  loan_purpose SMALLINT PRIMARY KEY,
  loan_purpose_name TEXT NOT NULL
);

CREATE TABLE owner_occupancy (
  owner_occupancy SMALLINT PRIMARY KEY,
  owner_occupancy_name TEXT NOT NULL
);

CREATE TABLE preapproval (
  preapproval SMALLINT PRIMARY KEY,
  preapproval_name TEXT NOT NULL
);

CREATE TABLE action_taken (
  action_taken SMALLINT PRIMARY KEY,
  action_taken_name TEXT NOT NULL
);

CREATE TABLE msamd (
  msamd INTEGER PRIMARY KEY,
  msamd_name TEXT
);

CREATE TABLE state (
  state_code SMALLINT PRIMARY KEY,
  state_abbr CHAR(2) NOT NULL,
  state_name TEXT NOT NULL
);

CREATE TABLE county (
  state_code SMALLINT NOT NULL,
  county_code SMALLINT NOT NULL,
  county_name TEXT NOT NULL,
  PRIMARY KEY (state_code, county_code),
  FOREIGN KEY (state_code) REFERENCES state(state_code)
);

CREATE TABLE ethnicity (
  ethnicity_code SMALLINT PRIMARY KEY,
  ethnicity_name TEXT NOT NULL
);

CREATE TABLE sex (
  sex_code SMALLINT PRIMARY KEY,
  sex_name TEXT NOT NULL
);

CREATE TABLE race (
  race_code SMALLINT PRIMARY KEY,
  race_name TEXT NOT NULL
);

CREATE TABLE denial_reason (
  reason_code SMALLINT PRIMARY KEY,
  reason_name TEXT NOT NULL
);

CREATE TABLE purchaser_type (
  purchaser_type SMALLINT PRIMARY KEY,
  purchaser_type_name TEXT NOT NULL
);

CREATE TABLE hoepa_status (
  hoepa_status SMALLINT PRIMARY KEY,
  hoepa_status_name TEXT NOT NULL
);

CREATE TABLE lien_status (
  lien_status SMALLINT PRIMARY KEY,
  lien_status_name TEXT NOT NULL
);

CREATE TABLE edit_status (
  edit_status SMALLINT PRIMARY KEY,
  edit_status_name TEXT
);


CREATE TABLE location (
  location_id      SERIAL PRIMARY KEY,
  county_code      SMALLINT,
  msamd            INTEGER,
  state_code       SMALLINT,
  census_tract_number NUMERIC(11,3),
  population       INTEGER,
  minority_population NUMERIC,
  hud_median_family_income INTEGER,
  tract_to_msamd_income NUMERIC,
  number_of_owner_occupied_units INTEGER,
  number_of_1_to_4_family_units INTEGER
);

CREATE INDEX idx_location_all_fields ON location (
    county_code, msamd, state_code, census_tract_number,
    population, minority_population, hud_median_family_income,
    tract_to_msamd_income, number_of_owner_occupied_units,
    number_of_1_to_4_family_units
);

CREATE INDEX idx_location_key 
ON location (state_code, county_code, msamd, census_tract_number);

CREATE TABLE application (
  id BIGINT PRIMARY KEY,
  as_of_year SMALLINT NOT NULL,
  respondent_id TEXT,
  agency_code SMALLINT NOT NULL REFERENCES agency(agency_code),
  loan_type SMALLINT NOT NULL REFERENCES loan_type(loan_type),
  property_type SMALLINT NOT NULL REFERENCES property_type(property_type),
  loan_purpose SMALLINT NOT NULL REFERENCES loan_purpose(loan_purpose),
  owner_occupancy SMALLINT REFERENCES owner_occupancy(owner_occupancy),
  preapproval SMALLINT REFERENCES preapproval(preapproval),
  action_taken SMALLINT NOT NULL REFERENCES action_taken(action_taken),
  location_id INTEGER NOT NULL REFERENCES location(location_id),
  purchaser_type SMALLINT REFERENCES purchaser_type(purchaser_type),
  hoepa_status SMALLINT REFERENCES hoepa_status(hoepa_status),
  lien_status SMALLINT REFERENCES lien_status(lien_status),
  edit_status SMALLINT REFERENCES edit_status(edit_status),
  applicant_ethnicity SMALLINT REFERENCES ethnicity(ethnicity_code),
  co_applicant_ethnicity SMALLINT REFERENCES ethnicity(ethnicity_code),
  applicant_sex SMALLINT REFERENCES sex(sex_code),
  co_applicant_sex SMALLINT REFERENCES sex(sex_code),
  denial_reason_1 SMALLINT REFERENCES denial_reason(reason_code),
  denial_reason_2 SMALLINT REFERENCES denial_reason(reason_code),
  denial_reason_3 SMALLINT REFERENCES denial_reason(reason_code),
  loan_amount_000s INTEGER,
  applicant_income_000s INTEGER,
  rate_spread NUMERIC,
  sequence_number INTEGER,
  application_date_indicator SMALLINT
);


CREATE TABLE applicant_race (
  application_id BIGINT NOT NULL REFERENCES application(id),
  race_code      SMALLINT NOT NULL REFERENCES race(race_code),
  race_number    SMALLINT NOT NULL,
  PRIMARY KEY (application_id, race_number)
);

CREATE TABLE co_applicant_race (
  application_id BIGINT NOT NULL REFERENCES application(id),
  race_code      SMALLINT NOT NULL REFERENCES race(race_code),
  race_number    SMALLINT NOT NULL,
  PRIMARY KEY (application_id, race_number)
);

INSERT INTO agency (agency_code, agency_name, agency_abbr)
SELECT DISTINCT TRIM(agency_code)::SMALLINT, TRIM(agency_name), NULLIF(TRIM(agency_abbr),'')
FROM preliminary
WHERE TRIM(agency_code) <> '' AND TRIM(agency_name) <> '';

INSERT INTO loan_type (loan_type, loan_type_name)
SELECT DISTINCT TRIM(loan_type)::SMALLINT, TRIM(loan_type_name)
FROM preliminary
WHERE TRIM(loan_type) <> '' AND TRIM(loan_type_name) <> '';

INSERT INTO property_type (property_type, property_type_name)
SELECT DISTINCT TRIM(property_type)::SMALLINT, TRIM(property_type_name)
FROM preliminary
WHERE TRIM(property_type) <> '' AND TRIM(property_type_name) <> '';

INSERT INTO loan_purpose (loan_purpose, loan_purpose_name)
SELECT DISTINCT TRIM(loan_purpose)::SMALLINT, TRIM(loan_purpose_name)
FROM preliminary
WHERE TRIM(loan_purpose) <> '' AND TRIM(loan_purpose_name) <> '';

INSERT INTO owner_occupancy (owner_occupancy, owner_occupancy_name)
SELECT DISTINCT TRIM(owner_occupancy)::SMALLINT, TRIM(owner_occupancy_name)
FROM preliminary
WHERE TRIM(owner_occupancy) <> '' AND TRIM(owner_occupancy_name) <> '';

INSERT INTO preapproval (preapproval, preapproval_name)
SELECT DISTINCT TRIM(preapproval)::SMALLINT, TRIM(preapproval_name)
FROM preliminary
WHERE TRIM(preapproval) <> '' AND TRIM(preapproval_name) <> '';

INSERT INTO action_taken (action_taken, action_taken_name)
SELECT DISTINCT TRIM(action_taken)::SMALLINT, TRIM(action_taken_name)
FROM preliminary
WHERE TRIM(action_taken) <> '' AND TRIM(action_taken_name) <> '';

INSERT INTO msamd (msamd, msamd_name)
SELECT DISTINCT TRIM(msamd)::INTEGER, NULLIF(TRIM(msamd_name),'')
FROM preliminary
WHERE TRIM(msamd) <> '';

INSERT INTO state (state_code, state_abbr, state_name)
SELECT DISTINCT TRIM(state_code)::SMALLINT, TRIM(state_abbr), TRIM(state_name)
FROM preliminary
WHERE TRIM(state_code) <> '' AND TRIM(state_abbr) <> '' AND TRIM(state_name) <> '';

INSERT INTO county (state_code, county_code, county_name)
SELECT DISTINCT TRIM(state_code)::SMALLINT, TRIM(county_code)::SMALLINT, TRIM(county_name)
FROM preliminary
WHERE TRIM(state_code) <> '' AND TRIM(county_code) <> '' AND TRIM(county_name) <> '';


INSERT INTO ethnicity (ethnicity_code, ethnicity_name)
SELECT DISTINCT code, name
FROM (
    SELECT 
        TRIM(applicant_ethnicity)::SMALLINT AS code,
        TRIM(applicant_ethnicity_name) AS name
    FROM preliminary
    WHERE TRIM(applicant_ethnicity) <> '' AND TRIM(applicant_ethnicity) NOT IN ('5')

    UNION
    SELECT 
        TRIM(co_applicant_ethnicity)::SMALLINT AS code,
        TRIM(co_applicant_ethnicity_name) AS name
    FROM preliminary
    WHERE TRIM(co_applicant_ethnicity) <> ''

    UNION
    SELECT 5::SMALLINT AS code, 'No co-applicant'::TEXT AS name
    WHERE EXISTS (
        SELECT 1 FROM preliminary 
        WHERE TRIM(co_applicant_ethnicity) = '5'
    )
) combined
WHERE code IS NOT NULL
ON CONFLICT (ethnicity_code) DO NOTHING;

INSERT INTO sex (sex_code, sex_name)
SELECT DISTINCT TRIM(applicant_sex)::SMALLINT, TRIM(applicant_sex_name)
FROM preliminary
WHERE TRIM(applicant_sex) <> '' AND TRIM(applicant_sex_name) <> '';

INSERT INTO sex (sex_code, sex_name) 
VALUES (5, 'No co-applicant')
ON CONFLICT (sex_code) DO NOTHING;


INSERT INTO race (race_code, race_name)
SELECT DISTINCT code, name
FROM (
  SELECT TRIM(applicant_race_1)::SMALLINT AS code, TRIM(applicant_race_name_1) AS name
  FROM preliminary
  WHERE TRIM(applicant_race_1) <> '' AND TRIM(applicant_race_name_1) <> ''

  UNION
  SELECT TRIM(applicant_race_2)::SMALLINT, TRIM(applicant_race_name_2)
  FROM preliminary
  WHERE TRIM(applicant_race_2) <> '' AND TRIM(applicant_race_name_2) <> ''

  UNION
  SELECT TRIM(applicant_race_3)::SMALLINT, TRIM(applicant_race_name_3)
  FROM preliminary
  WHERE TRIM(applicant_race_3) <> '' AND TRIM(applicant_race_name_3) <> ''

  UNION
  SELECT TRIM(applicant_race_4)::SMALLINT, TRIM(applicant_race_name_4)
  FROM preliminary
  WHERE TRIM(applicant_race_4) <> '' AND TRIM(applicant_race_name_4) <> ''

  UNION
  SELECT TRIM(applicant_race_5)::SMALLINT, TRIM(applicant_race_name_5)
  FROM preliminary
  WHERE TRIM(applicant_race_5) <> '' AND TRIM(applicant_race_name_5) <> ''

  UNION
  SELECT TRIM(co_applicant_race_1)::SMALLINT, TRIM(co_applicant_race_name_1)
  FROM preliminary
  WHERE TRIM(co_applicant_race_1) <> '' AND TRIM(co_applicant_race_name_1) <> ''

  UNION
  SELECT TRIM(co_applicant_race_2)::SMALLINT, TRIM(co_applicant_race_name_2)
  FROM preliminary
  WHERE TRIM(co_applicant_race_2) <> '' AND TRIM(co_applicant_race_name_2) <> ''

  UNION
  SELECT TRIM(co_applicant_race_3)::SMALLINT, TRIM(co_applicant_race_name_3)
  FROM preliminary
  WHERE TRIM(co_applicant_race_3) <> '' AND TRIM(co_applicant_race_name_3) <> ''

  UNION
  SELECT TRIM(co_applicant_race_4)::SMALLINT, TRIM(co_applicant_race_name_4)
  FROM preliminary
  WHERE TRIM(co_applicant_race_4) <> '' AND TRIM(co_applicant_race_name_4) <> ''

  UNION
  SELECT TRIM(co_applicant_race_5)::SMALLINT, TRIM(co_applicant_race_name_5)
  FROM preliminary
  WHERE TRIM(co_applicant_race_5) <> '' AND TRIM(co_applicant_race_name_5) <> ''
) r_all;

INSERT INTO race (race_code, race_name) 
VALUES (8, 'No co-applicant')
ON CONFLICT (race_code) DO NOTHING;

INSERT INTO denial_reason (reason_code, reason_name)
SELECT DISTINCT code, name
FROM (
  SELECT TRIM(denial_reason_1)::SMALLINT AS code, TRIM(denial_reason_name_1) AS name
  FROM preliminary
  WHERE TRIM(denial_reason_1) <> '' AND TRIM(denial_reason_name_1) <> ''

  UNION
  SELECT TRIM(denial_reason_2)::SMALLINT, TRIM(denial_reason_name_2)
  FROM preliminary
  WHERE TRIM(denial_reason_2) <> '' AND TRIM(denial_reason_name_2) <> ''

  UNION
  SELECT TRIM(denial_reason_3)::SMALLINT, TRIM(denial_reason_name_3)
  FROM preliminary
  WHERE TRIM(denial_reason_3) <> '' AND TRIM(denial_reason_name_3) <> ''
) d_all;

INSERT INTO purchaser_type (purchaser_type, purchaser_type_name)
SELECT DISTINCT TRIM(purchaser_type)::SMALLINT, TRIM(purchaser_type_name)
FROM preliminary
WHERE TRIM(purchaser_type) <> '' AND TRIM(purchaser_type_name) <> '';

INSERT INTO hoepa_status (hoepa_status, hoepa_status_name)
SELECT DISTINCT TRIM(hoepa_status)::SMALLINT, TRIM(hoepa_status_name)
FROM preliminary
WHERE TRIM(hoepa_status) <> '' AND TRIM(hoepa_status_name) <> '';

INSERT INTO lien_status (lien_status, lien_status_name)
SELECT DISTINCT TRIM(lien_status)::SMALLINT, TRIM(lien_status_name)
FROM preliminary
WHERE TRIM(lien_status) <> '' AND TRIM(lien_status_name) <> '';

INSERT INTO edit_status (edit_status, edit_status_name)
SELECT DISTINCT TRIM(edit_status)::SMALLINT, NULLIF(TRIM(edit_status_name),'')
FROM preliminary
WHERE TRIM(edit_status) <> '';

INSERT INTO location (
  county_code,
  msamd,
  state_code,
  census_tract_number,
  population,
  minority_population,
  hud_median_family_income,
  tract_to_msamd_income,
  number_of_owner_occupied_units,
  number_of_1_to_4_family_units
)
SELECT DISTINCT
  NULLIF(TRIM(county_code),'')::SMALLINT,
  NULLIF(TRIM(msamd),'')::INTEGER,
  NULLIF(TRIM(state_code),'')::SMALLINT,
  NULLIF(TRIM(census_tract_number),'')::NUMERIC(11,3),
  NULLIF(TRIM(population),'')::INTEGER,
  NULLIF(TRIM(minority_population),'')::NUMERIC,
  NULLIF(TRIM(hud_median_family_income),'')::INTEGER,
  NULLIF(TRIM(tract_to_msamd_income),'')::NUMERIC,
  NULLIF(TRIM(number_of_owner_occupied_units),'')::INTEGER,
  NULLIF(TRIM(number_of_1_to_4_family_units),'')::INTEGER
FROM preliminary
WHERE TRIM(state_code) <> '';

INSERT INTO preapproval (preapproval, preapproval_name)
VALUES (3, 'Not applicable')
ON CONFLICT (preapproval) DO NOTHING;

INSERT INTO application (
  id, as_of_year, respondent_id, agency_code, loan_type, property_type,
  loan_purpose, owner_occupancy, preapproval, action_taken,
  location_id,
  purchaser_type, hoepa_status, lien_status,
  edit_status, applicant_ethnicity, co_applicant_ethnicity, applicant_sex,
  co_applicant_sex,
  denial_reason_1, denial_reason_2, denial_reason_3,
  loan_amount_000s, applicant_income_000s,
  rate_spread, sequence_number, application_date_indicator
)
SELECT
  p.id,
  NULLIF(TRIM(p.as_of_year),'')::SMALLINT,
  NULLIF(TRIM(p.respondent_id),''),
  NULLIF(TRIM(p.agency_code),'')::SMALLINT,
  NULLIF(TRIM(p.loan_type),'')::SMALLINT,
  NULLIF(TRIM(p.property_type),'')::SMALLINT,
  NULLIF(TRIM(p.loan_purpose),'')::SMALLINT,
  NULLIF(TRIM(p.owner_occupancy),'')::SMALLINT,
  NULLIF(TRIM(p.preapproval),'')::SMALLINT,
  NULLIF(TRIM(p.action_taken),'')::SMALLINT,
  l.location_id,
  NULLIF(TRIM(p.purchaser_type),'')::SMALLINT,
  NULLIF(TRIM(p.hoepa_status),'')::SMALLINT,
  NULLIF(TRIM(p.lien_status),'')::SMALLINT,
  NULLIF(TRIM(p.edit_status),'')::SMALLINT,
  NULLIF(TRIM(p.applicant_ethnicity),'')::SMALLINT,
  NULLIF(TRIM(p.co_applicant_ethnicity),'')::SMALLINT,
  NULLIF(TRIM(p.applicant_sex),'')::SMALLINT,
  NULLIF(TRIM(p.co_applicant_sex),'')::SMALLINT,
  NULLIF(TRIM(p.denial_reason_1),'')::SMALLINT,
  NULLIF(TRIM(p.denial_reason_2),'')::SMALLINT,
  NULLIF(TRIM(p.denial_reason_3),'')::SMALLINT,
  NULLIF(TRIM(p.loan_amount_000s),'')::INTEGER,
  NULLIF(TRIM(p.applicant_income_000s),'')::INTEGER,
  NULLIF(TRIM(p.rate_spread),'')::NUMERIC,
  NULLIF(TRIM(p.sequence_number),'')::INTEGER,
  NULLIF(TRIM(p.application_date_indicator),'')::SMALLINT
FROM preliminary p
JOIN location l
ON l.county_code = NULLIF(TRIM(p.county_code),'')::SMALLINT
AND l.msamd  = NULLIF(TRIM(p.msamd),'')::INTEGER
AND l.state_code  = NULLIF(TRIM(p.state_code),'')::SMALLINT
AND l.census_tract_number = NULLIF(TRIM(p.census_tract_number),'')::NUMERIC(11,3)
AND l.population= NULLIF(TRIM(p.population),'')::INTEGER
AND l.minority_population              = NULLIF(TRIM(p.minority_population),'')::NUMERIC
AND l.hud_median_family_income         = NULLIF(TRIM(p.hud_median_family_income),'')::INTEGER
AND l.tract_to_msamd_income            = NULLIF(TRIM(p.tract_to_msamd_income),'')::NUMERIC
AND l.number_of_owner_occupied_units   = NULLIF(TRIM(p.number_of_owner_occupied_units),'')::INTEGER
AND l.number_of_1_to_4_family_units    = NULLIF(TRIM(p.number_of_1_to_4_family_units),'')::INTEGER
WHERE p.id BETWEEN 1 AND 100000;

INSERT INTO application (
  id, as_of_year, respondent_id, agency_code, loan_type, property_type,
  loan_purpose, owner_occupancy, preapproval, action_taken,
  location_id,
  purchaser_type, hoepa_status, lien_status,
  edit_status, applicant_ethnicity, co_applicant_ethnicity, applicant_sex,
  co_applicant_sex,
  denial_reason_1, denial_reason_2, denial_reason_3,
  loan_amount_000s, applicant_income_000s,
  rate_spread, sequence_number, application_date_indicator
)
SELECT
  p.id,
  NULLIF(TRIM(p.as_of_year),'')::SMALLINT,
  NULLIF(TRIM(p.respondent_id),''),
  NULLIF(TRIM(p.agency_code),'')::SMALLINT,
  NULLIF(TRIM(p.loan_type),'')::SMALLINT,
  NULLIF(TRIM(p.property_type),'')::SMALLINT,
  NULLIF(TRIM(p.loan_purpose),'')::SMALLINT,
  NULLIF(TRIM(p.owner_occupancy),'')::SMALLINT,
  NULLIF(TRIM(p.preapproval),'')::SMALLINT,
  NULLIF(TRIM(p.action_taken),'')::SMALLINT,
  l.location_id,
  NULLIF(TRIM(p.purchaser_type),'')::SMALLINT,
  NULLIF(TRIM(p.hoepa_status),'')::SMALLINT,
  NULLIF(TRIM(p.lien_status),'')::SMALLINT,
  NULLIF(TRIM(p.edit_status),'')::SMALLINT,
  NULLIF(TRIM(p.applicant_ethnicity),'')::SMALLINT,
  NULLIF(TRIM(p.co_applicant_ethnicity),'')::SMALLINT,
  NULLIF(TRIM(p.applicant_sex),'')::SMALLINT,
  NULLIF(TRIM(p.co_applicant_sex),'')::SMALLINT,
  NULLIF(TRIM(p.denial_reason_1),'')::SMALLINT,
  NULLIF(TRIM(p.denial_reason_2),'')::SMALLINT,
  NULLIF(TRIM(p.denial_reason_3),'')::SMALLINT,
  NULLIF(TRIM(p.loan_amount_000s),'')::INTEGER,
  NULLIF(TRIM(p.applicant_income_000s),'')::INTEGER,
  NULLIF(TRIM(p.rate_spread),'')::NUMERIC,
  NULLIF(TRIM(p.sequence_number),'')::INTEGER,
  NULLIF(TRIM(p.application_date_indicator),'')::SMALLINT
FROM preliminary p
JOIN location l
ON l.county_code = NULLIF(TRIM(p.county_code),'')::SMALLINT
AND l.msamd  = NULLIF(TRIM(p.msamd),'')::INTEGER
AND l.state_code  = NULLIF(TRIM(p.state_code),'')::SMALLINT
AND l.census_tract_number = NULLIF(TRIM(p.census_tract_number),'')::NUMERIC(11,3)
AND l.population= NULLIF(TRIM(p.population),'')::INTEGER
AND l.minority_population              = NULLIF(TRIM(p.minority_population),'')::NUMERIC
AND l.hud_median_family_income         = NULLIF(TRIM(p.hud_median_family_income),'')::INTEGER
AND l.tract_to_msamd_income            = NULLIF(TRIM(p.tract_to_msamd_income),'')::NUMERIC
AND l.number_of_owner_occupied_units   = NULLIF(TRIM(p.number_of_owner_occupied_units),'')::INTEGER
AND l.number_of_1_to_4_family_units    = NULLIF(TRIM(p.number_of_1_to_4_family_units),'')::INTEGER
WHERE p.id BETWEEN 100001 AND 200000;


INSERT INTO application (
  id, as_of_year, respondent_id, agency_code, loan_type, property_type,
  loan_purpose, owner_occupancy, preapproval, action_taken,
  location_id,
  purchaser_type, hoepa_status, lien_status,
  edit_status, applicant_ethnicity, co_applicant_ethnicity, applicant_sex,
  co_applicant_sex,
  denial_reason_1, denial_reason_2, denial_reason_3,
  loan_amount_000s, applicant_income_000s,
  rate_spread, sequence_number, application_date_indicator
)
SELECT
  p.id,
  NULLIF(TRIM(p.as_of_year),'')::SMALLINT,
  NULLIF(TRIM(p.respondent_id),''),
  NULLIF(TRIM(p.agency_code),'')::SMALLINT,
  NULLIF(TRIM(p.loan_type),'')::SMALLINT,
  NULLIF(TRIM(p.property_type),'')::SMALLINT,
  NULLIF(TRIM(p.loan_purpose),'')::SMALLINT,
  NULLIF(TRIM(p.owner_occupancy),'')::SMALLINT,
  NULLIF(TRIM(p.preapproval),'')::SMALLINT,
  NULLIF(TRIM(p.action_taken),'')::SMALLINT,
  l.location_id,
  NULLIF(TRIM(p.purchaser_type),'')::SMALLINT,
  NULLIF(TRIM(p.hoepa_status),'')::SMALLINT,
  NULLIF(TRIM(p.lien_status),'')::SMALLINT,
  NULLIF(TRIM(p.edit_status),'')::SMALLINT,
  NULLIF(TRIM(p.applicant_ethnicity),'')::SMALLINT,
  NULLIF(TRIM(p.co_applicant_ethnicity),'')::SMALLINT,
  NULLIF(TRIM(p.applicant_sex),'')::SMALLINT,
  NULLIF(TRIM(p.co_applicant_sex),'')::SMALLINT,
  NULLIF(TRIM(p.denial_reason_1),'')::SMALLINT,
  NULLIF(TRIM(p.denial_reason_2),'')::SMALLINT,
  NULLIF(TRIM(p.denial_reason_3),'')::SMALLINT,
  NULLIF(TRIM(p.loan_amount_000s),'')::INTEGER,
  NULLIF(TRIM(p.applicant_income_000s),'')::INTEGER,
  NULLIF(TRIM(p.rate_spread),'')::NUMERIC,
  NULLIF(TRIM(p.sequence_number),'')::INTEGER,
  NULLIF(TRIM(p.application_date_indicator),'')::SMALLINT
FROM preliminary p
JOIN location l
ON l.county_code = NULLIF(TRIM(p.county_code),'')::SMALLINT
AND l.msamd  = NULLIF(TRIM(p.msamd),'')::INTEGER
AND l.state_code  = NULLIF(TRIM(p.state_code),'')::SMALLINT
AND l.census_tract_number = NULLIF(TRIM(p.census_tract_number),'')::NUMERIC(11,3)
AND l.population= NULLIF(TRIM(p.population),'')::INTEGER
AND l.minority_population              = NULLIF(TRIM(p.minority_population),'')::NUMERIC
AND l.hud_median_family_income         = NULLIF(TRIM(p.hud_median_family_income),'')::INTEGER
AND l.tract_to_msamd_income            = NULLIF(TRIM(p.tract_to_msamd_income),'')::NUMERIC
AND l.number_of_owner_occupied_units   = NULLIF(TRIM(p.number_of_owner_occupied_units),'')::INTEGER
AND l.number_of_1_to_4_family_units    = NULLIF(TRIM(p.number_of_1_to_4_family_units),'')::INTEGER
WHERE p.id BETWEEN 200001 AND 300000;


INSERT INTO application (
  id, as_of_year, respondent_id, agency_code, loan_type, property_type,
  loan_purpose, owner_occupancy, preapproval, action_taken,
  location_id,
  purchaser_type, hoepa_status, lien_status,
  edit_status, applicant_ethnicity, co_applicant_ethnicity, applicant_sex,
  co_applicant_sex,
  denial_reason_1, denial_reason_2, denial_reason_3,
  loan_amount_000s, applicant_income_000s,
  rate_spread, sequence_number, application_date_indicator
)
SELECT
  p.id,
  NULLIF(TRIM(p.as_of_year),'')::SMALLINT,
  NULLIF(TRIM(p.respondent_id),''),
  NULLIF(TRIM(p.agency_code),'')::SMALLINT,
  NULLIF(TRIM(p.loan_type),'')::SMALLINT,
  NULLIF(TRIM(p.property_type),'')::SMALLINT,
  NULLIF(TRIM(p.loan_purpose),'')::SMALLINT,
  NULLIF(TRIM(p.owner_occupancy),'')::SMALLINT,
  NULLIF(TRIM(p.preapproval),'')::SMALLINT,
  NULLIF(TRIM(p.action_taken),'')::SMALLINT,
  l.location_id,
  NULLIF(TRIM(p.purchaser_type),'')::SMALLINT,
  NULLIF(TRIM(p.hoepa_status),'')::SMALLINT,
  NULLIF(TRIM(p.lien_status),'')::SMALLINT,
  NULLIF(TRIM(p.edit_status),'')::SMALLINT,
  NULLIF(TRIM(p.applicant_ethnicity),'')::SMALLINT,
  NULLIF(TRIM(p.co_applicant_ethnicity),'')::SMALLINT,
  NULLIF(TRIM(p.applicant_sex),'')::SMALLINT,
  NULLIF(TRIM(p.co_applicant_sex),'')::SMALLINT,
  NULLIF(TRIM(p.denial_reason_1),'')::SMALLINT,
  NULLIF(TRIM(p.denial_reason_2),'')::SMALLINT,
  NULLIF(TRIM(p.denial_reason_3),'')::SMALLINT,
  NULLIF(TRIM(p.loan_amount_000s),'')::INTEGER,
  NULLIF(TRIM(p.applicant_income_000s),'')::INTEGER,
  NULLIF(TRIM(p.rate_spread),'')::NUMERIC,
  NULLIF(TRIM(p.sequence_number),'')::INTEGER,
  NULLIF(TRIM(p.application_date_indicator),'')::SMALLINT
FROM preliminary p
JOIN location l
ON l.county_code = NULLIF(TRIM(p.county_code),'')::SMALLINT
AND l.msamd  = NULLIF(TRIM(p.msamd),'')::INTEGER
AND l.state_code  = NULLIF(TRIM(p.state_code),'')::SMALLINT
AND l.census_tract_number = NULLIF(TRIM(p.census_tract_number),'')::NUMERIC(11,3)
AND l.population= NULLIF(TRIM(p.population),'')::INTEGER
AND l.minority_population              = NULLIF(TRIM(p.minority_population),'')::NUMERIC
AND l.hud_median_family_income         = NULLIF(TRIM(p.hud_median_family_income),'')::INTEGER
AND l.tract_to_msamd_income            = NULLIF(TRIM(p.tract_to_msamd_income),'')::NUMERIC
AND l.number_of_owner_occupied_units   = NULLIF(TRIM(p.number_of_owner_occupied_units),'')::INTEGER
AND l.number_of_1_to_4_family_units    = NULLIF(TRIM(p.number_of_1_to_4_family_units),'')::INTEGER
WHERE p.id BETWEEN 300001 AND 400000;


INSERT INTO applicant_race (application_id, race_code, race_number)
SELECT a.id,
       NULLIF(TRIM(p.applicant_race_1),'')::SMALLINT AS race_code,
       1 AS race_number
FROM preliminary p
JOIN application a ON a.id = p.id
WHERE TRIM(p.applicant_race_1) <> ''

UNION ALL
SELECT a.id,
       NULLIF(TRIM(p.applicant_race_2),'')::SMALLINT,
       2
FROM preliminary p
JOIN application a ON a.id = p.id
WHERE TRIM(p.applicant_race_2) <> ''

UNION ALL
SELECT a.id,
       NULLIF(TRIM(p.applicant_race_3),'')::SMALLINT,
       3
FROM preliminary p
JOIN application a ON a.id = p.id
WHERE TRIM(p.applicant_race_3) <> ''

UNION ALL
SELECT a.id,
       NULLIF(TRIM(p.applicant_race_4),'')::SMALLINT,
       4
FROM preliminary p
JOIN application a ON a.id = p.id
WHERE TRIM(p.applicant_race_4) <> ''

UNION ALL
SELECT a.id,
       NULLIF(TRIM(p.applicant_race_5),'')::SMALLINT,
       5
FROM preliminary p
JOIN application a ON a.id = p.id
WHERE TRIM(p.applicant_race_5) <> '';

INSERT INTO co_applicant_race (application_id, race_code, race_number)
SELECT a.id,
       NULLIF(TRIM(p.co_applicant_race_1),'')::SMALLINT AS race_code,
       1 AS race_number
FROM preliminary p
JOIN application a ON a.id = p.id
WHERE TRIM(p.co_applicant_race_1) <> ''

UNION ALL
SELECT a.id,
       NULLIF(TRIM(p.co_applicant_race_2),'')::SMALLINT,
       2
FROM preliminary p
JOIN application a ON a.id = p.id
WHERE TRIM(p.co_applicant_race_2) <> ''

UNION ALL
SELECT a.id,
       NULLIF(TRIM(p.co_applicant_race_3),'')::SMALLINT,
       3
FROM preliminary p
JOIN application a ON a.id = p.id
WHERE TRIM(p.co_applicant_race_3) <> ''

UNION ALL
SELECT a.id,
       NULLIF(TRIM(p.co_applicant_race_4),'')::SMALLINT,
       4
FROM preliminary p
JOIN application a ON a.id = p.id
WHERE TRIM(p.co_applicant_race_4) <> ''

UNION ALL
SELECT a.id,
       NULLIF(TRIM(p.co_applicant_race_5),'')::SMALLINT,
       5
FROM preliminary p
JOIN application a ON a.id = p.id
WHERE TRIM(p.co_applicant_race_5) <> '';
