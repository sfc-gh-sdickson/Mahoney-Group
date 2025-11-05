<p align="center">
  <img src="./Snowflake_Logo.svg" alt="Snowflake Logo" width="200">
</p>

# Mahoney Group Intelligence Agent Solution

## About Mahoney Group

Mahoney Group (M&O Agencies Inc.) is a premier insurance brokerage and risk management firm providing innovative solutions for clients globally. Founded in Arizona, Mahoney Group specializes in:

### Service Areas

- **Commercial Insurance**: Property, General Liability, Professional Liability, Workers' Compensation, Cyber Insurance, Commercial Auto, Excess Liability, Builders Risk, Pollution Liability
- **Employee Benefits**: Group Health, Dental, Vision, Life, Disability, Wellness Programs, Benefits Analytics, Compliance Services
- **Risk Management**: Loss Control Services, Claims Advocacy, Safety Programs, Ergonomic Assessments
- **Personal Lines**: Private Client Practice for high-net-worth individuals

### Key Industries Served

- Construction
- Healthcare Providers
- Hospitality (Hotels, Restaurants)
- Real Estate & Property Management
- Manufacturing
- Technology & Professional Services
- Human Services & Nonprofits
- Educational Institutions
- Pest Control
- Waste & Recycling
- Craft Breweries
- Self-Storage Facilities
- Native American Tribes
- ESOPs

### Corporate Headquarters
M&O Agencies Inc. / The Mahoney Group  
2625 W. Geronimo Place, Suite 350  
Chandler, AZ 85224  
Phone: 480-730-4920 | 877-440-3304  
www.mahoneygroup.com

---

## Project Overview

This Snowflake Intelligence solution demonstrates how Mahoney Group can leverage AI agents to analyze:

- **Commercial Insurance Intelligence**: Policy production, competitive wins, agent performance, renewal rates, loss ratios
- **Claims Management Intelligence**: Claim costs, adjuster performance, settlement strategies, litigation trends
- **Employee Benefits Intelligence**: Benefit plan enrollment, per-employee costs, carrier performance, plan mix
- **Risk Management Effectiveness**: Loss control services, safety recommendations, injury prevention impact
- **Client Retention**: Renewal likelihood, at-risk clients, satisfaction scoring
- **Unstructured Data Search**: Semantic search over claim notes, policy documents, and loss control reports using Cortex Search

---

## Database Schema

The solution includes:

### 1. RAW Schema: Core Business Tables

**Clients & Agents:**
- CLIENTS: Businesses purchasing insurance and benefits
- INSURANCE_AGENTS: Mahoney Group agents and brokers
- INSURANCE_PRODUCTS: All insurance products offered
- MARKETING_CAMPAIGNS: Marketing and lead generation campaigns

**Commercial Insurance:**
- POLICIES: Insurance policies sold to clients
- POLICY_COVERAGES: Specific coverages under policies
- POLICY_RENEWALS: Policy renewals and premium changes
- PREMIUM_PAYMENTS: Premium payment transactions

**Claims:**
- CLAIMS: Insurance claims filed by clients
- CLAIMS_ADJUSTERS: Claims adjusters handling claims
- CLAIM_DISPUTES: Disputed claims and litigation

**Employee Benefits:**
- BENEFIT_PLANS: Group health, dental, vision, life, disability plans
- CLIENT_SERVICES: Additional services provided to clients

**Risk Management:**
- LOSS_CONTROL_SERVICES: Loss control and safety services
- LOSS_CONTROL_REPORTS: Detailed safety assessment reports (unstructured)

**Unstructured Data:**
- CLAIM_NOTES: 30,000 adjuster notes and claim investigations (unstructured text)
- POLICY_DOCUMENTS: Insurance policy forms and endorsements (unstructured text)
- LOSS_CONTROL_REPORTS: 15,000 safety assessment reports (unstructured text)

### 2. ANALYTICS Schema: Curated Views and Semantic Models

**Analytical Views:**
- V_CLIENT_360: Complete client profile with policies, claims, and benefits
- V_POLICY_ANALYTICS: Policy performance metrics and loss ratios
- V_CLAIMS_ANALYTICS: Detailed claim metrics and outcomes
- V_AGENT_PERFORMANCE: Agent productivity and retention
- V_PRODUCT_PERFORMANCE: Product line profitability
- V_CLAIM_DISPUTE_ANALYTICS: Litigation and dispute tracking
- V_RENEWAL_ANALYTICS: Renewal performance metrics
- V_LOSS_CONTROL_ANALYTICS: Risk management service effectiveness
- V_BENEFIT_PLAN_ANALYTICS: Employee benefits program metrics

