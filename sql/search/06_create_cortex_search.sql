-- ============================================================================
-- Mahoney Group Intelligence Agent - Cortex Search Service Setup
-- ============================================================================
-- Purpose: Create unstructured data tables and Cortex Search services for
--          claim notes, policy documents, and loss control reports
-- Syntax verified against: https://docs.snowflake.com/en/sql-reference-commands
-- ============================================================================

USE DATABASE MAHONEY_GROUP_INTELLIGENCE;
USE SCHEMA RAW;
USE WAREHOUSE MAHONEY_WH;

-- ============================================================================
-- Step 1: Create table for claim notes (unstructured text data)
-- ============================================================================
CREATE OR REPLACE TABLE CLAIM_NOTES (
    note_id VARCHAR(30) PRIMARY KEY,
    claim_id VARCHAR(30),
    client_id VARCHAR(20),
    adjuster_id VARCHAR(20),
    note_text VARCHAR(16777216) NOT NULL,
    note_type VARCHAR(50),
    note_date TIMESTAMP_NTZ NOT NULL,
    claim_type VARCHAR(50),
    claim_category VARCHAR(50),
    resolution_achieved BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (claim_id) REFERENCES CLAIMS(claim_id),
    FOREIGN KEY (client_id) REFERENCES CLIENTS(client_id),
    FOREIGN KEY (adjuster_id) REFERENCES CLAIMS_ADJUSTERS(adjuster_id)
);

-- ============================================================================
-- Step 2: Create table for policy documents
-- ============================================================================
CREATE OR REPLACE TABLE POLICY_DOCUMENTS (
    document_id VARCHAR(30) PRIMARY KEY,
    policy_id VARCHAR(30),
    client_id VARCHAR(20),
    document_title VARCHAR(500) NOT NULL,
    document_content VARCHAR(16777216) NOT NULL,
    document_type VARCHAR(50),
    product_category VARCHAR(50),
    coverage_type VARCHAR(100),
    state VARCHAR(50),
    effective_date DATE,
    version VARCHAR(20),
    tags VARCHAR(500),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (policy_id) REFERENCES POLICIES(policy_id),
    FOREIGN KEY (client_id) REFERENCES CLIENTS(client_id)
);

-- ============================================================================
-- Step 3: Create table for loss control reports
-- ============================================================================
CREATE OR REPLACE TABLE LOSS_CONTROL_REPORTS (
    report_id VARCHAR(30) PRIMARY KEY,
    client_id VARCHAR(20) NOT NULL,
    service_id VARCHAR(30),
    report_title VARCHAR(500) NOT NULL,
    report_content VARCHAR(16777216) NOT NULL,
    report_type VARCHAR(50),
    industry_vertical VARCHAR(50),
    risk_area VARCHAR(100),
    priority_level VARCHAR(20),
    recommendations_count NUMBER(5,0),
    report_date TIMESTAMP_NTZ NOT NULL,
    consultant_name VARCHAR(200),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (client_id) REFERENCES CLIENTS(client_id),
    FOREIGN KEY (service_id) REFERENCES LOSS_CONTROL_SERVICES(service_id)
);

-- ============================================================================
-- Step 4: Enable change tracking (required for Cortex Search)
-- ============================================================================
ALTER TABLE CLAIM_NOTES SET CHANGE_TRACKING = TRUE;
ALTER TABLE POLICY_DOCUMENTS SET CHANGE_TRACKING = TRUE;
ALTER TABLE LOSS_CONTROL_REPORTS SET CHANGE_TRACKING = TRUE;

