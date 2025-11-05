-- ============================================================================
-- Mahoney Group Intelligence Agent - Synthetic Data Generation
-- ============================================================================
-- Purpose: Generate realistic sample data for Mahoney Group's multi-line insurance
--          and employee benefits business
-- Volume: ~10K clients, 150K policies, 50K claims, 30K benefit plans
-- ============================================================================

USE DATABASE MAHONEY_GROUP_INTELLIGENCE;
USE SCHEMA RAW;
USE WAREHOUSE MAHONEY_WH;

-- ============================================================================
-- Step 1: Generate Insurance Agents (Mahoney Group brokers)
-- ============================================================================
INSERT INTO INSURANCE_AGENTS
SELECT
    'AGT' || LPAD(SEQ4(), 5, '0') AS agent_id,
    ARRAY_CONSTRUCT('John Smith', 'Sarah Johnson', 'Michael Brown', 'Emily Davis', 'David Wilson',
                    'Jessica Martinez', 'Robert Garcia', 'Amanda Rodriguez', 'Christopher Lee', 'Lisa Anderson',
                    'James Taylor', 'Jennifer Thomas', 'Daniel Moore', 'Michelle Jackson', 'Matthew White',
                    'Ashley Harris', 'Ryan Martin', 'Lauren Thompson', 'Kevin Garcia', 'Nicole Martinez',
                    'Brandon Robinson', 'Stephanie Clark', 'Justin Lewis', 'Christina Walker', 'Tyler Hall',
                    'Rebecca Allen', 'Aaron Young', 'Melissa King', 'Eric Wright', 'Rachel Scott')[UNIFORM(0, 29, RANDOM())]
        AS agent_name,
    'agent' || SEQ4() || '@mahoneygroup.com' AS email,
    '+1-' || LPAD(UNIFORM(200, 999, RANDOM())::VARCHAR, 3, '0') || '-' || 
        LPAD(UNIFORM(0, 999, RANDOM())::VARCHAR, 3, '0') || '-' || 
        LPAD(UNIFORM(0, 9999, RANDOM())::VARCHAR, 4, '0') AS phone,
    ARRAY_CONSTRUCT('COMMERCIAL_LINES', 'EMPLOYEE_BENEFITS', 'PERSONAL_LINES', 'RISK_MANAGEMENT', 'EXECUTIVE_BENEFITS')[UNIFORM(0, 4, RANDOM())] AS agent_type,
    ARRAY_CONSTRUCT('Construction', 'Healthcare', 'Hospitality', 'Manufacturing', 'Real Estate', 
                    'Technology', 'Nonprofits', 'Education', 'Retail', 'Professional Services')[UNIFORM(0, 9, RANDOM())] AS specialization,
    ARRAY_CONSTRUCT('Chandler AZ', 'Phoenix AZ', 'Scottsdale AZ', 'Tempe AZ')[UNIFORM(0, 3, RANDOM())] AS office_location,
    ARRAY_CONSTRUCT('SOUTHWEST', 'WEST', 'MOUNTAIN', 'NATIONAL')[UNIFORM(0, 3, RANDOM())] AS region,
    'ACTIVE' AS agent_status,
    DATEADD('day', -1 * UNIFORM(365, 7300, RANDOM()), CURRENT_DATE()) AS hire_date,
    ARRAY_CONSTRUCT('PLATINUM', 'GOLD', 'SILVER', 'BRONZE')[UNIFORM(0, 3, RANDOM())] AS production_tier,
    UNIFORM(10, 150, RANDOM()) AS total_clients,
    UNIFORM(500000, 5000000, RANDOM()) AS total_premium_written,
    (UNIFORM(42, 50, RANDOM()) / 10.0)::NUMBER(3,2) AS average_client_satisfaction,
    DATEADD('day', -1 * UNIFORM(365, 7300, RANDOM()), CURRENT_TIMESTAMP()) AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
FROM TABLE(GENERATOR(ROWCOUNT => 50));

