# Mahoney Group Intelligence Agent - Setup Guide

This guide walks through configuring a Snowflake Intelligence agent for Mahoney Group's multi-line insurance and employee benefits intelligence solution.

---

## Prerequisites

1. **Snowflake Account** with:
   - Snowflake Intelligence (Cortex) enabled
   - Appropriate warehouse size (recommended: X-SMALL or larger)
   - Permissions to create databases, schemas, tables, and semantic views

2. **Roles and Permissions**:
   - `ACCOUNTADMIN` role or equivalent for initial setup
   - `CREATE DATABASE` privilege
   - `CREATE SEMANTIC VIEW` privilege
   - `CREATE CORTEX SEARCH SERVICE` privilege
   - `USAGE` on warehouses

---

## Step 1: Execute SQL Scripts in Order

Execute the SQL files in the following sequence:

### 1.1 Database Setup
```sql
-- Execute: sql/setup/01_database_and_schema.sql
-- Creates database, schemas (RAW, ANALYTICS), and warehouse
-- Execution time: < 1 second
```

### 1.2 Create Tables
```sql
-- Execute: sql/setup/02_create_tables.sql
-- Creates all table structures with proper relationships
-- Tables: CLIENTS, INSURANCE_AGENTS, INSURANCE_PRODUCTS, POLICIES,
--         POLICY_RENEWALS, PREMIUM_PAYMENTS, CLAIMS, CLAIMS_ADJUSTERS,
--         CLAIM_DISPUTES, BENEFIT_PLANS, LOSS_CONTROL_SERVICES, etc.
-- Execution time: < 5 seconds
```

### 1.3 Generate Sample Data
```sql
-- Execute: sql/data/03_generate_synthetic_data.sql
-- Generates realistic sample data:
--   - 10,000 clients
--   - 150,000 policies
--   - 50,000 claims
--   - 30,000 benefit plans
--   - 100,000 renewals
--   - 200,000 premium payments
-- Execution time: 10-20 minutes (depending on warehouse size)
```

### 1.4 Create Analytical Views
```sql
-- Execute: sql/views/04_create_views.sql
-- Creates curated analytical views:
--   - V_CLIENT_360
--   - V_POLICY_ANALYTICS
--   - V_CLAIMS_ANALYTICS
--   - V_AGENT_PERFORMANCE
--   - V_PRODUCT_PERFORMANCE
--   - V_CLAIM_DISPUTE_ANALYTICS
--   - V_RENEWAL_ANALYTICS
--   - V_LOSS_CONTROL_ANALYTICS
--   - V_BENEFIT_PLAN_ANALYTICS
-- Execution time: < 5 seconds
```

### 1.5 Create Semantic Views
```sql
-- Execute: sql/views/05_create_semantic_views.sql
-- Creates semantic views for AI agents (VERIFIED SYNTAX):
--   - SV_COMMERCIAL_INSURANCE_INTELLIGENCE
--   - SV_CLAIMS_MANAGEMENT_INTELLIGENCE
--   - SV_EMPLOYEE_BENEFITS_INTELLIGENCE
-- Execution time: < 5 seconds
```

### 1.6 Create Cortex Search Services
```sql
-- Execute: sql/search/06_create_cortex_search.sql
-- Creates tables for unstructured text data:
--   - CLAIM_NOTES (30,000 adjuster notes)
--   - POLICY_DOCUMENTS (3 policy forms)
--   - LOSS_CONTROL_REPORTS (15,000 safety reports)
-- Creates Cortex Search services for semantic search:
--   - CLAIM_NOTES_SEARCH
--   - POLICY_DOCUMENTS_SEARCH
--   - LOSS_CONTROL_REPORTS_SEARCH
-- Execution time: 5-10 minutes (data generation + index building)
```

---

## Step 2: Grant Cortex Analyst Permissions

Before creating the agent, ensure proper permissions are configured:

### 2.1 Grant Database Role for Cortex Analyst

