-- ============================================================================
-- Mahoney Group Intelligence Agent - Cortex Search Service Setup
-- ============================================================================
-- Purpose: Create unstructured data tables and Cortex Search services for
--          claim notes, policy documents, and loss control reports
-- Syntax verified against: https://docs.snowflake.com/en/sql-reference/sql/create-cortex-search
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
        WHEN 0 THEN 'Initial claim report received from ' || cl.client_name || '. Claimant reports ' || c.claim_type || ' on ' || TO_CHAR(c.incident_date, 'MM/DD/YYYY') || '. First notice of loss documented. Preliminary investigation commenced. Reserve set at $' || c.claim_amount_reserved::VARCHAR || '. Adjuster assigned and site inspection scheduled for next week. Will coordinate with client risk manager. Client has good claims history and cooperative relationship with Mahoney Group.'
        WHEN 1 THEN 'Site inspection completed at ' || cl.client_name || ' premises. ' || c.claim_category || ' damage assessed. Photos documented. Witness statements collected from 3 employees. Liability appears clear - client accepts responsibility. Estimating total loss at approximately $' || c.claim_amount_incurred::VARCHAR || '. Coverage confirmed under policy. Repair vendors contacted. Client requesting expedited settlement to minimize business interruption. Recommend settlement approval.'
        WHEN 2 THEN 'Complex claim involving ' || c.claim_type || ' at ' || cl.client_name || '. Multiple parties potentially liable. Detailed investigation required. Hired independent investigator to review incident. Subrogation potential identified - third party contractor may bear partial responsibility. Legal counsel consulted. Client concerned about reputation impact. Implementing enhanced communication plan. Media inquiries received and directed to corporate communications. Reserve increased to $' || c.claim_amount_reserved::VARCHAR || ' pending investigation completion.'
        WHEN 3 THEN 'Settlement negotiations ongoing with ' || cl.client_name || '. Initial demand received for $' || (c.claim_amount_incurred * 1.5)::NUMBER(13,2)::VARCHAR || '. Our evaluation supports settlement at $' || c.claim_amount_incurred::VARCHAR || '. Multiple rounds of negotiation completed. Mediation scheduled for next month if agreement not reached. Attorney representing claimant. Client authorized settlement up to policy limits. Both parties motivated to resolve. Recommend settlement at $' || (c.claim_amount_incurred * 1.1)::NUMBER(13,2)::VARCHAR || ' to avoid litigation costs.'
        WHEN 4 THEN 'Property damage claim at ' || cl.client_name || ' resolved successfully. Total paid: $' || c.claim_amount_paid::VARCHAR || '. Client extremely satisfied with claims handling and turnaround time. Repairs completed ahead of schedule. Business interruption minimized. No coverage disputes. Claim closed with positive outcome. Client expressed appreciation for Mahoney Group service. Adjuster performance excellent. Loss control team consulted on prevention measures. Implemented recommendations to prevent future similar losses.'
        WHEN 5 THEN 'Coverage dispute on ' || c.claim_type || ' claim for ' || cl.client_name || '. Claimant alleges coverage under policy, carrier questions whether loss falls within policy period. Policy exclusion may apply for ' || c.claim_category || '. Detailed policy interpretation required. Coverage counsel retained. Reservation of rights letter sent. Client frustrated with delay. Maintaining regular communication. Independent coverage opinion obtained supporting denial. Claimant has hired attorney. Anticipate litigation. Defense costs mounting - currently $' || (c.claim_amount_incurred * 0.15)::NUMBER(12,2)::VARCHAR || ' in legal fees.'
        WHEN 6 THEN 'Large loss claim at ' || cl.client_name || ' - catastrophic ' || c.claim_type || '. Total incurred: $' || c.claim_amount_incurred::VARCHAR || '. Multiple adjusters assigned. Claims team established. Daily status updates to client and underwriting. Excess carriers notified. Forensic investigation completed. Causation established. Business interruption coverage triggered. Working with client on interim operating facilities. Public adjuster representing insured. Coverage counsel engaged. Settlement authority requested from excess carriers. Complex multiparty claim requiring careful coordination.'
        WHEN 7 THEN 'Liability claim filed against ' || cl.client_name || ' alleging ' || c.claim_category || '. Claimant seeking damages for injuries sustained. Hired defense counsel. Discovery process initiated. Depositions scheduled. Client concerned about potential verdict exposure. Defendant has strong defense based on comparative negligence. Expert witnesses retained for both medical and liability opinions. Settlement discussions commenced. Plaintiff demand: $' || (c.claim_amount_incurred * 2)::NUMBER(13,2)::VARCHAR || '. Defense evaluation: $' || c.claim_amount_incurred::VARCHAR || '. Recommend attempting settlement at mediation.'
        WHEN 8 THEN 'Auto liability claim involving ' || cl.client_name || ' commercial vehicle. Driver citations issued by police. Liability accepted. Claimant injuries include soft tissue damage. Medical treatment ongoing. Bills submitted totaling $' || (c.claim_amount_incurred * 0.6)::NUMBER(12,2)::VARCHAR || '. Independent medical exam scheduled to assess injury extent and causation. Treatment appears reasonable and necessary. Working directly with claimant attorney on settlement. Lost wage claim submitted and verified. Expect settlement within policy limits. No bad faith concerns. Client fleet safety reviewed by loss control.'
        WHEN 9 THEN 'Workers compensation claim for ' || cl.client_name || ' employee. Back injury reported from lifting incident. Medical only status currently. Total medical: $' || (c.claim_amount_incurred * 0.4)::NUMBER(12,2)::VARCHAR || '. Employee returned to modified duty within 2 weeks. Employer very accommodating with restrictions. Physical therapy completed. No lost time benefits paid due to modified duty availability. Claim closing as medical only. Positive outcome demonstrating value of employer modified duty program. Nurse case manager assisted with return to work. Client safety program effective.'
        WHEN 10 THEN 'Cyber claim for ' || cl.client_name || ' - data breach incident. Forensic IT investigation completed. Approximately 5,000 records potentially compromised. Notification requirements triggered under state law. Credit monitoring services arranged for affected individuals. Public relations consultant engaged. Media coverage minimal. Regulatory investigation by state attorney general. Client IT security enhanced post-incident. Coverage under cyber policy confirmed. Total incurred costs: $' || c.claim_amount_incurred::VARCHAR || ' including forensic investigation, notification costs, credit monitoring, legal fees, and regulatory defense.'
        WHEN 11 THEN 'Product liability claim against ' || cl.client_name || '. Claimant alleges injury from defective product. Manufacturer component analysis completed. Product recall not required per testing. Independent testing shows product met all specifications. Claim appears unfounded based on investigation. User error likely cause of incident. Defense counsel recommends vigorous defense. Discovery supports defense position. Plaintiff expert opinion weak. Settlement not warranted. Preparing for trial if necessary. Client confident in product quality and safety. Similar claims not identified in product history.'
        WHEN 12 THEN 'Environmental claim at ' || cl.client_name || ' facility. Alleged pollution from historical operations. State environmental agency investigation ongoing. Remediation plan required. Environmental consultant engaged. Phase II environmental assessment completed. Contamination confirmed in soil and groundwater. Coverage questions under pollution liability policy. Long tail exposure - damages will develop over time. Reserved at $' || c.claim_amount_reserved::VARCHAR || ' subject to significant revision pending remediation cost estimates. Cooperation from client excellent. Complex environmental claim requiring specialized expertise.'
        WHEN 13 THEN 'Professional liability claim against ' || cl.client_name || '. Client allegations of errors and omissions in services provided. Detailed factual investigation completed. Client communications reviewed. Engagement letter and scope of work clearly defined. Services performed within professional standards. Expert witness retained supporting standard of care met. Claimant damages appear overstated. Settlement discussions ongoing. Carrier recommendation: settle for nuisance value to avoid defense costs. Defense costs currently $' || (c.claim_amount_incurred * 0.25)::NUMBER(12,2)::VARCHAR || '. Client reputation important consideration in settlement decision.'
        WHEN 14 THEN 'Builders risk claim for ' || cl.client_name || ' construction project. Storm damage to building under construction. Temporary protection inadequate. Contractor responsibility vs. builder risk coverage issue. Policy interpretation required. Coverage counsel consulted. Investigation shows adequate temporary protection was in place per policy requirements. Coverage confirmed. Repair estimates obtained from multiple contractors. Project timeline impacted - delay damages claimed. Extra expense coverage applies. Total covered loss: $' || c.claim_amount_incurred::VARCHAR || '. Claim settled and project completion on track.'
        WHEN 15 THEN 'D&O claim involving ' || cl.client_name || ' board of directors. Shareholder derivative action filed. Allegations of breach of fiduciary duty. Securities counsel retained for defense. Complex corporate governance issues. Board acted on advice of counsel and financial advisors. Defense appears strong. Discovery extensive. Depositions of board members completed. Plaintiff settlement demand: $' || (c.claim_amount_incurred * 3)::NUMBER(13,2)::VARCHAR || '. Coverage under D&O policy confirmed. Defense costs significant. Recommend settlement discussions at appropriate time. Board concerned about reputation and business impact.'
        WHEN 16 THEN 'Denied claim for ' || cl.client_name || ' - policy exclusion applies. Detailed coverage analysis completed. Late notice issue - claim reported ' || DATEDIFF('day', c.incident_date, c.report_date) || ' days after occurrence. Prejudice to carrier documented. Coverage counsel opinion supports denial. Denial letter sent with detailed explanation. Client disagrees with denial and has hired coverage counsel. Bad faith allegations threatened. File extensively documented to support denial decision. Anticipate coverage litigation. Defense costs being incurred under reservation of rights. Denial position appears defensible.'
        WHEN 17 THEN 'Subrogation recovery on ' || cl.client_name || ' claim. Paid out $' || c.claim_amount_paid::VARCHAR || ' to insured. Third party clearly liable. Subrogation demand sent to responsible party and their carrier. Negotiations ongoing. Recovery potential: 75-100% of paid amount. Insured cooperation excellent. Evidence well documented. Liability clear based on police report and witness statements. Expect settlement of subrogation claim within 90 days. Will reimburse client deductible from recovery proceeds. Successful subrogation supports client retention and renewal terms.'
        WHEN 18 THEN 'Disputed claim for ' || cl.client_name || ' now in litigation. Complaint filed in Superior Court. Answer submitted denying allegations. Discovery schedule established. Both parties engaged in settlement discussions through mediation. Mediator neutral evaluation: $' || (c.claim_amount_incurred * 0.8)::NUMBER(12,2)::VARCHAR || '. Carrier willing to settle at mediator evaluation. Plaintiff countered at $' || (c.claim_amount_incurred * 1.2)::NUMBER(13,2)::VARCHAR || '. Additional mediation session scheduled. Client concerned about trial exposure and costs. Defense costs approaching $' || (c.claim_amount_incurred * 0.3)::NUMBER(12,2)::VARCHAR || '. Recommend settlement within authority to avoid further expense and uncertainty of trial.'
        WHEN 19 THEN 'Claim closed - full and final release obtained. ' || cl.client_name || ' claim concluded successfully. Total paid: $' || c.claim_amount_paid::VARCHAR || ' which is ' || ROUND(((c.claim_amount_paid / NULLIF(c.claim_amount_reserved, 0)) * 100), 2)::VARCHAR || '% of initial reserve. No coverage disputes. No bad faith allegations. Client satisfied with outcome. Adjuster file quality excellent. Claim handling time: ' || DATEDIFF('day', c.report_date, c.settlement_date) || ' days. Meets all KPI targets. File closed and archived. Positive outcome for all parties. Client relationship strengthened through professional claims handling.'
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
INSERT INTO POLICY_DOCUMENTS VALUES
('DOC001', NULL, NULL, 'Commercial General Liability Policy Wording - Mahoney Group Standard Form',
$$COMMERCIAL GENERAL LIABILITY POLICY
MAHONEY GROUP INSURANCE SERVICES

POLICY DECLARATIONS AND COVERAGE FORM

This Commercial General Liability (CGL) policy provides coverage for bodily injury, property damage, personal injury, and advertising injury claims. Coverage is provided on an occurrence basis.

SECTION I - COVERAGES

COVERAGE A: BODILY INJURY AND PROPERTY DAMAGE LIABILITY
We will pay those sums that the insured becomes legally obligated to pay as damages because of "bodily injury" or "property damage" to which this insurance applies. We will have the right and duty to defend the insured against any "suit" seeking those damages. However, we will have no duty to defend the insured against any "suit" seeking damages for "bodily injury" or "property damage" to which this insurance does not apply.

1. Insuring Agreement
   a. We will pay those sums that the insured becomes legally obligated to pay as damages because of "bodily injury" or "property damage" to which this insurance applies. We will have the right and duty to defend the insured against any "suit" seeking those damages.
   
   b. This insurance applies to "bodily injury" and "property damage" only if:
      (1) The "bodily injury" or "property damage" is caused by an "occurrence" that takes place in the "coverage territory";
      (2) The "bodily injury" or "property damage" occurs during the policy period; and
      (3) Prior to the policy period, no insured listed under Paragraph 1. of Section II – Who Is An Insured and no "employee" authorized by you to give or receive notice of an "occurrence" or claim, knew that the "bodily injury" or "property damage" had occurred, in whole or in part.

2. Exclusions
   This insurance does not apply to:
   a. Expected Or Intended Injury
   b. Contractual Liability
   c. Liquor Liability
   d. Workers Compensation And Similar Laws
   e. Employer's Liability
   f. Pollution
   g. Aircraft, Auto Or Watercraft
   h. Mobile Equipment
   i. War
   j. Professional Services
   k. Damage To Property
   l. Damage To Your Product
   m. Damage To Your Work
   n. Damage To Impaired Property Or Property Not Physically Injured
   o. Recall Of Products, Work Or Impaired Property
   p. Personal And Advertising Injury
   q. Electronic Data

COVERAGE B: PERSONAL AND ADVERTISING INJURY LIABILITY
We will pay those sums that the insured becomes legally obligated to pay as damages because of "personal and advertising injury" to which this insurance applies.

1. Insuring Agreement
   a. We will pay those sums that the insured becomes legally obligated to pay as damages because of "personal and advertising injury" to which this insurance applies. We will have the right and duty to defend the insured against any "suit" seeking those damages.
   
   b. This insurance applies to "personal and advertising injury" caused by an offense arising out of your business but only if the offense was committed in the "coverage territory" during the policy period.

2. Exclusions
   Specific exclusions apply including knowing violation of rights, material published prior to policy period, criminal acts, breach of contract, and others.

COVERAGE C: MEDICAL PAYMENTS
We will pay medical expenses as described below for "bodily injury" caused by an accident:
   a. On premises you own or rent;
   b. On ways next to premises you own or rent; or
   c. Because of your operations;
provided that the accident takes place in the coverage territory during the policy period.

SUPPLEMENTARY PAYMENTS - COVERAGES A AND B
We will pay, with respect to any claim we investigate or settle, or any "suit" against an insured we defend:
   1. All expenses we incur.
   2. Up to $250 for cost of bail bonds.
   3. Reasonable expenses incurred by the insured at our request.
   4. All costs taxed against the insured in the "suit".
   5. Prejudgment interest awarded against the insured.
   6. All interest on the full amount of any judgment.

SECTION II - WHO IS AN INSURED
1. You are an insured (the Named Insured shown in the Declarations).
2. Your employees, officers, directors, partners, and members are insureds while acting within the scope of their duties.
3. Newly acquired or formed organizations are automatically covered for 180 days.

SECTION III - LIMITS OF INSURANCE
1. The Limits of Insurance shown in the Declarations and the rules below fix the most we will pay regardless of the number of insureds, claims, or persons injured.
2. General Aggregate Limit applies separately to each project away from premises.
3. Products-Completed Operations Aggregate Limit is the most we will pay for all damages under Coverage A arising out of the "products-completed operations hazard".
4. Personal and Advertising Injury Limit is the most we will pay for all damages because of all "personal and advertising injury" sustained by any one person or organization.
5. Each Occurrence Limit is the most we will pay for the sum of all damages because of all "bodily injury" and "property damage" arising out of any one "occurrence".
6. Medical Expense Limit is the most we will pay for all medical expenses because of "bodily injury" sustained by any one person.

SECTION IV - COMMERCIAL GENERAL LIABILITY CONDITIONS
1. Bankruptcy
2. Duties In The Event Of Occurrence, Offense, Claim Or Suit
3. Legal Action Against Us
4. Other Insurance
5. Premium Audit
6. Representations
7. Separation Of Insureds
8. Transfer Of Rights Of Recovery Against Others To Us
9. When We Do Not Renew

SECTION V - DEFINITIONS
Key definitions include "bodily injury", "property damage", "occurrence", "personal and advertising injury", "products-completed operations hazard", "suit", "coverage territory", and others.

This policy form must be attached to Declarations showing policy limits, premiums, deductibles, and specific endorsements. Coverage is subject to all policy terms, conditions, and exclusions.$$,
'POLICY_FORM', 'LIABILITY', 'General Liability', NULL, NULL, NULL, 'commercial general liability, CGL, occurrence basis, bodily injury, property damage', CURRENT_TIMESTAMP()),