-- ============================================================================
-- Step 2: Generate Insurance Products
-- ============================================================================
INSERT INTO INSURANCE_PRODUCTS VALUES
-- Commercial Property Insurance
('PROD001', 'Commercial Property Insurance - Standard', 'PROP-STD-001', 'PROPERTY', 'COMMERCIAL', 'Building and Contents', 0.85, 'MEDIUM', 'Standard commercial property coverage for buildings and contents', 'ACTIVE', TRUE, '2020-01-01', 'All Industries', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('PROD002', 'Commercial Property Insurance - High Value', 'PROP-HV-001', 'PROPERTY', 'COMMERCIAL', 'High Value Property', 1.25, 'HIGH', 'Enhanced coverage for high-value commercial properties', 'ACTIVE', TRUE, '2020-01-01', 'Real Estate, Manufacturing', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),

-- General Liability
('PROD010', 'General Liability - Standard', 'GL-STD-001', 'LIABILITY', 'COMMERCIAL', 'General Liability', 0.65, 'LOW', 'Standard general liability coverage', 'ACTIVE', TRUE, '2020-01-01', 'All Industries', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('PROD011', 'General Liability - Construction', 'GL-CONST-001', 'LIABILITY', 'COMMERCIAL', 'Construction GL', 2.15, 'HIGH', 'Specialized general liability for construction operations', 'ACTIVE', TRUE, '2020-01-01', 'Construction', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('PROD012', 'General Liability - Hospitality', 'GL-HOSP-001', 'LIABILITY', 'COMMERCIAL', 'Hospitality GL', 1.35, 'MEDIUM', 'General liability for restaurants, hotels, and hospitality', 'ACTIVE', TRUE, '2020-01-01', 'Hospitality', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),

-- Professional Liability
('PROD020', 'Professional Liability - Standard', 'PL-STD-001', 'LIABILITY', 'COMMERCIAL', 'Errors & Omissions', 1.85, 'MEDIUM', 'Professional liability/E&O coverage', 'ACTIVE', TRUE, '2020-01-01', 'Professional Services, Healthcare', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('PROD021', 'Professional Liability - Healthcare', 'PL-HC-001', 'LIABILITY', 'COMMERCIAL', 'Medical Malpractice', 3.25, 'HIGH', 'Professional liability for healthcare providers', 'ACTIVE', TRUE, '2020-01-01', 'Healthcare', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('PROD022', 'Directors & Officers Liability', 'DO-STD-001', 'LIABILITY', 'COMMERCIAL', 'D&O Coverage', 2.45, 'MEDIUM', 'Directors and officers liability insurance', 'ACTIVE', TRUE, '2020-01-01', 'All Industries', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),

-- Workers Compensation
('PROD030', 'Workers Compensation - Standard', 'WC-STD-001', 'WORKERS_COMP', 'COMMERCIAL', 'Workers Compensation', 2.15, 'MEDIUM', 'Standard workers compensation insurance', 'ACTIVE', TRUE, '2020-01-01', 'All Industries', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('PROD031', 'Workers Compensation - Construction', 'WC-CONST-001', 'WORKERS_COMP', 'COMMERCIAL', 'Construction WC', 6.50, 'HIGH', 'Workers compensation for construction industry', 'ACTIVE', TRUE, '2020-01-01', 'Construction', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('PROD032', 'Workers Compensation - Healthcare', 'WC-HC-001', 'WORKERS_COMP', 'COMMERCIAL', 'Healthcare WC', 3.85, 'MEDIUM', 'Workers compensation for healthcare facilities', 'ACTIVE', TRUE, '2020-01-01', 'Healthcare', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),

-- Cyber Insurance
('PROD040', 'Cyber Liability Insurance', 'CYB-STD-001', 'CYBER', 'COMMERCIAL', 'Cyber & Data Breach', 1.95, 'HIGH', 'Cyber liability and data breach coverage', 'ACTIVE', TRUE, '2021-01-01', 'Technology, Healthcare, Finance', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('PROD041', 'Cyber Crime Insurance', 'CYB-CRIME-001', 'CYBER', 'COMMERCIAL', 'Cyber Crime', 1.65, 'HIGH', 'Coverage for cyber crimes and electronic theft', 'ACTIVE', TRUE, '2021-01-01', 'All Industries', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),

-- Commercial Auto
('PROD050', 'Commercial Auto - Standard Fleet', 'AUTO-STD-001', 'AUTO', 'COMMERCIAL', 'Fleet Coverage', 1.45, 'MEDIUM', 'Commercial auto liability and physical damage', 'ACTIVE', TRUE, '2020-01-01', 'All Industries', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('PROD051', 'Commercial Auto - Trucking', 'AUTO-TRUCK-001', 'AUTO', 'COMMERCIAL', 'Trucking Coverage', 3.25, 'HIGH', 'Commercial auto for trucking and transportation', 'ACTIVE', TRUE, '2020-01-01', 'Transportation, Logistics', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),

-- Umbrella/Excess Liability
('PROD060', 'Excess Liability - $5M', 'EXCESS-5M-001', 'EXCESS', 'COMMERCIAL', 'Umbrella Liability', 0.45, 'LOW', 'Excess liability coverage up to $5 million', 'ACTIVE', TRUE, '2020-01-01', 'All Industries', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('PROD061', 'Excess Liability - $10M', 'EXCESS-10M-001', 'EXCESS', 'COMMERCIAL', 'Umbrella Liability', 0.75, 'MEDIUM', 'Excess liability coverage up to $10 million', 'ACTIVE', TRUE, '2020-01-01', 'All Industries', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),

-- Builders Risk
('PROD070', 'Builders Risk Insurance', 'BR-STD-001', 'PROPERTY', 'COMMERCIAL', 'Course of Construction', 1.25, 'MEDIUM', 'Coverage for buildings under construction', 'ACTIVE', TRUE, '2020-01-01', 'Construction, Real Estate', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),

-- Pollution Liability
('PROD080', 'Pollution Liability Insurance', 'POLL-STD-001', 'LIABILITY', 'COMMERCIAL', 'Environmental Coverage', 2.85, 'HIGH', 'Pollution liability and environmental coverage', 'ACTIVE', TRUE, '2020-01-01', 'Manufacturing, Construction, Waste Management', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),

-- Employee Benefits
('PROD100', 'Group Health Insurance - PPO', 'HEALTH-PPO-001', 'HEALTH', 'EMPLOYEE_BENEFITS', 'Medical Coverage', 0.00, 'LOW', 'PPO health insurance plans', 'ACTIVE', TRUE, '2020-01-01', 'All Industries', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('PROD101', 'Group Health Insurance - HDHP', 'HEALTH-HDHP-001', 'HEALTH', 'EMPLOYEE_BENEFITS', 'Medical Coverage', 0.00, 'LOW', 'High deductible health plans with HSA', 'ACTIVE', TRUE, '2020-01-01', 'All Industries', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('PROD102', 'Group Dental Insurance', 'DENTAL-STD-001', 'DENTAL', 'EMPLOYEE_BENEFITS', 'Dental Coverage', 0.00, 'LOW', 'Group dental insurance coverage', 'ACTIVE', TRUE, '2020-01-01', 'All Industries', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('PROD103', 'Group Vision Insurance', 'VISION-STD-001', 'VISION', 'EMPLOYEE_BENEFITS', 'Vision Coverage', 0.00, 'LOW', 'Group vision insurance coverage', 'ACTIVE', TRUE, '2020-01-01', 'All Industries', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('PROD104', 'Group Life Insurance', 'LIFE-STD-001', 'LIFE', 'EMPLOYEE_BENEFITS', 'Life Insurance', 0.00, 'LOW', 'Group term life insurance', 'ACTIVE', TRUE, '2020-01-01', 'All Industries', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('PROD105', 'Short-Term Disability', 'STD-STD-001', 'DISABILITY', 'EMPLOYEE_BENEFITS', 'STD Coverage', 0.00, 'LOW', 'Short-term disability insurance', 'ACTIVE', TRUE, '2020-01-01', 'All Industries', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('PROD106', 'Long-Term Disability', 'LTD-STD-001', 'DISABILITY', 'EMPLOYEE_BENEFITS', 'LTD Coverage', 0.00, 'LOW', 'Long-term disability insurance', 'ACTIVE', TRUE, '2020-01-01', 'All Industries', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP());

-- ============================================================================
-- Step 3: Generate Clients
-- ============================================================================
INSERT INTO CLIENTS
SELECT
    'CLI' || LPAD(SEQ4(), 10, '0') AS client_id,
    CASE (UNIFORM(0, 100, RANDOM()) % 20)
        WHEN 0 THEN 'ABC Construction Inc'
        WHEN 1 THEN 'Southwest Medical Group'
        WHEN 2 THEN 'Desert Hospitality LLC'
        WHEN 3 THEN 'Valley Manufacturing Company'
        WHEN 4 THEN 'Phoenix Real Estate Holdings'
        WHEN 5 THEN 'Arizona Technology Solutions'
        WHEN 6 THEN 'Copper State Builders'
        WHEN 7 THEN 'Grand Canyon Healthcare'
        WHEN 8 THEN 'Sonoran Desert Resorts'
        WHEN 9 THEN 'Cactus Valley Apartments'
        WHEN 10 THEN 'Desert View Nonprofits Foundation'
        WHEN 11 THEN 'Arizona Professional Services'
        WHEN 12 THEN 'Southwest Transportation LLC'
        WHEN 13 THEN 'Valley View Restaurants'
        WHEN 14 THEN 'Phoenix Education Institute'
        WHEN 15 THEN 'Arizona Waste Management'
        WHEN 16 THEN 'Desert Manufacturing Corp'
        WHEN 17 THEN 'Scottsdale Senior Living'
        WHEN 18 THEN 'Arizona Self Storage'
        WHEN 19 THEN 'Southwest Pest Control'
    END || ' ' || SEQ4() AS client_name,
    'contact' || SEQ4() || '@client' || UNIFORM(1, 999, RANDOM()) || '.com' AS primary_contact_email,
    '+1-' || LPAD(UNIFORM(200, 999, RANDOM())::VARCHAR, 3, '0') || '-' || 
        LPAD(UNIFORM(0, 999, RANDOM())::VARCHAR, 3, '0') || '-' || 
        LPAD(UNIFORM(0, 9999, RANDOM())::VARCHAR, 4, '0') AS primary_contact_phone,
    'USA' AS country,
    ARRAY_CONSTRUCT('AZ', 'CA', 'NV', 'UT', 'CO', 'NM', 'TX')[UNIFORM(0, 6, RANDOM())] AS state,
    ARRAY_CONSTRUCT('Phoenix', 'Chandler', 'Scottsdale', 'Mesa', 'Tempe', 'Gilbert', 'Glendale', 'Peoria', 'Tucson', 'Flagstaff')[UNIFORM(0, 9, RANDOM())] AS city,
    DATEADD('day', -1 * UNIFORM(365, 3650, RANDOM()), CURRENT_DATE()) AS onboarding_date,
    ARRAY_CONSTRUCT('ACTIVE', 'ACTIVE', 'ACTIVE', 'ACTIVE', 'INACTIVE')[UNIFORM(0, 4, RANDOM())] AS client_status,
    ARRAY_CONSTRUCT('SMALL_BUSINESS', 'MIDMARKET', 'LARGE_ACCOUNT')[UNIFORM(0, 2, RANDOM())] AS business_segment,
    ARRAY_CONSTRUCT('CONSTRUCTION', 'HEALTHCARE', 'HOSPITALITY', 'MANUFACTURING', 'REAL_ESTATE', 
                    'TECHNOLOGY', 'NONPROFITS', 'EDUCATION', 'RETAIL', 'PROFESSIONAL_SERVICES',
                    'TRANSPORTATION', 'WASTE_MANAGEMENT', 'AGRICULTURE', 'CRAFT_BREWERIES')[UNIFORM(0, 13, RANDOM())] AS industry_vertical,
    UNIFORM(500000, 50000000, RANDOM()) AS annual_revenue,
    UNIFORM(10, 500, RANDOM()) AS employee_count,
    ARRAY_CONSTRUCT('A+', 'A', 'A-', 'B+', 'B', 'B-', 'C+', 'C')[UNIFORM(0, 7, RANDOM())] AS risk_rating,
    UNIFORM(50000, 500000, RANDOM()) AS lifetime_premium_value,
    UNIFORM(0, 50, RANDOM()) AS total_claim_history,
    (UNIFORM(38, 50, RANDOM()) / 10.0)::NUMBER(3,2) AS client_satisfaction_score,
    DATEADD('day', -1 * UNIFORM(365, 3650, RANDOM()), CURRENT_TIMESTAMP()) AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
FROM TABLE(GENERATOR(ROWCOUNT => 10000));

-- ============================================================================
-- Step 4: Generate Claims Adjusters
-- ============================================================================
INSERT INTO CLAIMS_ADJUSTERS
SELECT
    'ADJ' || LPAD(SEQ4(), 5, '0') AS adjuster_id,
    ARRAY_CONSTRUCT('Michael Johnson', 'Sarah Williams', 'David Brown', 'Jennifer Jones', 'Robert Garcia',
                    'Mary Martinez', 'James Rodriguez', 'Patricia Lopez', 'John Lee', 'Linda Walker',
                    'William Hall', 'Barbara Allen', 'Richard Young', 'Susan King', 'Joseph Wright')[UNIFORM(0, 14, RANDOM())]
        AS adjuster_name,
    'adjuster' || SEQ4() || '@mahoneygroup.com' AS email,
    ARRAY_CONSTRUCT('PROPERTY', 'LIABILITY', 'AUTO', 'WORKERS_COMP', 'GENERAL')[UNIFORM(0, 4, RANDOM())] AS adjuster_type,
    ARRAY_CONSTRUCT('Property Damage', 'Bodily Injury', 'Auto Claims', 'Workers Compensation', 'Commercial Claims')[UNIFORM(0, 4, RANDOM())] AS specialization,
    DATEADD('day', -1 * UNIFORM(365, 3650, RANDOM()), CURRENT_DATE()) AS hire_date,
    (UNIFORM(38, 50, RANDOM()) / 10.0)::NUMBER(3,2) AS average_satisfaction_rating,
    UNIFORM(50, 500, RANDOM()) AS total_claims_handled,
    UNIFORM(5000, 75000, RANDOM()) AS average_claim_cost,
    'ACTIVE' AS adjuster_status,
    DATEADD('day', -1 * UNIFORM(365, 3650, RANDOM()), CURRENT_TIMESTAMP()) AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
FROM TABLE(GENERATOR(ROWCOUNT => 30));

-- ============================================================================
-- Step 5: Generate Policies
-- ============================================================================
INSERT INTO POLICIES
SELECT
    'POL' || LPAD(SEQ4(), 10, '0') AS policy_id,
    clients.client_id,
    agents.agent_id,
    products.product_id,
    'PN-' || YEAR(effective_date) || '-' || LPAD(SEQ4(), 8, '0') AS policy_number,
    effective_date,
    DATEADD('year', 1, effective_date) AS expiration_date,
    ARRAY_CONSTRUCT('ACTIVE', 'ACTIVE', 'ACTIVE', 'EXPIRED', 'CANCELLED')[UNIFORM(0, 4, RANDOM())] AS policy_status,
    products.product_category AS policy_type,
    UNIFORM(5000, 100000, RANDOM()) * products.base_rate AS annual_premium,
    UNIFORM(100000, 10000000, RANDOM()) AS total_coverage_limit,
    UNIFORM(1000, 25000, RANDOM()) AS deductible_amount,
    (UNIFORM(0, 100, RANDOM()) < 35) AS competitive_win,
    CASE WHEN (UNIFORM(0, 100, RANDOM()) < 35) 
        THEN ARRAY_CONSTRUCT('Travelers', 'Hartford', 'Zurich', 'Liberty Mutual', 'AIG', 'Chubb', 'CNA')[UNIFORM(0, 6, RANDOM())]
        ELSE NULL 
    END AS previous_carrier,
    (UNIFORM(8, 15, RANDOM()) / 10.0)::NUMBER(5,2) AS commission_rate,
    ARRAY_CONSTRUCT('ANNUAL', 'SEMI_ANNUAL', 'QUARTERLY', 'MONTHLY')[UNIFORM(0, 3, RANDOM())] AS payment_plan,
    DATEADD('day', -1 * UNIFORM(1, 730, RANDOM()), CURRENT_TIMESTAMP()) AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
FROM (
    SELECT 
        c.client_id,
        a.agent_id,
        p.product_id,
        p.base_rate,
        p.product_category,
        DATEADD('day', -1 * UNIFORM(1, 1095, RANDOM()), CURRENT_DATE()) AS effective_date
    FROM CLIENTS c
    CROSS JOIN (SELECT * FROM INSURANCE_AGENTS ORDER BY RANDOM() LIMIT 1) a
    CROSS JOIN (SELECT * FROM INSURANCE_PRODUCTS ORDER BY RANDOM() LIMIT 1) p
    WHERE c.client_status = 'ACTIVE'
    LIMIT 150000
) AS sub
JOIN CLIENTS clients ON sub.client_id = clients.client_id
JOIN INSURANCE_AGENTS agents ON sub.agent_id = agents.agent_id
JOIN INSURANCE_PRODUCTS products ON sub.product_id = products.product_id;

-- ============================================================================
-- Step 6: Generate Policy Renewals
-- ============================================================================
INSERT INTO POLICY_RENEWALS
SELECT
    'REN' || LPAD(SEQ4(), 10, '0') AS renewal_id,
    p.policy_id,
    p.client_id,
    p.agent_id,
    p.product_id,
    renewal_date,
    DATEADD('day', 1, p.expiration_date) AS renewal_effective_date,
    p.annual_premium * (1 + premium_change_pct / 100.0) AS renewal_premium,
    p.annual_premium AS previous_premium,
    premium_change_pct,
    ARRAY_CONSTRUCT('RENEWED', 'RENEWED', 'RENEWED', 'NON_RENEWED', 'PENDING')[UNIFORM(0, 4, RANDOM())] AS renewal_status,
    ARRAY_CONSTRUCT('STANDARD', 'EARLY_RENEWAL', 'LATE_RENEWAL', 'AUTO_RENEWAL')[UNIFORM(0, 3, RANDOM())] AS renewal_type,
    (UNIFORM(45, 95, RANDOM()) / 100.0)::NUMBER(8,2) AS loss_ratio_at_renewal,
    DATEADD('day', -1 * UNIFORM(1, 365, RANDOM()), CURRENT_TIMESTAMP()) AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
FROM (
    SELECT 
        policy_id,
        client_id,
        agent_id,
        product_id,
        expiration_date,
        annual_premium,
        DATEADD('day', -30, expiration_date) AS renewal_date,
        (UNIFORM(-15, 25, RANDOM()) / 1.0)::NUMBER(8,2) AS premium_change_pct
    FROM POLICIES
    WHERE policy_status IN ('ACTIVE', 'EXPIRED')
        AND expiration_date < CURRENT_DATE()
        AND UNIFORM(0, 100, RANDOM()) < 70
    LIMIT 100000
) AS sub
JOIN POLICIES p ON sub.policy_id = p.policy_id;

-- ============================================================================
-- Step 7: Generate Premium Payments
-- ============================================================================
INSERT INTO PREMIUM_PAYMENTS
SELECT
    'PAY' || LPAD(SEQ4(), 10, '0') AS payment_id,
    p.policy_id,
    p.client_id,
    payment_date,
    payment_amount,
    ARRAY_CONSTRUCT('INITIAL_PREMIUM', 'RENEWAL_PREMIUM', 'INSTALLMENT', 'AUDIT_PREMIUM', 'ENDORSEMENT')[UNIFORM(0, 4, RANDOM())] AS payment_type,
    ARRAY_CONSTRUCT('CHECK', 'ACH', 'CREDIT_CARD', 'WIRE_TRANSFER')[UNIFORM(0, 3, RANDOM())] AS payment_method,
    ARRAY_CONSTRUCT('COMPLETED', 'COMPLETED', 'COMPLETED', 'PENDING', 'FAILED')[UNIFORM(0, 4, RANDOM())] AS payment_status,
    'USD' AS currency,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 10 THEN UNIFORM(50, 500, RANDOM()) ELSE 0 END AS late_fee_amount,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 15 THEN UNIFORM(100, 1000, RANDOM()) ELSE 0 END AS discount_amount,
    payment_date AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
FROM (
    SELECT 
        policy_id,
        client_id,
        DATEADD('day', UNIFORM(0, 365, RANDOM()), effective_date) AS payment_date,
        CASE 
            WHEN payment_plan = 'ANNUAL' THEN annual_premium
            WHEN payment_plan = 'SEMI_ANNUAL' THEN annual_premium / 2
            WHEN payment_plan = 'QUARTERLY' THEN annual_premium / 4
            WHEN payment_plan = 'MONTHLY' THEN annual_premium / 12
        END AS payment_amount,
        payment_plan,
        effective_date
    FROM POLICIES
    WHERE policy_status IN ('ACTIVE', 'EXPIRED')
    LIMIT 200000
) AS sub
JOIN POLICIES p ON sub.policy_id = p.policy_id;

-- ============================================================================
-- Step 8: Generate Claims
-- ============================================================================
INSERT INTO CLAIMS
SELECT
    'CLM' || LPAD(SEQ4(), 10, '0') AS claim_id,
    p.policy_id,
    p.client_id,
    adj.adjuster_id,
    'CN-' || YEAR(incident_date) || '-' || LPAD(SEQ4(), 8, '0') AS claim_number,
    incident_date,
    DATEADD('day', UNIFORM(1, 10, RANDOM()), incident_date) AS report_date,
    claim_type,
    claim_category,
    loss_type,
    incident_description,
    ARRAY_CONSTRUCT('REPORTED', 'OPEN', 'UNDER_INVESTIGATION', 'SETTLED', 'CLOSED', 'DENIED')[UNIFORM(0, 5, RANDOM())] AS claim_status,
    ARRAY_CONSTRUCT('MINOR', 'MODERATE', 'SERIOUS', 'CATASTROPHIC')[UNIFORM(0, 3, RANDOM())] AS severity,
    claim_amount_paid,
    claim_amount_reserved,
    claim_amount_paid + claim_amount_reserved AS claim_amount_incurred,
    CASE WHEN claim_status IN ('SETTLED', 'CLOSED') 
        THEN DATEADD('day', UNIFORM(30, 180, RANDOM()), report_date) 
        ELSE NULL 
    END AS settlement_date,
    CASE WHEN claim_status IN ('SETTLED', 'CLOSED') 
        THEN claim_amount_paid 
        ELSE NULL 
    END AS settlement_amount,
    (UNIFORM(0, 100, RANDOM()) < 20) AS subrogation_potential,
    (UNIFORM(0, 100, RANDOM()) < 15) AS litigation_involved,
    DATEADD('day', UNIFORM(1, 10, RANDOM()), incident_date) AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
FROM (
    SELECT 
        policy_id,
        client_id,
        policy_type,
        DATEADD('day', UNIFORM(0, 365, RANDOM()), effective_date) AS incident_date,
        effective_date,
        CASE policy_type
            WHEN 'PROPERTY' THEN 'PROPERTY_DAMAGE'
            WHEN 'LIABILITY' THEN 'BODILY_INJURY'
            WHEN 'WORKERS_COMP' THEN 'INJURY'
            WHEN 'AUTO' THEN 'AUTO_ACCIDENT'
            WHEN 'CYBER' THEN 'DATA_BREACH'
            ELSE 'OTHER'
        END AS claim_type,
        CASE policy_type
            WHEN 'PROPERTY' THEN ARRAY_CONSTRUCT('FIRE', 'WATER_DAMAGE', 'THEFT', 'VANDALISM', 'STORM')[UNIFORM(0, 4, RANDOM())]
            WHEN 'LIABILITY' THEN ARRAY_CONSTRUCT('SLIP_AND_FALL', 'PRODUCT_LIABILITY', 'PREMISES_LIABILITY')[UNIFORM(0, 2, RANDOM())]
            WHEN 'WORKERS_COMP' THEN ARRAY_CONSTRUCT('BACK_INJURY', 'SLIP_AND_FALL', 'MACHINERY_INJURY', 'REPETITIVE_STRAIN')[UNIFORM(0, 3, RANDOM())]
            WHEN 'AUTO' THEN ARRAY_CONSTRUCT('COLLISION', 'COMPREHENSIVE', 'LIABILITY')[UNIFORM(0, 2, RANDOM())]
            WHEN 'CYBER' THEN ARRAY_CONSTRUCT('DATA_BREACH', 'RANSOMWARE', 'BUSINESS_INTERRUPTION')[UNIFORM(0, 2, RANDOM())]
            ELSE 'OTHER'
        END AS claim_category,
        ARRAY_CONSTRUCT('ACCIDENTAL', 'SUDDEN', 'GRADUAL', 'NATURAL_DISASTER', 'THEFT')[UNIFORM(0, 4, RANDOM())] AS loss_type,
        'Incident resulted in ' || claim_type || ' requiring insurance claim' AS incident_description,
        UNIFORM(5000, 150000, RANDOM()) AS claim_amount_paid,
        UNIFORM(2000, 50000, RANDOM()) AS claim_amount_reserved,
        ARRAY_CONSTRUCT('REPORTED', 'OPEN', 'UNDER_INVESTIGATION', 'SETTLED', 'CLOSED', 'DENIED')[UNIFORM(0, 5, RANDOM())] AS claim_status
    FROM POLICIES
    WHERE policy_status IN ('ACTIVE', 'EXPIRED')
        AND UNIFORM(0, 100, RANDOM()) < 35
    LIMIT 50000
) AS sub
JOIN POLICIES p ON sub.policy_id = p.policy_id
CROSS JOIN (SELECT adjuster_id FROM CLAIMS_ADJUSTERS ORDER BY RANDOM() LIMIT 1) adj;

-- ============================================================================
-- Step 9: Generate Claim Disputes
-- ============================================================================
INSERT INTO CLAIM_DISPUTES
SELECT
    'DIS' || LPAD(SEQ4(), 10, '0') AS dispute_id,
    c.claim_id,
    c.client_id,
    DATEADD('day', UNIFORM(15, 90, RANDOM()), c.report_date) AS dispute_filed_date,
    ARRAY_CONSTRUCT('COVERAGE_DENIAL', 'CLAIM_AMOUNT', 'LIABILITY', 'POLICY_INTERPRETATION', 'CAUSATION')[UNIFORM(0, 4, RANDOM())] AS dispute_type,
    ARRAY_CONSTRUCT('LOW', 'MEDIUM', 'HIGH')[UNIFORM(0, 2, RANDOM())] AS dispute_severity,
    'Client disputes the claim decision and has filed formal dispute' AS dispute_description,
    ARRAY_CONSTRUCT('OPEN', 'IN_MEDIATION', 'IN_ARBITRATION', 'RESOLVED', 'LITIGATION')[UNIFORM(0, 4, RANDOM())] AS dispute_status,
    ARRAY_CONSTRUCT('NEGOTIATION', 'MEDIATION', 'ARBITRATION', 'LITIGATION', 'SETTLEMENT')[UNIFORM(0, 4, RANDOM())] AS resolution_method,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 60 
        THEN ARRAY_CONSTRUCT('CARRIER_FAVOR', 'CLIENT_FAVOR', 'COMPROMISE', 'WITHDRAWN')[UNIFORM(0, 3, RANDOM())]
        ELSE NULL 
    END AS dispute_outcome,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 60 
        THEN DATEADD('day', UNIFORM(90, 365, RANDOM()), c.report_date)
        ELSE NULL 
    END AS resolution_date,
    UNIFORM(2000, 50000, RANDOM()) AS legal_costs,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 60 
        THEN UNIFORM(5000, 100000, RANDOM())
        ELSE NULL 
    END AS settlement_amount,
    (UNIFORM(0, 100, RANDOM()) < 40) AS attorney_involved,
    DATEADD('day', UNIFORM(15, 90, RANDOM()), c.report_date) AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
FROM CLAIMS c
WHERE c.claim_status IN ('OPEN', 'UNDER_INVESTIGATION', 'DENIED')
    AND UNIFORM(0, 100, RANDOM()) < 20
LIMIT 10000;

-- ============================================================================
-- Step 10: Generate Loss Control Services
-- ============================================================================
INSERT INTO LOSS_CONTROL_SERVICES
SELECT
    'LCS' || LPAD(SEQ4(), 10, '0') AS service_id,
    c.client_id,
    ARRAY_CONSTRUCT('SAFETY_INSPECTION', 'RISK_ASSESSMENT', 'TRAINING', 'ERGONOMIC_EVALUATION', 'FIRE_SAFETY')[UNIFORM(0, 4, RANDOM())] AS service_type,
    DATEADD('day', UNIFORM(1, 365, RANDOM()), c.onboarding_date) AS service_date,
    ARRAY_CONSTRUCT('John Smith - Risk Consultant', 'Sarah Johnson - Safety Specialist', 'Michael Brown - Loss Control')[UNIFORM(0, 2, RANDOM())] AS consultant_name,
    'Comprehensive assessment completed with ' || UNIFORM(5, 15, RANDOM()) || ' recommendations provided' AS recommendations_provided,
    ARRAY_CONSTRUCT('HIGH', 'MEDIUM', 'LOW')[UNIFORM(0, 2, RANDOM())] AS priority_level,
    ARRAY_CONSTRUCT('IMPLEMENTED', 'IN_PROGRESS', 'PLANNED', 'NOT_STARTED')[UNIFORM(0, 3, RANDOM())] AS implementation_status,
    UNIFORM(10000, 100000, RANDOM()) AS estimated_cost_savings,
    'COMPLETED' AS service_status,
    DATEADD('day', UNIFORM(1, 365, RANDOM()), c.onboarding_date) AS created_at
FROM CLIENTS c
WHERE c.client_status = 'ACTIVE'
    AND UNIFORM(0, 100, RANDOM()) < 40
LIMIT 15000;

-- ============================================================================
-- Step 11: Generate Benefit Plans
-- ============================================================================
INSERT INTO BENEFIT_PLANS
SELECT
    'BEN' || LPAD(SEQ4(), 10, '0') AS plan_id,
    c.client_id,
    a.agent_id,
    p.product_name AS plan_name,
    p.product_category AS plan_type,
    p.product_line AS plan_category,
    DATEADD('day', UNIFORM(1, 730, RANDOM()), c.onboarding_date) AS effective_date,
    DATEADD('year', 1, DATEADD('day', UNIFORM(1, 730, RANDOM()), c.onboarding_date)) AS expiration_date,
    c.employee_count AS covered_employees,
    CASE p.product_category
        WHEN 'HEALTH' THEN c.employee_count * UNIFORM(450, 650, RANDOM())
        WHEN 'DENTAL' THEN c.employee_count * UNIFORM(30, 50, RANDOM())
        WHEN 'VISION' THEN c.employee_count * UNIFORM(10, 20, RANDOM())
        WHEN 'LIFE' THEN c.employee_count * UNIFORM(15, 30, RANDOM())
        WHEN 'DISABILITY' THEN c.employee_count * UNIFORM(25, 45, RANDOM())
        ELSE c.employee_count * 100
    END AS monthly_premium,
    CASE p.product_category
        WHEN 'HEALTH' THEN c.employee_count * UNIFORM(450, 650, RANDOM()) * 12
        WHEN 'DENTAL' THEN c.employee_count * UNIFORM(30, 50, RANDOM()) * 12
        WHEN 'VISION' THEN c.employee_count * UNIFORM(10, 20, RANDOM()) * 12
        WHEN 'LIFE' THEN c.employee_count * UNIFORM(15, 30, RANDOM()) * 12
        WHEN 'DISABILITY' THEN c.employee_count * UNIFORM(25, 45, RANDOM()) * 12
        ELSE c.employee_count * 1200
    END AS annual_premium,
    'ACTIVE' AS plan_status,
    ARRAY_CONSTRUCT('Blue Cross Blue Shield', 'United Healthcare', 'Aetna', 'Cigna', 'Humana')[UNIFORM(0, 4, RANDOM())] AS carrier_name,
    DATEADD('day', UNIFORM(1, 730, RANDOM()), c.onboarding_date) AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
FROM CLIENTS c
CROSS JOIN (SELECT agent_id FROM INSURANCE_AGENTS WHERE agent_type = 'EMPLOYEE_BENEFITS' ORDER BY RANDOM() LIMIT 1) a
CROSS JOIN (SELECT * FROM INSURANCE_PRODUCTS WHERE product_line = 'EMPLOYEE_BENEFITS' ORDER BY RANDOM() LIMIT 1) p
WHERE c.client_status = 'ACTIVE'
    AND c.employee_count >= 10
    AND UNIFORM(0, 100, RANDOM()) < 50
LIMIT 30000;

-- ============================================================================
-- Step 12: Generate Marketing Campaigns
-- ============================================================================
INSERT INTO MARKETING_CAMPAIGNS VALUES
('CAMP001', 'Construction Safety Program 2024', 'INDUSTRY_TARGETED', '2024-01-01', '2024-12-31', 'CONSTRUCTION', 'MIDMARKET,LARGE_ACCOUNT', 150000, 'EMAIL,WEBINAR', 'ACTIVE', 450, 45, 2250000, CURRENT_TIMESTAMP()),
('CAMP002', 'Healthcare Risk Management Series', 'INDUSTRY_TARGETED', '2024-01-01', '2024-12-31', 'HEALTHCARE', 'MIDMARKET', 100000, 'EMAIL,EVENTS', 'ACTIVE', 320, 32, 1600000, CURRENT_TIMESTAMP()),
('CAMP003', 'Small Business Insurance Package', 'SEGMENT_TARGETED', '2024-01-01', '2024-06-30', 'All Industries', 'SMALL_BUSINESS', 75000, 'DIGITAL_ADS', 'COMPLETED', 890, 112, 3360000, CURRENT_TIMESTAMP()),
('CAMP004', 'Cyber Insurance Awareness Campaign', 'PRODUCT_FOCUSED', '2024-03-01', '2024-09-30', 'TECHNOLOGY,HEALTHCARE', 'ALL', 125000, 'EMAIL,SOCIAL_MEDIA', 'ACTIVE', 560, 68, 2720000, CURRENT_TIMESTAMP()),
('CAMP005', 'Real Estate Insurance Solutions', 'INDUSTRY_TARGETED', '2024-02-01', '2024-12-31', 'REAL_ESTATE', 'MIDMARKET,LARGE_ACCOUNT', 80000, 'DIRECT_MAIL', 'ACTIVE', 280, 35, 1750000, CURRENT_TIMESTAMP());

-- ============================================================================
-- Display completion message
-- ============================================================================
SELECT 'Synthetic data generation completed successfully' AS status;
SELECT COUNT(*) AS client_count FROM CLIENTS;
SELECT COUNT(*) AS policy_count FROM POLICIES;
SELECT COUNT(*) AS claim_count FROM CLAIMS;
SELECT COUNT(*) AS benefit_plan_count FROM BENEFIT_PLANS;


