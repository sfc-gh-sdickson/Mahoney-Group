-- ============================================================================
-- Mahoney Group Intelligence Agent - Model Registry Wrapper Procedures
-- ============================================================================
-- Purpose: Create Python procedures that wrap Model Registry models
--          so they can be added as tools to the Intelligence Agent
-- Based on: Zenith Demo Model Registry integration pattern
-- Syntax verified: https://docs.snowflake.com/en/sql-reference/sql/create-procedure
-- ============================================================================

USE DATABASE MAHONEY_GROUP_INTELLIGENCE;
USE SCHEMA ANALYTICS;
USE WAREHOUSE MAHONEY_WH;

-- ============================================================================
-- Procedure 1: Claim Cost Prediction Wrapper
-- ============================================================================

-- Drop if exists (in case it was created as FUNCTION before)
DROP FUNCTION IF EXISTS PREDICT_CLAIM_COST(STRING, STRING);

CREATE OR REPLACE PROCEDURE PREDICT_CLAIM_COST(
    CLAIM_TYPE_FILTER STRING,
    INDUSTRY_FILTER STRING
)
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = '3.10'
PACKAGES = ('snowflake-ml-python', 'scikit-learn')
HANDLER = 'predict_claim_cost'
COMMENT = 'Calls CLAIM_COST_PREDICTOR model from Model Registry to predict claim costs'
AS
$$
def predict_claim_cost(session, claim_type_filter, industry_filter):
    from snowflake.ml.registry import Registry
    import json
    
    # Get model from registry
    reg = Registry(session=session, database_name="MAHONEY_GROUP_INTELLIGENCE", schema_name="ANALYTICS")
    model = reg.get_model("CLAIM_COST_PREDICTOR").default
    
    # Build query with optional filters
    claim_filter = f"AND c.claim_type = '{claim_type_filter}'" if claim_type_filter else ""
    industry = f"AND cl.industry_vertical = '{industry_filter}'" if industry_filter else ""
    
    query = f"""
    SELECT
        c.claim_type,
        c.claim_category,
        c.loss_type,
        c.severity,
        cl.industry_vertical,
        cl.employee_count::FLOAT AS client_size,
        cl.risk_rating,
        prod.product_category,
        prod.coverage_type,
        p.policy_type,
        DATEDIFF('day', c.incident_date, c.report_date)::FLOAT AS days_to_report,
        c.litigation_involved::BOOLEAN AS has_litigation,
        c.subrogation_potential::BOOLEAN AS has_subrogation,
        0.0::FLOAT AS total_incurred
    FROM RAW.CLAIMS c
    JOIN RAW.CLIENTS cl ON c.client_id = cl.client_id
    JOIN RAW.POLICIES p ON c.policy_id = p.policy_id
    JOIN RAW.INSURANCE_PRODUCTS prod ON p.product_id = prod.product_id
    WHERE c.claim_status = 'OPEN' {claim_filter} {industry}
    LIMIT 50
    """
    
    input_df = session.sql(query)
    
    # Get predictions
    predictions = model.run(input_df, function_name="predict")
    
    # Calculate statistics
    result = predictions.select("PREDICTED_COST").to_pandas()
    
    return json.dumps({
        "claim_type_filter": claim_type_filter or "ALL",
        "industry_filter": industry_filter or "ALL",
        "total_claims_analyzed": len(result),
        "avg_predicted_cost": round(float(result['PREDICTED_COST'].mean()), 2),
        "total_predicted_cost": round(float(result['PREDICTED_COST'].sum()), 2),
        "min_predicted_cost": round(float(result['PREDICTED_COST'].min()), 2),
        "max_predicted_cost": round(float(result['PREDICTED_COST'].max()), 2)
    })
$$;

-- ============================================================================
-- Procedure 2: High-Risk Claims Detection Wrapper
-- ============================================================================

-- Drop if exists
DROP FUNCTION IF EXISTS DETECT_HIGH_RISK_CLAIMS(STRING);

CREATE OR REPLACE PROCEDURE DETECT_HIGH_RISK_CLAIMS(
    CLAIM_STATUS_FILTER STRING
)
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = '3.10'
PACKAGES = ('snowflake-ml-python', 'scikit-learn')
HANDLER = 'detect_high_risk'
COMMENT = 'Calls HIGH_RISK_CLAIMS_DETECTOR model from Model Registry to identify high-risk claims'
AS
$$
def detect_high_risk(session, claim_status_filter):
    from snowflake.ml.registry import Registry
    import json
    
    # Get model
    reg = Registry(session=session, database_name="MAHONEY_GROUP_INTELLIGENCE", schema_name="ANALYTICS")
    model = reg.get_model("HIGH_RISK_CLAIMS_DETECTOR").default
    
    # Build query
    status_filter = f"AND c.claim_status = '{claim_status_filter}'" if claim_status_filter else "AND c.claim_status IN ('OPEN', 'DISPUTED')"
    
    query = f"""
    SELECT
        c.claim_type,
        c.claim_category,
        c.loss_type,
        c.severity,
        cl.industry_vertical,
        cl.risk_rating,
        prod.product_category,
        p.policy_type,
        DATEDIFF('day', c.incident_date, c.report_date)::FLOAT AS days_to_report,
        c.litigation_involved::BOOLEAN AS has_litigation,
        c.subrogation_potential::BOOLEAN AS has_subrogation,
        FALSE::BOOLEAN AS is_high_risk
    FROM RAW.CLAIMS c
    JOIN RAW.CLIENTS cl ON c.client_id = cl.client_id
    JOIN RAW.POLICIES p ON c.policy_id = p.policy_id
    JOIN RAW.INSURANCE_PRODUCTS prod ON p.product_id = prod.product_id
    WHERE 1=1 {status_filter}
    LIMIT 100
    """
    
    input_df = session.sql(query)
    
    # Get predictions
    predictions = model.run(input_df, function_name="predict")
    
    # Count high-risk claims
    result = predictions.select("HIGH_RISK_PREDICTION").to_pandas()
    high_risk_count = int(result['HIGH_RISK_PREDICTION'].sum())
    total_count = len(result)
    
    return json.dumps({
        "claim_status_filter": claim_status_filter or "OPEN,DISPUTED",
        "total_claims_analyzed": total_count,
        "high_risk_count": high_risk_count,
        "high_risk_rate_pct": round(high_risk_count / total_count * 100, 2) if total_count > 0 else 0,
        "recommendation": f"Flag {high_risk_count} claims for enhanced review and management oversight" if high_risk_count > 0 else "No high-risk claims identified"
    })