```sql
USE ROLE ACCOUNTADMIN;

-- Grant Cortex Analyst user role
GRANT DATABASE ROLE SNOWFLAKE.CORTEX_ANALYST_USER TO ROLE <your_role>;

-- Grant usage on database and schemas
GRANT USAGE ON DATABASE MAHONEY_GROUP_INTELLIGENCE TO ROLE <your_role>;
GRANT USAGE ON SCHEMA MAHONEY_GROUP_INTELLIGENCE.ANALYTICS TO ROLE <your_role>;
GRANT USAGE ON SCHEMA MAHONEY_GROUP_INTELLIGENCE.RAW TO ROLE <your_role>;

-- Grant privileges on semantic views
GRANT REFERENCES, SELECT ON SEMANTIC VIEW MAHONEY_GROUP_INTELLIGENCE.ANALYTICS.SV_COMMERCIAL_INSURANCE_INTELLIGENCE TO ROLE <your_role>;
GRANT REFERENCES, SELECT ON SEMANTIC VIEW MAHONEY_GROUP_INTELLIGENCE.ANALYTICS.SV_CLAIMS_MANAGEMENT_INTELLIGENCE TO ROLE <your_role>;
GRANT REFERENCES, SELECT ON SEMANTIC VIEW MAHONEY_GROUP_INTELLIGENCE.ANALYTICS.SV_EMPLOYEE_BENEFITS_INTELLIGENCE TO ROLE <your_role>;

-- Grant usage on warehouse
GRANT USAGE ON WAREHOUSE MAHONEY_WH TO ROLE <your_role>;

-- Grant usage on Cortex Search services
GRANT USAGE ON CORTEX SEARCH SERVICE MAHONEY_GROUP_INTELLIGENCE.RAW.CLAIM_NOTES_SEARCH TO ROLE <your_role>;
GRANT USAGE ON CORTEX SEARCH SERVICE MAHONEY_GROUP_INTELLIGENCE.RAW.POLICY_DOCUMENTS_SEARCH TO ROLE <your_role>;
GRANT USAGE ON CORTEX SEARCH SERVICE MAHONEY_GROUP_INTELLIGENCE.RAW.LOSS_CONTROL_REPORTS_SEARCH TO ROLE <your_role>;
```

---

## Step 3: Create Snowflake Intelligence Agent

### Step 3.1: Create the Agent

1. In Snowsight, click on **AI & ML** > **Agents**
2. Click on **Create Agent**
3. Select **Create this agent for Snowflake Intelligence**
4. Configure:
   - **Agent Object Name**: `MAHONEY_GROUP_INTELLIGENCE_AGENT`
   - **Display Name**: `Mahoney Group Intelligence Agent`
5. Click **Create**

### Step 3.2: Add Description and Instructions

1. Click on **MAHONEY_GROUP_INTELLIGENCE_AGENT** to open the agent
2. Click **Edit** on the top right corner
3. In the **Description** section, add:
   ```
   This agent orchestrates between Mahoney Group's multi-line insurance and employee benefits data for 
   analyzing structured metrics using Cortex Analyst (semantic views) and unstructured claim notes, 
   policy documents, and loss control reports using Cortex Search services.
   ```

### Step 3.3: Configure Response Instructions

1. Click on **Instructions** in the left pane
2. Enter the following **Response Instructions**:
   ```
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
   ```

3. **Add Sample Questions** (click "Add a question" for each):
   - "Which industries have the highest claim costs?"
   - "What is our competitive win rate against major carriers?"
   - "Search claim notes for successful settlement strategies"
   - "Show renewal rates by business segment"
   - "What are per-employee benefit costs?"

---

## Step 3.4: Add Cortex Analyst Tools (Semantic Views)

1. Click on **Tools** in the left pane
2. Find **Cortex Analyst** and click **+ Add**

**Add Semantic View 1: Commercial Insurance Intelligence**

