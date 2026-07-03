#  Enterprise Supply Chain Risk & NPI Readiness Analytics Platform

##  Note from Masrur
Hey there, and thanks for stopping by. I built this project to show, hands-on, how I use data to make supply chain decisions, the kind of work I do day to day as a program manager. It walks through the full journey: pulling insight out of raw transactional data with SQL, and turning it all into dashboards for KPI tracking and executive business review. My analytical and reporting work earned me the title of "Game Changer" in my current role, and that recognition is what inspired me to build this project and share it with the world. I hope it gives you a clear sense of how I think and work. Feel free to dig into any piece that interests you.

##  About the Data (please read first)
Everything here runs on a **fully synthetic, anonymized dataset** I built specifically for this demonstration. Every supplier (Supplier 1 to 16), factory (Factory 1 to 5), and program (Program A to E) is a generic placeholder. There is **no proprietary or confidential information from any specific organization anywhere in this project.**

The dataset is designed to mirror the *structure* of a real data-center hardware supply chain, hardware components, lead times, demand signals, inventory positions, and purchase orders, so the analytical methods are realistic and transferable. Every value in it is fabricated.

## Project Overview
This repository is an end-to-end supply chain analytics and business intelligence project for a multi-regional network, tracking performance across five business units (Programs A through E). The goal is to bridge raw backend data and high-level executive decision-making, the same gap I work to close in my role.

## Business Design Flow

This project follows a simple operating model:
* **SQL** | The analytical engine. Answers a specific operational question, what is at risk, what is depleting, where is supplier risk concentrated, using CTEs, window functions, and multi-table joins.
* **Power BI** | The executive view. A fully interactive QBR dashboard where slicers filter every KPI and chart live, from a global view down to a single region in one click which can turn a status review into a decision meeting.
* **Excel** | The working dashboard. A 100% formula-driven, interactive workbook, no macros, with live KPI cards, demand forecast-vs-actual tracking, ranked supplier and risk tables, and dynamic dropdown slicers. 

---

## Data Visualization & Reporting

### Power BI | Executive Business Review Dashboard
*An interactive QBR dashboard. The slicers filter every KPI and chart live, so you can move from a global view down to a single region or program in one click. Tracks spend, on-time delivery, coverage risk, clean-launch rate, supplier concentration (Pareto), and the demand forecast-vs-actual gap.*

