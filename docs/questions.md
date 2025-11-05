# Mahoney Group Intelligence Agent - Test Questions

These questions demonstrate the intelligence agent's ability to analyze Mahoney Group's multi-line insurance operations, including commercial insurance, employee benefits, claims management, and risk management across multiple industries.

---

## Simple Questions (5)

These questions test basic data retrieval and single-dimension analysis.

### 1. Client Count by Industry
**Question:** "How many clients does Mahoney Group have in each industry vertical?"

**Why Simple:**
- Single table query (CLIENTS)
- Basic COUNT aggregation
- Simple GROUP BY

**Data Source:** CLIENTS

---

### 2. Total Premium Written
**Question:** "What is the total annual premium written across all policies?"

**Why Simple:**
- Single metric from POLICIES table
- Simple SUM aggregation
- No filters or complex joins

**Data Source:** POLICIES

---

### 3. Active Claims Count
**Question:** "How many claims are currently in OPEN or UNDER_INVESTIGATION status?"

**Why Simple:**
- Single table query (CLAIMS)
- Basic COUNT with simple filter
- Two status values

**Data Source:** CLAIMS

---

### 4. Agent Performance - Top Producer
**Question:** "Which agent has written the most premium this year?"

**Why Simple:**
- Basic aggregation on POLICIES
- Single metric (SUM premium)
- Simple MAX or ORDER BY

**Data Source:** POLICIES, INSURANCE_AGENTS

---

### 5. Average Claim Cost
**Question:** "What is the average claim cost for settled claims?"

**Why Simple:**
- Single AVG calculation
- Basic filter for settled claims
- No complex joins

**Data Source:** CLAIMS

---

## Complex Questions (10)

These questions require multi-table joins, calculations, segmentation, and business intelligence analysis.

### 1. Loss Ratio Analysis by Product Line
**Question:** "Analyze loss ratios by insurance product category. Show total premium, total claims incurred, loss ratio percentage, and profitability for each product line. Which products are most profitable?"

**Why Complex:**
- Multi-table joins (POLICIES, CLAIMS, INSURANCE_PRODUCTS)
- Loss ratio calculation (claims / premium)
- Profitability analysis
- Aggregation by product category

**Data Sources:** POLICIES, CLAIMS, INSURANCE_PRODUCTS

---

### 2. Competitive Win Rate and Premium Capture
**Question:** "What is Mahoney Group's competitive win rate? Show total competitive wins by previous carrier (Travelers, Hartford, Zurich, Liberty Mutual, AIG, Chubb, CNA), premium captured from each competitor, and which industries we're winning in."

**Why Complex:**
- Competitive intelligence filtering
- Multi-dimensional segmentation (carrier, industry)
- Premium impact calculation
- Win rate analysis

**Data Sources:** POLICIES, CLIENTS

---

### 3. Agent Performance Dashboard
**Question:** "Analyze agent performance metrics. Show total premium written, number of clients, average policy size, renewal rate, client satisfaction score, and competitive wins by agent. Rank agents by total production."

**Why Complex:**
- Agent productivity metrics across multiple dimensions
- Renewal rate calculation
- Multiple aggregations
- Performance benchmarking
- Ranking/sorting

**Data Sources:** INSURANCE_AGENTS, POLICIES, POLICY_RENEWALS, CLIENTS

---

### 4. High-Risk Client Identification
**Question:** "Identify high-risk clients requiring intervention. Show clients with loss ratio >80%, claim frequency above industry average, risk rating of C+ or below, and client satisfaction <4.0. Calculate potential premium impact of risk reduction."

**Why Complex:**
- Risk factor aggregation
- Industry benchmarking calculations
- Multi-criteria filtering
- Premium impact estimation
- Client health scoring

**Data Sources:** CLIENTS, POLICIES, CLAIMS

---

### 5. Claims Cost Analysis by Industry and Claim Type
**Question:** "Analyze claim costs by industry vertical and claim type. Show average incurred cost, total claims, claim frequency rate (claims per policy), and litigation percentage for each combination. Identify highest-cost segments."

**Why Complex:**
- Multi-dimensional analysis (industry x claim type)
- Multiple cost metrics
- Frequency rate calculation (claims/policies ratio)
- Litigation analysis
- Cross-tabulation

