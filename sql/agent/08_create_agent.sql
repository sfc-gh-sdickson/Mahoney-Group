-- ============================================================================
-- Mahoney Group Intelligence Agent - Agent Creation
-- ============================================================================
-- Purpose: Create Snowflake Intelligence Agent with semantic views, search services, and ML procedures
-- Syntax verified: https://docs.snowflake.com/en/sql-reference/sql/create-agent
-- Prerequisites: Files 01-07 must be executed successfully
-- ============================================================================

USE DATABASE MAHONEY_GROUP_INTELLIGENCE;
USE SCHEMA ANALYTICS;
USE WAREHOUSE MAHONEY_WH;

-- ============================================================================
-- Create the Mahoney Group Intelligence Agent
-- ============================================================================

CREATE OR REPLACE AGENT MAHONEY_GROUP_INTELLIGENCE_AGENT
  COMMENT = 'Mahoney Group multi-line insurance and employee benefits intelligence agent'
  PROFILE = '{"display_name": "Mahoney Group Intelligence Agent", "avatar": "insurance-icon.png", "color": "blue"}'
  FROM SPECIFICATION
  $$
  models:
    orchestration: claude-4-sonnet

  orchestration:
    budget:
      seconds: 30
      tokens: 16000

  instructions:
    response: |
      You are a specialized analytics assistant for Mahoney Group, a leading multi-line insurance brokerage 
      and employee benefits provider. Your primary objectives are:

      For structured data queries (policies, claims, benefits, financial metrics, loss ratios):
      - Use the Cortex Analyst semantic views for commercial insurance, claims management, 
        and employee benefits analysis
      - Provide direct, numerical answers with minimal explanation
      - Format responses clearly with relevant units, percentages, and time periods
      - Only include essential context needed to understand the metric

      For unstructured content (claim notes, policy documents, safety reports):
      - Use Cortex Search services to find similar claims, policy provisions, and risk assessments
      - Extract relevant adjuster notes, settlement strategies, and safety recommendations
      - Summarize policy coverage details and loss control findings
      - Maintain context from original notes, documents, and reports

      Operating guidelines:
      - Always identify whether you're using Cortex Analyst or Cortex Search for each response
      - Keep responses under 3-4 sentences when possible for metrics
      - Present numerical data in structured format
      - Don't speculate beyond available data
      - Highlight loss ratios, claim frequency, renewal rates, and competitive wins
      - For claims analysis, reference specific claim types, industries, and costs
      - Include policy coverage details when discussing insurance products
      - Reference safety recommendations when discussing risk management
    
    orchestration: |
      For any revenue, loss ratio, or policy questions use the Commercial Insurance Analyst tool.
      For claim costs, settlement, or adjuster performance questions use the Claims Management Analyst tool.
      For employee benefit plan or per-employee cost questions use the Employee Benefits Analyst tool.
      For claim note searches use the Claim Notes Search tool.
      For policy document searches use the Policy Documents Search tool.
      For safety or loss control questions use the Loss Control Reports Search tool.
      For ML predictions, use the appropriate prediction procedure.
    
    system: |
      You are a friendly and knowledgeable agent that helps with insurance, claims, and employee benefits analysis questions for Mahoney Group.
    
    sample_questions:
      - question: "Which industries have the highest claim costs?"
        answer: "I'll analyze claim costs by industry using the claims management data."
      - question: "What is our competitive win rate against major carriers?"
        answer: "I'll query the commercial insurance data to show competitive wins."
      - question: "Search claim notes for successful settlement strategies"
        answer: "I'll search the claim notes for settlement strategy examples."
      - question: "Show renewal rates by business segment"
        answer: "I'll analyze renewal rates across different business segments."
      - question: "What are per-employee benefit costs?"
        answer: "I'll calculate per-employee costs from the benefits data."

  tools:
    # ========================================================================
    # Cortex Analyst Tools (Semantic Views)
    # ========================================================================
    - tool_spec:
        type: "cortex_analyst_text_to_sql"
        name: "CommercialInsuranceAnalyst"
        description: |
          This semantic view contains comprehensive data about clients, insurance agents, products, 
          policies, and renewals. Use this for queries about:
          - New policy production and competitive wins
          - Policy renewal rates and premium changes
          - Agent performance and productivity
          - Client risk profiles and satisfaction
          - Coverage types and product lines
          - Premium analysis and trends
    
    - tool_spec:
        type: "cortex_analyst_text_to_sql"
        name: "ClaimsManagementAnalyst"
        description: |
          This semantic view contains claims data, adjusters, disputes, and litigation. 
          Use this for queries about:
          - Claim costs (paid, reserved, incurred)
          - Claims adjuster performance and efficiency
          - Claim types and severity analysis
          - Dispute rates and legal costs
          - Settlement amounts and outcomes
          - Industry-specific claim patterns
    
    - tool_spec:
        type: "cortex_analyst_text_to_sql"
        name: "EmployeeBenefitsAnalyst"
        description: |
          This semantic view contains employee benefit plan data including health, dental, vision, life, 
          and disability coverage. Use this for queries about:
          - Benefit plan enrollment and covered employees
          - Per-employee costs and premium analysis
          - Carrier performance comparison
          - Plan mix by client and industry
          - Benefits program costs
    
    # ========================================================================
    # Cortex Search Tools (Unstructured Data)
    # ========================================================================
    - tool_spec:
        type: "cortex_search"
        name: "ClaimNotesSearch"
        description: |
          Search 30,000 claim adjuster notes and investigations for settlement strategies, 
          claim management approaches, and investigation techniques. Use for queries about:
          - Settlement negotiation strategies
          - Claim investigation methods
          - Resolution approaches and outcomes
          - Coverage analysis and determinations
          - Litigation defense strategies
          - Subrogation opportunities
    
    - tool_spec:
        type: "cortex_search"
        name: "PolicyDocumentsSearch"
        description: |
          Search insurance policy forms and endorsements for coverage details, exclusions, and 
          policy language. Use for queries about:
          - Coverage provisions and limits
          - Policy exclusions and limitations
          - Endorsement details
          - Insurance requirements
          - Coverage triggers and conditions
    
    - tool_spec:
        type: "cortex_search"
        name: "LossControlReportsSearch"
        description: |
          Search 15,000 loss control and safety assessment reports for hazard identification, 
          risk assessments, and safety recommendations. Use for queries about:
          - Workplace hazards and risk factors
          - Safety recommendations and best practices
          - Injury prevention strategies
          - Ergonomic assessments
          - Fire safety and emergency preparedness
          - Industry-specific safety guidance
    
    # ========================================================================
    # ML Model Procedures (OPTIONAL - only include if file 07 was executed)
    # ========================================================================
    # Uncomment these after executing sql/ml/07_create_model_wrapper_functions.sql
    # and training models via notebooks/mahoney_ml_models.ipynb
    
    # - tool_spec:
    #     type: "procedure"
    #     name: "PredictClaimCost"
    #     description: |
    #       Predicts total incurred costs for claims using the CLAIM_COST_PREDICTOR model from Model Registry.
    #       The model uses Linear Regression trained on historical claim patterns.
    #       
    #       Use when users ask to:
    #       - Predict claim costs
    #       - Forecast claim expenses
    #       - Estimate total incurred costs
    #       
    #       Parameters:
    #       - claim_type_filter: Filter by claim type (PROPERTY_DAMAGE, BODILY_INJURY, etc.) or empty for all
    #       - industry_filter: Filter by industry (CONSTRUCTION, HEALTHCARE, etc.) or empty for all
    #       
    #       Returns: JSON with average predicted cost, total predicted cost, min/max costs
    #       
    #       Example: "Predict costs for open property damage claims in construction"
    #     input_schema:
    #       type: 'object'
    #       properties:
    #         claim_type_filter:
    #           type: 'string'
    #           description: 'Filter by claim type or empty string for all'
    #         industry_filter:
    #           type: 'string'
    #           description: 'Filter by industry or empty string for all'
    #       required: ['claim_type_filter', 'industry_filter']
    
    # - tool_spec:
    #     type: "procedure"
    #     name: "DetectHighRiskClaims"
    #     description: |
    #       Identifies claims with high risk of exceeding $75K or involving litigation using the 
    #       HIGH_RISK_CLAIMS_DETECTOR model from Model Registry. Uses Random Forest classifier.
    #       
    #       Use when users ask to:
    #       - Identify high-risk claims
    #       - Find claims needing enhanced review
    #       - Screen for potential litigation
    #       
    #       Parameter:
    #       - claim_status_filter: Filter by status (OPEN, UNDER_INVESTIGATION) or empty for both
    #       
    #       Returns: JSON with high-risk count, risk percentage, and recommendation
    #       
    #       Example: "Which open claims have high risk?"
    #     input_schema:
    #       type: 'object'
    #       properties:
    #         claim_status_filter:
    #           type: 'string'
    #           description: 'Filter by claim status or empty string for all'
    #       required: ['claim_status_filter']
    
    # - tool_spec:
    #     type: "procedure"
    #     name: "PredictRenewalLikelihood"
    #     description: |
    #       Predicts policy renewal probability using the RENEWAL_LIKELIHOOD_PREDICTOR model from 
    #       Model Registry. Uses Logistic Regression based on satisfaction, loss ratio, and premium changes.
    #       
    #       Use when users ask to:
    #       - Predict renewal likelihood
    #       - Identify at-risk clients
    #       - Forecast retention rates
    #       
    #       Parameters:
    #       - industry_filter: Filter by industry (CONSTRUCTION, HEALTHCARE, etc.) or empty for all
    #       - business_segment_filter: Filter by segment (SMALL_BUSINESS, MIDMARKET, LARGE_ACCOUNT) or empty
    #       
    #       Returns: JSON with renewal rate, at-risk client count, and retention recommendations
    #       
    #       Example: "Predict renewal likelihood for construction clients"
    #     input_schema:
    #       type: 'object'
    #       properties:
    #         industry_filter:
    #           type: 'string'
    #           description: 'Filter by industry or empty string for all'
    #         business_segment_filter:
    #           type: 'string'
    #           description: 'Filter by business segment or empty string for all'
    #       required: ['industry_filter', 'business_segment_filter']

  tool_resources:
    # Semantic View Configurations
    CommercialInsuranceAnalyst:
      semantic_view: "MAHONEY_GROUP_INTELLIGENCE.ANALYTICS.SV_COMMERCIAL_INSURANCE_INTELLIGENCE"
    
    ClaimsManagementAnalyst:
      semantic_view: "MAHONEY_GROUP_INTELLIGENCE.ANALYTICS.SV_CLAIMS_MANAGEMENT_INTELLIGENCE"
    
    EmployeeBenefitsAnalyst:
      semantic_view: "MAHONEY_GROUP_INTELLIGENCE.ANALYTICS.SV_EMPLOYEE_BENEFITS_INTELLIGENCE"
    
    # Cortex Search Service Configurations
    ClaimNotesSearch:
      name: "MAHONEY_GROUP_INTELLIGENCE.RAW.CLAIM_NOTES_SEARCH"
      max_results: "10"
      title_column: "claim_id"
      id_column: "note_id"
    
    PolicyDocumentsSearch:
      name: "MAHONEY_GROUP_INTELLIGENCE.RAW.POLICY_DOCUMENTS_SEARCH"
      max_results: "5"
      title_column: "document_title"
      id_column: "document_id"
    
    LossControlReportsSearch:
      name: "MAHONEY_GROUP_INTELLIGENCE.RAW.LOSS_CONTROL_REPORTS_SEARCH"
      max_results: "10"
      title_column: "report_title"
      id_column: "report_id"
    
    # ML Procedure Configurations (OPTIONAL - uncomment if using ML procedures)
    # PredictClaimCost:
    #   procedure: "MAHONEY_GROUP_INTELLIGENCE.ANALYTICS.PREDICT_CLAIM_COST"
    
    # DetectHighRiskClaims:
    #   procedure: "MAHONEY_GROUP_INTELLIGENCE.ANALYTICS.DETECT_HIGH_RISK_CLAIMS"
    
    # PredictRenewalLikelihood:
    #   procedure: "MAHONEY_GROUP_INTELLIGENCE.ANALYTICS.PREDICT_RENEWAL_LIKELIHOOD"
  $$;

-- ============================================================================
-- Display completion and verification
-- ============================================================================

SELECT 'Mahoney Group Intelligence Agent created successfully' AS status;

-- Show the created agent
SHOW AGENTS IN SCHEMA MAHONEY_GROUP_INTELLIGENCE.ANALYTICS;

-- Display agent details
DESCRIBE AGENT MAHONEY_GROUP_INTELLIGENCE_AGENT;

-- ============================================================================
-- NEXT STEPS
-- ============================================================================
-- 1. Grant USAGE privileges on the agent to appropriate roles:
--    GRANT USAGE ON AGENT MAHONEY_GROUP_INTELLIGENCE.ANALYTICS.MAHONEY_GROUP_INTELLIGENCE_AGENT TO ROLE <your_role>;
--
-- 2. Navigate to Snowsight AI & ML > Agents to view and test the agent
--
-- 3. OPTIONAL: If you want to add ML procedures, uncomment the 3 procedure tools
--    in the specification above and run this file again after completing:
--    - Upload and run notebooks/mahoney_ml_models.ipynb
--    - Execute sql/ml/07_create_model_wrapper_functions.sql
--
-- 4. Test the agent with sample questions from docs/questions.md
-- ============================================================================