('DOC002', NULL, NULL, 'Workers Compensation Policy Overview - Arizona Coverage',
$$WORKERS COMPENSATION AND EMPLOYERS LIABILITY INSURANCE POLICY
MAHONEY GROUP INSURANCE SERVICES - ARIZONA COVERAGE

GENERAL SECTION
This policy provides workers compensation insurance and employers liability insurance. Part One (Workers Compensation Insurance) is provided according to Arizona workers compensation law. Part Two (Employers Liability Insurance) protects against certain lawsuits by employees.

PART ONE: WORKERS COMPENSATION INSURANCE
We will pay promptly when due the benefits required of you by the workers compensation law of Arizona.

A. How This Insurance Applies
   1. This workers compensation insurance applies to bodily injury by accident or bodily injury by disease. Bodily injury includes resulting death.
   2. Bodily injury by accident must occur during the policy period.
   3. Bodily injury by disease must be caused or aggravated by the conditions of your employment. The employee's last day of last exposure to the conditions causing or aggravating such bodily injury by disease must occur during the policy period.

B. We Will Defend
   We have the right and duty to defend at our expense any claim, proceeding or suit against you for benefits payable by this insurance. We have the right to investigate and settle these claims, proceedings or suits.

C. We Will Also Pay
   We will also pay these costs, in addition to other amounts payable under this insurance, as part of any claim, proceeding, or suit we defend:
   1. Reasonable expenses incurred at our request
   2. Premiums for bonds to release attachments and for appeal bonds
   3. Litigation costs taxed against you
   4. Interest on a judgment
   5. Expenses we incur

D. Other States Insurance
   If you begin work in any state listed in Item 3.C. of the Information Page after the effective date of this policy, we will provide coverage for that state. Coverage will be subject to applicable state workers compensation laws.

E. Payments You Must Make
   You are responsible for any payments in excess of the benefits regularly provided by the workers compensation law including those required because of your serious and willful misconduct.

PART TWO: EMPLOYERS LIABILITY INSURANCE
We will pay all sums you legally must pay as damages because of bodily injury to your employees, provided the bodily injury is covered by this Employers Liability Insurance.

A. How This Insurance Applies
   This Employers Liability Insurance applies to bodily injury by accident or bodily injury by disease. Bodily injury includes resulting death.
   1. The bodily injury must arise out of and in the course of the injured employee's employment by you.
   2. The employment must be necessary or incidental to your work in a state or territory listed in Item 3.A. of the Information Page.
   3. Bodily injury by accident must occur during the policy period.
   4. Bodily injury by disease must be caused or aggravated by the conditions of your employment.

B. We Will Defend
   We have the right and duty to defend, at our expense, any claim, proceeding or suit against you for damages payable by this insurance. We have the right to investigate and settle these claims, proceedings or suits.

C. We Will Also Pay
   We will also pay these costs as part of any claim, proceeding, or suit we defend:
   1. Reasonable expenses incurred at our request
   2. Premiums for bonds
   3. Litigation costs taxed against you
   4. Interest on judgments
   5. Expenses we incur

D. Exclusions
   This insurance does not cover:
   1. Liability assumed under a contract
   2. Punitive or exemplary damages
   3. Bodily injury to an employee while employed in violation of law
   4. Bodily injury intentionally caused or aggravated by you
   5. Bodily injury occurring outside the United States, its territories or possessions, and Canada
   6. Damages arising out of coercion, criticism, demotion, evaluation, reassignment, discipline, defamation, harassment, humiliation, discrimination against or termination of any employee
   7. Bodily injury to any person in work subject to the Longshore and Harbor Workers' Compensation Act, the Nonappropriated Fund Instrumentalities Act, or the Federal Coal Mine Health and Safety Act

E. Limits of Liability
   1. Bodily Injury by Accident - $1,000,000 each accident
   2. Bodily Injury by Disease - $1,000,000 policy limit
   3. Bodily Injury by Disease - $1,000,000 each employee

PART THREE: OTHER STATES INSURANCE
The Other States Insurance provision provides coverage for employees working in states not originally listed on your policy. This includes coverage for employees working temporarily in other states.

PART FOUR: YOUR DUTIES IF INJURY OCCURS
You must:
1. Provide for immediate medical and other services required by the workers compensation law.
2. Give us or our agent the names and addresses of the injured persons and of witnesses, and other information we may need.
3. Promptly give us all notices, demands and legal papers related to the injury, claim, proceeding or suit.
4. Cooperate with us in the investigation, settlement or defense of any claim, proceeding or suit.
5. Do nothing after an injury occurs that would interfere with our right to recover from others.

PART FIVE: PREMIUM
Premium is based on your estimated payroll for the policy period, subject to audit after the policy expires. Different job classifications have different premium rates based on the risk of injury. Final premium is determined by actual payroll and job classifications during the policy year.

This is a summary document. The actual policy contains detailed terms, conditions, exclusions, and definitions.$$,
'POLICY_FORM', 'WORKERS_COMP', 'Workers Compensation', 'AZ', NULL, NULL, 'workers compensation, Arizona, employers liability, workplace injury', CURRENT_TIMESTAMP()),