**Data Sources:** CLAIMS, CLIENTS, POLICIES

---

### 6. Renewal Performance and At-Risk Analysis
**Question:** "Analyze policy renewal performance. Show renewal rate by business segment and industry, average premium change at renewal, and identify clients at risk of non-renewal based on loss ratio, premium increases >20%, and satisfaction scores. Estimate premium at risk."

**Why Complex:**
- Renewal metrics calculation
- Retention risk scoring
- Multi-factor at-risk identification
- Premium exposure quantification
- Segmented analysis

**Data Sources:** POLICY_RENEWALS, CLIENTS, POLICIES

---

### 7. Claims Adjuster Efficiency Analysis
**Question:** "Analyze claims adjuster performance. Show average days to settle, average claim cost, claims handled per month, client satisfaction rating, and percentage of claims with disputes by adjuster type (PROPERTY, LIABILITY, AUTO, etc.). Which adjuster types are most efficient?"

**Why Complex:**
- Multiple efficiency dimensions
- Time-to-settlement calculations
- Workload metrics
- Quality indicators (disputes, satisfaction)
- Adjuster type comparison

**Data Sources:** CLAIMS_ADJUSTERS, CLAIMS, CLAIM_DISPUTES

---

### 8. Geographic Market Performance
**Question:** "Analyze performance by state. Show total premium, policy count, average premium per policy, loss ratio, competitive win rate, and market penetration by state. Identify expansion opportunities in states with low penetration but favorable loss ratios."

**Why Complex:**
- Geographic segmentation
- Multiple performance metrics per state
- Market penetration analysis
- Opportunity identification
- Cross-metric analysis

**Data Sources:** CLIENTS, POLICIES, CLAIMS

---

### 9. Employee Benefits Program Analysis
**Question:** "Analyze employee benefits program performance. Show total covered employees, premium per employee, plan enrollment by type (HEALTH, DENTAL, VISION, LIFE), carrier performance, and clients with comprehensive vs. limited benefits. Calculate average benefits spend per employee by industry."

**Why Complex:**
- Benefits program metrics
- Per-employee calculations
- Plan mix analysis
- Carrier comparison
- Industry benchmarking

**Data Sources:** BENEFIT_PLANS, CLIENTS, INSURANCE_AGENTS

---

### 10. Claims Dispute and Litigation Trends
**Question:** "Analyze claim dispute and litigation trends. Show dispute rate by claim type and industry, average legal costs, average settlement amounts, resolution methods (mediation, arbitration, litigation), resolution times, and outcomes (carrier favor, client favor, compromise). Which disputes are most costly?"

**Why Complex:**
- Litigation frequency analysis
- Multiple cost metrics
- Resolution method comparison
- Time-to-resolution analysis
- Outcome analysis
- Industry-specific exposure

**Data Sources:** CLAIM_DISPUTES, CLAIMS, CLIENTS

---

## Unstructured Data Search Questions (Cortex Search)

These questions test the agent's ability to search and retrieve insights from unstructured data using Cortex Search services.

### 11. Claim Settlement Strategies
**Question:** "Search claim notes for successful settlement strategies in property damage claims. What approaches led to favorable outcomes?"

**Why Complex:**
- Semantic search over claim notes
- Best practice extraction
- Outcome correlation
- Strategy identification

**Data Source:** CLAIM_NOTES_SEARCH

---

### 12. Policy Coverage Questions
**Question:** "What do our policy documents say about cyber insurance coverage for ransomware attacks? What exclusions apply?"

**Why Complex:**
- Policy document retrieval
- Coverage interpretation
- Exclusion identification

**Data Source:** POLICY_DOCUMENTS_SEARCH

---

### 13. Loss Control Recommendations
**Question:** "Search loss control reports for workplace safety recommendations in manufacturing facilities. What are the most common hazards identified?"

**Why Complex:**
- Risk assessment report search
- Hazard pattern recognition
- Recommendation extraction
- Industry-specific filtering

**Data Source:** LOSS_CONTROL_REPORTS_SEARCH

---

### 14. Claim Investigation Techniques
**Question:** "Search claim notes for effective investigation techniques in high-value property damage claims. What evidence collection methods were most successful?"

