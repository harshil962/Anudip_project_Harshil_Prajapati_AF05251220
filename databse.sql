-- ============================================================
-- GitHub Repo Website — PageSpeed Audit Model (Mobile)
-- Auto-generated MySQL schema + data from uploaded xlsx audit
-- Audited 13 Jul 2026
-- ============================================================

DROP DATABASE IF EXISTS pagespeed_audit;
CREATE DATABASE pagespeed_audit;
USE pagespeed_audit;

-- LEVEL 1: Category roll-up
CREATE TABLE categories (
    category_id     VARCHAR(10)  PRIMARY KEY,
    category_name   VARCHAR(100) NOT NULL,
    weight          DECIMAL(5,4) NOT NULL,
    calculated_score DECIMAL(8,4) NULL,
    reported_score  DECIMAL(6,2) NOT NULL,
    status          VARCHAR(30)  NOT NULL
);

INSERT INTO categories (category_id, category_name, weight, calculated_score, reported_score, status) VALUES
('C1', 'Performance', 0.3, 91.038483, 64, 'Needs Improvement'),
('C2', 'Accessibility', 0.2, 98.166667, 97, 'Excellent'),
('C3', 'Best Practices', 0.2, 100, 100, 'Excellent'),
('C4', 'SEO', 0.2, 100, 100, 'Excellent'),
('C5', 'Agentic Browsing', 0.1, NULL, 100, 'Excellent');

-- Overall Score row (weight = 1, rolls up all categories)
CREATE TABLE overall_score (
    id INT PRIMARY KEY AUTO_INCREMENT,
    label VARCHAR(50) NOT NULL,
    reported_score DECIMAL(6,2) NOT NULL,
    status VARCHAR(30) NOT NULL
);
INSERT INTO overall_score (label, reported_score, status) VALUES ('Overall Score', 88.6, 'Good');

-- Core Web Vitals (Field Data, latest 28-day period)
CREATE TABLE core_web_vitals (
    metric_id   INT PRIMARY KEY AUTO_INCREMENT,
    metric_name VARCHAR(100) NOT NULL,
    result      VARCHAR(30)  NOT NULL,
    status      VARCHAR(30)  NOT NULL
);
INSERT INTO core_web_vitals (metric_name, result, status) VALUES
('Largest Contentful Paint (LCP)', '2.2 s', 'Good'),
('Interaction to Next Paint (INP)', '248 ms', 'Needs Improvement'),
('Cumulative Layout Shift (CLS)', '0.03', 'Good'),
('First Contentful Paint (FCP)', '1.9 s', 'Needs Improvement'),
('Time to First Byte (TTFB)', '1.2 s', 'Needs Improvement');

-- LEVEL 2: Sub-Factor breakdown
CREATE TABLE sub_factors (
    subfactor_id VARCHAR(10) PRIMARY KEY,
    category_id  VARCHAR(10) NOT NULL,
    subfactor_name VARCHAR(100) NOT NULL,
    weight       DECIMAL(5,4) NOT NULL,
    score        DECIMAL(8,4) NOT NULL,
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);
INSERT INTO sub_factors (subfactor_id, category_id, subfactor_name, weight, score) VALUES
('P1', 'C1', 'Largest Contentful Paint (LCP)', 0.3, 100),
('A1', 'C2', 'Color Contrast', 0.2, 96.666667),
('B1', 'C3', 'HTTPS Security', 0.25, 100),
('S1', 'C4', 'Meta Title', 0.25, 100),
('P2', 'C1', 'Interaction to Next Paint (INP)', 0.25, 80.645161),
('A2', 'C2', 'Image Alt Text', 0.2, 96.666667),
('B2', 'C3', 'JavaScript Errors', 0.2, 100),
('S2', 'C4', 'Meta Description', 0.2, 100),
('P3', 'C1', 'Cumulative Layout Shift (CLS)', 0.2, 100),
('A3', 'C2', 'Form Labels', 0.15, 100),
('B3', 'C3', 'Console Errors', 0.15, 100),
('S3', 'C4', 'Heading Structure', 0.2, 100),
('P4', 'C1', 'First Contentful Paint (FCP)', 0.15, 94.736842),
('A4', 'C2', 'Keyboard Navigation', 0.15, 100),
('B4', 'C3', 'Deprecated APIs', 0.15, 100),
('S4', 'C4', 'Robots.txt', 0.15, 100),
('P5', 'C1', 'Time to First Byte (TTFB)', 0.1, 66.666667),
('A5', 'C2', 'ARIA Attributes', 0.15, 96.666667),
('B5', 'C3', 'Third-Party Libraries', 0.15, 100),
('S5', 'C4', 'Sitemap.xml', 0.1, 100),
('A6', 'C2', 'Heading Structure', 0.15, 100),
('B6', 'C3', 'Image Optimization', 0.1, 100),
('S6', 'C4', 'Mobile Friendliness', 0.1, 100);