('DOC003', NULL, NULL, 'Cyber Insurance Policy - Data Breach and Network Security Coverage',
$$CYBER LIABILITY AND DATA BREACH INSURANCE POLICY
MAHONEY GROUP INSURANCE SERVICES

TECHNOLOGY ERRORS & OMISSIONS AND CYBER LIABILITY COVERAGE FORM

INSURING AGREEMENTS
We will pay on behalf of the Insured all Loss and Claim Expenses that the Insured shall become legally obligated to pay resulting from any Claim first made against the Insured during the Policy Period or Extended Reporting Period (if applicable) for:

1. TECHNOLOGY ERRORS & OMISSIONS LIABILITY
   Any actual or alleged act, error, omission, or breach of duty by the Insured in the performance of Technology Services, including:
   a. Failure to perform professional services as specified
   b. Failure of technology products or services to perform as represented
   c. Unintentional disclosure of confidential information
   d. Infringement of intellectual property rights (limited coverage)

2. NETWORK SECURITY LIABILITY
   Any failure of Network Security resulting in:
   a. Unauthorized access to or unauthorized use of the Insured's Computer System
   b. Denial of service attack against the Insured's Computer System
   c. Transmission of malicious code from the Insured's Computer System
   d. Breach of security leading to unauthorized disclosure of data

3. PRIVACY LIABILITY
   Any actual or alleged violation of Privacy Regulations resulting from:
   a. Disclosure or unauthorized access to personally identifiable information
   b. Failure to prevent unauthorized access to sensitive data
   c. Violation of privacy laws including HIPAA, GLBA, CCPA, or other applicable regulations
   d. Failure to comply with the Insured's published privacy policy

FIRST PARTY COVERAGES (Subject to separate sublimits)

4. BREACH RESPONSE COSTS
   We will pay reasonable and necessary costs incurred to respond to a Data Breach Event, including:
   a. Forensic Investigation Costs - IT forensic analysis to determine breach cause and scope
   b. Legal Costs - Attorneys' fees for breach response counsel
   c. Notification Costs - Costs to notify affected individuals as required by law
   d. Credit Monitoring - Credit monitoring and identity theft protection services for affected individuals
   e. Crisis Management - Public relations and crisis management services
   f. Regulatory Defense - Costs to defend regulatory proceedings and investigations

5. CYBER EXTORTION
   Payments made to extortionists threatening to:
   a. Damage, disable, or shut down the Insured's Computer System
   b. Introduce malicious code or ransomware
   c. Disclose confidential or sensitive information
   d. Launch a denial of service attack
   Also includes fees for cyber security experts, negotiators, and ransom delivery

6. BUSINESS INTERRUPTION
   Loss of Net Income and Extra Expenses sustained by the Insured due to:
   a. Necessary interruption of business operations caused by a Network Security Failure
   b. System outage caused by a covered cyber incident
   c. Denial of service attack
   Coverage begins after Waiting Period (typically 8 hours) shown in Declarations

7. DEPENDENT BUSINESS INTERRUPTION
   Loss of Net Income and Extra Expenses due to interruption of a Dependent Business Partner's operations caused by a covered cyber incident affecting the partner's systems.

8. DATA RESTORATION COSTS
   Reasonable costs to restore, recreate, or recollect Data and Software damaged or destroyed by a covered cyber incident.

9. CYBER CRIME/SOCIAL ENGINEERING
   Direct financial loss sustained by the Insured resulting from:
   a. Fraudulent Transfer of funds due to social engineering or phishing attack
   b. Theft of funds resulting from unauthorized computer system access
   c. Invoice manipulation by unauthorized third parties
   Coverage subject to specific sublimit and enhanced authentication requirements

EXCLUSIONS
This insurance does not cover:
1. Bodily injury or property damage (covered under CGL policy)
2. Intentional or criminal acts
3. Prior knowledge of circumstances that could lead to a claim
4. Infrastructure failures (power outage, telecommunications failure)
5. War and terrorism (unless terrorism coverage purchased)
6. Contractual liability exceeding what would exist absent the contract
7. Intellectual property infringement (except as specifically covered)
8. Failure to maintain minimum security standards as required by policy
9. Unencrypted portable devices or laptops (unless encryption waiver obtained)
10. Payment card industry fines and penalties (PCI-DSS)
11. Loss or damage to cryptocurrency or digital assets
12. Losses covered by other insurance

CONDITIONS
1. Minimum Security Requirements
   The Insured must maintain reasonable security measures including:
   - Multi-factor authentication for remote access
   - Encryption of sensitive data
   - Regular security patches and updates
   - Anti-virus and anti-malware software
   - Firewall protection
   - Regular data backups
   - Employee security awareness training
   - Incident response plan
   
   Failure to maintain these requirements may result in reduced coverage or denial of claims.

2. Notification Requirements
   The Insured must notify the Insurer within 72 hours of discovering a Data Breach Event or cyber incident that may result in a claim.

3. Consent to Settle
   The Insurer will not settle any claim without the Insured's consent, which shall not be unreasonably withheld.

4. Cooperation
   The Insured must cooperate fully with the Insurer's investigation and defense of claims.

DEFINITIONS
- Computer System: Hardware, software, networks, and electronic data processing systems
- Data Breach Event: Unauthorized access to or acquisition of unencrypted personally identifiable information
- Network Security Failure: Failure of security controls designed to protect Computer Systems
- Privacy Regulations: Federal, state, and foreign laws governing collection, use, and disclosure of personal information
- Technology Services: Professional services related to design, development, implementation, or support of technology systems

LIMITS OF INSURANCE
- Each Claim Limit: Maximum payable for any one claim
- Aggregate Limit: Maximum payable for all claims during policy period
- Sublimits apply separately to certain first-party coverages
- Retention/Deductible applies to each claim
- Claim Expenses may be within or outside limits depending on policy form

This policy provides essential cyber insurance coverage for technology risks. Coverage is subject to all policy terms, conditions, exclusions, and definitions. Consult the complete policy for full details.$$,
'POLICY_FORM', 'CYBER', 'Cyber & Data Breach', NULL, NULL, NULL, 'cyber insurance, data breach, ransomware, network security, privacy liability, HIPAA, business interruption', CURRENT_TIMESTAMP());

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
        WHEN 3 THEN 'Slip, Trip, and Fall Hazard Analysis - ' || c.client_name
        WHEN 4 THEN 'Warehouse Safety Inspection Report - ' || c.client_name
        WHEN 5 THEN 'Construction Site Safety Audit - ' || c.client_name
        WHEN 6 THEN 'Restaurant Kitchen Safety Review - ' || c.client_name
        WHEN 7 THEN 'Healthcare Facility Safety Assessment - ' || c.client_name
        WHEN 8 THEN 'Office Safety and Ergonomics Evaluation - ' || c.client_name
        WHEN 9 THEN 'Manufacturing Equipment Safety Review - ' || c.client_name
    END AS report_title,
    CASE (UNIFORM(0, 4, RANDOM()))
        WHEN 0 THEN $$COMPREHENSIVE WORKPLACE SAFETY ASSESSMENT REPORT