**Semantic Views for AI Agents:**
- SV_COMMERCIAL_INSURANCE_INTELLIGENCE: Clients, agents, products, policies, renewals
- SV_CLAIMS_MANAGEMENT_INTELLIGENCE: Claims, adjusters, disputes, litigation
- SV_EMPLOYEE_BENEFITS_INTELLIGENCE: Benefit plans, covered employees, carriers

### 3. Cortex Search Services: Semantic Search Over Unstructured Data

- **CLAIM_NOTES_SEARCH**: Search 30,000 adjuster notes and claim investigations
- **POLICY_DOCUMENTS_SEARCH**: Search insurance policy forms and coverage details
- **LOSS_CONTROL_REPORTS_SEARCH**: Search 15,000 safety assessment reports

---

## Files

### Core Files
- `README.md`: This comprehensive solution documentation
- `docs/AGENT_SETUP.md`: Complete agent configuration instructions
- `docs/questions.md`: 5 simple + 10 complex + 10 unstructured test questions

### SQL Files
- `sql/setup/01_database_and_schema.sql`: Database and schema creation
- `sql/setup/02_create_tables.sql`: Table definitions with proper constraints
- `sql/data/03_generate_synthetic_data.sql`: Realistic insurance sample data
- `sql/views/04_create_views.sql`: Analytical views
- `sql/views/05_create_semantic_views.sql`: Semantic views for AI agents (verified syntax)
- `sql/search/06_create_cortex_search.sql`: Unstructured data tables and Cortex Search services
- `sql/ml/07_create_model_wrapper_functions.sql`: ML model wrapper procedures (optional)

### ML Models (Optional)
- `notebooks/mahoney_ml_models.ipynb`: Snowflake Notebook for training ML models

---

## Setup Instructions

1. Execute SQL files in order (01 through 06)
   - 01: Database and schema setup
   - 02: Create tables
   - 03: Generate synthetic data (10-20 min)
   - 04: Create analytical views
   - 05: Create semantic views
   - 06: Create Cortex Search services (5-10 min)
2. Follow AGENT_SETUP.md for agent configuration
3. Test with questions from questions.md

---

## Data Model Highlights

### Structured Data
- Realistic multi-line insurance scenarios
- 10K clients across SMALL_BUSINESS, MIDMARKET, LARGE_ACCOUNT segments
- 150K insurance policies (Property, Liability, Workers Comp, Cyber, Auto, etc.)
- 50K insurance claims with detailed cost breakdowns
- 30K employee benefit plans (Health, Dental, Vision, Life, Disability)
- 100K policy renewals with premium change analysis
- 200K premium payment transactions
- 15K loss control services
- 10K claim disputes and litigation cases

### Unstructured Data
- 30,000 claim notes with realistic adjuster narratives and investigations
- 3 comprehensive policy documents (CGL, Workers Comp, Cyber Insurance)
- 15,000 loss control reports with safety assessments and recommendations
- Semantic search powered by Snowflake Cortex Search
- RAG (Retrieval Augmented Generation) ready for AI agents

---

## Key Features

✅ **Hybrid Data Architecture**: Combines structured tables with unstructured claim notes and policy documents  
✅ **Semantic Search**: Find similar claims and risk patterns by meaning, not keywords  
✅ **RAG-Ready**: Agent can retrieve context from claim notes and safety reports  
✅ **Production-Ready Syntax**: All SQL verified against Snowflake documentation  
✅ **Comprehensive Demo**: 150K policies, 50K claims, 30K benefit plans, 30K claim notes  
✅ **Verified Syntax**: CREATE SEMANTIC VIEW and CREATE CORTEX SEARCH SERVICE syntax verified against official Snowflake documentation  
✅ **No Duplicate Synonyms**: All semantic view synonyms globally unique across all three views  
✅ **ML-Powered** (Optional): 3 ML models for claim cost prediction, high-risk detection, and renewal forecasting

---

## Complex Questions Examples

The agent can answer sophisticated questions like:

### Structured Data Analysis (Semantic Views)
1. **Loss Ratio Analysis**: Loss ratios by product line and coverage type
2. **Competitive Intelligence**: Win rate vs. competitors (Travelers, Hartford, Zurich, Liberty Mutual, AIG, Chubb, CNA)
3. **Agent Performance**: Premium production by agent, renewal rates, client satisfaction
4. **Claims Cost Analysis**: Average costs by claim type, industry, and severity
5. **Renewal Performance**: Renewal rates, premium changes, at-risk clients
6. **Benefits Analytics**: Per-employee costs, plan enrollment, carrier performance
7. **Risk Management ROI**: Loss control service effectiveness and injury reduction
8. **Geographic Analysis**: Performance by state, market penetration, expansion opportunities
9. **Client Health Scoring**: Risk ratings, satisfaction, retention likelihood
10. **Adjuster Efficiency**: Case closure rates, average costs, satisfaction ratings

### Unstructured Data Search (Cortex Search)
11. **Claim Settlements**: Settlement strategies and negotiation approaches from adjuster notes
12. **Policy Coverage**: Coverage details and exclusions from policy documents
13. **Safety Recommendations**: Workplace hazards and prevention strategies from loss control reports
14. **Investigation Techniques**: Effective claim investigation methods from adjuster notes
15. **Risk Mitigation**: Successful risk reduction strategies from safety assessments
16. **Coverage Questions**: Policy interpretation and endorsement details
17. **Best Practices**: Successful claim management and settlement approaches
18. **Hazard Identification**: Common workplace hazards by industry
19. **Loss Prevention**: Effective injury prevention programs
20. **Compliance Guidance**: Regulatory requirements and compliance approaches

---

## Semantic Views

The solution includes three verified semantic views:

1. **SV_COMMERCIAL_INSURANCE_INTELLIGENCE**: Comprehensive view of clients, agents, products, policies, and renewals
2. **SV_CLAIMS_MANAGEMENT_INTELLIGENCE**: Claims, adjusters, disputes, legal costs, and settlements
3. **SV_EMPLOYEE_BENEFITS_INTELLIGENCE**: Benefit plans, covered employees, carriers, and costs

All semantic views follow the verified syntax structure:
- TABLES clause with PRIMARY KEY definitions
- RELATIONSHIPS clause defining foreign keys
- DIMENSIONS clause with synonyms and comments
- METRICS clause with aggregations and calculations
- Proper clause ordering (TABLES → RELATIONSHIPS → DIMENSIONS → METRICS → COMMENT)
- **NO DUPLICATE SYNONYMS** - All synonyms globally unique

---

## Cortex Search Services

Three Cortex Search services enable semantic search over unstructured data:

1. **CLAIM_NOTES_SEARCH**: Search 30,000 adjuster notes
   - Find settlement strategies and investigation techniques
   - Retrieve successful claim management approaches
   - Analyze resolution outcomes
   - Searchable attributes: client_id, adjuster_id, claim_type, claim_category, note_type

2. **POLICY_DOCUMENTS_SEARCH**: Search insurance policy forms
   - Retrieve coverage provisions and exclusions
   - Find policy language and endorsements
   - Access coverage details by product type
   - Searchable attributes: product_category, coverage_type, document_type, state

3. **LOSS_CONTROL_REPORTS_SEARCH**: Search 15,000 safety assessment reports
   - Find hazard identification and risk assessments
   - Identify effective safety recommendations
   - Retrieve injury prevention strategies
   - Searchable attributes: client_id, industry_vertical, risk_area, priority_level, report_type

All Cortex Search services use verified syntax:
- ON clause specifying search column
- ATTRIBUTES clause for filterable columns
- WAREHOUSE assignment
- TARGET_LAG for refresh frequency
- AS clause with source query

---

## Syntax Verification

All SQL syntax has been verified against official Snowflake documentation:

- **CREATE SEMANTIC VIEW**: https://docs.snowflake.com/en/sql-reference/sql/create-semantic-view
- **CREATE CORTEX SEARCH SERVICE**: https://docs.snowflake.com/en/sql-reference/sql/create-cortex-search
- **Cortex Search Overview**: https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-search/cortex-search-overview

Key verification points:
- ✅ Clause order is mandatory (TABLES → RELATIONSHIPS → DIMENSIONS → METRICS)
- ✅ PRIMARY KEY columns verified to exist in source tables
- ✅ No self-referencing or cyclic relationships
- ✅ Semantic expression format: `name AS expression`
- ✅ Change tracking enabled for Cortex Search tables
- ✅ Correct ATTRIBUTES syntax for filterable columns
- ✅ All column references verified against table definitions
- ✅ No duplicate synonyms across all three semantic views

---

## Getting Started

### Prerequisites
- Snowflake account with Cortex Intelligence enabled
- ACCOUNTADMIN or equivalent privileges
- X-SMALL or larger warehouse