-- LEVEL 3: Detail factors
CREATE TABLE detail_factors (
    factor_id    VARCHAR(10) PRIMARY KEY,
    subfactor_id VARCHAR(10) NOT NULL,
    factor_name  VARCHAR(150) NOT NULL,
    value        DECIMAL(10,4) NOT NULL,
    unit         VARCHAR(20)  NOT NULL,
    type         ENUM('Lower','Higher','Zero') NOT NULL,
    threshold    DECIMAL(10,4) NOT NULL,
    score        DECIMAL(8,4) NOT NULL,
    good_range   VARCHAR(30)  NOT NULL,
    flag         ENUM('OK','Fix') NOT NULL,
    FOREIGN KEY (subfactor_id) REFERENCES sub_factors(subfactor_id)
);
INSERT INTO detail_factors (factor_id, subfactor_id, factor_name, value, unit, type, threshold, score, good_range, flag) VALUES
('P1F1', 'P1', 'Largest Contentful Paint (measured)', 2.2, 's', 'Lower', 2.5, 100, '<= 2.5 s', 'OK'),
('P2F1', 'P2', 'Interaction to Next Paint (measured)', 248, 'ms', 'Lower', 200, 80.645161, '<= 200 ms', 'OK'),
('P3F1', 'P3', 'Cumulative Layout Shift (measured)', 0.03, 'score', 'Lower', 0.1, 100, '<= 0.1', 'OK'),
('P4F1', 'P4', 'First Contentful Paint (measured)', 1.9, 's', 'Lower', 1.8, 94.736842, '<= 1.8 s', 'OK'),
('P5F1', 'P5', 'Time to First Byte (measured)', 1.2, 's', 'Lower', 0.8, 66.666667, '<= 0.8 s', 'Fix'),
('A1F1', 'A1', 'Contrast Ratio', 4.6, 'ratio', 'Higher', 4.5, 100, '>= 4.5:1', 'OK'),
('A1F2', 'A1', 'Low Contrast Text', 1, 'count', 'Zero', 0, 90, '0', 'OK'),
('A1F3', 'A1', 'Low Contrast Links', 0, 'count', 'Zero', 0, 100, '0', 'OK'),
('A2F1', 'A2', 'Missing Alt Text', 0, 'count', 'Zero', 0, 100, '0', 'OK'),
('A2F2', 'A2', 'Empty Alt Attributes', 1, 'count', 'Zero', 0, 90, '0', 'OK'),
('A2F3', 'A2', 'Redundant Alt Text', 0, 'count', 'Zero', 0, 100, '0', 'OK'),
('A3F1', 'A3', 'Missing Labels', 0, 'count', 'Zero', 0, 100, '0', 'OK'),
('A3F2', 'A3', 'Placeholder-Only Inputs', 0, 'count', 'Zero', 0, 100, '0', 'OK'),
('A3F3', 'A3', 'Ambiguous Labels', 0, 'count', 'Zero', 0, 100, '0', 'OK'),
('A4F1', 'A4', 'Keyboard Traps', 0, 'count', 'Zero', 0, 100, '0', 'OK'),
('A4F2', 'A4', 'Missing Focus Indicators', 0, 'count', 'Zero', 0, 100, '0', 'OK'),
('A4F3', 'A4', 'Tab Order Errors', 0, 'count', 'Zero', 0, 100, '0', 'OK'),
('A5F1', 'A5', 'Missing ARIA Labels', 0, 'count', 'Zero', 0, 100, '0', 'OK'),
('A5F2', 'A5', 'Invalid ARIA Roles', 0, 'count', 'Zero', 0, 100, '0', 'OK'),
('A5F3', 'A5', 'Redundant ARIA', 1, 'count', 'Zero', 0, 90, '0', 'OK'),
('A6F1', 'A6', 'Skipped Heading Levels', 0, 'count', 'Zero', 0, 100, '0', 'OK'),
('A6F2', 'A6', 'Multiple H1 Tags', 0, 'count', 'Zero', 0, 100, '0', 'OK'),
('A6F3', 'A6', 'Empty Headings', 0, 'count', 'Zero', 0, 100, '0', 'OK'),
('B1F1', 'B1', 'HTTPS Not Enforced', 0, 'count', 'Zero', 0, 100, '0', 'OK'),
('B1F2', 'B1', 'Mixed Content Warnings', 0, 'count', 'Zero', 0, 100, '0', 'OK'),
('B1F3', 'B1', 'Insecure Requests', 0, 'count', 'Zero', 0, 100, '0', 'OK'),
('B2F1', 'B2', 'JS Runtime Errors', 0, 'count', 'Zero', 0, 100, '0', 'OK'),
('B2F2', 'B2', 'Deprecated JS APIs Used', 0, 'count', 'Zero', 0, 100, '0', 'OK'),
('B2F3', 'B2', 'Unhandled Promise Rejections', 0, 'count', 'Zero', 0, 100, '0', 'OK'),
('B3F1', 'B3', 'Errors Logged', 0, 'count', 'Zero', 0, 100, '0', 'OK'),
('B3F2', 'B3', 'Warnings Logged', 0, 'count', 'Zero', 0, 100, '0', 'OK'),
('B3F3', 'B3', 'Failed Network Requests', 0, 'count', 'Zero', 0, 100, '0', 'OK'),
('B4F1', 'B4', 'Deprecated APIs Used', 0, 'count', 'Zero', 0, 100, '0', 'OK'),
('B4F2', 'B4', 'Vendor-Prefixed CSS', 0, 'count', 'Zero', 0, 100, '0', 'OK'),
('B4F3', 'B4', 'Old Library Versions', 0, 'count', 'Zero', 0, 100, '0', 'OK'),
('B5F1', 'B5', 'Outdated Libraries', 0, 'count', 'Zero', 0, 100, '0', 'OK'),
('B5F2', 'B5', 'Unused Libraries Loaded', 0, 'count', 'Zero', 0, 100, '0', 'OK'),
('B5F3', 'B5', 'Known Vulnerabilities', 0, 'count', 'Zero', 0, 100, '0', 'OK'),
('B6F1', 'B6', 'Unoptimized Images', 0, 'count', 'Zero', 0, 100, '0', 'OK'),
('B6F2', 'B6', 'Missing WebP Format', 0, 'count', 'Zero', 0, 100, '0', 'OK'),
('B6F3', 'B6', 'Oversized Images', 0, 'count', 'Zero', 0, 100, '0', 'OK'),
('S1F1', 'S1', 'Missing Meta Title', 0, 'count', 'Zero', 0, 100, '0', 'OK'),
('S1F2', 'S1', 'Duplicate Titles', 0, 'count', 'Zero', 0, 100, '0', 'OK'),
('S1F3', 'S1', 'Title Length Issues', 0, 'count', 'Zero', 0, 100, '0', 'OK'),
('S2F1', 'S2', 'Missing Description', 0, 'count', 'Zero', 0, 100, '0', 'OK'),
('S2F2', 'S2', 'Duplicate Description', 0, 'count', 'Zero', 0, 100, '0', 'OK'),
('S2F3', 'S2', 'Description Length Issues', 0, 'count', 'Zero', 0, 100, '0', 'OK'),
('S3F1', 'S3', 'Missing H1', 0, 'count', 'Zero', 0, 100, '0', 'OK'),
('S3F2', 'S3', 'Multiple H1 Tags', 0, 'count', 'Zero', 0, 100, '0', 'OK'),
('S3F3', 'S3', 'Poor Heading Hierarchy', 0, 'count', 'Zero', 0, 100, '0', 'OK'),
('S4F1', 'S4', 'Robots.txt Missing', 0, 'count', 'Zero', 0, 100, '0', 'OK'),
('S4F2', 'S4', 'Blocked Important Pages', 0, 'count', 'Zero', 0, 100, '0', 'OK'),
('S4F3', 'S4', 'Syntax Errors', 0, 'count', 'Zero', 0, 100, '0', 'OK'),
('S5F1', 'S5', 'Sitemap Missing', 0, 'count', 'Zero', 0, 100, '0', 'OK'),
('S5F2', 'S5', 'Broken Links in Sitemap', 0, 'count', 'Zero', 0, 100, '0', 'OK'),
('S5F3', 'S5', 'Outdated Sitemap', 0, 'count', 'Zero', 0, 100, '0', 'OK'),
('S6F1', 'S6', 'Viewport Not Set', 0, 'count', 'Zero', 0, 100, '0', 'OK'),
('S6F2', 'S6', 'Tap Targets Too Small', 0, 'count', 'Zero', 0, 100, '0', 'OK'),
('S6F3', 'S6', 'Text Too Small to Read', 0, 'count', 'Zero', 0, 100, '0', 'OK');

