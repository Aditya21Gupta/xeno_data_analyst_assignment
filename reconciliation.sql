WITH RECURSIVE campaign_tree AS (
    SELECT id AS campaign_id, id AS root_id
    FROM campaign
    WHERE parent_id IS NULL

    UNION ALL
    SELECT c.id AS campaign_id, t.root_id
    FROM campaign c
    JOIN campaign_tree t ON c.parent_id = t.campaign_id
),
eligible_campaigns AS (
    SELECT id
    FROM campaign
    WHERE creation_status IN ('approved', 'aborted', 'resumed', 'stopped')
      AND processing_status = 'processed'
),
chain_info AS (
    SELECT root_id, COUNT(campaign_id) AS chain_size
    FROM campaign_tree
    GROUP BY root_id
)
SELECT 
    COUNT(DISTINCT 
        CASE 
            WHEN ci.chain_size > 1 THEN ct.root_id || '-' || cl.customer_id
            ELSE cl.id 
        END
    ) AS target_base
FROM communication_log cl
JOIN eligible_campaigns ec ON cl.communication_id = ec.id
JOIN campaign_tree ct ON cl.communication_id = ct.campaign_id
JOIN chain_info ci ON ct.root_id = ci.root_id;