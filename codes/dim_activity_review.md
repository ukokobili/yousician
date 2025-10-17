# `dim_activity.sql` – Code Review 

**Reviewer:** Jacob Ukokobili  
**Role:** Analytics Engineer  

---

Hello! Thanks for reaching out for a review. You did great and your CTE layout is clear and the naming keeps the logic readable. Below are the main points to help improve performance and answer your questions.

## What You've Done Well

- **Clean CTE story**: Each block handles a single job and the flow is easy to follow.
- **Straightforward naming**: Column names match the business language, so the results are easy to explain.
- **Solid feature coverage**: You already pull the right metrics: first/last songs, challenge counts, and song-after-challenge.

## Some Key Performance Issues

### 1. Correlated Subquery in `signed_up_users`

**Problem:**
```sql
where login_at = (select min(login_at) from login llb where lla.user_id = llb.user_id)
```
This runs a subquery for every single row in the login table, which is extremely slow.

**Right Approach:** 
```sql
user_base as (
    select
        user_id,
        country,
        min(login_at) as first_login
    from login
    group by user_id, country
)
```

### 2. Incorrect of Window Functions in `first_song_played` / `last_song_played`

**Problem:** `MIN/MAX(...) OVER (...)` plus a `ROW_NUMBER()` filter means the same partition gets scanned multiple times.

**Right Approach:** 
```sql
with song_summary as (
    select
        user_id,
        min_by(song_name, event_happened_at) as first_song_played,
        max_by(song_name, event_happened_at) as last_song_played,
        min(event_happened_at) as first_played_at,
        max(event_happened_at) as last_played_at
    from song_played
    group by user_id
),
```
This eliminates window functions entirely for the first/last song logic and is more readable.

**Note** For first/last aggregations, min_by()/max_by() are often cleaner than window functions!

### 3. Cartesian Join in `song_played_after_challenge_staging` (The Main Bottleneck!)

**Problem:**
```sql
from song_played
    left join challenge_opened on song_played.user_id = challenge_opened.user_id
```
When you join only on `user_id`, the database multiplies every song by every challenge **for that user**. A user with 100 songs and 50 challenges yields 5,000 intermediate rows *before you even apply your 2-second filter*. This is why your query is slow.

**Why this matters:** By adding time predicates directly to the join (`co.event_happened_at < sp.event_happened_at`), you tell the database to *only create rows for qualifying pairs*, dramatically reducing the intermediate dataset **before** the expensive calculations happen. This can give you a **100-1000x speedup** depending on your data volume.

**Right Approach:** 
```sql
song_after_challenge as (
    select
        sp.user_id,
        sp.song_name as first_challenge_song,
        co.challenge_name as first_challenge,
        sp.event_happened_at as first_song_played_after_challenge_at
    from song_played sp
    inner join challenge_opened co
        on sp.user_id = co.user_id
        and co.event_happened_at < sp.event_happened_at
        and date_part('epoch_millisecond', sp.event_happened_at)
            - date_part('epoch_millisecond', co.event_happened_at) <= 2000
    qualify row_number() over (
        partition by sp.user_id
        order by sp.event_happened_at,
                 date_part('epoch_millisecond', sp.event_happened_at)
                 - date_part('epoch_millisecond', co.event_happened_at)
    ) = 1
),
```

## An Optimized Version Summary
Here's a high-level structure of how the optimized query would look:
```sql
with
    user_base as (
        -- Group logins once and capture the first login per user
    ),
    song_summary as (
        -- Use min_by / max_by to fetch first and last songs without extra window scans
    ),
    guitar_challenge_summary as (
        -- Count distinct guitar challenges, keep other logic the same
    ),
    song_after_challenge as (
        -- Join on user AND time window, then QUALIFY the closest challenge-song pair
    ),
    final as (
        -- Join everything together
    )
select * from final;
```

## Validation & Next Steps

Once you refactor your query, run a quick sanity check:
1. Compare row counts between your old and new query on a small subset of data (e.g., 10 users)
2. Pick a few specific user IDs and verify the results match (first song, last song, challenge count should all be identical)
3. Check execution time—you should see a dramatic improvement

This is a great habit to build now. It catches any subtle logic changes early and gives you confidence in refactored code.

**Quick check on your business logic:** Your original code filtered to `where instrument = 'guitar'` in the challenge count. Does the optimized version need this too, or was that specific to guitar challenges? Make sure that business rule is preserved in your refactor.

## Incremental Loading Question

Downstream tables shouldn't be incremental yet. Matching songs to the closest challenge and tracking first/last events both require full history. Once this base table runs fast, you can revisit incremental logic for downstream summaries.

## Learning Tips

- **QUALIFY clause**: This feature is for filtering window function results without subqueries.
- **Window functions vs aggregates**: Use aggregates when you can (like `min_by`), and reserve window functions for ranking/ordering logic.
- **Join performance**: Add as many safe join predicates as you can to keep intermediate tables small. Time windows are your friend here.
- **Cartesian joins**: Always be suspicious of joins on only one or two dimensions—ask yourself if you're unintentionally multiplying rows.
- **MIN_BY()/MAX_BY()**: Perfect for returning a value tied to the earliest/latest timestamp

## Summary

This is a great start. The main performance bottleneck is the Cartesian join in `song_played_after_challenge_staging`. Fixing that alone will probably give you a **100-1000x speedup** depending on your data volume. The correlated subqueries are also problematic but likely less impactful than the join issue.

Feel free to reach out if you want to discuss any of these suggestions or need help implementing them. Great work on your first dimension model this is exactly the kind of careful feature engineering that makes analytics platforms reliable. Looking forward to seeing the optimized version.

---