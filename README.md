# Market Gaps & Localization: Optimizing Netflix Global Content Strategy
![Excel](https://img.shields.io/badge/Excel-217346?style=for-the-badge&logo=microsoft-excel&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white)
![Power BI](https://img.shields.io/badge/Power_BI-F2C811?style=for-the-badge&logo=powerbi&logoColor=black)
> **View the visual summary on my [Portfolio Website ↗]([MASUKKAN_LINK_WEBSITE_PORTOPOLIO_KAMU_DISINI])**
> 
## 📌 Business Problem
Netflix's domestic streaming market is approaching saturation. Billions are allocated annually for local content and new categories. But this investment risks becoming waste without data-backed decisions.
This project answers 3 strategic questions:
1. **Where are the underserved niches?** Which genres have high audience demand but low Netflix supply?
2. **Does long-form content really fail?** Is the "short attention span" assumption actually true?
3. **Where is the best ROI for local content?** Which countries deliver the best quality-to-volume ratio?
   
## 🔧 Tech Stack & Pipeline
```text
Raw Data (.csv/.xlsx)
      │
      ▼
[Excel] → Encoding fix (Mojibake on international names), phantom format cleaning
      │
      ▼
[PostgreSQL] → Relational modeling, UNNEST to explode multi-genre rows, EDA via SQL
      │
      ▼
[Power BI] → Interactive dashboard, F-Pattern UI, dual-axis charts, scatter quadrant
```

## 🗂️ Key Data Challenges
1. Mojibake Encoding (Excel): International actor and director names were corrupted due to improper character encoding during data export. Resolved by forcing UTF-8 ingestion at the Excel import stage.

2. Phantom Number Formats: Values like 25.00.00 appeared in numeric duration columns. Detected and cleaned for proper Integer casting.

3. Multi-Valued Columns in SQL: A film with 3 genres (e.g., "Drama, Comedy, Thriller") must be counted fairly in all three genre categories. Used STRING_TO_ARRAY + UNNEST in PostgreSQL to explode these into separate rows before aggregation.

## 🛠️ Data Architecture & SQL Implementation
After initial data cleaning (handling delimiter errors and text inconsistencies), I built three separate aggregation queries in **PostgreSQL** to efficiently answer each business experiment.

### Experiment 1: Genre Market Gap Analysis
This query aggregates average ratings and total viewer engagement per individual genre to spot market gaps.
```sql
SELECT
    genre_tunggal,
    COUNT(*) AS total_produksi,
    ROUND(AVG(rating::numeric), 2) AS rata_rating,
    SUM(vote::int) AS total_engagement
FROM netflix_shows
GROUP BY genre_tunggal
ORDER BY rata_rating DESC;
```
*Logic Breakdown: Sorting by rata_rating DESC immediately pushes niche genres like Film-Noir and News to the top, proving the existence of potential market gaps.*

### Experiment 2: Duration Categories & Attention Span Test
This query utilizes a CASE WHEN statement as an early gatekeeper to group content into specific duration "buckets" before calculating performance metrics.
```sql
SELECT
    CASE
        WHEN duration < 60 THEN 'Sangat Pendek (<1 Jam)'
        WHEN duration BETWEEN 60 AND 120 THEN 'Standar (1-2 Jam)'
        ELSE 'Panjang (>2 Jam)'
    END AS kategori_durasi,
    COUNT(*) AS jumlah_konten,
    ROUND(AVG(rating::numeric), 2) AS rata_rata_rating,
    ROUND(AVG(vote::int), 0) AS rata_rata_vote
FROM netflix_shows
WHERE duration IS NOT NULL
GROUP BY 1
ORDER BY rata_rata_rating DESC;
```

### Experiment 3: Localization Efficiency (Non-US Markets)
*This query filters the performance of international producers since 2010, applying a minimum sample threshold to maintain statistical validity.*
```sql
SELECT
    country,
    COUNT(*) AS jumlah_konten,
    ROUND(AVG(rating::numeric), 2) AS rata_rata_rating,
    SUM(vote::int) AS total_daya_tarik
FROM netflix_shows
WHERE country <> 'Unknown'
    AND country <> 'United States'
    AND year >= 2010 -- Filtering for modern trends
    AND rating IS NOT NULL
GROUP BY country
HAVING COUNT(*) >= 10 -- Removing bias from countries with too few samples
ORDER BY rata_rata_rating DESC, total_daya_tarik DESC
LIMIT 5;
```
*Logic Breakdown: The WHERE clause executes early filtering to save memory computation, while the HAVING clause is used after grouping to eliminate countries with less than 10 total productions.*

## 📊 Key Insights & Dashboard
Full Power BI Dashboard
The dashboard was designed with the Netflix Dark Mode + Red Accent corporate identity, using an F-Pattern layout for intuitive executive scanning.

![Netflix Content Strategy Dashboard](Images/dashboard.png)

### Dashboard Features:

* Market Gap Scatter Plot: Plots genres by Rating vs. Volume, instantly revealing underserved high-quality niches vs. crowded low-quality genres.
* Duration Distribution (Dual-Axis): Compares rating and vote volume across content length categories on a single chart.
* Country ROI Table: Ranks non-US countries by quality-to-quantity efficiency.

### Key Findings
1. Film-Noir is a Hidden Gem, "News" is Statistical Noise Market gap analysis revealed Film-Noir as the most underserved genre: only 5 titles, yet averaging 7.26 rating and ~37,500 votes/title. This is real demand. "News" appearing with 8.40 rating is misleading: only 2 titles with 482 total votes. The scatter quadrant separates true market gaps from data anomalies.
2. The "Short Attention Span" Myth is Dead Long-form content (>2 hours) averages 49,038 votes per title, the highest of any duration category. Not only does it maintain competitive ratings, it dominates audience engagement.
3. United Kingdom: Maximum Quality, Minimum Volume UK produces only 30 titles but achieves the highest average global rating (7.10) among all non-US producers. Quality over quantity, proven by data.

## 💡 Strategic Recommendations
1. Fund long-form original productions and license Film-Noir independent titles to capture an underserved audience with low competition.
2. Prioritize UK-based studios as the primary target for international content funding based on proven quality-to-volume efficiency.

## 📂 Repository Structure
```text
├── data/
│   ├── netflix_new.csv        # Raw Netflix catalog data
├── sql/
│   ├── explore.sql            # PostgreSQL EDA queries
│   └── results/               # Aggregated query result tables (.csv)
│       ├── nichie_new.csv     # Genre market gap analysis results
│       ├── duration_analyst.csv  # Duration vs performance results
│       └── country_roi.csv    # Country efficiency ranking results
├── images/
│   └── dashboard.png          # Power BI dashboard screenshot
├── Porto1.pbix                # Power BI Desktop source file
└── README.md
```

## 🚀 How to View
1. View the Dashboard Screenshot Open images/dashboard.png directly, or visit the Portfolio Website for the full visual breakdown.
2. Open Power BI Dashboard (Interactive), Download and install Power BI Desktop (free). Open Porto1.pbix in Power BI Desktop to explore all interactive filters.
