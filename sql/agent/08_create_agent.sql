-- ============================================================================
-- Mahoney Group Intelligence Agent - Agent Creation
-- ============================================================================
-- Purpose: Create Snowflake Intelligence Agent with semantic views, search services, and ML procedures
-- Syntax verified: https://docs.snowflake.com/en/sql-reference/sql/create-agent
-- Pattern verified: Axon Demo sql/agent/08_create_intelligence_agent.sql
-- Prerequisites: Files 01-07 must be executed successfully (especially ML models and procedures)
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
      # Simple Questions (5)
      - question: "How many clients does Mahoney Group have in each industry vertical?"
        answer: "I'll count clients by industry vertical using the commercial insurance data."
      - question: "What is the total annual premium written across all policies?"
        answer: "I'll sum the annual premium from all policies."
      - question: "How many claims are currently in OPEN or UNDER_INVESTIGATION status?"
        answer: "I'll count active claims with those statuses."
      - question: "Which agent has written the most premium this year?"
        answer: "I'll analyze agent performance to find the top producer by premium written."
      - question: "What is the average claim cost for settled claims?"
        answer: "I'll calculate the average cost for all settled claims."
      
      # Complex Questions (5)
      - question: "Analyze loss ratios by insurance product category. Show total premium, total claims incurred, loss ratio percentage, and profitability for each product line. Which products are most profitable?"
        answer: "I'll analyze loss ratios across product categories with premium and claims data to identify the most profitable products."
      - question: "What is Mahoney Group's competitive win rate? Show total competitive wins by previous carrier (Travelers, Hartford, Zurich, Liberty Mutual, AIG, Chubb, CNA), premium captured from each competitor, and which industries we're winning in."
        answer: "I'll analyze competitive wins by carrier and industry, showing win rates and premium captured."
      - question: "Analyze claim costs by industry vertical and claim type. Show average incurred cost, total claims, claim frequency rate (claims per policy), and litigation percentage for each combination. Identify highest-cost segments."
        answer: "I'll create a cross-tabulation of claim costs by industry and type, identifying the most expensive segments."
      - question: "Analyze policy renewal performance. Show renewal rate by business segment and industry, average premium change at renewal, and identify clients at risk of non-renewal based on loss ratio, premium increases >20%, and satisfaction scores. Estimate premium at risk."
        answer: "I'll analyze renewal rates and identify at-risk clients with premium exposure calculations."
      - question: "Analyze employee benefits program performance. Show total covered employees, premium per employee, plan enrollment by type (HEALTH, DENTAL, VISION, LIFE), carrier performance, and clients with comprehensive vs. limited benefits. Calculate average benefits spend per employee by industry."
        answer: "I'll analyze benefits program metrics including per-employee costs and plan mix by industry."
      
      # ML Model Questions (5)
      - question: "Predict claim costs for open property damage claims in construction"
        answer: "I'll use the claim cost prediction model to forecast expenses for these claims."
      - question: "Which open claims have high risk and should be flagged for enhanced review?"
        answer: "I'll run the high-risk detection model to identify claims needing additional management oversight."
      - question: "Predict renewal likelihood for healthcare clients in the midmarket segment"
        answer: "I'll use the renewal prediction model to forecast retention rates for this segment."
      - question: "What are the predicted costs for open bodily injury claims across all industries?"
        answer: "I'll run the claim cost predictor to estimate total incurred costs for these claims."
      - question: "Identify at-risk policies expiring in the next 90 days and predict which ones will not renew"
        answer: "I'll use the renewal likelihood model to identify policies at risk of non-renewal and calculate premium exposure."

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
    # ML Model Procedures (using 'generic' type)
    # ========================================================================
    - tool_spec:
        type: 'generic'
        name: 'PredictClaimCost'
        description: 'Predicts total incurred costs for claims using ML model trained on historical claim patterns'
        input_schema:
          type: 'object'
          properties:
            claim_type_filter:
              type: 'string'
              description: 'Filter by claim type (PROPERTY, LIABILITY, AUTO, etc.) or empty string for all'
            industry_filter:
              type: 'string'
              description: 'Filter by industry (CONSTRUCTION, HEALTHCARE, etc.) or empty string for all'
          required: ['claim_type_filter', 'industry_filter']
    
    - tool_spec:
        type: 'generic'
        name: 'DetectHighRiskClaims'
        description: 'Identifies claims with high risk of exceeding $75K or involving litigation'
        input_schema:
          type: 'object'
          properties:
            claim_status_filter:
              type: 'string'
              description: 'Filter by claim status (OPEN, UNDER_INVESTIGATION, etc.) or empty string for all'
          required: ['claim_status_filter']
    
    - tool_spec:
        type: 'generic'
        name: 'PredictRenewalLikelihood'
        description: 'Predicts policy renewal probability based on satisfaction, loss ratio, and relationship factors'
        input_schema:
          type: 'object'
          properties:
            industry_filter:
              type: 'string'
              description: 'Filter by industry (CONSTRUCTION, HEALTHCARE, etc.) or empty string for all'
            business_segment_filter:
              type: 'string'
              description: 'Filter by business segment (SMALL_BUSINESS, MIDMARKET, LARGE_ACCOUNT) or empty string for all'
          required: ['industry_filter', 'business_segment_filter']

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
    
    # ML Procedure Configurations
    PredictClaimCost:
      type: 'procedure'
      identifier: 'MAHONEY_GROUP_INTELLIGENCE.ANALYTICS.PREDICT_CLAIM_COST'
      execution_environment:
        type: 'warehouse'
        warehouse: 'MAHONEY_WH'
        query_timeout: 60
    
    DetectHighRiskClaims:
      type: 'procedure'
      identifier: 'MAHONEY_GROUP_INTELLIGENCE.ANALYTICS.DETECT_HIGH_RISK_CLAIMS'
      execution_environment:
        type: 'warehouse'
        warehouse: 'MAHONEY_WH'
        query_timeout: 60
    
    PredictRenewalLikelihood:
      type: 'procedure'
      identifier: 'MAHONEY_GROUP_INTELLIGENCE.ANALYTICS.PREDICT_RENEWAL_LIKELIHOOD'
      execution_environment:
        type: 'warehouse'
        warehouse: 'MAHONEY_WH'
        query_timeout: 60
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
-- 1. BEFORE running this file, ensure ML models and procedures are created:
--    a) Upload and run notebooks/mahoney_ml_models.ipynb to train models
--    b) Execute sql/ml/07_create_model_wrapper_functions.sql to create wrapper procedures
--    (Agent includes 3 ML procedure tools - they must exist before agent creation)
--
-- 2. Grant USAGE privileges on ML procedures:
--    GRANT USAGE ON PROCEDURE MAHONEY_GROUP_INTELLIGENCE.ANALYTICS.PREDICT_CLAIM_COST(STRING, STRING) TO ROLE <your_role>;
--    GRANT USAGE ON PROCEDURE MAHONEY_GROUP_INTELLIGENCE.ANALYTICS.DETECT_HIGH_RISK_CLAIMS(STRING) TO ROLE <your_role>;
--    GRANT USAGE ON PROCEDURE MAHONEY_GROUP_INTELLIGENCE.ANALYTICS.PREDICT_RENEWAL_LIKELIHOOD(STRING, STRING) TO ROLE <your_role>;
--
-- 3. Grant USAGE privileges on the agent to appropriate roles:
--    GRANT USAGE ON AGENT MAHONEY_GROUP_INTELLIGENCE.ANALYTICS.MAHONEY_GROUP_INTELLIGENCE_AGENT TO ROLE <your_role>;
--
-- 4. Navigate to Snowsight AI & ML > Agents to view and test the agent
--
-- 5. Test the agent with all 15 sample questions:
--    - 5 simple questions (client counts, premium totals, etc.)
--    - 5 complex questions (loss ratios, competitive wins, etc.)
--    - 5 ML prediction questions (claim cost, high-risk, renewal likelihood)
--
-- 6. For full test suite and expected results, see docs/questions.md
--
-- Agent now includes 9 tools:
-- - 3 Cortex Analyst (semantic views)
-- - 3 Cortex Search (unstructured data)
-- - 3 ML Procedures (predictive models)
-- ============================================================================