### Quick Start
```sql
-- 1. Create database and schemas
@sql/setup/01_database_and_schema.sql

-- 2. Create tables
@sql/setup/02_create_tables.sql

-- 3. Generate sample data (10-20 minutes)
@sql/data/03_generate_synthetic_data.sql

-- 4. Create analytical views
@sql/views/04_create_views.sql

-- 5. Create semantic views
@sql/views/05_create_semantic_views.sql

-- 6. Create Cortex Search services (5-10 minutes)
@sql/search/06_create_cortex_search.sql
```

### Configure Agent
Follow the detailed instructions in `docs/AGENT_SETUP.md` to:
1. Create the Snowflake Intelligence Agent
2. Add semantic views as data sources (Cortex Analyst)
3. Configure Cortex Search services
4. Set up system prompts and instructions
5. Test with sample questions

---

## Testing

### Verify Installation
```sql
-- Check semantic views
SHOW SEMANTIC VIEWS IN SCHEMA MAHONEY_GROUP_INTELLIGENCE.ANALYTICS;

-- Check Cortex Search services
SHOW CORTEX SEARCH SERVICES IN SCHEMA MAHONEY_GROUP_INTELLIGENCE.RAW;

-- Test Cortex Search
SELECT PARSE_JSON(
  SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
      'MAHONEY_GROUP_INTELLIGENCE.RAW.CLAIM_NOTES_SEARCH',
      '{"query": "property damage settlement strategy", "limit":5}'
  )
)['results'] as results;
```

### Sample Test Questions
1. "Which industries have the highest claim frequency?"
2. "What is our competitive win rate against major carriers?"
3. "Search claim notes for successful settlement strategies"
4. "Show renewal rates by business segment"
5. "What are per-employee benefit costs by industry?"

---

## Data Volumes

- **Clients**: 10,000
- **Insurance Agents**: 50
- **Insurance Products**: 30+ (Property, Liability, WC, Cyber, Auto, etc.)
- **Policies**: 150,000
- **Policy Renewals**: 100,000
- **Premium Payments**: 200,000
- **Claims**: 50,000
- **Claim Disputes**: 10,000
- **Claims Adjusters**: 30
- **Benefit Plans**: 30,000
- **Loss Control Services**: 15,000
- **Claim Notes**: 30,000 (unstructured)
- **Policy Documents**: 3 comprehensive forms
- **Loss Control Reports**: 15,000 (unstructured)

---

## Architecture

The Mahoney Group Intelligence Agent follows a three-layer architecture:

**Layer 1: Snowflake Intelligence Agent (Orchestration)**
- Routes requests to appropriate services
- Combines structured and unstructured insights
- Provides conversational interface

**Layer 2A: Cortex Analyst (Structured Data)**
- Analyzes structured data via semantic views
- 3 semantic views covering commercial insurance, claims, and benefits
- Provides metrics, aggregations, and trend analysis

**Layer 2B: Cortex Search (Unstructured Data)**
- Searches unstructured documents semantically
- 3 search services: Claim notes, policy documents, loss control reports
- Enables RAG (Retrieval Augmented Generation)

**Layer 3: RAW Schema (Source Data)**
- 15+ structured tables with 500K+ records
- 45K+ unstructured documents
- All relationships defined with foreign keys

---

## Support

For questions or issues:
- Review `docs/AGENT_SETUP.md` for detailed setup instructions
- Check `docs/questions.md` for example questions
- Refer to Snowflake documentation for syntax verification
- Contact your Snowflake account team for assistance

---

## Version History

- **v1.0** (November 2025): Initial release
  - Verified semantic view syntax
  - Verified Cortex Search syntax
  - 10K clients, 150K policies, 50K claims, 30K benefit plans
  - 30K claim notes with semantic search
  - 3 policy document forms
  - 15K loss control reports
  - 20+ complex test questions
  - Comprehensive documentation

---

## License

This solution is provided as a template for building Snowflake Intelligence agents for multi-line insurance brokerages. Adapt as needed for your specific use case.

---

**Created**: November 2025  
**Template Based On**: Zenith Insurance Intelligence Agent (Workers' Compensation Specialist)  
**Snowflake Documentation**: Syntax verified against official documentation  
**Target Use Case**: Mahoney Group multi-line insurance and employee benefits intelligence

**NO GUESSING - ALL SYNTAX VERIFIED** ✅  
**NO DUPLICATE SYNONYMS - ALL GLOBALLY UNIQUE** ✅