1. **Select semantic view**: `MAHONEY_GROUP_INTELLIGENCE.ANALYTICS.SV_COMMERCIAL_INSURANCE_INTELLIGENCE`
2. **Add a description**:
   ```
   This semantic view contains comprehensive data about clients, insurance agents, products, 
   policies, and renewals. Use this for queries about:
   - New policy production and competitive wins
   - Policy renewal rates and premium changes
   - Agent performance and productivity
   - Client risk profiles and satisfaction
   - Coverage types and product lines
   - Premium analysis and trends
   ```
3. **Save**

**Add Semantic View 2: Claims Management Intelligence**

1. Click **+ Add** again for another Cortex Analyst tool
2. **Select semantic view**: `MAHONEY_GROUP_INTELLIGENCE.ANALYTICS.SV_CLAIMS_MANAGEMENT_INTELLIGENCE`
3. **Add a description**:
   ```
   This semantic view contains claims data, adjusters, disputes, and litigation. 
   Use this for queries about:
   - Claim costs (paid, reserved, incurred)
   - Claims adjuster performance and efficiency
   - Claim types and severity analysis
   - Dispute rates and legal costs
   - Settlement amounts and outcomes
   - Industry-specific claim patterns
   ```
4. **Save**

**Add Semantic View 3: Employee Benefits Intelligence**

1. Click **+ Add** again for another Cortex Analyst tool
2. **Select semantic view**: `MAHONEY_GROUP_INTELLIGENCE.ANALYTICS.SV_EMPLOYEE_BENEFITS_INTELLIGENCE`
3. **Add a description**:
   ```
   This semantic view contains employee benefit plan data including health, dental, vision, life, 
   and disability coverage. Use this for queries about:
   - Benefit plan enrollment and covered employees
   - Per-employee costs and premium analysis
   - Carrier performance comparison
   - Plan mix by client and industry
   - Benefits program costs
   ```
4. **Save**

---

## Step 3.5: Add Cortex Search Tools (Unstructured Data)

1. While still in **Tools**, find **Cortex Search** and click **+ Add**

**Add Cortex Search 1: Claim Notes**

1. **Select Cortex Search Service**: `MAHONEY_GROUP_INTELLIGENCE.RAW.CLAIM_NOTES_SEARCH`
2. **Add a description**:
   ```
   Search 30,000 claim adjuster notes and investigations for settlement strategies, 
   claim management approaches, and investigation techniques. Use for queries about:
   - Settlement negotiation strategies
   - Claim investigation methods
   - Resolution approaches and outcomes
   - Coverage analysis and determinations
   - Litigation defense strategies
   - Subrogation opportunities
   ```
3. **Configure search settings**:
   - **ID Column**: `note_id`
   - **Title Column**: `claim_id`
   - **Max Results**: 10
4. **Save**

**Add Cortex Search 2: Policy Documents**

1. Click **+ Add** again for another Cortex Search
2. **Select Cortex Search Service**: `MAHONEY_GROUP_INTELLIGENCE.RAW.POLICY_DOCUMENTS_SEARCH`
3. **Add a description**:
   ```
   Search insurance policy forms and endorsements for coverage details, exclusions, and 
   policy language. Use for queries about:
   - Coverage provisions and limits
   - Policy exclusions and limitations
   - Endorsement details
   - Insurance requirements
   - Coverage triggers and conditions
   ```
4. **Configure search settings**:
   - **ID Column**: `document_id`
   - **Title Column**: `document_title`
   - **Max Results**: 5
5. **Save**

**Add Cortex Search 3: Loss Control Reports**

1. Click **+ Add** again for another Cortex Search
2. **Select Cortex Search Service**: `MAHONEY_GROUP_INTELLIGENCE.RAW.LOSS_CONTROL_REPORTS_SEARCH`
3. **Add a description**:
   ```
   Search 15,000 loss control and safety assessment reports for hazard identification, 
   risk assessments, and safety recommendations. Use for queries about:
   - Workplace hazards and risk factors
   - Safety recommendations and best practices
   - Injury prevention strategies
   - Ergonomic assessments
   - Fire safety and emergency preparedness
   - Industry-specific safety guidance
   ```
