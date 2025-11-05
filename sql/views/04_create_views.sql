-- ============================================================================
-- Mahoney Group Intelligence Agent - Analytical Views
-- ============================================================================
-- Purpose: Create curated analytical views for business intelligence
-- ============================================================================

USE DATABASE MAHONEY_GROUP_INTELLIGENCE;
USE SCHEMA ANALYTICS;
USE WAREHOUSE MAHONEY_WH;

-- ============================================================================
-- V_CLIENT_360: Complete client profile
-- ============================================================================
CREATE OR REPLACE VIEW V_CLIENT_360 AS
SELECT
    c.client_id,
    c.client_name,
    c.primary_contact_email,
    c.primary_contact_phone,
    c.state,
    c.city,
    c.onboarding_date,
    c.client_status,
    c.business_segment,
    c.industry_vertical,
    c.annual_revenue,
    c.employee_count,
    c.risk_rating,
    c.client_satisfaction_score,
    COUNT(DISTINCT p.policy_id) AS total_policies,
    SUM(p.annual_premium) AS total_annual_premium,
    COUNT(DISTINCT cl.claim_id) AS total_claims,
    SUM(cl.claim_amount_incurred) AS total_claim_costs,
    CASE 
        WHEN SUM(p.annual_premium) > 0 
        THEN (SUM(cl.claim_amount_incurred) / SUM(p.annual_premium))::NUMBER(8,2)
        ELSE 0 
    END AS loss_ratio,
    COUNT(DISTINCT bp.plan_id) AS total_benefit_plans,
    SUM(bp.annual_premium) AS total_benefit_premium,
    MAX(a.agent_name) AS primary_agent_name
FROM RAW.CLIENTS c
LEFT JOIN RAW.POLICIES p ON c.client_id = p.client_id
LEFT JOIN RAW.CLAIMS cl ON c.client_id = cl.client_id
LEFT JOIN RAW.BENEFIT_PLANS bp ON c.client_id = bp.client_id
LEFT JOIN RAW.INSURANCE_AGENTS a ON p.agent_id = a.agent_id
GROUP BY
    c.client_id, c.client_name, c.primary_contact_email, c.primary_contact_phone,
    c.state, c.city, c.onboarding_date, c.client_status, c.business_segment,
    c.industry_vertical, c.annual_revenue, c.employee_count, c.risk_rating,
    c.client_satisfaction_score;

-- ============================================================================
-- V_POLICY_ANALYTICS: Policy performance metrics
-- ============================================================================
CREATE OR REPLACE VIEW V_POLICY_ANALYTICS AS
SELECT
    p.policy_id,
    p.policy_number,
    p.client_id,
    c.client_name,
    c.industry_vertical,
    c.business_segment,
    c.state AS client_state,
    p.agent_id,
    a.agent_name,
    p.product_id,
    pr.product_name,
    pr.product_category,
    pr.product_line,
    p.effective_date,
    p.expiration_date,
    p.policy_status,
    p.annual_premium,
    p.total_coverage_limit,
    p.deductible_amount,
    p.competitive_win,
    p.previous_carrier,
    p.payment_plan,
    COUNT(DISTINCT cl.claim_id) AS claim_count,
    SUM(cl.claim_amount_incurred) AS total_claim_costs,
    CASE 
        WHEN p.annual_premium > 0 
        THEN (SUM(cl.claim_amount_incurred) / p.annual_premium)::NUMBER(8,2)
        ELSE 0 
    END AS loss_ratio
FROM RAW.POLICIES p
JOIN RAW.CLIENTS c ON p.client_id = c.client_id
JOIN RAW.INSURANCE_AGENTS a ON p.agent_id = a.agent_id
JOIN RAW.INSURANCE_PRODUCTS pr ON p.product_id = pr.product_id
LEFT JOIN RAW.CLAIMS cl ON p.policy_id = cl.policy_id
GROUP BY
    p.policy_id, p.policy_number, p.client_id, c.client_name, c.industry_vertical,
    c.business_segment, c.state, p.agent_id, a.agent_name, p.product_id,
    pr.product_name, pr.product_category, pr.product_line, p.effective_date,
    p.expiration_date, p.policy_status, p.annual_premium, p.total_coverage_limit,
    p.deductible_amount, p.competitive_win, p.previous_carrier, p.payment_plan;

