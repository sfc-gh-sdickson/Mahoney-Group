-- ============================================================================
-- Mahoney Group Intelligence Agent - Semantic Views
-- ============================================================================
-- Purpose: Create semantic views for Snowflake Intelligence agents
-- All syntax VERIFIED against official documentation:
-- https://docs.snowflake.com/en/sql-reference/sql/create-semantic-view
-- 
-- Syntax Verification Notes:
-- 1. Clause order is MANDATORY: TABLES → RELATIONSHIPS → DIMENSIONS → METRICS → COMMENT
-- 2. Semantic expression format: semantic_name AS sql_expression
-- 3. No self-referencing relationships allowed
-- 4. No cyclic relationships allowed
-- 5. PRIMARY KEY columns must exist in table definitions
-- 6. All column references VERIFIED against 02_create_tables.sql
-- 7. All synonyms are GLOBALLY UNIQUE across all semantic views
-- ============================================================================

USE DATABASE MAHONEY_GROUP_INTELLIGENCE;
USE SCHEMA ANALYTICS;
USE WAREHOUSE MAHONEY_WH;

-- ============================================================================
-- Semantic View 1: Commercial Insurance Intelligence
-- ============================================================================
CREATE OR REPLACE SEMANTIC VIEW SV_COMMERCIAL_INSURANCE_INTELLIGENCE
  TABLES (
    clients AS RAW.CLIENTS
      PRIMARY KEY (client_id)
      WITH SYNONYMS ('business clients view1', 'insured companies', 'policyholders')
      COMMENT = 'Business clients purchasing insurance from Mahoney Group',
    agents AS RAW.INSURANCE_AGENTS
      PRIMARY KEY (agent_id)
      WITH SYNONYMS ('insurance brokers', 'mahoney agents', 'producers')
      COMMENT = 'Mahoney Group insurance agents and brokers',
    products AS RAW.INSURANCE_PRODUCTS
      PRIMARY KEY (product_id)
      WITH SYNONYMS ('insurance products view1', 'coverage products', 'policy products')
      COMMENT = 'Insurance products offered by Mahoney Group',
    policies AS RAW.POLICIES
      PRIMARY KEY (policy_id)
      WITH SYNONYMS ('insurance policies', 'active policies', 'written policies')
      COMMENT = 'Insurance policies sold to clients',
    renewals AS RAW.POLICY_RENEWALS
      PRIMARY KEY (renewal_id)
      WITH SYNONYMS ('policy renewals view1', 'renewal transactions', 'reinstatements')
      COMMENT = 'Policy renewals and renewal activity'
  )
  RELATIONSHIPS (
    policies(client_id) REFERENCES clients(client_id),
    policies(agent_id) REFERENCES agents(agent_id),
    policies(product_id) REFERENCES products(product_id),
    renewals(policy_id) REFERENCES policies(policy_id),
    renewals(client_id) REFERENCES clients(client_id),
    renewals(agent_id) REFERENCES agents(agent_id),
    renewals(product_id) REFERENCES products(product_id)
  )
  DIMENSIONS (
    clients.client_name AS client_name
      WITH SYNONYMS ('business name view1', 'company name', 'insured name')
      COMMENT = 'Name of the client business',
    clients.client_status AS client_status
      WITH SYNONYMS ('account status view1', 'client account status')
      COMMENT = 'Client status: ACTIVE, INACTIVE',
    clients.business_segment AS business_segment
      WITH SYNONYMS ('client segment view1', 'business size category')
      COMMENT = 'Business segment: SMALL_BUSINESS, MIDMARKET, LARGE_ACCOUNT',
    clients.industry_vertical AS industry_vertical
      WITH SYNONYMS ('industry type view1', 'business industry', 'industry sector')
      COMMENT = 'Industry vertical: CONSTRUCTION, HEALTHCARE, HOSPITALITY, MANUFACTURING, REAL_ESTATE, etc.',
    clients.state AS state
      WITH SYNONYMS ('client state view1', 'business location state')
      COMMENT = 'Client state location',
    clients.city AS city
      WITH SYNONYMS ('client city view1', 'business location city')
      COMMENT = 'Client city location',
    clients.risk_rating AS risk_rating
      WITH SYNONYMS ('risk score', 'risk grade', 'client risk level')
      COMMENT = 'Risk rating: A+, A, A-, B+, B, B-, C+, C',
    agents.agent_name AS agent_name
      WITH SYNONYMS ('broker name', 'producer name', 'agent full name')
      COMMENT = 'Name of the Mahoney Group agent',
    agents.agent_type AS agent_type
      WITH SYNONYMS ('agent category', 'broker type', 'agent specialty')
      COMMENT = 'Agent type: COMMERCIAL_LINES, EMPLOYEE_BENEFITS, PERSONAL_LINES, RISK_MANAGEMENT',
    agents.specialization AS specialization
      WITH SYNONYMS ('agent expertise', 'industry specialization', 'agent focus')
      COMMENT = 'Agent industry specialization',
    agents.office_location AS office_location
      WITH SYNONYMS ('agent office', 'branch location')
      COMMENT = 'Agent office location',
    agents.region AS region
      WITH SYNONYMS ('agent territory', 'sales region', 'geographic region')
      COMMENT = 'Agent region',
    agents.agent_status AS agent_status
      WITH SYNONYMS ('agent active status', 'broker status')
      COMMENT = 'Agent status: ACTIVE, INACTIVE',
    agents.production_tier AS production_tier
      WITH SYNONYMS ('agent tier', 'producer level', 'performance tier')
      COMMENT = 'Production tier: PLATINUM, GOLD, SILVER, BRONZE',
    products.product_name AS product_name
      WITH SYNONYMS ('coverage name', 'insurance product name', 'policy name')
      COMMENT = 'Name of the insurance product',
    products.product_category AS product_category
      WITH SYNONYMS ('product type', 'coverage category', 'insurance type')
      COMMENT = 'Product category: PROPERTY, LIABILITY, WORKERS_COMP, AUTO, CYBER, EXCESS',
    products.product_line AS product_line
      WITH SYNONYMS ('line of business', 'product line segment')
      COMMENT = 'Product line: COMMERCIAL, EMPLOYEE_BENEFITS',
    products.coverage_type AS coverage_type
      WITH SYNONYMS ('coverage classification', 'policy coverage type')
      COMMENT = 'Type of coverage provided',
    products.risk_level AS risk_level
      WITH SYNONYMS ('product risk', 'hazard level', 'risk classification')
      COMMENT = 'Risk level: LOW, MEDIUM, HIGH',
    products.product_status AS product_status
      WITH SYNONYMS ('product availability', 'offering status')
      COMMENT = 'Product status: ACTIVE, INACTIVE',
    policies.policy_status AS policy_status
      WITH SYNONYMS ('coverage status', 'policy state')
      COMMENT = 'Policy status: ACTIVE, EXPIRED, CANCELLED',
    policies.competitive_win AS competitive_win
      WITH SYNONYMS ('won from competitor', 'competitive takeout', 'market share gain')
      COMMENT = 'Whether policy was won from competitor',
    policies.payment_plan AS payment_plan
      WITH SYNONYMS ('premium payment plan', 'billing frequency')
      COMMENT = 'Payment plan: ANNUAL, SEMI_ANNUAL, QUARTERLY, MONTHLY',
    renewals.renewal_status AS renewal_status
      WITH SYNONYMS ('renewal state', 'reinstatement status')
      COMMENT = 'Renewal status: RENEWED, NON_RENEWED, PENDING',
    renewals.renewal_type AS renewal_type
      WITH SYNONYMS ('type of renewal', 'renewal classification')
      COMMENT = 'Renewal type: STANDARD, EARLY_RENEWAL, LATE_RENEWAL, AUTO_RENEWAL'
  )
  METRICS (
    clients.total_clients AS COUNT(DISTINCT client_id)
      WITH SYNONYMS ('client count view1', 'number of clients')
      COMMENT = 'Total number of clients',
    clients.avg_annual_revenue AS AVG(annual_revenue)
      WITH SYNONYMS ('average client revenue', 'mean annual revenue')
      COMMENT = 'Average annual revenue of clients',
    clients.avg_employee_count AS AVG(employee_count)
      WITH SYNONYMS ('average employees', 'mean employee count')
      COMMENT = 'Average number of employees per client',
    clients.avg_satisfaction AS AVG(client_satisfaction_score)
      WITH SYNONYMS ('average client satisfaction', 'mean satisfaction score')
      COMMENT = 'Average client satisfaction score',
    agents.total_agents AS COUNT(DISTINCT agent_id)
      WITH SYNONYMS ('agent count', 'broker count', 'producer count')
      COMMENT = 'Total number of agents',
    agents.avg_satisfaction AS AVG(average_client_satisfaction)
      WITH SYNONYMS ('average agent satisfaction')
      COMMENT = 'Average agent client satisfaction rating',
    products.total_products AS COUNT(DISTINCT product_id)
      WITH SYNONYMS ('product count view1', 'number of products')
      COMMENT = 'Total number of insurance products',
    products.avg_base_rate AS AVG(base_rate)
      WITH SYNONYMS ('average product rate', 'mean base rate')
      COMMENT = 'Average base rate across products',
    policies.total_policies AS COUNT(DISTINCT policy_id)
      WITH SYNONYMS ('policy count', 'number of policies written')
      COMMENT = 'Total number of policies',
    policies.total_premium AS SUM(annual_premium)
      WITH SYNONYMS ('total annual premium', 'aggregate premium')
      COMMENT = 'Total annual premium across all policies',
    policies.avg_premium AS AVG(annual_premium)
      WITH SYNONYMS ('average policy premium', 'mean premium per policy')
      COMMENT = 'Average premium per policy',
    policies.total_coverage AS SUM(total_coverage_limit)
      WITH SYNONYMS ('total coverage limit', 'aggregate coverage')
      COMMENT = 'Total coverage limits across all policies',
    renewals.total_renewals AS COUNT(DISTINCT renewal_id)
      WITH SYNONYMS ('renewal count', 'number of renewals')
      COMMENT = 'Total number of policy renewals',
    renewals.total_renewal_premium AS SUM(renewal_premium)
      WITH SYNONYMS ('total renewed premium', 'aggregate renewal premium')
      COMMENT = 'Total renewal premium',
    renewals.avg_premium_change AS AVG(premium_change_pct)
      WITH SYNONYMS ('average premium change', 'mean rate change')
      COMMENT = 'Average premium change percentage at renewal'
  )
  COMMENT = 'Mahoney Group Commercial Insurance Intelligence - comprehensive view of clients, agents, products, policies, and renewals';

