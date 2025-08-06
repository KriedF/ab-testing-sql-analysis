-- Statistical Significance Testing for A/B Test Results
-- Determines if observed differences are statistically meaningful
-- Business Question: Can we confidently say the new algorithm is better?

-- Step 1: Calculate basic statistics for each group
WITH test_stats AS (
    SELECT 
        test_group,
        COUNT(*) as sample_size,
        SUM(converted) as conversions,
        ROUND((SUM(converted) * 100.0) / COUNT(*), 2) as conversion_rate,
        AVG(time_on_platform_minutes) as avg_engagement,
        STDDEV(time_on_platform_minutes) as std_dev_engagement,
        AVG(content_views) as avg_content_views
    FROM ab_test_results
    GROUP BY test_group
),

-- Step 2: Compare the two groups directly
comparison AS (
    SELECT 
        MAX(CASE WHEN test_group = 'control' THEN conversion_rate END) as control_conversion,
        MAX(CASE WHEN test_group = 'treatment' THEN conversion_rate END) as treatment_conversion,
        MAX(CASE WHEN test_group = 'control' THEN sample_size END) as control_sample,
        MAX(CASE WHEN test_group = 'treatment' THEN sample_size END) as treatment_sample,
        MAX(CASE WHEN test_group = 'control' THEN avg_engagement END) as control_engagement,
        MAX(CASE WHEN test_group = 'treatment' THEN avg_engagement END) as treatment_engagement
    FROM test_stats
)

SELECT 
    'A/B Test Results Summary' as analysis_type,
    
    -- Conversion Rate Comparison
    control_conversion as control_conversion_rate,
    treatment_conversion as treatment_conversion_rate,
    ROUND(treatment_conversion - control_conversion, 2) as conversion_lift_percentage,
    
    -- Engagement Comparison  
    ROUND(control_engagement, 1) as control_avg_minutes,
    ROUND(treatment_engagement, 1) as treatment_avg_minutes,
    ROUND(treatment_engagement - control_engagement, 1) as engagement_lift_minutes,
    
    -- Sample Size Check
    control_sample + treatment_sample as total_sample_size,
    
    -- Statistical Significance Check (Simplified)
    CASE 
        WHEN ABS(treatment_conversion - control_conversion) > 5.0 
            AND (control_sample + treatment_sample) > 20 
        THEN 'Likely Significant - Recommend Implementation'
        WHEN ABS(treatment_conversion - control_conversion) > 2.0 
            AND (control_sample + treatment_sample) > 20
        THEN 'Possibly Significant - Need Larger Sample'
        ELSE 'Not Significant - Continue Testing'
    END as business_recommendation

FROM comparison;

-- Business Interpretation:
-- Conversion lift > 5% with decent sample size = Strong signal to implement
-- Engagement lift > 20 minutes = Users finding more value in new algorithm
-- Always consider practical significance alongside statistical significance
