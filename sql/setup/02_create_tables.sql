-- ============================================================================
-- Mahoney Group Intelligence Agent - Table Definitions
-- ============================================================================
-- Purpose: Create all necessary tables for Mahoney Group's multi-line insurance
--          and employee benefits business model
-- All columns verified against Snowflake SQL syntax
-- ============================================================================

USE DATABASE MAHONEY_GROUP_INTELLIGENCE;
USE SCHEMA RAW;
USE WAREHOUSE MAHONEY_WH;

-- ============================================================================
-- CLIENTS TABLE (businesses purchasing insurance from Mahoney Group)
-- ============================================================================
CREATE OR REPLACE TABLE CLIENTS (
    client_id VARCHAR(20) PRIMARY KEY,
    client_name VARCHAR(200) NOT NULL,
    primary_contact_email VARCHAR(200) NOT NULL,
    primary_contact_phone VARCHAR(20),
    country VARCHAR(50) DEFAULT 'USA',
    state VARCHAR(50),
    city VARCHAR(100),
    onboarding_date DATE NOT NULL,
    client_status VARCHAR(20) DEFAULT 'ACTIVE',
    business_segment VARCHAR(30),
    industry_vertical VARCHAR(50),
    annual_revenue NUMBER(15,2),
    employee_count NUMBER(10,0),
    risk_rating VARCHAR(10),
    lifetime_premium_value NUMBER(12,2) DEFAULT 0.00,
    total_claim_history NUMBER(10,0) DEFAULT 0,
    client_satisfaction_score NUMBER(3,2),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ============================================================================
-- INSURANCE_AGENTS TABLE (Mahoney Group agents/brokers)
-- ============================================================================
CREATE OR REPLACE TABLE INSURANCE_AGENTS (
    agent_id VARCHAR(20) PRIMARY KEY,
    agent_name VARCHAR(200) NOT NULL,
    email VARCHAR(200) NOT NULL,
    phone VARCHAR(20),
    agent_type VARCHAR(50),
    specialization VARCHAR(100),
    office_location VARCHAR(100),
    region VARCHAR(50),
    agent_status VARCHAR(20) DEFAULT 'ACTIVE',
    hire_date DATE,
    production_tier VARCHAR(30),
    total_clients NUMBER(10,0) DEFAULT 0,
    total_premium_written NUMBER(15,2) DEFAULT 0.00,
    average_client_satisfaction NUMBER(3,2),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ============================================================================
-- INSURANCE_PRODUCTS TABLE (all insurance products offered)
-- ============================================================================
CREATE OR REPLACE TABLE INSURANCE_PRODUCTS (
    product_id VARCHAR(30) PRIMARY KEY,
    product_name VARCHAR(200) NOT NULL,
    product_code VARCHAR(50) NOT NULL,
    product_category VARCHAR(50) NOT NULL,
    product_line VARCHAR(50) NOT NULL,
    coverage_type VARCHAR(100),
    base_rate NUMBER(10,4),
    risk_level VARCHAR(20),
    product_description VARCHAR(1000),
    product_status VARCHAR(30) DEFAULT 'ACTIVE',
    is_active BOOLEAN DEFAULT TRUE,
    launch_date DATE,
    target_industries VARCHAR(500),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ============================================================================
-- POLICIES TABLE (insurance policies sold to clients)
-- ============================================================================
CREATE OR REPLACE TABLE POLICIES (
    policy_id VARCHAR(30) PRIMARY KEY,
    client_id VARCHAR(20) NOT NULL,
    agent_id VARCHAR(20) NOT NULL,
    product_id VARCHAR(30) NOT NULL,
    policy_number VARCHAR(50) UNIQUE NOT NULL,
    effective_date DATE NOT NULL,
    expiration_date DATE NOT NULL,
    policy_status VARCHAR(30) DEFAULT 'ACTIVE',
    policy_type VARCHAR(50),
    annual_premium NUMBER(12,2) NOT NULL,
    total_coverage_limit NUMBER(15,2),
    deductible_amount NUMBER(10,2),
    competitive_win BOOLEAN DEFAULT FALSE,
    previous_carrier VARCHAR(100),
    commission_rate NUMBER(5,2),
    payment_plan VARCHAR(30),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (client_id) REFERENCES CLIENTS(client_id),
    FOREIGN KEY (agent_id) REFERENCES INSURANCE_AGENTS(agent_id),
    FOREIGN KEY (product_id) REFERENCES INSURANCE_PRODUCTS(product_id)
);

-- ============================================================================
-- POLICY_COVERAGES TABLE (specific coverages under policies)
-- ============================================================================
CREATE OR REPLACE TABLE POLICY_COVERAGES (
    coverage_id VARCHAR(30) PRIMARY KEY,
    policy_id VARCHAR(30) NOT NULL,
    coverage_name VARCHAR(200) NOT NULL,
    coverage_type VARCHAR(50),
    coverage_limit NUMBER(15,2),
    coverage_deductible NUMBER(10,2),
    coverage_premium NUMBER(10,2),
    coverage_status VARCHAR(30) DEFAULT 'ACTIVE',
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (policy_id) REFERENCES POLICIES(policy_id)
);

-- ============================================================================
-- POLICY_RENEWALS TABLE
-- ============================================================================
CREATE OR REPLACE TABLE POLICY_RENEWALS (
    renewal_id VARCHAR(30) PRIMARY KEY,
    policy_id VARCHAR(30) NOT NULL,
    client_id VARCHAR(20) NOT NULL,
    agent_id VARCHAR(20) NOT NULL,
    product_id VARCHAR(30) NOT NULL,
    renewal_date DATE NOT NULL,
    renewal_effective_date DATE NOT NULL,
    renewal_premium NUMBER(12,2),
    previous_premium NUMBER(12,2),
    premium_change_pct NUMBER(8,2),
    renewal_status VARCHAR(30) DEFAULT 'RENEWED',
    renewal_type VARCHAR(50),
    loss_ratio_at_renewal NUMBER(8,2),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (policy_id) REFERENCES POLICIES(policy_id),
    FOREIGN KEY (client_id) REFERENCES CLIENTS(client_id),
    FOREIGN KEY (agent_id) REFERENCES INSURANCE_AGENTS(agent_id),
    FOREIGN KEY (product_id) REFERENCES INSURANCE_PRODUCTS(product_id)
);

-- ============================================================================
-- PREMIUM_PAYMENTS TABLE
-- ============================================================================
CREATE OR REPLACE TABLE PREMIUM_PAYMENTS (
    payment_id VARCHAR(30) PRIMARY KEY,
    policy_id VARCHAR(30) NOT NULL,
    client_id VARCHAR(20) NOT NULL,
    payment_date TIMESTAMP_NTZ NOT NULL,
    payment_amount NUMBER(12,2) NOT NULL,
    payment_type VARCHAR(50) NOT NULL,
    payment_method VARCHAR(30),
    payment_status VARCHAR(30) DEFAULT 'COMPLETED',
    currency VARCHAR(10) DEFAULT 'USD',
    late_fee_amount NUMBER(10,2) DEFAULT 0.00,
    discount_amount NUMBER(10,2) DEFAULT 0.00,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (policy_id) REFERENCES POLICIES(policy_id),
    FOREIGN KEY (client_id) REFERENCES CLIENTS(client_id)
);

-- ============================================================================
-- CLAIMS_ADJUSTERS TABLE
-- ============================================================================
CREATE OR REPLACE TABLE CLAIMS_ADJUSTERS (
    adjuster_id VARCHAR(20) PRIMARY KEY,
    adjuster_name VARCHAR(200) NOT NULL,
    email VARCHAR(200) NOT NULL,
    adjuster_type VARCHAR(50),
    specialization VARCHAR(100),
    hire_date DATE,
    average_satisfaction_rating NUMBER(3,2),
    total_claims_handled NUMBER(10,0) DEFAULT 0,
    average_claim_cost NUMBER(12,2),
    adjuster_status VARCHAR(30) DEFAULT 'ACTIVE',
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ============================================================================
-- CLAIMS TABLE (insurance claims filed)
-- ============================================================================
CREATE OR REPLACE TABLE CLAIMS (
    claim_id VARCHAR(30) PRIMARY KEY,
    policy_id VARCHAR(30) NOT NULL,
    client_id VARCHAR(20) NOT NULL,
    adjuster_id VARCHAR(20),
    claim_number VARCHAR(50) UNIQUE NOT NULL,
    incident_date DATE NOT NULL,
    report_date TIMESTAMP_NTZ NOT NULL,
    claim_type VARCHAR(50) NOT NULL,
    claim_category VARCHAR(50),
    loss_type VARCHAR(50),
    incident_description VARCHAR(5000),
    claim_status VARCHAR(30) DEFAULT 'REPORTED',
    severity VARCHAR(20) DEFAULT 'MEDIUM',
    claim_amount_paid NUMBER(12,2) DEFAULT 0.00,
    claim_amount_reserved NUMBER(12,2) DEFAULT 0.00,
    claim_amount_incurred NUMBER(12,2) DEFAULT 0.00,
    settlement_date TIMESTAMP_NTZ,
    settlement_amount NUMBER(12,2),
    subrogation_potential BOOLEAN DEFAULT FALSE,
    litigation_involved BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (policy_id) REFERENCES POLICIES(policy_id),
    FOREIGN KEY (client_id) REFERENCES CLIENTS(client_id),
    FOREIGN KEY (adjuster_id) REFERENCES CLAIMS_ADJUSTERS(adjuster_id)
);

-- ============================================================================
-- CLAIM_DISPUTES TABLE
-- ============================================================================
CREATE OR REPLACE TABLE CLAIM_DISPUTES (
    dispute_id VARCHAR(30) PRIMARY KEY,
    claim_id VARCHAR(30) NOT NULL,
    client_id VARCHAR(20) NOT NULL,
    dispute_filed_date TIMESTAMP_NTZ NOT NULL,
    dispute_type VARCHAR(50) NOT NULL,
    dispute_severity VARCHAR(20) DEFAULT 'MEDIUM',
    dispute_description VARCHAR(5000),
    dispute_status VARCHAR(30) DEFAULT 'OPEN',
    resolution_method VARCHAR(50),
    dispute_outcome VARCHAR(100),
    resolution_date TIMESTAMP_NTZ,
    legal_costs NUMBER(12,2) DEFAULT 0.00,
    settlement_amount NUMBER(12,2),
    attorney_involved BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (claim_id) REFERENCES CLAIMS(claim_id),
    FOREIGN KEY (client_id) REFERENCES CLIENTS(client_id)
);

-- ============================================================================
-- LOSS_CONTROL_SERVICES TABLE (risk management services)
-- ============================================================================
CREATE OR REPLACE TABLE LOSS_CONTROL_SERVICES (
    service_id VARCHAR(30) PRIMARY KEY,
    client_id VARCHAR(20) NOT NULL,
    service_type VARCHAR(50) NOT NULL,
    service_date DATE NOT NULL,
    consultant_name VARCHAR(200),
    recommendations_provided VARCHAR(5000),
    priority_level VARCHAR(20),
    implementation_status VARCHAR(30),
    estimated_cost_savings NUMBER(12,2),
    service_status VARCHAR(30) DEFAULT 'COMPLETED',
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (client_id) REFERENCES CLIENTS(client_id)
);

-- ============================================================================
-- BENEFIT_PLANS TABLE (employee benefits)
-- ============================================================================
CREATE OR REPLACE TABLE BENEFIT_PLANS (
    plan_id VARCHAR(30) PRIMARY KEY,
    client_id VARCHAR(20) NOT NULL,
    agent_id VARCHAR(20) NOT NULL,
    plan_name VARCHAR(200) NOT NULL,
    plan_type VARCHAR(50) NOT NULL,
    plan_category VARCHAR(50),
    effective_date DATE NOT NULL,
    expiration_date DATE,
    covered_employees NUMBER(10,0),
    monthly_premium NUMBER(12,2),
    annual_premium NUMBER(12,2),
    plan_status VARCHAR(30) DEFAULT 'ACTIVE',
    carrier_name VARCHAR(200),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (client_id) REFERENCES CLIENTS(client_id),
    FOREIGN KEY (agent_id) REFERENCES INSURANCE_AGENTS(agent_id)
);

-- ============================================================================
-- CLIENT_SERVICES TABLE (additional services provided to clients)
-- ============================================================================
CREATE OR REPLACE TABLE CLIENT_SERVICES (
    service_id VARCHAR(30) PRIMARY KEY,
    client_id VARCHAR(20) NOT NULL,
    agent_id VARCHAR(20),
    service_type VARCHAR(50) NOT NULL,
    service_date TIMESTAMP_NTZ NOT NULL,
    service_description VARCHAR(2000),
    service_outcome VARCHAR(100),
    client_satisfaction NUMBER(3,2),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (client_id) REFERENCES CLIENTS(client_id),
    FOREIGN KEY (agent_id) REFERENCES INSURANCE_AGENTS(agent_id)
);

-- ============================================================================
-- MARKETING_CAMPAIGNS TABLE
-- ============================================================================
CREATE OR REPLACE TABLE MARKETING_CAMPAIGNS (
    campaign_id VARCHAR(30) PRIMARY KEY,
    campaign_name VARCHAR(200) NOT NULL,
    campaign_type VARCHAR(50) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    target_industry VARCHAR(100),
    target_segment VARCHAR(50),
    budget NUMBER(12,2),
    campaign_channel VARCHAR(50),
    campaign_status VARCHAR(30) DEFAULT 'ACTIVE',
    leads_generated NUMBER(10,0) DEFAULT 0,
    policies_sold NUMBER(10,0) DEFAULT 0,
    premium_generated NUMBER(15,2) DEFAULT 0.00,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ============================================================================
-- CLIENT_CAMPAIGN_INTERACTIONS TABLE
-- ============================================================================
CREATE OR REPLACE TABLE CLIENT_CAMPAIGN_INTERACTIONS (
    interaction_id VARCHAR(30) PRIMARY KEY,
    client_id VARCHAR(20) NOT NULL,
    campaign_id VARCHAR(30) NOT NULL,
    interaction_date TIMESTAMP_NTZ NOT NULL,
    interaction_type VARCHAR(50) NOT NULL,
    led_to_quote BOOLEAN DEFAULT FALSE,
    led_to_policy BOOLEAN DEFAULT FALSE,
    premium_generated NUMBER(12,2) DEFAULT 0.00,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (client_id) REFERENCES CLIENTS(client_id),
    FOREIGN KEY (campaign_id) REFERENCES MARKETING_CAMPAIGNS(campaign_id)
);

-- ============================================================================
-- Display confirmation
-- ============================================================================
SELECT 'All tables created successfully' AS status;