-- LEVEL 4: Optimization Suggestions
CREATE TABLE optimization_suggestions (
    suggestion_id  VARCHAR(10) PRIMARY KEY,
    subfactor_id   VARCHAR(10) NOT NULL,
    problem        TEXT NOT NULL,
    recommendation TEXT NOT NULL,
    est_score_gain DECIMAL(8,4) NOT NULL,
    priority       ENUM('High','Medium','Low') NOT NULL,
    FOREIGN KEY (subfactor_id) REFERENCES sub_factors(subfactor_id)
);
INSERT INTO optimization_suggestions (suggestion_id, subfactor_id, problem, recommendation, est_score_gain, priority) VALUES
('SG1', 'P1', 'Large, unoptimized banner/hero images slow down LCP (measured 2.2 s)', 'Compress images, use WebP/AVIF, and lazy-load offscreen images', 0, 'High'),
('SG2', 'P2', 'Heavy JavaScript execution delays interaction response (measured 248 ms INP)', 'Code-split JS, defer non-critical scripts, remove unused code', 4.83871, 'High'),
('SG3', 'P4', 'Render-blocking CSS delays first paint (measured 1.9 s FCP)', 'Minify CSS & JavaScript and inline critical CSS', 0.789474, 'Medium'),
('SG4', 'P5', 'Backend processing / server latency slows initial response (measured 1.2 s TTFB)', 'Enable caching, optimize server config, use a CDN', 3.333333, 'Medium'),
('SG5', 'A1', 'Minor low-contrast text found on the page', 'Increase contrast ratio to at least 4.5:1 for all body text', 0.666667, 'Low'),
('SG6', 'A5', 'A redundant ARIA attribute was found', 'Review and remove unnecessary ARIA roles/attributes', 0.5, 'Low'),
('SG7', 'B1', 'Keep HTTPS/mixed-content checks in place as the site evolves', 'Periodically re-scan for mixed content as new pages/assets are added', 0, 'Low'),
('SG8', 'S1', 'Maintain unique, well-sized meta titles as new pages are added', 'Add a title-length and duplicate-title check to the CI pipeline', 0, 'Low');

-- Helpful indexes
CREATE INDEX idx_subfactors_category ON sub_factors(category_id);
CREATE INDEX idx_detailfactors_subfactor ON detail_factors(subfactor_id);
CREATE INDEX idx_suggestions_subfactor ON optimization_suggestions(subfactor_id);