-- ============================================================================
-- V_CLAIMS_ANALYTICS: Detailed claim metrics
-- ============================================================================
CREATE OR REPLACE VIEW V_CLAIMS_ANALYTICS AS
SELECT
    cl.claim_id,
    cl.claim_number,
    cl.policy_id,
    p.policy_number,
    cl.client_id,
    c.client_name,
    c.industry_vertical,
    c.business_segment,
    c.state AS client_state,
    cl.adjuster_id,
    adj.adjuster_name,
    adj.specialization AS adjuster_specialization,
    cl.incident_date,
    cl.report_date,
    cl.claim_type,
    cl.claim_category,
    cl.loss_type,
    cl.claim_status,
    cl.severity,
    cl.claim_amount_paid,
    cl.claim_amount_reserved,
    cl.claim_amount_incurred,
    cl.settlement_date,
    cl.settlement_amount,
    cl.subrogation_potential,
    cl.litigation_involved,
    DATEDIFF('day', cl.report_date, COALESCE(cl.settlement_date, CURRENT_DATE())) AS days_open,
    pr.product_category AS policy_type,
    pr.product_name
FROM RAW.CLAIMS cl
JOIN RAW.POLICIES p ON cl.policy_id = p.policy_id
JOIN RAW.CLIENTS c ON cl.client_id = c.client_id
LEFT JOIN RAW.CLAIMS_ADJUSTERS adj ON cl.adjuster_id = adj.adjuster_id
JOIN RAW.INSURANCE_PRODUCTS pr ON p.product_id = pr.product_id;

-- ============================================================================
-- V_AGENT_PERFORMANCE: Agent productivity and quality metrics
-- ============================================================================
CREATE OR REPLACE VIEW V_AGENT_PERFORMANCE AS
SELECT
    a.agent_id,
    a.agent_name,
    a.email,
    a.agent_type,
    a.specialization,
    a.office_location,
    a.region,
    a.agent_status,
    a.production_tier,
    COUNT(DISTINCT p.client_id) AS total_clients,
    COUNT(DISTINCT p.policy_id) AS total_policies,
    SUM(p.annual_premium) AS total_premium_written,
    AVG(p.annual_premium) AS average_policy_premium,
    COUNT(DISTINCT bp.plan_id) AS total_benefit_plans,
    SUM(bp.annual_premium) AS total_benefit_premium,
    COUNT(DISTINCT r.renewal_id) AS total_renewals,
    SUM(CASE WHEN r.renewal_status = 'RENEWED' THEN 1 ELSE 0 END) AS successful_renewals,
    CASE 
        WHEN COUNT(DISTINCT r.renewal_id) > 0
        THEN (SUM(CASE WHEN r.renewal_status = 'RENEWED' THEN 1 ELSE 0 END)::FLOAT / COUNT(DISTINCT r.renewal_id) * 100)::NUMBER(5,2)
        ELSE 0 
    END AS renewal_rate_pct,
    SUM(CASE WHEN p.competitive_win = TRUE THEN 1 ELSE 0 END) AS competitive_wins,
    AVG(c.client_satisfaction_score) AS avg_client_satisfaction
FROM RAW.INSURANCE_AGENTS a
LEFT JOIN RAW.POLICIES p ON a.agent_id = p.agent_id
LEFT JOIN RAW.POLICY_RENEWALS r ON a.agent_id = r.agent_id
LEFT JOIN RAW.BENEFIT_PLANS bp ON a.agent_id = bp.agent_id
LEFT JOIN RAW.CLIENTS c ON p.client_id = c.client_id
GROUP BY
    a.agent_id, a.agent_name, a.email, a.agent_type, a.specialization,
    a.office_location, a.region, a.agent_status, a.production_tier;

-- ============================================================================
-- V_PRODUCT_PERFORMANCE: Product line performance
-- ============================================================================
CREATE OR REPLACE VIEW V_PRODUCT_PERFORMANCE AS
SELECT
    pr.product_id,
    pr.product_name,
    pr.product_code,
    pr.product_category,
    pr.product_line,
    pr.coverage_type,
    pr.product_status,
    pr.target_industries,
    COUNT(DISTINCT p.policy_id) AS policies_sold,
    SUM(p.annual_premium) AS total_premium,
    AVG(p.annual_premium) AS average_premium,
    COUNT(DISTINCT cl.claim_id) AS total_claims,
    SUM(cl.claim_amount_incurred) AS total_claim_costs,
    CASE 
        WHEN SUM(p.annual_premium) > 0 
        THEN (SUM(cl.claim_amount_incurred) / SUM(p.annual_premium))::NUMBER(8,2)
        ELSE 0 
    END AS loss_ratio,
    COUNT(DISTINCT p.client_id) AS unique_clients
FROM RAW.INSURANCE_PRODUCTS pr
LEFT JOIN RAW.POLICIES p ON pr.product_id = p.product_id
LEFT JOIN RAW.CLAIMS cl ON p.policy_id = cl.policy_id
GROUP BY
    pr.product_id, pr.product_name, pr.product_code, pr.product_category,
    pr.product_line, pr.coverage_type, pr.product_status, pr.target_industries;