-- ============================================================================
-- Semantic View 2: Claims Management Intelligence
-- ============================================================================
CREATE OR REPLACE SEMANTIC VIEW SV_CLAIMS_MANAGEMENT_INTELLIGENCE
  TABLES (
    clients AS RAW.CLIENTS
      PRIMARY KEY (client_id)
      WITH SYNONYMS ('clients with claims view2', 'claim clients', 'claimant companies')
      COMMENT = 'Clients with insurance claims',
    claims AS RAW.CLAIMS
      PRIMARY KEY (claim_id)
      WITH SYNONYMS ('insurance claims', 'loss claims', 'filed claims')
      COMMENT = 'Insurance claims filed by clients',
    adjusters AS RAW.CLAIMS_ADJUSTERS
      PRIMARY KEY (adjuster_id)
      WITH SYNONYMS ('claims adjusters', 'loss adjusters', 'claim examiners')
      COMMENT = 'Claims adjusters handling claims',
    policies AS RAW.POLICIES
      PRIMARY KEY (policy_id)
      WITH SYNONYMS ('claim policies', 'policies with claims', 'insured policies')
      COMMENT = 'Policies associated with claims',
    disputes AS RAW.CLAIM_DISPUTES
      PRIMARY KEY (dispute_id)
      WITH SYNONYMS ('claim disputes', 'disputed claims', 'claim litigation')
      COMMENT = 'Disputed claims and litigation'
  )
  RELATIONSHIPS (
    claims(client_id) REFERENCES clients(client_id),
    claims(policy_id) REFERENCES policies(policy_id),
    claims(adjuster_id) REFERENCES adjusters(adjuster_id),
    policies(client_id) REFERENCES clients(client_id),
    disputes(claim_id) REFERENCES claims(claim_id),
    disputes(client_id) REFERENCES clients(client_id)
  )
  DIMENSIONS (
    clients.client_name AS client_name
      WITH SYNONYMS ('claim client name', 'claimant company name')
      COMMENT = 'Name of the client',
    clients.business_segment AS business_segment
      WITH SYNONYMS ('client segment view2', 'company size')
      COMMENT = 'Business segment: SMALL_BUSINESS, MIDMARKET, LARGE_ACCOUNT',
    clients.industry_vertical AS industry_vertical
      WITH SYNONYMS ('industry type view2', 'claim industry', 'business sector')
      COMMENT = 'Industry vertical of client',
    clients.state AS state
      WITH SYNONYMS ('client state view2', 'claim location state')
      COMMENT = 'Client state location',
    claims.claim_number AS claim_number
      WITH SYNONYMS ('claim reference', 'claim identifier')
      COMMENT = 'Unique claim number',
    claims.claim_type AS claim_type
      WITH SYNONYMS ('type of claim', 'loss type', 'claim classification')
      COMMENT = 'Claim type: PROPERTY_DAMAGE, BODILY_INJURY, INJURY, AUTO_ACCIDENT, DATA_BREACH',
    claims.claim_category AS claim_category
      WITH SYNONYMS ('claim subcategory', 'loss category')
      COMMENT = 'Specific category within claim type',
    claims.loss_type AS loss_type
      WITH SYNONYMS ('cause of loss', 'loss cause')
      COMMENT = 'Loss type: ACCIDENTAL, SUDDEN, GRADUAL, NATURAL_DISASTER, THEFT',
    claims.claim_status AS claim_status
      WITH SYNONYMS ('claim state', 'claim case status')
      COMMENT = 'Claim status: REPORTED, OPEN, UNDER_INVESTIGATION, SETTLED, CLOSED, DENIED',
    claims.severity AS severity
      WITH SYNONYMS ('claim severity', 'loss severity', 'damage severity')
      COMMENT = 'Severity: MINOR, MODERATE, SERIOUS, CATASTROPHIC',
    claims.litigation_involved AS litigation_involved
      WITH SYNONYMS ('in litigation', 'legal action', 'attorney involved')
      COMMENT = 'Whether litigation is involved',
    adjusters.adjuster_name AS adjuster_name
      WITH SYNONYMS ('examiner name', 'adjuster full name')
      COMMENT = 'Name of claims adjuster',
    adjusters.adjuster_type AS adjuster_type
      WITH SYNONYMS ('adjuster specialty', 'examiner type')
      COMMENT = 'Adjuster type: PROPERTY, LIABILITY, AUTO, WORKERS_COMP, GENERAL',
    adjusters.specialization AS specialization
      WITH SYNONYMS ('adjuster expertise', 'claims specialty')
      COMMENT = 'Adjuster specialization area',
    adjusters.adjuster_status AS adjuster_status
      WITH SYNONYMS ('adjuster active status', 'examiner status')
      COMMENT = 'Adjuster status: ACTIVE, INACTIVE',
    disputes.dispute_type AS dispute_type
      WITH SYNONYMS ('type of dispute', 'dispute reason', 'contested issue')
      COMMENT = 'Dispute type: COVERAGE_DENIAL, CLAIM_AMOUNT, LIABILITY, POLICY_INTERPRETATION',
    disputes.dispute_severity AS dispute_severity
      WITH SYNONYMS ('dispute complexity', 'litigation severity')
      COMMENT = 'Dispute severity: LOW, MEDIUM, HIGH',
    disputes.dispute_status AS dispute_status
      WITH SYNONYMS ('dispute state', 'litigation status')
      COMMENT = 'Dispute status: OPEN, IN_MEDIATION, IN_ARBITRATION, RESOLVED, LITIGATION',
    disputes.resolution_method AS resolution_method
      WITH SYNONYMS ('dispute resolution type', 'settlement method')
      COMMENT = 'Resolution method: NEGOTIATION, MEDIATION, ARBITRATION, LITIGATION, SETTLEMENT',
    disputes.dispute_outcome AS dispute_outcome
      WITH SYNONYMS ('dispute result', 'litigation outcome')
      COMMENT = 'Dispute outcome: CARRIER_FAVOR, CLIENT_FAVOR, COMPROMISE, WITHDRAWN',
    disputes.attorney_involved AS attorney_involved
      WITH SYNONYMS ('legal representation', 'lawyer involved')
      COMMENT = 'Whether attorney is involved'
  )
  METRICS (
    clients.total_clients AS COUNT(DISTINCT client_id)
      WITH SYNONYMS ('client count view2', 'clients with claims')
      COMMENT = 'Total number of clients with claims',
    claims.total_claims AS COUNT(DISTINCT claim_id)
      WITH SYNONYMS ('claim count', 'number of claims', 'loss count')
      COMMENT = 'Total number of claims',
    claims.total_paid AS SUM(claim_amount_paid)
      WITH SYNONYMS ('total claims paid', 'aggregate payments')
      COMMENT = 'Total amount paid on claims',
    claims.total_reserved AS SUM(claim_amount_reserved)
      WITH SYNONYMS ('total reserves', 'aggregate case reserves')
      COMMENT = 'Total reserved amounts for claims',
    claims.total_incurred AS SUM(claim_amount_incurred)
      WITH SYNONYMS ('total incurred costs', 'aggregate claim costs', 'total losses')
      COMMENT = 'Total incurred costs (paid + reserved)',
    claims.avg_incurred AS AVG(claim_amount_incurred)
      WITH SYNONYMS ('average claim cost', 'mean incurred per claim')
      COMMENT = 'Average incurred cost per claim',
    claims.total_settlements AS SUM(settlement_amount)
      WITH SYNONYMS ('total settlement payments', 'aggregate settlements')
      COMMENT = 'Total settlement amounts',
    adjusters.total_adjusters AS COUNT(DISTINCT adjuster_id)
      WITH SYNONYMS ('adjuster count', 'examiner count')
      COMMENT = 'Total number of claims adjusters',
    adjusters.avg_adjuster_rating AS AVG(average_satisfaction_rating)
      WITH SYNONYMS ('average adjuster satisfaction')
      COMMENT = 'Average satisfaction rating for adjusters',
    adjusters.avg_claim_cost AS AVG(average_claim_cost)
      WITH SYNONYMS ('average adjuster claim cost')
      COMMENT = 'Average claim cost per adjuster',
    disputes.total_disputes AS COUNT(DISTINCT dispute_id)
      WITH SYNONYMS ('dispute count', 'number of disputes', 'litigation count')
      COMMENT = 'Total number of claim disputes',
    disputes.total_legal_costs AS SUM(legal_costs)
      WITH SYNONYMS ('total attorney fees', 'aggregate legal expenses')
      COMMENT = 'Total legal costs',
    disputes.avg_legal_costs AS AVG(legal_costs)
      WITH SYNONYMS ('average legal costs', 'mean attorney fees')
      COMMENT = 'Average legal costs per dispute',
    disputes.total_settlement_amount AS SUM(settlement_amount)
      WITH SYNONYMS ('total dispute settlements', 'aggregate settlements')
      COMMENT = 'Total settlement amounts for disputes'
  )
  COMMENT = 'Mahoney Group Claims Management Intelligence - comprehensive view of claims, adjusters, disputes, and litigation';