CLIENT: $$ || c.client_name || $$
INDUSTRY: $$ || c.industry_vertical || $$
LOCATION: $$ || c.city || $$, $$ || c.state || $$
ASSESSMENT DATE: $$ || TO_CHAR(lcs.service_date, 'MM/DD/YYYY') || $$
CONSULTANT: $$ || lcs.consultant_name || $$

EXECUTIVE SUMMARY
A comprehensive workplace safety assessment was conducted at the above-referenced facility. The assessment included interviews with management and employees, review of safety policies and procedures, inspection of physical premises, examination of injury and illness records, and evaluation of safety training programs. Overall, the facility demonstrates a commitment to workplace safety with several strong safety practices in place. However, opportunities for improvement were identified in several key areas that could reduce injury frequency and severity.

FACILITY OVERVIEW
- Total square footage: Approximately $$ || UNIFORM(10000, 100000, RANDOM()) || $$ sq ft
- Number of employees: $$ || c.employee_count || $$
- Operating hours: $$ || UNIFORM(1, 3, RANDOM()) || $$ shifts
- Primary operations: $$ || c.industry_vertical || $$ activities
- Years at current location: $$ || UNIFORM(1, 20, RANDOM()) || $$ years

SAFETY PROGRAM EVALUATION
The facility has implemented a written safety program with designated safety committee. Monthly safety meetings are conducted with documented attendance. New employee orientation includes basic safety training. However, job-specific safety training documentation is incomplete. Annual refresher training is not consistently provided to all employees.