$$;

-- ============================================================================
-- Procedure 3: Renewal Likelihood Prediction Wrapper
-- ============================================================================

-- Drop if exists
DROP FUNCTION IF EXISTS PREDICT_RENEWAL_LIKELIHOOD(STRING, STRING);

CREATE OR REPLACE PROCEDURE PREDICT_RENEWAL_LIKELIHOOD(
    INDUSTRY_FILTER STRING,
    BUSINESS_SEGMENT_FILTER STRING
)
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = '3.10'
PACKAGES = ('snowflake-ml-python', 'scikit-learn')
HANDLER = 'predict_renewal'
COMMENT = 'Calls RENEWAL_PREDICTOR model to predict policy renewal likelihood'
AS
$$
def predict_renewal(session, industry_filter, business_segment_filter):
    from snowflake.ml.registry import Registry
    import json
    
    # Get model
    reg = Registry(session=session, database_name="MAHONEY_GROUP_INTELLIGENCE", schema_name="ANALYTICS")
    model = reg.get_model("RENEWAL_LIKELIHOOD_PREDICTOR").default
    
    # Build query
    industry = f"AND cl.industry_vertical = '{industry_filter}'" if industry_filter else ""
    segment = f"AND cl.business_segment = '{business_segment_filter}'" if business_segment_filter else ""
    
    query = f"""
    SELECT
        cl.client_status,
        cl.industry_vertical,
        cl.business_segment,
        cl.risk_rating,
        cl.employee_count::FLOAT AS client_size,
        DATEDIFF('year', cl.onboarding_date, CURRENT_DATE())::FLOAT AS years_as_client,
        cl.client_satisfaction_score::FLOAT AS satisfaction_score,
        prod.product_category,
        prod.coverage_type,
        p.policy_type,
        DATEDIFF('year', p.effective_date, CURRENT_DATE())::FLOAT AS policy_years,
        (SELECT COUNT(*) FROM RAW.CLAIMS c WHERE c.policy_id = p.policy_id)::FLOAT AS claims_count,
        COALESCE((SELECT SUM(c.claim_amount_incurred) FROM RAW.CLAIMS c WHERE c.policy_id = p.policy_id), 0)::FLOAT AS total_claims_cost,
        CASE WHEN p.annual_premium > 0 
             THEN (COALESCE((SELECT SUM(c.claim_amount_incurred) FROM RAW.CLAIMS c WHERE c.policy_id = p.policy_id), 0) / p.annual_premium)::FLOAT
             ELSE 0.0 END AS loss_ratio,
        FALSE::BOOLEAN AS did_renew
    FROM RAW.POLICIES p
    JOIN RAW.CLIENTS cl ON p.client_id = cl.client_id
    JOIN RAW.INSURANCE_PRODUCTS prod ON p.product_id = prod.product_id
    WHERE p.policy_status = 'ACTIVE'
      AND DATEDIFF('day', CURRENT_DATE(), p.expiration_date) BETWEEN 0 AND 90 {industry} {segment}
    LIMIT 100
    """
    
    input_df = session.sql(query)
    
    # Get predictions
    predictions = model.run(input_df, function_name="predict")
    
    # Calculate statistics
    result = predictions.select("RENEWAL_PREDICTION").to_pandas()
    renewal_count = int(result['RENEWAL_PREDICTION'].sum())
    total_count = len(result)
    
    return json.dumps({
        "industry_filter": industry_filter or "ALL",
        "business_segment_filter": business_segment_filter or "ALL",
        "total_policies_analyzed": total_count,
        "predicted_renewals": renewal_count,
        "predicted_renewal_rate_pct": round(renewal_count / total_count * 100, 2) if total_count > 0 else 0,
        "at_risk_count": total_count - renewal_count,
        "recommendation": f"Proactive retention outreach for {total_count - renewal_count} at-risk policies" if (total_count - renewal_count) > 0 else "All policies have strong renewal likelihood"
    })
$$;

-- ============================================================================
-- Test the wrapper procedures
-- ============================================================================

SELECT 'ML model wrapper procedures created successfully' AS status;

-- Test each procedure (uncomment after models are registered via notebook)
/*
CALL PREDICT_CLAIM_COST('PROPERTY', 'MANUFACTURING');
CALL DETECT_HIGH_RISK_CLAIMS('OPEN');
CALL PREDICT_RENEWAL_LIKELIHOOD('HEALTHCARE', 'MIDMARKET');
*/

SELECT 'Execute notebook first to register models, then uncomment tests above' AS instruction;
