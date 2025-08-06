-- Basic A/B Test Results Analysis
-- Testing new recommendation algorithm vs old algorithm
-- Business Question: Did the new algorithm improve user engagement?

SELECT 
    test_group,
    feature_version,
    COUNT(*) as total_users,
    
    -- Conversion Rate Analysis
    SUM(converted) as conversions,
    ROUND((SUM(converted) * 100.0) / COUNT(*), 2) as conversion_rate_percent,
    
    -- Engagement Metrics
    ROUND(AVG(time_on_platform_minutes), 1) as avg_time_on_platform,
    ROUND(AVG(content_views), 1) as avg_content_views,
    
    -- Quick Statistical Check
    ROUND(
        ABS((AVG(CASE WHEN test_group = 'treatment' THEN time_on_platform_minutes END) - 
             AVG(CASE WHEN test_group = 'control' THEN time_on_platform_minutes END))), 1
    ) as engagement_difference_minutes

FROM ab_test_results
GROUP BY test_group, feature_version
ORDER BY test_group;

-- Initial Insights:
-- If treatment group shows higher conversion_rate_percent and avg_content_views,
-- the new algorithm appears to be performing better
-- Next step: Statistical significance testing to confirm results are not due to chance