Strengths Identified:
- Management commitment to safety is evident
- Safety committee meets regularly and addresses concerns
- New employee orientation includes safety component
- Injury reporting system is functioning
- Personal protective equipment is provided
- Emergency evacuation plan is posted

Areas for Improvement:
- Job-specific safety training needs enhancement
- Annual refresher training program should be implemented
- Safety training documentation requires better organization
- Lockout/tagout program needs written procedures
- Forklift operator certification records incomplete
- Incident investigation process needs strengthening
- Hazard communication program requires updating
- Safety inspection frequency should increase

PHYSICAL HAZARDS IDENTIFIED
During the facility inspection, the following physical hazards requiring attention were documented:

HIGH PRIORITY (Immediate Action Required):
1. Electrical panel obstructed by storage - creates accessibility and fire hazard
2. Exit door blocked by equipment - violates emergency egress requirements
3. Fire extinguisher inspection tags not current - last inspection over 1 year ago
4. Damaged ladder still in use - creates fall hazard
5. Chemical storage area lacks proper ventilation - potential exposure concern

MEDIUM PRIORITY (Action Within 30 Days):
1. Inadequate lighting in warehouse aisles - increases trip/fall risk
2. Uneven floor surfaces not marked - trip hazard
3. Guardrails on elevated platform need repair - fall protection concern
4. Eye wash station obstructed - emergency equipment access issue
5. Extension cords used as permanent wiring - electrical safety violation
6. Compressed gas cylinders not properly secured - tip over hazard
7. Missing machine guards on equipment - caught-in hazard
8. Inadequate aisle marking and pedestrian pathways - vehicle/pedestrian interaction
9. Chemical containers not properly labeled - hazcom violation
10. First aid kit supplies depleted - inadequate emergency response