**Why Complex:**
- Investigation best practices
- Evidence methodology extraction
- Success pattern identification

**Data Source:** CLAIM_NOTES_SEARCH

---

### 15. Risk Management Best Practices
**Question:** "Search loss control reports for ergonomic risk reduction strategies in construction companies. What recommendations resulted in measurable injury reduction?"

**Why Complex:**
- Industry-specific risk management
- Intervention effectiveness analysis
- Outcome measurement extraction

**Data Source:** LOSS_CONTROL_REPORTS_SEARCH

---

## Combined Questions (Structured + Unstructured)

These questions require the agent to combine insights from both structured data (Cortex Analyst) and unstructured content (Cortex Search).

### 16. High-Cost Claims + Best Practices
**Question:** "Which claim types have the highest average costs? Search claim notes for cost management strategies used successfully in these claim categories."

**Why Complex:**
- Structured cost analysis
- Unstructured best practice retrieval
- Strategy correlation with outcomes

**Tools Used:** SV_CLAIMS_MANAGEMENT_INTELLIGENCE + CLAIM_NOTES_SEARCH

---

### 17. Risk Management Program Effectiveness
**Question:** "Show clients with loss control services in the past year. Search loss control reports for their specific recommendations. Did clients with implemented recommendations show claim reduction?"

**Why Complex:**
- Client loss control participation analysis
- Recommendation extraction from reports
- Outcome measurement (claim reduction)
- Correlation analysis

**Tools Used:** SV_COMMERCIAL_INSURANCE_INTELLIGENCE + LOSS_CONTROL_REPORTS_SEARCH

---

### 18. Policy Coverage Analysis
**Question:** "Show premium volume by insurance product. Search policy documents for coverage details and exclusions specific to our top 3 products by premium."

**Why Complex:**
- Premium analysis and product ranking
- Policy document retrieval
- Coverage and exclusion synthesis

**Tools Used:** SV_COMMERCIAL_INSURANCE_INTELLIGENCE + POLICY_DOCUMENTS_SEARCH

---

### 19. Litigation Cost Management
**Question:** "Analyze legal costs by dispute type. Search claim notes for successful defense strategies in the most expensive dispute categories."

**Why Complex:**
- Structured litigation cost analysis
- Unstructured strategy extraction
- Category-specific best practices

**Tools Used:** SV_CLAIMS_MANAGEMENT_INTELLIGENCE + CLAIM_NOTES_SEARCH

---

### 20. Industry-Specific Risk Assessment
**Question:** "Show claim frequency and severity by industry vertical. Search loss control reports for industry-specific risk factors and prevention strategies."

**Why Complex:**
- Structured risk metrics by industry
- Unstructured risk factor identification
- Prevention strategy extraction

**Tools Used:** SV_CLAIMS_MANAGEMENT_INTELLIGENCE + LOSS_CONTROL_REPORTS_SEARCH

---

## Question Complexity Summary

These questions test the agent's ability to:

1. **Multi-table joins** - connecting clients, policies, claims, benefits across entities
2. **Temporal analysis** - premium trends, claim duration, time-to-settlement
3. **Segmentation & classification** - industry verticals, product categories, claim types
4. **Derived metrics** - loss ratios, renewal rates, claim frequency rates, growth calculations
5. **Competitive intelligence** - win rate by competitor, market share analysis
6. **Performance benchmarking** - agent productivity, adjuster efficiency, client programs
7. **Correlation analysis** - satisfaction vs. retention, risk rating vs. claims
8. **Risk assessment** - client health scoring, claim risk identification
9. **Outcome measurement** - settlement success, retention rates, resolution times
10. **Cost analysis** - claim costs, legal costs, benefits costs, premium adequacy
11. **Semantic search** - policy provisions, claim strategies, risk management recommendations
12. **Best practice extraction** - successful strategies, effective interventions
13. **Document synthesis** - policy wording, loss control reports, claim investigations

These questions reflect realistic business intelligence needs for Mahoney Group's multi-line insurance and employee benefits brokerage operations including underwriting, claims management, risk management, and client retention.

---

**Version:** 1.0  
**Created:** November 2025  
**Target Use Case:** Mahoney Group multi-line insurance and employee benefits intelligence


