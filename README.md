# Comm-Log Send Reconciliation — Xeno Data Analyst Assignment 

# Overview
This repository contains the SQL query and reconciliation bridge to compute the "target_base" metric for Merchant 501 (October 2026).

# Reconciliation Bridge

| Step | Description | Result | Reason |
| :--- | :--- | :--- | :--- |
| 0 | Naive count | 30 | Total rows returned by running "SELECT COUNT(*) FROM communication_log". |
| 1 | Exclude ineligible campaigns | 26 | Excluded 4 log rows associated with campaign 9004 (creation_status = 'approval_awaiting'). |
| 2 | Deduplicate retry chains | 22 | Deduplicated duplicate customer sends within multi-level retry chains (9001 and 9201 families), while preserving independent send events for standalone campaigns (9101). |

# Key Findings & Methodology
1. **Recursive Campaign Traversal:** Leveraged a recursive CTE ("campaign_tree") to trace multi-level retry chains back to their originating parent campaign.
2. **Eligibility Enforcements:** Filtered out unapproved creation statuses per reporting ground rules.
3. **Targeted Deduplication:** Applied dynamic logic—distinct counting customers per root campaign for retries, while distinct counting log IDs for standalone campaigns (properly accounting for re-targeting events like customer "C20").