LOW PRIORITY (Action Within 90 Days):
1. Safety signage needs updating and additional posting
2. Housekeeping needs improvement in several areas
3. Material storage heights exceed safe limits
4. Loading dock lacks wheel chocks for trailers
5. Break room lacks adequate seating

WORKERS COMPENSATION CLAIMS ANALYSIS
Review of workers compensation claims for past 3 years reveals:
- Total claims: $$ || UNIFORM(5, 30, RANDOM()) || $$
- Most frequent injuries: Back strains ($$ || UNIFORM(20, 40, RANDOM()) || $$%), Slips/trips/falls ($$ || UNIFORM(15, 30, RANDOM()) || $$%), Hand injuries ($$ || UNIFORM(10, 20, RANDOM()) || $$%)
- Most costly claims: Back injuries, Shoulder injuries, Knee injuries
- Claim frequency trend: $$ || CASE WHEN UNIFORM(0,1,RANDOM())=0 THEN 'Increasing' ELSE 'Decreasing' END || $$
- Average cost per claim: $$$ || UNIFORM(8000, 25000, RANDOM()) || $$

Claims analysis indicates that manual material handling is the leading cause of injuries. Enhanced training on proper lifting techniques, increased use of mechanical lifting aids, and ergonomic job design could reduce injury frequency significantly.