4. **Configure search settings**:
   - **ID Column**: `report_id`
   - **Title Column**: `report_title`
   - **Max Results**: 10
5. **Save**

---

## Step 4: Test the Agent

### Step 4.1: Test Structured Data Queries (Cortex Analyst)

1. In the agent interface, click **Chat**
2. Try these test questions:

**Test 1: Loss Ratio Analysis**
```
Analyze loss ratios by insurance product category. Which products are most profitable?
```
Expected: Uses SV_COMMERCIAL_INSURANCE_INTELLIGENCE with claims data

**Test 2: Competitive Intelligence**
```
What is our competitive win rate? Which competitors are we winning against most?
```
Expected: Uses SV_COMMERCIAL_INSURANCE_INTELLIGENCE, filters competitive_win = TRUE

**Test 3: Claims Cost Analysis**
```
What are the average claim costs by claim type and industry?
```
Expected: Uses SV_CLAIMS_MANAGEMENT_INTELLIGENCE, groups by claim_type and industry

**Test 4: Renewal Analysis**
```
Show renewal rates by business segment. Which segments have the best retention?
```
Expected: Uses SV_COMMERCIAL_INSURANCE_INTELLIGENCE, calculates renewal rates

**Test 5: Benefits Cost Analysis**
```
What are the average per-employee benefit costs by plan type?
```
Expected: Uses SV_EMPLOYEE_BENEFITS_INTELLIGENCE, calculates costs per employee

### Step 4.2: Test Unstructured Data Queries (Cortex Search)

**Test 6: Claim Settlement Strategies**
```
Search claim notes for successful property damage settlement strategies
```
Expected: Uses CLAIM_NOTES_SEARCH, returns relevant adjuster notes

**Test 7: Policy Coverage Questions**
```
What do our cyber insurance policy documents say about ransomware coverage?
```
Expected: Uses POLICY_DOCUMENTS_SEARCH, retrieves cyber policy provisions

**Test 8: Safety Recommendations**
```
Search loss control reports for workplace safety recommendations in construction
```
Expected: Uses LOSS_CONTROL_REPORTS_SEARCH, returns construction safety findings

**Test 9: Claim Investigation Techniques**
```
Find claim notes about effective investigation methods in high-value claims
```
Expected: Uses CLAIM_NOTES_SEARCH, finds investigation best practices

**Test 10: Risk Assessment**
```
Search loss control reports for ergonomic hazards in manufacturing facilities
```
Expected: Uses LOSS_CONTROL_REPORTS_SEARCH, retrieves ergonomic assessments

### Step 4.3: Test Combined Queries (Structured + Unstructured)

**Test 11: Claims + Settlement Analysis**
```
Which claim types have the highest costs? Search notes for cost management strategies.
```
Expected: Uses both SV_CLAIMS_MANAGEMENT_INTELLIGENCE and CLAIM_NOTES_SEARCH

**Test 12: Risk Management Effectiveness**
```
Show clients with loss control services. Search reports for their safety recommendations.
```
Expected: Uses SV_COMMERCIAL_INSURANCE_INTELLIGENCE and LOSS_CONTROL_REPORTS_SEARCH

---

## Verification Steps

### Verify Semantic Views
```sql
SHOW SEMANTIC VIEWS IN SCHEMA MAHONEY_GROUP_INTELLIGENCE.ANALYTICS;
-- Should show 3 semantic views
```

### Verify Cortex Search Services
```sql
SHOW CORTEX SEARCH SERVICES IN SCHEMA MAHONEY_GROUP_INTELLIGENCE.RAW;
-- Should show 3 search services
```

### Test Cortex Search Directly
```sql
SELECT PARSE_JSON(
  SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
      'MAHONEY_GROUP_INTELLIGENCE.RAW.CLAIM_NOTES_SEARCH',
      '{"query": "settlement negotiation strategy", "limit":5}'
  )
)['results'] as results;
```