-- ============================================================================
-- Step 5: Generate sample claim notes
-- ============================================================================
INSERT INTO CLAIM_NOTES
SELECT
    'NOTE' || LPAD(SEQ4(), 10, '0') AS note_id,
    c.claim_id,
    c.client_id,
    c.adjuster_id,
    CASE (ABS(RANDOM()) % 20)
        WHEN 0 THEN 'Initial claim report received from ' || cl.client_name || '. Claimant reports ' || c.claim_type || ' on ' || TO_CHAR(c.incident_date, 'MM/DD/YYYY') || '. First notice of loss documented. Preliminary investigation commenced. Reserve set at $' || COALESCE(c.claim_amount_reserved, 0)::VARCHAR || '. Adjuster assigned and site inspection scheduled for next week. Will coordinate with client risk manager. Client has good claims history and cooperative relationship with Mahoney Group.'
        WHEN 1 THEN 'Site inspection completed at ' || cl.client_name || ' premises. ' || COALESCE(c.claim_category, 'Property') || ' damage assessed. Photos documented. Witness statements collected from 3 employees. Liability appears clear - client accepts responsibility. Estimating total loss at approximately $' || COALESCE(c.claim_amount_incurred, 0)::VARCHAR || '. Coverage confirmed under policy. Repair vendors contacted. Client requesting expedited settlement to minimize business interruption. Recommend settlement approval.'
        WHEN 2 THEN 'Complex claim involving ' || c.claim_type || ' at ' || cl.client_name || '. Multiple parties potentially liable. Detailed investigation required. Hired independent investigator to review incident. Subrogation potential identified - third party contractor may bear partial responsibility. Legal counsel consulted. Client concerned about reputation impact. Implementing enhanced communication plan. Media inquiries received and directed to corporate communications. Reserve increased to $' || COALESCE(c.claim_amount_reserved, 0)::VARCHAR || ' pending investigation completion.'
        WHEN 3 THEN 'Settlement negotiations ongoing with ' || cl.client_name || '. Initial demand received for $' || (COALESCE(c.claim_amount_incurred, 0) * 1.5)::NUMBER(13,2)::VARCHAR || '. Our evaluation supports settlement at $' || COALESCE(c.claim_amount_incurred, 0)::VARCHAR || '. Multiple rounds of negotiation completed. Mediation scheduled for next month if agreement not reached. Attorney representing claimant. Client authorized settlement up to policy limits. Both parties motivated to resolve. Recommend settlement at $' || (COALESCE(c.claim_amount_incurred, 0) * 1.1)::NUMBER(13,2)::VARCHAR || ' to avoid litigation costs.'
        WHEN 4 THEN 'Property damage claim at ' || cl.client_name || ' resolved successfully. Total paid: $' || COALESCE(c.claim_amount_paid, 0)::VARCHAR || '. Client extremely satisfied with claims handling and turnaround time. Repairs completed ahead of schedule. Business interruption minimized. No coverage disputes. Claim closed with positive outcome. Client expressed appreciation for Mahoney Group service. Adjuster performance excellent. Loss control team consulted on prevention measures. Implemented recommendations to prevent future similar losses.'
        WHEN 5 THEN 'Coverage dispute on ' || c.claim_type || ' claim for ' || cl.client_name || '. Claimant alleges coverage under policy, carrier questions whether loss falls within policy period. Policy exclusion may apply for ' || COALESCE(c.claim_category, 'this claim type') || '. Detailed policy interpretation required. Coverage counsel retained. Reservation of rights letter sent. Client frustrated with delay. Maintaining regular communication. Independent coverage opinion obtained supporting denial. Claimant has hired attorney. Anticipate litigation. Defense costs mounting - currently $' || (COALESCE(c.claim_amount_incurred, 0) * 0.15)::NUMBER(12,2)::VARCHAR || ' in legal fees.'
        WHEN 6 THEN 'Large loss claim at ' || cl.client_name || ' - catastrophic ' || c.claim_type || '. Total incurred: $' || COALESCE(c.claim_amount_incurred, 0)::VARCHAR || '. Multiple adjusters assigned. Claims team established. Daily status updates to client and underwriting. Excess carriers notified. Forensic investigation completed. Causation established. Business interruption coverage triggered. Working with client on interim operating facilities. Public adjuster representing insured. Coverage counsel engaged. Settlement authority requested from excess carriers. Complex multiparty claim requiring careful coordination.'
        WHEN 7 THEN 'Liability claim filed against ' || cl.client_name || ' alleging ' || COALESCE(c.claim_category, 'liability') || '. Claimant seeking damages for injuries sustained. Hired defense counsel. Discovery process initiated. Depositions scheduled. Client concerned about potential verdict exposure. Defendant has strong defense based on comparative negligence. Expert witnesses retained for both medical and liability opinions. Settlement discussions commenced. Plaintiff demand: $' || (COALESCE(c.claim_amount_incurred, 0) * 2)::NUMBER(13,2)::VARCHAR || '. Defense evaluation: $' || COALESCE(c.claim_amount_incurred, 0)::VARCHAR || '. Recommend attempting settlement at mediation.'
        WHEN 8 THEN 'Auto liability claim involving ' || cl.client_name || ' commercial vehicle. Driver citations issued by police. Liability accepted. Claimant injuries include soft tissue damage. Medical treatment ongoing. Bills submitted totaling $' || (COALESCE(c.claim_amount_incurred, 0) * 0.6)::NUMBER(12,2)::VARCHAR || '. Independent medical exam scheduled to assess injury extent and causation. Treatment appears reasonable and necessary. Working directly with claimant attorney on settlement. Lost wage claim submitted and verified. Expect settlement within policy limits. No bad faith concerns. Client fleet safety reviewed by loss control.'
        WHEN 9 THEN 'Workers compensation claim for ' || cl.client_name || ' employee. Back injury reported from lifting incident. Medical only status currently. Total medical: $' || (COALESCE(c.claim_amount_incurred, 0) * 0.4)::NUMBER(12,2)::VARCHAR || '. Employee returned to modified duty within 2 weeks. Employer very accommodating with restrictions. Physical therapy completed. No lost time benefits paid due to modified duty availability. Claim closing as medical only. Positive outcome demonstrating value of employer modified duty program. Nurse case manager assisted with return to work. Client safety program effective.'
        WHEN 10 THEN 'Cyber claim for ' || cl.client_name || ' - data breach incident. Forensic IT investigation completed. Approximately 5,000 records potentially compromised. Notification requirements triggered under state law. Credit monitoring services arranged for affected individuals. Public relations consultant engaged. Media coverage minimal. Regulatory investigation by state attorney general. Client IT security enhanced post-incident. Coverage under cyber policy confirmed. Total incurred costs: $' || COALESCE(c.claim_amount_incurred, 0)::VARCHAR || ' including forensic investigation, notification costs, credit monitoring, legal fees, and regulatory defense.'
        WHEN 11 THEN 'Product liability claim against ' || cl.client_name || '. Claimant alleges injury from defective product. Manufacturer component analysis completed. Product recall not required per testing. Independent testing shows product met all specifications. Claim appears unfounded based on investigation. User error likely cause of incident. Defense counsel recommends vigorous defense. Discovery supports defense position. Plaintiff expert opinion weak. Settlement not warranted. Preparing for trial if necessary. Client confident in product quality and safety. Similar claims not identified in product history.'
        WHEN 12 THEN 'Environmental claim at ' || cl.client_name || ' facility. Alleged pollution from historical operations. State environmental agency investigation ongoing. Remediation plan required. Environmental consultant engaged. Phase II environmental assessment completed. Contamination confirmed in soil and groundwater. Coverage questions under pollution liability policy. Long tail exposure - damages will develop over time. Reserved at $' || COALESCE(c.claim_amount_reserved, 0)::VARCHAR || ' subject to significant revision pending remediation cost estimates. Cooperation from client excellent. Complex environmental claim requiring specialized expertise.'
        WHEN 13 THEN 'Professional liability claim against ' || cl.client_name || '. Client allegations of errors and omissions in services provided. Detailed factual investigation completed. Client communications reviewed. Engagement letter and scope of work clearly defined. Services performed within professional standards. Expert witness retained supporting standard of care met. Claimant damages appear overstated. Settlement discussions ongoing. Carrier recommendation: settle for nuisance value to avoid defense costs. Defense costs currently $' || (COALESCE(c.claim_amount_incurred, 0) * 0.25)::NUMBER(12,2)::VARCHAR || '. Client reputation important consideration in settlement decision.'
        WHEN 14 THEN 'Builders risk claim for ' || cl.client_name || ' construction project. Storm damage to building under construction. Temporary protection inadequate. Contractor responsibility vs. builder risk coverage issue. Policy interpretation required. Coverage counsel consulted. Investigation shows adequate temporary protection was in place per policy requirements. Coverage confirmed. Repair estimates obtained from multiple contractors. Project timeline impacted - delay damages claimed. Extra expense coverage applies. Total covered loss: $' || COALESCE(c.claim_amount_incurred, 0)::VARCHAR || '. Claim settled and project completion on track.'
        WHEN 15 THEN 'D&O claim involving ' || cl.client_name || ' board of directors. Shareholder derivative action filed. Allegations of breach of fiduciary duty. Securities counsel retained for defense. Complex corporate governance issues. Board acted on advice of counsel and financial advisors. Defense appears strong. Discovery extensive. Depositions of board members completed. Plaintiff settlement demand: $' || (COALESCE(c.claim_amount_incurred, 0) * 3)::NUMBER(13,2)::VARCHAR || '. Coverage under D&O policy confirmed. Defense costs significant. Recommend settlement discussions at appropriate time. Board concerned about reputation and business impact.'
        WHEN 16 THEN 'Denied claim for ' || cl.client_name || ' - policy exclusion applies. Detailed coverage analysis completed. Late notice issue - claim reported ' || DATEDIFF('day', c.incident_date, c.report_date) || ' days after occurrence. Prejudice to carrier documented. Coverage counsel opinion supports denial. Denial letter sent with detailed explanation. Client disagrees with denial and has hired coverage counsel. Bad faith allegations threatened. File extensively documented to support denial decision. Anticipate coverage litigation. Defense costs being incurred under reservation of rights. Denial position appears defensible.'
        WHEN 17 THEN 'Subrogation recovery on ' || cl.client_name || ' claim. Paid out $' || COALESCE(c.claim_amount_paid, 0)::VARCHAR || ' to insured. Third party clearly liable. Subrogation demand sent to responsible party and their carrier. Negotiations ongoing. Recovery potential: 75-100% of paid amount. Insured cooperation excellent. Evidence well documented. Liability clear based on police report and witness statements. Expect settlement of subrogation claim within 90 days. Will reimburse client deductible from recovery proceeds. Successful subrogation supports client retention and renewal terms.'
        WHEN 18 THEN 'Disputed claim for ' || cl.client_name || ' now in litigation. Complaint filed in Superior Court. Answer submitted denying allegations. Discovery schedule established. Both parties engaged in settlement discussions through mediation. Mediator neutral evaluation: $' || (COALESCE(c.claim_amount_incurred, 0) * 0.8)::NUMBER(12,2)::VARCHAR || '. Carrier willing to settle at mediator evaluation. Plaintiff countered at $' || (COALESCE(c.claim_amount_incurred, 0) * 1.2)::NUMBER(13,2)::VARCHAR || '. Additional mediation session scheduled. Client concerned about trial exposure and costs. Defense costs approaching $' || (COALESCE(c.claim_amount_incurred, 0) * 0.3)::NUMBER(12,2)::VARCHAR || '. Recommend settlement within authority to avoid further expense and uncertainty of trial.'
        WHEN 19 THEN 'Claim closed - full and final release obtained. ' || cl.client_name || ' claim concluded successfully. Total paid: $' || COALESCE(c.claim_amount_paid, 0)::VARCHAR || ' which is ' || ROUND(((COALESCE(c.claim_amount_paid, 0) / NULLIF(COALESCE(c.claim_amount_reserved, 1), 0)) * 100), 2)::VARCHAR || '% of initial reserve. No coverage disputes. No bad faith allegations. Client satisfied with outcome. Adjuster file quality excellent. Claim handling time: ' || COALESCE(DATEDIFF('day', c.report_date, c.settlement_date), 0)::VARCHAR || ' days. Meets all KPI targets. File closed and archived. Positive outcome for all parties. Client relationship strengthened through professional claims handling.'
        ELSE 'Claim note for ' || cl.client_name || ' regarding ' || c.claim_type || ' claim number ' || c.claim_number || '. Status: ' || COALESCE(c.claim_status, 'PENDING') || '. Adjuster assigned. Documentation in progress.'
    END AS note_text,
    ARRAY_CONSTRUCT('ADJUSTER_NOTE', 'INVESTIGATION_REPORT', 'SETTLEMENT_DISCUSSION', 'COVERAGE_ANALYSIS', 'SITE_INSPECTION')[UNIFORM(0, 4, RANDOM())] AS note_type,
    c.incident_date AS note_date,
    c.claim_type,
    c.claim_category,
    c.claim_status = 'CLOSED' AS resolution_achieved,
    c.created_at AS created_at