RECOMMENDATIONS AND ACTION PLAN
The following recommendations are provided to enhance workplace safety and reduce injury frequency:

IMMEDIATE ACTIONS (0-30 Days):
1. Remove obstruction from electrical panel and post "Keep Clear" signage
2. Relocate equipment blocking emergency exit
3. Schedule fire extinguisher inspection and service
4. Remove damaged ladder from service and replace
5. Install ventilation in chemical storage area or relocate chemicals
6. Conduct emergency evacuation drill and document
7. Provide additional safety training for employees in high-risk positions

SHORT-TERM ACTIONS (30-90 Days):
1. Upgrade lighting in warehouse areas to minimum 30 foot-candles
2. Repair uneven floor surfaces and install hazard marking
3. Repair guardrails on elevated platform per OSHA standards
4. Relocate items obstructing eye wash station
5. Replace extension cords with permanent electrical wiring
6. Install gas cylinder restraints in all storage locations
7. Install machine guards on all equipment per manufacturer specifications
8. Paint aisle markings and establish pedestrian walkways
9. Implement hazard communication program with updated labels and SDS
10. Restock first aid kits and assign monthly inspection responsibility

LONG-TERM ACTIONS (90-180 Days):
1. Develop and implement comprehensive written lockout/tagout program
2. Create job-specific safety training program for all positions
3. Implement annual safety training refresher for all employees
4. Enhance incident investigation process with root cause analysis
5. Increase safety inspection frequency to weekly with documented checklist
6. Install additional safety signage throughout facility
7. Implement formal housekeeping program with assigned responsibilities
8. Develop safe material storage procedures and train employees
9. Install wheel chocks at loading dock and train drivers
10. Upgrade break room facilities

ERGONOMIC ASSESSMENT
Review of work processes identified several ergonomic concerns contributing to musculoskeletal injuries:
- Manual lifting tasks exceed NIOSH recommended weight limits
- Repetitive reaching above shoulder height
- Prolonged standing without anti-fatigue mats
- Awkward postures during assembly operations
- Limited use of mechanical lifting aids

Recommendations:
- Implement mechanical lifting devices (hoists, lift tables, pallet jacks)
- Redesign workstations to keep frequently used items within easy reach
- Provide anti-fatigue mats at standing workstations
- Rotate employees through different tasks to reduce repetitive motion
- Provide ergonomic training to supervisors and employees

ESTIMATED COST SAVINGS
Implementation of the recommendations in this report is estimated to reduce workers compensation claims by $$ || UNIFORM(25, 50, RANDOM()) || $$% over the next 2 years. Based on current claim costs of approximately $$$ || UNIFORM(50000, 200000, RANDOM()) || $$ annually, this represents potential savings of $$$ || UNIFORM(25000, 100000, RANDOM()) || $$ per year. Additional benefits include:
- Reduced insurance premiums through improved loss experience
- Improved employee morale and productivity
- Reduced absenteeism
- Enhanced regulatory compliance
- Lower potential for OSHA citations and penalties

CONCLUSION
This facility demonstrates commitment to employee safety. Implementation of the recommendations provided will further enhance the safety program and reduce injury frequency and severity. Mahoney Group Loss Control services are available to assist with implementation of recommendations, provide safety training, and conduct follow-up assessments. We recommend scheduling a follow-up assessment in 6 months to evaluate progress and identify any new concerns.$$

        WHEN 1 THEN $$FIRE SAFETY AND EMERGENCY PREPAREDNESS EVALUATION

FACILITY: $$ || c.client_name || $$
DATE: $$ || TO_CHAR(lcs.service_date, 'MM/DD/YYYY') || $$
INSPECTOR: $$ || lcs.consultant_name || $$

SCOPE OF ASSESSMENT
This fire safety and emergency preparedness evaluation assessed the facility's compliance with applicable fire codes, adequacy of fire protection systems, emergency planning and preparedness, and opportunities to reduce fire risk exposure.