---

## Troubleshooting

### Agent Not Finding Data
1. Verify permissions on semantic views and search services
2. Check that warehouse is assigned and running
3. Ensure semantic views have data (check row counts)

### Cortex Search Not Working
1. Verify change tracking is enabled on tables
2. Check that search services are in READY state
3. Allow 5-10 minutes for initial indexing after creation

### Slow Response Times
1. Increase warehouse size for data generation
2. Verify Cortex Search indexes have built
3. Check query complexity in Cortex Analyst

---

## Next Steps

1. **Customize Questions**: Add insurance-specific questions to the agent
2. **Integrate with Applications**: Use agent via API for custom applications
3. **Monitor Usage**: Track which queries are most common
4. **Expand Data**: Add more clients, policies, or time periods
5. **Enhance Search**: Add more unstructured content (emails, contracts, etc.)

---

## OPTIONAL: Add ML Models (Claim Cost, Risk Detection, Renewal Prediction)

This section is optional but adds powerful ML prediction capabilities to your agent.

### Prerequisites for ML Models

- Core setup (Steps 1-3) completed
- Files 01-06 executed successfully
- Agent configured with semantic views and Cortex Search

### ML Setup Overview

1. Upload and run Snowflake Notebook to train models
2. Execute SQL wrapper procedures file
3. Add 3 ML procedures to agent as tools

**Time:** 20-30 minutes

---

### ML Step 1: Upload Notebook to Snowflake (5 min)

1. In Snowsight, click **Projects** → **Notebooks**
2. Click **+ Notebook** → **Import .ipynb file**
3. Upload: `notebooks/mahoney_ml_models.ipynb`
4. Name it: `Mahoney Group ML Models`
5. Configure:
   - **Database:** MAHONEY_GROUP_INTELLIGENCE
   - **Schema:** ANALYTICS
   - **Warehouse:** MAHONEY_WH
6. Click **Create**

### ML Step 2: Add Required Packages

1. In the notebook, click **Packages** dropdown (upper right)
2. Search and add each package:
   - `snowflake-ml-python`
   - `scikit-learn`
   - `xgboost`
   - `matplotlib`
3. Click **Start** to activate the notebook

### ML Step 3: Run Notebook to Train Models (10 min)

1. Click **Run All** (or run each cell sequentially)
2. Wait for training to complete (2-3 minutes per model)
3. Verify output shows:
   - "✅ Claim cost prediction model trained"
   - "✅ High-risk claims detection model trained"
   - "✅ Renewal likelihood prediction model trained"
   - "✅ Models registered to Model Registry"

**Models created:**
- CLAIM_COST_PREDICTOR (Linear Regression for cost prediction)
- HIGH_RISK_CLAIMS_DETECTOR (Random Forest for risk classification)
- RENEWAL_LIKELIHOOD_PREDICTOR (Logistic Regression for renewal forecasting)

### ML Step 4: Create Wrapper Procedures (2 min)

Execute the SQL wrapper procedures:

```sql
@sql/ml/07_create_model_wrapper_functions.sql
```

This creates 3 stored procedures that wrap the Model Registry models so the agent can call them.

**Procedures created:**
- PREDICT_CLAIM_COST(claim_type_filter, industry_filter)
- DETECT_HIGH_RISK_CLAIMS(claim_status_filter)
- PREDICT_RENEWAL_LIKELIHOOD(industry_filter, business_segment_filter)

### ML Step 5: Add ML Procedures to Agent (10 min)

#### Navigate to Agent Tools

1. In your agent editor (MAHONEY_GROUP_INTELLIGENCE_AGENT)
2. Click **Tools** (left sidebar)

#### Add Procedure 1: PREDICT_CLAIM_COST

