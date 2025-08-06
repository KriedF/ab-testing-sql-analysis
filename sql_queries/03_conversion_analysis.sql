-- Conversion Funnel and Time-to-Convert Analysis
-- Business Question: How does the new algorithm affect user behavior patterns?

-- Analysis 1: Time to Conversion
WITH conversion_timing AS (
    SELECT 
        test_group,
        user_id,
        converted,
        CASE 
            WHEN converted = 1 THEN 
                DATE('2024-07-08') - DATE(test_start_date)  -- Days to convert
            ELSE NULL 
        END as days_to_convert
    FROM ab_test_results
    WHERE converted = 1
)

SELECT 
    'Conversion Timing Analysis' as analysis_type,
    test_group,
    COUNT(*) as converted_users,
    ROUND(AVG(days_to_convert), 1) as avg_days_to_convert,
    MIN(days_to_convert) as fastest_conversion_days,
    MAX(days_to_convert) as slowest_conversion_days
FROM conversion_timing
GROUP BY test_group

UNION ALL

-- Analysis 2: User Engagement Levels by Group
SELECT 
    'Engagement Distribution' as analysis_type,
    test_group,
    COUNT(*) as users_in_group,
    ROUND(AVG(content_views), 1) as avg_content_views,
    ROUND(AVG(time_on_platform_minutes), 1) as avg_minutes_on_platform,
    -- High engagement users (top 25% of content views)
    COUNT(CASE WHEN content_views > 30 THEN 1 END) as high_engagement_users
FROM ab_test_results
GROUP BY test_group

UNION ALL

-- Analysis 3: Conversion Rate by Engagement Level
SELECT 
    'Conversion by Engagement' as analysis_type,
    CASE 
        WHEN content_views >= 40 THEN 'High Engagement (40+ views)'
        WHEN content_views >= 20 THEN 'Medium Engagement (20-39 views)'
        ELSE 'Low Engagement (<20 views)'
    END as engagement_level,
    COUNT(*) as total_users,
    ROUND((SUM(converted) * 100.0) / COUNT(*), 1) as conversion_rate,
    NULL as avg_minutes_on_platform  -- Placeholder for consistent column structure
FROM ab_test_results
GROUP BY 
    CASE 
        WHEN content_views >= 40 THEN 'High Engagement (40+ views)'
        WHEN content_views >= 20 THEN 'Medium Engagement (20-39 views)'
        ELSE 'Low Engagement (<20 views)'
    END
ORDER BY analysis_type, test_group;

-- Key Insights for Product Team:
-- 1. If treatment group converts faster = algorithm helps users find value quicker
-- 2. If treatment group has more high-engagement users = algorithm increases stickiness
-- 3. Conversion rates by engagement level show which user types benefit most from new algorithm