FIRE PROTECTION SYSTEMS
- Sprinkler System: $$ || CASE WHEN UNIFORM(0,1,RANDOM())=0 THEN 'Wet pipe system throughout facility' ELSE 'Partial sprinkler coverage' END || $$
- Fire Alarm: $$ || CASE WHEN UNIFORM(0,1,RANDOM())=0 THEN 'Addressable system with central monitoring' ELSE 'Local alarm system' END || $$
- Fire Extinguishers: $$ || UNIFORM(15, 50, RANDOM()) || $$ extinguishers located throughout facility
- Emergency Lighting: Battery-powered emergency lights at exits
- Exit Signs: Illuminated exit signs at all required locations

FINDINGS AND RECOMMENDATIONS
1. Fire extinguisher annual inspection overdue - schedule service immediately
2. Several exit doors locked from inside - install panic hardware
3. Exit pathway obstructed by storage - maintain clear egress routes
4. Emergency evacuation plan not posted in all areas - post building-wide
5. Fire drill not conducted in past 12 months - conduct quarterly drills
6. Hot work permit program not documented - implement written procedures
7. Flammable liquid storage exceeds code limits - install approved storage cabinet
8. Electrical panels lack clearance - maintain 36-inch clear space

Emergency Action Plan requires updating to include current employee roster, designated assembly points, and evacuation procedures for disabled persons.$$

        WHEN 2 THEN $$ERGONOMIC RISK ASSESSMENT

CLIENT: $$ || c.client_name || $$
ASSESSMENT DATE: $$ || TO_CHAR(lcs.service_date, 'MM/DD/YYYY') || $$

OBJECTIVE
Evaluate workplace ergonomic risk factors contributing to musculoskeletal disorders and provide recommendations to reduce injury risk.

HIGH-RISK JOB TASKS IDENTIFIED
Based on observations and employee interviews, the following job tasks present elevated ergonomic risk:

1. Manual Material Handling
   - Lifting frequency: $$ || UNIFORM(20, 100, RANDOM()) || $$ lifts per shift
   - Average weight: $$ || UNIFORM(25, 50, RANDOM()) || $$ lbs
   - Lifting from floor level to shoulder height
   - Recommendation: Implement mechanical lifting aids, use lift tables to raise load to waist height

2. Repetitive Upper Extremity Tasks
   - Assembly operations requiring $$ || UNIFORM(3000, 8000, RANDOM()) || $$ repetitions per shift
   - Forceful gripping and pinching
   - Awkward wrist postures
   - Recommendation: Job rotation, ergonomic tools, workstation redesign

3. Prolonged Standing
   - Standing $$ || UNIFORM(6, 10, RANDOM()) || $$ hours per shift without breaks
   - Hard concrete surface
   - Recommendation: Anti-fatigue mats, sit-stand workstations, scheduled rest breaks

IMPLEMENTATION PRIORITIES
Priority 1 (High Risk): Material handling tasks - implement immediately
Priority 2 (Moderate Risk): Repetitive tasks - implement within 30 days
Priority 3 (Lower Risk): Standing tasks - implement within 90 days

ESTIMATED IMPACT
Implementation of recommendations expected to reduce ergonomic injury claims by $$ || UNIFORM(30, 60, RANDOM()) || $$% within 12 months. Estimated annual savings: $$$ || UNIFORM(30000, 80000, RANDOM()) || $$.$$

        WHEN 3 THEN $$SLIP, TRIP, AND FALL HAZARD ANALYSIS

LOCATION: $$ || c.client_name || $$
INSPECTION DATE: $$ || TO_CHAR(lcs.service_date, 'MM/DD/YYYY') || $$

OVERVIEW
Slip, trip, and fall incidents are among the most common workplace injuries. This assessment identified hazards contributing to fall risk and provides specific recommendations for hazard mitigation.

WALKING SURFACE HAZARDS
1. Uneven floor transitions not marked - install beveled transitions and hazard marking
2. Wet surfaces near entry during rain - install entrance mats and wet floor warning signs
3. Poor lighting in stairwells - upgrade to minimum 30 foot-candles
4. Damaged floor tiles in break room - repair or replace
5. Extension cords across walkways - secure cords or reroute
6. Debris and clutter in aisles - implement housekeeping program
7. Missing handrails on stairs - install per code requirements
8. Ice accumulation on exterior walkways in winter - implement ice management program

LADDER SAFETY
Several ladders showed signs of damage. Implement ladder inspection program and remove damaged ladders from service. Provide training on proper ladder use and selection.

FALL PROTECTION
Elevated work platforms require guardrails per OSHA standards. Current guardrails show damage and do not meet 42-inch height requirement. Immediate repair required.

RECOMMENDATIONS
Estimated cost of recommended improvements: $$$ || UNIFORM(15000, 40000, RANDOM()) || $$
Estimated annual savings from injury prevention: $$$ || UNIFORM(25000, 75000, RANDOM()) || $$$$

        ELSE $$RISK ASSESSMENT REPORT

CLIENT: $$ || c.client_name || $$
REPORT DATE: $$ || TO_CHAR(lcs.service_date, 'MM/DD/YYYY') || $$
CONSULTANT: $$ || lcs.consultant_name || $$

This comprehensive risk assessment evaluated workplace hazards and provided recommendations to enhance safety and reduce injury risk. Key findings include the need for enhanced safety training, improved housekeeping, repair of physical hazards, and implementation of formal safety procedures.

Detailed recommendations provided to management with implementation timeline and estimated cost savings of $$$ || UNIFORM(20000, 100000, RANDOM()) || $$ annually through reduced workers compensation claims and improved safety culture.

Follow-up assessment recommended in $$ || UNIFORM(6, 12, RANDOM()) || $$ months to verify implementation and measure effectiveness of recommendations.$$
    END AS report_content,
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