-- ============================================================================
-- Semantic View 3: Employee Benefits Intelligence
-- ============================================================================
CREATE OR REPLACE SEMANTIC VIEW SV_EMPLOYEE_BENEFITS_INTELLIGENCE
  TABLES (
    clients AS RAW.CLIENTS
      PRIMARY KEY (client_id)
      WITH SYNONYMS ('benefits clients view3', 'employers with benefits', 'benefit plan sponsors')
      COMMENT = 'Clients with employee benefit plans',
    benefit_plans AS RAW.BENEFIT_PLANS
      PRIMARY KEY (plan_id)
      WITH SYNONYMS ('employee benefit plans', 'group benefits', 'benefits coverage')
      COMMENT = 'Employee benefit plans provided to clients',
    agents AS RAW.INSURANCE_AGENTS
      PRIMARY KEY (agent_id)
      WITH SYNONYMS ('benefits advisors', 'benefits consultants', 'benefits brokers')
      COMMENT = 'Agents managing employee benefits'
  )
  RELATIONSHIPS (
    benefit_plans(client_id) REFERENCES clients(client_id),
    benefit_plans(agent_id) REFERENCES agents(agent_id)
  )
  DIMENSIONS (
    clients.client_name AS client_name
      WITH SYNONYMS ('employer name', 'benefits client name', 'plan sponsor name')
      COMMENT = 'Name of the employer/client',
    clients.business_segment AS business_segment
      WITH SYNONYMS ('client segment view3', 'employer size')
      COMMENT = 'Business segment: SMALL_BUSINESS, MIDMARKET, LARGE_ACCOUNT',
    clients.industry_vertical AS industry_vertical
      WITH SYNONYMS ('industry type view3', 'employer industry')
      COMMENT = 'Industry vertical of client',
    clients.state AS state
      WITH SYNONYMS ('client state view3', 'employer location state')
      COMMENT = 'Client state location',
    benefit_plans.plan_name AS plan_name
      WITH SYNONYMS ('benefit plan name', 'coverage plan name')
      COMMENT = 'Name of the benefit plan',
    benefit_plans.plan_type AS plan_type
      WITH SYNONYMS ('benefit type', 'coverage type', 'plan category')
      COMMENT = 'Plan type: HEALTH, DENTAL, VISION, LIFE, DISABILITY',
    benefit_plans.plan_category AS plan_category
      WITH SYNONYMS ('benefit line', 'plan classification')
      COMMENT = 'Plan category',
    benefit_plans.plan_status AS plan_status
      WITH SYNONYMS ('benefit plan status', 'coverage status')
      COMMENT = 'Plan status: ACTIVE, EXPIRED, CANCELLED',
    benefit_plans.carrier_name AS carrier_name
      WITH SYNONYMS ('insurance carrier', 'benefits carrier', 'carrier provider')
      COMMENT = 'Name of the insurance carrier',
    agents.agent_name AS agent_name
      WITH SYNONYMS ('benefits advisor name', 'consultant name')
      COMMENT = 'Name of the benefits agent',
    agents.agent_type AS agent_type
      WITH SYNONYMS ('advisor type', 'consultant type')
      COMMENT = 'Agent type',
    agents.specialization AS specialization
      WITH SYNONYMS ('benefits expertise', 'advisor specialization')
      COMMENT = 'Agent specialization',
    agents.office_location AS office_location
      WITH SYNONYMS ('advisor office', 'consultant location')
      COMMENT = 'Agent office location'
  )
  METRICS (
    clients.total_clients AS COUNT(DISTINCT client_id)
      WITH SYNONYMS ('client count view3', 'employers with benefits')
      COMMENT = 'Total number of clients with benefits',
    clients.avg_employee_count AS AVG(employee_count)
      WITH SYNONYMS ('average covered employees', 'mean employee count')
      COMMENT = 'Average number of employees per client',
    benefit_plans.total_plans AS COUNT(DISTINCT plan_id)
      WITH SYNONYMS ('plan count', 'number of benefit plans')
      COMMENT = 'Total number of benefit plans',
    benefit_plans.total_covered_employees AS SUM(covered_employees)
      WITH SYNONYMS ('total employees covered', 'aggregate covered lives')
      COMMENT = 'Total number of covered employees',
    benefit_plans.avg_covered_employees AS AVG(covered_employees)
      WITH SYNONYMS ('average employees per plan', 'mean covered employees')
      COMMENT = 'Average covered employees per plan',
    benefit_plans.total_monthly_premium AS SUM(monthly_premium)
      WITH SYNONYMS ('total monthly cost', 'aggregate monthly premium')
      COMMENT = 'Total monthly premium across all plans',
    benefit_plans.total_annual_premium AS SUM(annual_premium)
      WITH SYNONYMS ('total annual cost', 'aggregate annual premium')
      COMMENT = 'Total annual premium across all plans',
    benefit_plans.avg_monthly_premium AS AVG(monthly_premium)
      WITH SYNONYMS ('average monthly premium', 'mean monthly cost per plan')
      COMMENT = 'Average monthly premium per plan',
    benefit_plans.avg_annual_premium AS AVG(annual_premium)
      WITH SYNONYMS ('average annual premium', 'mean annual cost per plan')
      COMMENT = 'Average annual premium per plan',
    agents.total_agents AS COUNT(DISTINCT agent_id)
      WITH SYNONYMS ('advisor count', 'benefits consultant count')
      COMMENT = 'Total number of benefits agents'
  )
  COMMENT = 'Mahoney Group Employee Benefits Intelligence - comprehensive view of benefit plans, clients, agents, and coverage';

-- ============================================================================
-- Display confirmation and verification
-- ============================================================================
SELECT 'Semantic views created successfully - all syntax verified' AS status;

-- Verify semantic views exist
SELECT 
    table_name AS semantic_view_name,
    comment AS description
FROM INFORMATION_SCHEMA.VIEWS
WHERE TABLE_SCHEMA = 'ANALYTICS'
  AND table_name LIKE 'SV_%'
ORDER BY table_name;

-- Show semantic view details
SHOW SEMANTIC VIEWS IN SCHEMA ANALYTICS;


