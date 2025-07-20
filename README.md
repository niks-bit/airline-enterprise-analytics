# ✈️ Local Airline Flight & Customer Experience Analysis

**Author:** Nikki Dobles  
**Tools Used:** SQL, Tableau Public  
**Datasets:** `flights.csv`, `feedback.csv`  
**Duration:** 1 week of mock data simulating Cebu Pacific’s domestic operations  

---

## 📌 Project Summary

This case study explores the intersection of airline operational performance and customer experience, using mock data from Cebu Pacific's domestic flights. The goal is to identify which routes and experiences drive or hinder customer loyalty.

### 🧠 Key Insight:
> **Delays do not strongly impact loyalty. Poor service experience does.**  
> The **ZAM–DVO** route, despite average delays, had the **lowest recommendation rate** — making it the top candidate for experience improvement.

---

## 🧾 Files Included

| File | Description |
|------|-------------|
| `airline_route_analysis.sql` | Full SQL analysis with structured sections and commentary |
| `flights.csv` | Flight-level operational data (route, delay, distance, passengers) |
| `feedback.csv` | Passenger-level feedback data (ratings, seat comfort, recommendation) |
| `dashboard.twbx` (optional) | Tableau dashboard version of the analysis |
| `images/dashboard.png` (optional) | Snapshot of final dashboard |

---

## 📚 Analysis Outline (`airline_route_analysis.sql`)

### 1️⃣ Database Exploration
- Lists available tables
- Previews data in `flights` and `feedback` tables

### 2️⃣ Busiest Routes with Most Delays
- Counts total flights per route
- Calculates average delays
- Identifies top 5 high-traffic routes
- Flags delay-prone routes with potential operational issues

### 3️⃣ Delay Impact on Customer Experience
- Merges flights and feedback data
- Analyzes how delays affect ratings and recommendation likelihood
- Reveals that **loyalty does not correlate directly with delay length**
- Highlights that passengers may tolerate delays if other factors are satisfactory

### 4️⃣ Route-Level Experience Performance
- Aggregates feedback metrics (rating, seat comfort, service quality) per route
- Calculates recommendation rate per route
- Flags **ZAM–DVO** as a key underperformer in loyalty metrics, despite average delays
- Suggests this route as a priority for CX improvements

---

## 🧠 Takeaways

We started wide by identifying high-impact routes. Then we challenged a common assumption: that delays drive dissatisfaction. After disproving that, we focused on the **route-level experience** — and uncovered that **ZAM–DVO** is a high-volume route with experience quality issues, not delay issues.

> 🎯 **ZAM–DVO stands out as the only major route where poor passenger experience — not punctuality — is driving low loyalty**, making it the clearest candidate for targeted customer experience improvement.

---

## 📊 Dashboard

> Tableau dashboard recreates SQL logic visually  
> Includes:  
> - Route-level delay comparison  
> - Average rating by delay category  
> - Route experience + loyalty table

🔗 *Link to Tableau Public (if available)*  
🖼 *Or include an image like:*  
![Dashboard Preview](images/dashboard.png)

---

## 🛠️ How to Run

You can run the `.sql` file using:
- SQLite or DB Browser
- Any SQL IDE with support for JOINs and aggregation

No setup is required aside from loading the two CSVs into your SQL database.