![Power BI Preview](https://github.com/masrurrezamash-sketch/Masrur_Supply_Chain_NPI_Analytics_Demo/blob/main/PbDB.png)

Based on the demo dashboard, leadership can quickly:
- Identify red-flagged parts that require recovery plans, risk buys, or supplier escalation
- Review the Top 5 suppliers driving the largest share of spend and determine whether supplier concentration requires second-source planning
- Compare forecast versus actual demand to determine whether gaps are one-time misses or recurring trends requiring demand-planning review
- Filter by region or program to isolate where supply risk, forecast variance, or launch-readiness issues are concentrated


<br/>

### Excel | Operational Tracking & Analytics Dashboard
*A fully formula-driven dashboard built entirely on native Excel, no macros, no VBA. Six live KPI cards, a demand forecast-vs-actual trend, a purchase-order status breakdown, ranked Top 5 supplier and at-risk-parts tables, and shortage risk by region, all driven by dynamic dropdown slicers. Change a dropdown and every KPI and chart recalculates instantly.*

![Excel Preview](https://github.com/masrurrezamash-sketch/Masrur_Supply_Chain_NPI_Analytics_Demo/blob/main/Excel%20Dashboard%20first%20half.jpg)
![Excel Preview](https://github.com/masrurrezamash-sketch/Masrur_Supply_Chain_NPI_Analytics_Demo/blob/main/Excel%20Dashboard%20second%20half.jpg)



Through this operational dashboard, a program manager can:
- Filter to a single region or program and instantly review on-time delivery and open PO value
- View overall inventory health by region and identify where inventory may need to be reallocated
- Identify the Top 5 at-risk parts by coverage and determine where recovery plans, risk buys, or supplier escalations are needed
- Review overall Clean Launch % for NPI milestones and identify programs that need status review, challenge resolution, or next-step ownership
- Compare supplier performance to identify high performers and suppliers requiring closer management attention


*Techniques used: Excel Tables with structured references, dynamic dropdown slicers, SUMIFS / COUNTIFS / AVERAGEIFS with wildcard logic, XLOOKUP, LARGE + INDEX/MATCH for dynamic ranking, IFERROR guards, and conditional formatting, all native, nothing hard-coded.*

---

##  SQL | Core Supply Chain KPIs
*Standard SQL (CTEs, window functions, conditional aggregation, multi-table joins) written to extract the metrics that drive supply chain decisions. Each query answers one specific operational question.*

### 1. Financial Exposure: Spend-at-Risk Query
*Tracks total financial exposure and delayed units caused by logistics bottlenecks across manufacturing factories.*
![SQL Output 1](https://github.com/masrurrezamash-sketch/Masrur_Supply_Chain_NPI_Analytics_Demo/blob/main/SqlOutput1.png)

**The question it answers:** How much capital is exposed right now, and where? It quantifies the dollars sitting in delayed and open POs, broken out by factory. 

**My recommendation:** Prioritize logistics recovery on the highest-value delayed POs first, since exposure is concentrated rather than evenly spread. Work with procurement, logistics, and suppliers to confirm recovery dates, unblock receiving issues, and create a weekly recovery tracker for delayed PO exposure.

<br/>

### 2. Operational Risk: Critical Stockout Warnings
*Cross-references inventory on-hand against component burn rates and supplier lead times to flag parts that will stock out before replenishment can arrive.*
![SQL Output 2](https://github.com/masrurrezamash-sketch/Masrur_Supply_Chain_NPI_Analytics_Demo/blob/main/SqlOutput2.png)

**The question it answers:** What is going to run dry before we can refill it? This is the depletion check, coverage weeks measured against lead time. 

**My recommendation:** Place risk buys or qualify alternate sources now for any part where coverage runs below lead time, and raise the reorder points on these parts to reflect current lead times rather than historical ones, so early-warning triggers land on time during next cycle instead of too late.

<br/>

### 3. Supplier Performance & Pareto Spend Distribution
*Evaluates vendor delivery metrics and classifies spend into tiers to pinpoint supplier concentration risk.*
![SQL Output 3](https://github.com/masrurrezamash-sketch/Masrur_Supply_Chain_NPI_Analytics_Demo/blob/main/SqlOutput3.png)

**The question it answers:** Where is our supplier risk concentrated? It ranks suppliers by spend and performance, showing which handful carry most of the exposure. This tells the program manager which suppliers warrant a second source, a scorecard conversation, or tighter management, the highest-leverage places to reduce risk.

**My recommendation:** For high-spend suppliers with elevated risk ratings, initiate executive supplier reviews, require recovery plans, evaluate second-source options, and track corrective actions to closure.


<br/>

### 4. Demand Volatility & Forecast Variance Tracking
*Aggregates forecast-to-actual variance across Programs A to E to surface the parts driving the biggest tracking errors.*
![SQL Output 4](https://github.com/masrurrezamash-sketch/Masrur_Supply_Chain_NPI_Analytics_Demo/blob/main/SqlOutput4.png)

**The question it answers:** Where are our forecasts missing, and which parts are driving it? 

**My recommendation:** Review the highest-variance parts with demand planning, product, sales, and supply teams. Validate whether the miss is caused by launch ramp changes, customer pull-ins, poor forecast assumptions, or supply constraints. For parts with repeated upside demand misses, adjust procurement commits or safety stock. For downside misses, reduce exposure before excess inventory builds.

<br/>

### 5. NPI Launch Health & Sourcing Diversity
*Monitors milestone completion rates and multi-sourcing percentages to gauge pre-production launch readiness.*
![SQL Output 5](https://github.com/masrurrezamash-sketch/Masrur_SupplyChain_AnalyticsDemo/blob/42ee390ea0030180f6035737d477c3961069ca26/SqlOutput5.png)

**The question it answers:** Are our new product launches on track and de-risked? It tracks milestone completion and sourcing diversity across programs. 

**My recommendation:** Hold launch readiness reviews before product launch, assign owners to incomplete milestones, and require mitigation plans for single-source or low-diversity parts. If sourcing diversity is weak, leadership should evaluate second-source qualification before launch risk becomes production risk.

Across all five, the theme is the same: concentrate effort on the vital few: the highest-value exposures, the most concentrated supplier risks, and the largest forecast variances.

##  Tools & Techniques
**SQL** (CTEs, window functions, conditional aggregation, multi-table joins) · **Power BI**
(interactive slicers, executive KPI design) · **Excel** (structured references, dynamic slicers,
SUMIFS/COUNTIFS, XLOOKUP, INDEX/MATCH, conditional formatting)

*Thanks again for taking the time to look through my work. Whether you are a recruiter, a hiring manager, a fellow supply chain or data professional, or simply someone curious and looking to learn, I would love to connect. I am always happy to walk through my approach, talk shop, or trade ideas, so please do not hesitate to reach out. :)*

*— Masrur*

[Connect with me on LinkedIn](https://linkedin.com/in/masrur-mash)