-- ============================================================================
-- V_CLAIM_DISPUTE_ANALYTICS: Dispute analysis
-- ============================================================================
CREATE OR REPLACE VIEW V_CLAIM_DISPUTE_ANALYTICS AS
SELECT
    d.dispute_id,
    d.claim_id,
    cl.claim_number,
    d.client_id,
    c.client_name,
    c.industry_vertical,
    c.business_segment,
    d.dispute_filed_date,
    d.dispute_type,
    d.dispute_severity,
    d.dispute_status,
    d.resolution_method,
    d.dispute_outcome,
    d.resolution_date,
    d.legal_costs,
    d.settlement_amount,
    d.attorney_involved,
    DATEDIFF('day', d.dispute_filed_date, COALESCE(d.resolution_date, CURRENT_DATE())) AS days_to_resolution,
    cl.claim_type,
    cl.claim_amount_incurred AS original_claim_amount
FROM RAW.CLAIM_DISPUTES d
JOIN RAW.CLAIMS cl ON d.claim_id = cl.claim_id
JOIN RAW.CLIENTS c ON d.client_id = c.client_id;

-- ============================================================================
-- V_RENEWAL_ANALYTICS: Renewal performance
-- ============================================================================
CREATE OR REPLACE VIEW V_RENEWAL_ANALYTICS AS
SELECT
    r.renewal_id,
    r.policy_id,
    p.policy_number,
    r.client_id,
    c.client_name,
    c.industry_vertical,
    c.business_segment,
    r.agent_id,
    a.agent_name,
    r.renewal_date,
    r.renewal_effective_date,
    r.renewal_status,
    r.renewal_type,
    r.previous_premium,
    r.renewal_premium,
    r.premium_change_pct,
    r.loss_ratio_at_renewal,
    pr.product_name,
    pr.product_category
FROM RAW.POLICY_RENEWALS r
JOIN RAW.POLICIES p ON r.policy_id = p.policy_id
JOIN RAW.CLIENTS c ON r.client_id = c.client_id
JOIN RAW.INSURANCE_AGENTS a ON r.agent_id = a.agent_id
JOIN RAW.INSURANCE_PRODUCTS pr ON r.product_id = pr.product_id;

-- ============================================================================
-- V_LOSS_CONTROL_ANALYTICS: Risk management service effectiveness
-- ============================================================================
CREATE OR REPLACE VIEW V_LOSS_CONTROL_ANALYTICS AS
SELECT
    lcs.service_id,
    lcs.client_id,
    c.client_name,
    c.industry_vertical,
    c.business_segment,
    lcs.service_type,
    lcs.service_date,
    lcs.consultant_name,
    lcs.priority_level,
    lcs.implementation_status,
    lcs.estimated_cost_savings,
    lcs.service_status,
    COUNT(DISTINCT cl.claim_id) AS claims_after_service,
    SUM(cl.claim_amount_incurred) AS total_claims_cost_after_service
FROM RAW.LOSS_CONTROL_SERVICES lcs
JOIN RAW.CLIENTS c ON lcs.client_id = c.client_id
LEFT JOIN RAW.CLAIMS cl ON c.client_id = cl.client_id 
    AND cl.incident_date > lcs.service_date
GROUP BY
    lcs.service_id, lcs.client_id, c.client_name, c.industry_vertical,
    c.business_segment, lcs.service_type, lcs.service_date, lcs.consultant_name,
    lcs.priority_level, lcs.implementation_status, lcs.estimated_cost_savings,
    lcs.service_status;

-- ============================================================================
-- V_BENEFIT_PLAN_ANALYTICS: Employee benefits performance
-- ============================================================================
CREATE OR REPLACE VIEW V_BENEFIT_PLAN_ANALYTICS AS
SELECT
    bp.plan_id,
    bp.client_id,
    c.client_name,
    c.industry_vertical,
    c.business_segment,
    c.state AS client_state,
    bp.agent_id,
    a.agent_name,
    bp.plan_name,
    bp.plan_type,
    bp.plan_category,
    bp.effective_date,
    bp.expiration_date,
    bp.plan_status,
    bp.covered_employees,
    bp.monthly_premium,
    bp.annual_premium,
    bp.carrier_name,
    (bp.annual_premium / NULLIF(bp.covered_employees, 0))::NUMBER(10,2) AS per_employee_cost
FROM RAW.BENEFIT_PLANS bp
JOIN RAW.CLIENTS c ON bp.client_id = c.client_id
JOIN RAW.INSURANCE_AGENTS a ON bp.agent_id = a.agent_id;

-- ============================================================================
-- Display confirmation
-- ============================================================================
SELECT 'Analytical views created successfully' AS status;

-- Show created views
SELECT table_name AS view_name, comment
FROM INFORMATION_SCHEMA.VIEWS
WHERE TABLE_SCHEMA = 'ANALYTICS'
ORDER BY table_name;


