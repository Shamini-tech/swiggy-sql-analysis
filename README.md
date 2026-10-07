# Swiggy Restaurant Analysis (SQL)

Exploratory analysis of **148,541 Swiggy restaurant listings** across India using SQL (SQLite). The project cleans messy text data into numeric fields, then answers business questions about cuisines, chains, pricing and ratings.

## Dataset

- Source: [Swiggy Restaurants Dataset on Kaggle](https://www.kaggle.com/datasets/ashishjangra27/swiggy-restaurants-dataset)
- Columns used: `id`, `name`, `city`, `rating`, `rating_count`, `cost`, `cuisine`
- The CSV is not included in this repo because of its size. Download it from the Kaggle link above.

## Tools

- SQL (SQLite)
- DB Browser for SQLite

## Data cleaning

`rating`, `rating_count` and `cost` were stored as text, so they could not be averaged or compared directly. I created a new table, `swiggy_clean`, and left the raw table untouched:

| Raw value | Cleaned to | Column |
|---|---|---|
| `4.4`, `--` | `4.4`, `NULL` | `rating_num` |
| `₹ 200` | `200` | `cost_num` |
| `50+ ratings`, `1K+ ratings`, `Too Few Ratings` | `50`, `1000`, `NULL` | `rating_count_num` |

Validation: all 148,541 rows were kept. 61,441 listings have a rating, and 148,410 have a cost. Unrated restaurants are kept in count-based queries (restaurants per location, cuisines, chains) and excluded from rating-based queries.

## Questions answered

1. Which locations have the most restaurants?
2. What are the most common cuisine listings?
3. Which chains have the most branches?
4. Which locations have the best average rating (50+ rated restaurants)?
5. Which locations are the most expensive on average?
6. Which cuisines have the highest average rating (100+ rated restaurants)?
7. Which restaurants have a 4.5+ rating with 1,000+ ratings?
8. Which locations give the best value for money (high rating, low cost)?

All queries are in [`swiggy_analysis.sql`](swiggy_analysis.sql). Key results are in [`findings.md`](findings.md).

## How to run

1. Download `swiggy.csv` from Kaggle.
2. In DB Browser for SQLite: File > New Database, then File > Import > Table from CSV file. Name the table `swiggy`.
3. Open the Execute SQL tab and run the queries in `swiggy_analysis.sql` in order.

## Notes and limitations

- The `city` column mostly holds **neighbourhood-level locations** (for example `Indiranagar,Bangalore`), so location results are by area, not by whole city.
- Cuisine values are stored as combined strings, so `Ice Cream,Desserts` and `Desserts,Ice Cream` count as separate entries.
- About 59% of listings have no rating yet, so rating-based findings cover only the rated restaurants.
- Minimum-count filters (such as 50+ rated restaurants) stop locations with very few listings from topping the rankings.