FROM RAW.CLAIMS c
JOIN RAW.CLIENTS cl ON c.client_id = cl.client_id
WHERE c.claim_id IS NOT NULL
LIMIT 30000;

-- ============================================================================
-- Step 6: Generate sample policy documents
-- ============================================================================
INSERT INTO POLICY_DOCUMENTS
SELECT
    'DOC' || LPAD(SEQ4(), 10, '0') AS document_id,
    NULL AS policy_id,
    NULL AS client_id,
    CASE (UNIFORM(0, 9, RANDOM()))
        WHEN 0 THEN 'Commercial General Liability Policy Form - Standard Coverage'
        WHEN 1 THEN 'Workers Compensation Policy - State Specific Coverage'
        WHEN 2 THEN 'Cyber Liability Insurance Policy - Data Breach Protection'
        WHEN 3 THEN 'Directors and Officers Liability Policy - Executive Coverage'
        WHEN 4 THEN 'Professional Liability Errors and Omissions Policy'
        WHEN 5 THEN 'Employment Practices Liability Insurance Policy'
        WHEN 6 THEN 'Commercial Property Insurance Policy - Building and Contents'
        WHEN 7 THEN 'Business Auto Liability Policy - Fleet Coverage'
        WHEN 8 THEN 'Umbrella Excess Liability Policy - Additional Limits'
        ELSE 'General Liability Insurance Policy - Standard Form'
    END AS document_title,
    CASE (UNIFORM(0, 9, RANDOM()))
        WHEN 0 THEN 'COMMERCIAL GENERAL LIABILITY INSURANCE POLICY. This policy provides coverage for bodily injury, property damage, personal injury and advertising injury. Coverage is provided on an occurrence basis. The policy includes general aggregate limits, products-completed operations aggregate, personal and advertising injury limits, each occurrence limits, fire damage limits, and medical expense limits. Policy includes standard exclusions for expected or intended injury, contractual liability, liquor liability, workers compensation, pollution, aircraft and watercraft. Insured duties include providing notice of occurrence or claim, cooperating with investigation and defense, and not making voluntary payments or assuming obligations. This is a claims-made policy requiring claims to be reported during the policy period.'
        WHEN 1 THEN 'WORKERS COMPENSATION AND EMPLOYERS LIABILITY INSURANCE. This policy provides workers compensation insurance as required by state law and employers liability insurance. Part One covers benefits required by workers compensation law. Part Two provides employers liability coverage for lawsuits by employees. Coverage applies to bodily injury by accident or disease arising out of employment. Policy limits include per accident, disease policy limit, and disease per employee. Standard exclusions apply including intentional injury, liability assumed under contract, punitive damages, and employment-related practices. Premium based on payroll with different rates for job classifications.'
        WHEN 2 THEN 'CYBER LIABILITY AND DATA BREACH INSURANCE. This policy provides coverage for network security failures, privacy breaches, technology errors and omissions. First party coverages include breach response costs, forensic investigation, notification costs, credit monitoring, public relations, cyber extortion, business interruption, and data restoration. Third party coverages include privacy liability, network security liability, and media liability. Policy includes sublimits for various first party coverages. Minimum security requirements must be maintained including multi-factor authentication, encryption, regular backups, anti-virus software, and employee training. Claims must be reported within 72 hours of discovery.'
        WHEN 3 THEN 'DIRECTORS AND OFFICERS LIABILITY INSURANCE. This policy provides coverage for wrongful acts by directors and officers in their capacity as such. Coverage includes defense costs, settlements, and judgments. Policy covers derivative actions, securities claims, employment practices claims, and regulatory proceedings. Standard exclusions include intentional dishonest acts, personal profit, illegal remuneration, and bodily injury. Policy includes advancement of defense costs. Coverage is on a claims-made basis requiring reporting during policy period or extended reporting period. Policy includes provisions for allocation between insured and non-insured matters.'
        WHEN 4 THEN 'PROFESSIONAL LIABILITY ERRORS AND OMISSIONS INSURANCE. This policy provides coverage for claims arising from professional services including negligence, errors, omissions, and breach of professional duty. Coverage includes defense costs and indemnity for settlements and judgments. Policy is claims-made requiring claim to be first made and reported during policy period. Standard exclusions include bodily injury, property damage, intentional acts, criminal acts, and employment practices. Prior acts coverage available subject to prior acts date. Tail coverage available for extended reporting period. Insured must maintain minimum professional standards and continuing education requirements.'
        WHEN 5 THEN 'EMPLOYMENT PRACTICES LIABILITY INSURANCE. This policy provides coverage for employment-related claims including wrongful termination, discrimination, harassment, retaliation, failure to promote, and wage and hour violations. Coverage includes defense costs, settlements, and judgments. Policy covers claims brought by employees, former employees, and job applicants. Standard exclusions include bodily injury, violation of laws including WARN Act, intentional acts, and wage and hour claims in certain states. Policy requires implementation of employment practices policies and employee training. Claims made basis requiring reporting during policy period.'
        WHEN 6 THEN 'COMMERCIAL PROPERTY INSURANCE POLICY. This policy provides coverage for direct physical loss or damage to covered property. Covered property includes buildings, business personal property, and personal property of others. Coverage provided on replacement cost or actual cash value basis. Standard perils covered include fire, lightning, windstorm, hail, explosion, aircraft, vehicles, smoke, vandalism, sprinkler leakage, and others. Standard exclusions include flood, earthquake, wear and tear, mechanical breakdown, and nuclear hazard. Policy includes coinsurance provision requiring minimum insurance to value. Additional coverages include debris removal, preservation of property, fire department service charge.'
        WHEN 7 THEN 'BUSINESS AUTO LIABILITY INSURANCE POLICY. This policy provides coverage for liability arising from the ownership, maintenance, or use of covered autos. Coverage includes bodily injury and property damage liability. Policy covers owned autos, hired autos, and non-owned autos. Coverage provided on occurrence basis. Standard exclusions include intentional injury, workers compensation, property owned or transported, and racing. Policy includes provisions for uninsured and underinsured motorist coverage. Medical payments coverage available. Physical damage coverage available for collision and comprehensive perils. Fleet safety program required for large fleets.'
        WHEN 8 THEN 'UMBRELLA EXCESS LIABILITY INSURANCE. This policy provides additional liability coverage in excess of underlying policies including general liability, auto liability, and employers liability. Coverage follows form of underlying policies with some differences. Policy includes drop down coverage when underlying limits exhausted. Standard exclusions include intentional acts, pollution, professional liability, and employment practices in some cases. Policy requires maintenance of underlying insurance with specified limits. Self-insured retention applies to claims not covered by underlying insurance. Policy coordination provisions address how coverage applies with underlying policies.'
        ELSE 'GENERAL LIABILITY INSURANCE POLICY. This insurance policy provides coverage for various liability exposures. Coverage includes bodily injury liability and property damage liability. Policy provides defense and indemnity for covered claims. Standard policy terms, conditions, and exclusions apply. Insured must comply with policy conditions including notice provisions, cooperation requirements, and other duties. Policy limits are specified in declarations. Premium based on exposure basis and rating factors. This is a sample policy document for illustrative purposes showing standard insurance policy language and structure.'
    END AS document_content,
    'POLICY_FORM' AS document_type,
    ARRAY_CONSTRUCT('LIABILITY', 'WORKERS_COMP', 'CYBER', 'DIRECTORS_OFFICERS', 'PROFESSIONAL', 'EMPLOYMENT', 'PROPERTY', 'AUTO', 'UMBRELLA', 'GENERAL')[UNIFORM(0, 9, RANDOM())] AS product_category,
    ARRAY_CONSTRUCT('General Liability', 'Workers Compensation', 'Cyber & Data Breach', 'D&O', 'Professional Liability', 'Employment Practices', 'Commercial Property', 'Business Auto', 'Umbrella', 'Package')[UNIFORM(0, 9, RANDOM())] AS coverage_type,
    ARRAY_CONSTRUCT('AZ', 'CA', 'TX', 'NY', 'FL', NULL)[UNIFORM(0, 5, RANDOM())] AS state,
    NULL AS effective_date,
    'v1.0' AS version,
    'insurance policy, commercial insurance, business insurance, liability coverage' AS tags,
    CURRENT_TIMESTAMP() AS created_at