1. Click **+ Add** button (top right)
2. Click **Procedure** tile (NOT Function)
3. In dropdown, select: `MAHONEY_GROUP_INTELLIGENCE.ANALYTICS.PREDICT_CLAIM_COST`
4. Paste in Description:
   ```
   Claim Cost Prediction Procedure
   
   Predicts total incurred costs for claims using the CLAIM_COST_PREDICTOR model from Model Registry.
   The model uses Linear Regression trained on historical claim patterns.
   
   Use when users ask to:
   - Predict claim costs
   - Forecast claim expenses
   - Estimate total incurred costs
   
   Parameters:
   - claim_type_filter: Filter by claim type (PROPERTY_DAMAGE, BODILY_INJURY, etc.) or empty for all
   - industry_filter: Filter by industry (CONSTRUCTION, HEALTHCARE, etc.) or empty for all
   
   Returns: JSON with average predicted cost, total predicted cost, min/max costs
   
   Example: "Predict costs for open property damage claims in construction"
   ```
5. Click **Add**

#### Add Procedure 2: DETECT_HIGH_RISK_CLAIMS

1. Click **+ Add** → **Procedure**
2. Select: `MAHONEY_GROUP_INTELLIGENCE.ANALYTICS.DETECT_HIGH_RISK_CLAIMS`
3. Description:
   ```
   High-Risk Claims Detection Procedure
   
   Identifies claims with high risk of exceeding $75K or involving litigation using the 
   HIGH_RISK_CLAIMS_DETECTOR model from Model Registry. Uses Random Forest classifier.
   
   Use when users ask to:
   - Identify high-risk claims
   - Find claims needing enhanced review
   - Screen for potential litigation
   
   Parameter:
   - claim_status_filter: Filter by status (OPEN, UNDER_INVESTIGATION) or empty for both
   
   Returns: JSON with high-risk count, risk percentage, and recommendation
   
   Example: "Which open claims have high risk?"
   ```
4. Click **Add**

#### Add Procedure 3: PREDICT_RENEWAL_LIKELIHOOD

1. Click **+ Add** → **Procedure**
2. Select: `MAHONEY_GROUP_INTELLIGENCE.ANALYTICS.PREDICT_RENEWAL_LIKELIHOOD`
3. Description:
   ```
   Renewal Likelihood Prediction Procedure
   
   Predicts policy renewal probability using the RENEWAL_LIKELIHOOD_PREDICTOR model from 
   Model Registry. Uses Logistic Regression based on satisfaction, loss ratio, and premium changes.
   
   Use when users ask to:
   - Predict renewal likelihood
   - Identify at-risk clients
   - Forecast retention rates
   
   Parameters:
   - industry_filter: Filter by industry (CONSTRUCTION, HEALTHCARE, etc.) or empty for all
   - business_segment_filter: Filter by segment (SMALL_BUSINESS, MIDMARKET, LARGE_ACCOUNT) or empty
   
   Returns: JSON with renewal rate, at-risk client count, and retention recommendations
   
   Example: "Predict renewal likelihood for construction clients"
   ```
4. Click **Add**

#### Verify ML Procedures Added

Your agent's **Tools** section should now show:
- **Cortex Analyst (3):** Semantic views
- **Cortex Search (3):** Search services
- **Procedures (3):** ML prediction procedures

**Total: 9 tools**

### ML Step 6: Test ML Capabilities

Ask your agent:

```
"Predict costs for open property damage claims"
"Which claims have high risk that should be investigated?"
"Predict renewal likelihood for construction clients"
```

The agent will call the appropriate ML procedures and return predictions!

---

## Complete Setup Summary

### Core Setup (Required - 45 minutes):
1. Execute SQL files 01-06
2. Configure agent with semantic views and Cortex Search

### ML Setup (Optional - 30 minutes):
1. Upload and run ML notebook
2. Execute wrapper procedures SQL
3. Add 3 procedures to agent

**Total with ML: ~75 minutes**

---

**Version:** 1.0  
**Created:** November 2025  
**Based on:** Zenith Insurance Intelligence Agent Template  
**Verified:** All syntax verified against Snowflake documentation

**Setup Time Estimate**: 30-45 minutes core | +30 minutes ML (optional)