FROM TABLE(GENERATOR(ROWCOUNT => 10));

-- ============================================================================
-- Step 7: Generate sample loss control reports
-- ============================================================================
INSERT INTO LOSS_CONTROL_REPORTS
SELECT
    'RPT' || LPAD(SEQ4(), 10, '0') AS report_id,
    lcs.client_id,
    lcs.service_id,
    CASE (UNIFORM(0, 9, RANDOM()))
        WHEN 0 THEN 'Comprehensive Workplace Safety Assessment - ' || c.client_name
        WHEN 1 THEN 'Fire Safety and Emergency Preparedness Evaluation - ' || c.client_name
        WHEN 2 THEN 'Ergonomic Risk Assessment - ' || c.client_name
        WHEN 3 THEN 'Slip Trip and Fall Hazard Analysis - ' || c.client_name
        WHEN 4 THEN 'Warehouse Safety Inspection Report - ' || c.client_name
        WHEN 5 THEN 'Construction Site Safety Audit - ' || c.client_name
        WHEN 6 THEN 'Restaurant Kitchen Safety Review - ' || c.client_name
        WHEN 7 THEN 'Healthcare Facility Safety Assessment - ' || c.client_name
        WHEN 8 THEN 'Office Safety and Ergonomics Evaluation - ' || c.client_name
        WHEN 9 THEN 'Manufacturing Equipment Safety Review - ' || c.client_name
        ELSE 'General Risk Assessment Report - ' || c.client_name
    END AS report_title,
    'WORKPLACE SAFETY ASSESSMENT REPORT. Client: ' || c.client_name || 
    '. Industry: ' || COALESCE(c.industry_vertical, 'General') || 
    '. Location: ' || COALESCE(c.city, 'Unknown') || ', ' || COALESCE(c.state, 'N/A') || 
    '. Assessment Date: ' || TO_CHAR(lcs.service_date, 'MM/DD/YYYY') || 
    '. Consultant: ' || COALESCE(lcs.consultant_name, 'Risk Consultant') || 
    '. EXECUTIVE SUMMARY: A comprehensive workplace safety assessment was conducted at the facility. The assessment included interviews with management and employees, review of safety policies and procedures, inspection of physical premises, examination of injury and illness records, and evaluation of safety training programs. Overall, the facility demonstrates a commitment to workplace safety with several strong safety practices in place. However, opportunities for improvement were identified in several key areas that could reduce injury frequency and severity. FACILITY OVERVIEW: Facility operations include ' || COALESCE(c.industry_vertical, 'general business') || ' activities with approximately ' || COALESCE(c.employee_count, 0) || ' employees. SAFETY PROGRAM EVALUATION: The facility has implemented a written safety program with designated safety committee. Monthly safety meetings are conducted with documented attendance. New employee orientation includes basic safety training. Job-specific safety training documentation requires enhancement. PHYSICAL HAZARDS IDENTIFIED: During the facility inspection, several physical hazards requiring attention were documented including electrical panels obstructed by storage, exit doors blocked by equipment, fire extinguisher inspections overdue, damaged equipment still in use, and chemical storage areas lacking proper ventilation. WORKERS COMPENSATION CLAIMS ANALYSIS: Review of workers compensation claims reveals manual material handling as the leading cause of injuries. Enhanced training on proper lifting techniques, increased use of mechanical lifting aids, and ergonomic job design could reduce injury frequency significantly. RECOMMENDATIONS: Immediate actions include removing obstructions from electrical panels and emergency exits, scheduling fire equipment inspections, removing damaged equipment from service, installing ventilation in chemical storage areas, and conducting emergency evacuation drills. Short-term actions include upgrading lighting, repairing floor surfaces, restoring guardrails to OSHA standards, replacing extension cords with permanent wiring, installing machine guards, painting aisle markings, implementing hazard communication program, and restocking first aid supplies. Long-term actions include developing comprehensive lockout tagout program, creating job-specific safety training program, implementing annual safety refreshers, enhancing incident investigation process, increasing safety inspection frequency, and implementing formal housekeeping program. ESTIMATED COST SAVINGS: Implementation of recommendations estimated to reduce workers compensation claims by ' || UNIFORM(25, 50, RANDOM()) || ' percent over next 2 years representing potential annual savings of ' || UNIFORM(25000, 100000, RANDOM()) || ' dollars per year. Additional benefits include reduced insurance premiums, improved employee morale and productivity, reduced absenteeism, enhanced regulatory compliance, and lower potential for OSHA citations. CONCLUSION: This facility demonstrates commitment to employee safety. Implementation of the recommendations provided will further enhance the safety program and reduce injury frequency and severity. Mahoney Group Loss Control services available to assist with implementation, provide training, and conduct follow-up assessments. Follow-up assessment recommended in 6 months.' AS report_content,
    lcs.service_type AS report_type,
    c.industry_vertical,
    ARRAY_CONSTRUCT('SLIPS_TRIPS_FALLS', 'ERGONOMICS', 'FIRE_SAFETY', 'ELECTRICAL_SAFETY', 'MATERIAL_HANDLING')[UNIFORM(0, 4, RANDOM())] AS risk_area,
    lcs.priority_level,
    UNIFORM(5, 25, RANDOM()) AS recommendations_count,
    lcs.service_date AS report_date,
    lcs.consultant_name,
    lcs.created_at AS created_at
FROM RAW.LOSS_CONTROL_SERVICES lcs
JOIN RAW.CLIENTS c ON lcs.client_id = c.client_id
WHERE lcs.service_id IS NOT NULL
LIMIT 15000;

-- ============================================================================
-- Step 8: Create Cortex Search Service for Claim Notes
-- ============================================================================
CREATE OR REPLACE CORTEX SEARCH SERVICE CLAIM_NOTES_SEARCH
  ON note_text
  ATTRIBUTES client_id, adjuster_id, claim_type, claim_category, note_type
  WAREHOUSE = MAHONEY_WH
  TARGET_LAG = '1 hour'
  AS (
    SELECT 
      note_text,
      client_id,
      adjuster_id,
      claim_type,
      claim_category,
      note_type,
      note_id,
      claim_id
    FROM CLAIM_NOTES
  );

-- ============================================================================
-- Step 9: Create Cortex Search Service for Policy Documents
-- ============================================================================
CREATE OR REPLACE CORTEX SEARCH SERVICE POLICY_DOCUMENTS_SEARCH
  ON document_content
  ATTRIBUTES product_category, coverage_type, document_type, state
  WAREHOUSE = MAHONEY_WH
  TARGET_LAG = '1 day'
  AS (
    SELECT 
      document_content,
      product_category,
      coverage_type,
      document_type,
      state,
      document_title,
      document_id
    FROM POLICY_DOCUMENTS
  );

-- ============================================================================
-- Step 10: Create Cortex Search Service for Loss Control Reports
-- ============================================================================
CREATE OR REPLACE CORTEX SEARCH SERVICE LOSS_CONTROL_REPORTS_SEARCH
  ON report_content
  ATTRIBUTES client_id, industry_vertical, risk_area, priority_level, report_type
  WAREHOUSE = MAHONEY_WH
  TARGET_LAG = '1 hour'
  AS (
    SELECT 
      report_content,
      client_id,
      industry_vertical,
      risk_area,
      priority_level,
      report_type,
      report_title,
      report_id
    FROM LOSS_CONTROL_REPORTS
  );

-- ============================================================================
-- Display completion and verification
-- ============================================================================
SELECT 'Cortex Search services created successfully' AS status;

-- Show Cortex Search services
SHOW CORTEX SEARCH SERVICES IN SCHEMA RAW;

-- Test Cortex Search service
SELECT PARSE_JSON(
  SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
      'MAHONEY_GROUP_INTELLIGENCE.RAW.CLAIM_NOTES_SEARCH',
      '{"query": "property damage settlement", "limit":5}'
  )
)['results'] as results;

