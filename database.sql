-- ============================================
-- AGM BAR - MySQL Database Schema
-- Multi-tenant architecture with subdomain support
-- ============================================

-- Create database
CREATE DATABASE IF NOT EXISTS agmbar_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE agmbar_db;

-- ============================================
-- 1. BUSINESSES TABLE
-- Core table for each bar/restaurant/lounge
-- ============================================
CREATE TABLE businesses (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    subdomain VARCHAR(50) UNIQUE NOT NULL,
    business_name VARCHAR(255) NOT NULL,
    business_type ENUM('bar', 'restaurant', 'lounge', 'cafe', 'hotel', 'other') DEFAULT 'bar',
    slug VARCHAR(100) UNIQUE NOT NULL,
    
    -- Contact Information
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    address TEXT,
    city VARCHAR(100),
    state VARCHAR(100),
    country VARCHAR(100) DEFAULT 'Nigeria',
    
    -- Branding
    logo_url VARCHAR(500),
    banner_url VARCHAR(500),
    primary_color VARCHAR(7) DEFAULT '#3b82f6',
    secondary_color VARCHAR(7) DEFAULT '#8b5cf6',
    
    -- Business Details
    description TEXT,
    tagline VARCHAR(255),
    website_url VARCHAR(255),
    social_facebook VARCHAR(255),
    social_instagram VARCHAR(255),
    social_twitter VARCHAR(255),
    
    -- Subscription & Status
    subscription_plan ENUM('trial', 'basic', 'pro', 'enterprise') DEFAULT 'trial',
    subscription_status ENUM('active', 'inactive', 'suspended', 'cancelled') DEFAULT 'active',
    trial_ends_at DATETIME,
    subscription_starts_at DATETIME,
    subscription_ends_at DATETIME,
    
    -- QR Code
    qr_code_url VARCHAR(500),
    
    -- Status
    is_active BOOLEAN DEFAULT TRUE,
    is_verified BOOLEAN DEFAULT FALSE,
    onboarding_completed BOOLEAN DEFAULT FALSE,
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    
    INDEX idx_subdomain (subdomain),
    INDEX idx_slug (slug),
    INDEX idx_subscription_status (subscription_status),
    INDEX idx_is_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 2. AI PERSONALITY CONFIGURATION TABLE
-- Custom AI personality for each business
-- ============================================
CREATE TABLE ai_personalities (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    business_id CHAR(36) UNIQUE NOT NULL,
    
    -- Basic Personality Traits
    personality_name VARCHAR(100) DEFAULT 'Assistant',
    personality_type ENUM('friendly', 'professional', 'casual', 'energetic', 'sophisticated', 'humorous') DEFAULT 'friendly',
    tone ENUM('formal', 'informal', 'balanced') DEFAULT 'balanced',
    
    -- Greeting & Introduction
    greeting_message TEXT,
    introduction TEXT,
    farewell_message TEXT,
    
    -- Communication Style (1-10 scale)
    friendliness_level TINYINT DEFAULT 7 CHECK (friendliness_level BETWEEN 1 AND 10),
    formality_level TINYINT DEFAULT 5 CHECK (formality_level BETWEEN 1 AND 10),
    humor_level TINYINT DEFAULT 5 CHECK (humor_level BETWEEN 1 AND 10),
    chattiness_level TINYINT DEFAULT 6 CHECK (chattiness_level BETWEEN 1 AND 10),
    
    -- Language & Response Style
    primary_language VARCHAR(10) DEFAULT 'en',
    use_emojis BOOLEAN DEFAULT TRUE,
    use_local_slang BOOLEAN DEFAULT FALSE,
    response_length ENUM('concise', 'moderate', 'detailed') DEFAULT 'moderate',
    
    -- Business Knowledge
    specialties TEXT, -- JSON array of what the AI should emphasize
    unique_selling_points TEXT, -- JSON array
    house_rules TEXT, -- JSON array
    promotions_info TEXT, -- JSON array of current promotions
    
    -- Behavioral Guidelines
    upsell_strategy ENUM('passive', 'moderate', 'aggressive') DEFAULT 'moderate',
    handles_complaints BOOLEAN DEFAULT TRUE,
    can_take_orders BOOLEAN DEFAULT TRUE,
    can_make_reservations BOOLEAN DEFAULT TRUE,
    can_play_games BOOLEAN DEFAULT TRUE,
    
    -- Custom Instructions
    custom_instructions TEXT, -- Free-form instructions for AI behavior
    restricted_topics TEXT, -- JSON array of topics to avoid
    preferred_responses TEXT, -- JSON object of situation -> response mappings
    
    -- Voice & Character
    character_description TEXT, -- How the AI should describe itself
    background_story TEXT, -- Optional backstory for roleplay
    
    -- Advanced Settings
    context_awareness_level ENUM('basic', 'medium', 'advanced') DEFAULT 'medium',
    proactive_suggestions BOOLEAN DEFAULT TRUE,
    remembers_preferences BOOLEAN DEFAULT TRUE,
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE,
    INDEX idx_business_id (business_id),
    INDEX idx_personality_type (personality_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 3. BUSINESS SETTINGS TABLE
-- Operational settings for each business
-- ============================================
CREATE TABLE business_settings (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    business_id CHAR(36) UNIQUE NOT NULL,
    
    -- Operating Hours (JSON format)
    operating_hours JSON, -- {"monday": {"open": "09:00", "close": "22:00", "closed": false}}
    timezone VARCHAR(50) DEFAULT 'Africa/Lagos',
    
    -- Currency & Pricing
    currency VARCHAR(3) DEFAULT 'NGN',
    tax_rate DECIMAL(5,2) DEFAULT 0.00,
    service_charge_rate DECIMAL(5,2) DEFAULT 0.00,
    
    -- Feature Toggles
    enable_ai_chat BOOLEAN DEFAULT TRUE,
    enable_ordering BOOLEAN DEFAULT TRUE,
    enable_reservations BOOLEAN DEFAULT TRUE,
    enable_games BOOLEAN DEFAULT TRUE,
    enable_payments BOOLEAN DEFAULT FALSE,
    enable_loyalty BOOLEAN DEFAULT FALSE,
    enable_reviews BOOLEAN DEFAULT TRUE,
    
    -- Ordering Settings
    min_order_amount DECIMAL(10,2) DEFAULT 0.00,
    max_order_amount DECIMAL(10,2),
    requires_phone_verification BOOLEAN DEFAULT FALSE,
    auto_accept_orders BOOLEAN DEFAULT FALSE,
    estimated_prep_time_minutes INT DEFAULT 30,
    
    -- Reservation Settings
    max_party_size INT DEFAULT 20,
    min_advance_booking_hours INT DEFAULT 2,
    max_advance_booking_days INT DEFAULT 30,
    requires_deposit BOOLEAN DEFAULT FALSE,
    deposit_amount DECIMAL(10,2),
    
    -- Notification Settings
    notify_on_new_order BOOLEAN DEFAULT TRUE,
    notify_on_new_reservation BOOLEAN DEFAULT TRUE,
    notify_on_cancellation BOOLEAN DEFAULT TRUE,
    
    -- Integration Settings
    whatsapp_enabled BOOLEAN DEFAULT FALSE,
    whatsapp_number VARCHAR(20),
    telegram_enabled BOOLEAN DEFAULT FALSE,
    telegram_chat_id VARCHAR(100),
    
    -- Table Management
    total_tables INT DEFAULT 0,
    table_prefix VARCHAR(10) DEFAULT 'T',
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE,
    INDEX idx_business_id (business_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 4. USERS TABLE
-- Admin users who manage businesses
-- ============================================
CREATE TABLE users (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    business_id CHAR(36) NOT NULL,
    
    -- Authentication
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    
    -- Profile
    full_name VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    avatar_url VARCHAR(500),
    
    -- Role & Permissions
    role ENUM('owner', 'admin', 'manager', 'staff') DEFAULT 'admin',
    permissions JSON, -- Array of specific permissions
    
    -- Status
    is_active BOOLEAN DEFAULT TRUE,
    is_verified BOOLEAN DEFAULT FALSE,
    email_verified_at TIMESTAMP NULL,
    
    -- Security
    last_login_at TIMESTAMP NULL,
    last_login_ip VARCHAR(45),
    failed_login_attempts INT DEFAULT 0,
    locked_until TIMESTAMP NULL,
    password_reset_token VARCHAR(100),
    password_reset_expires_at TIMESTAMP NULL,
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    
    FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE,
    INDEX idx_email (email),
    INDEX idx_business_id (business_id),
    INDEX idx_role (role)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 5. MENU CATEGORIES TABLE
-- ============================================
CREATE TABLE menu_categories (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    business_id CHAR(36) NOT NULL,
    
    name VARCHAR(100) NOT NULL,
    description TEXT,
    display_order INT DEFAULT 0,
    icon VARCHAR(50), -- Icon identifier
    is_active BOOLEAN DEFAULT TRUE,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE,
    INDEX idx_business_id (business_id),
    INDEX idx_display_order (display_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 6. MENU ITEMS TABLE
-- ============================================
CREATE TABLE menu_items (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    business_id CHAR(36) NOT NULL,
    category_id CHAR(36) NOT NULL,
    
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    
    -- Item Details
    image_url VARCHAR(500),
    preparation_time_minutes INT,
    
    -- Inventory
    available BOOLEAN DEFAULT TRUE,
    stock_quantity INT,
    low_stock_threshold INT,
    
    -- Nutritional Info (optional)
    calories INT,
    is_vegetarian BOOLEAN DEFAULT FALSE,
    is_vegan BOOLEAN DEFAULT FALSE,
    is_gluten_free BOOLEAN DEFAULT FALSE,
    allergens TEXT, -- JSON array
    
    -- Modifiers & Options
    has_modifiers BOOLEAN DEFAULT FALSE,
    modifiers JSON, -- Array of modifier options
    
    -- Popularity & Stats
    total_orders INT DEFAULT 0,
    popularity_score DECIMAL(3,2) DEFAULT 0.00,
    
    -- Display
    display_order INT DEFAULT 0,
    is_featured BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    
    FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES menu_categories(id) ON DELETE CASCADE,
    INDEX idx_business_id (business_id),
    INDEX idx_category_id (category_id),
    INDEX idx_available (available),
    INDEX idx_price (price)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 7. ORDERS TABLE
-- ============================================
CREATE TABLE orders (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    business_id CHAR(36) NOT NULL,
    order_number VARCHAR(50) UNIQUE NOT NULL,
    
    -- Customer Information
    customer_name VARCHAR(255) NOT NULL,
    customer_phone VARCHAR(20) NOT NULL,
    customer_email VARCHAR(255),
    table_number VARCHAR(20),
    
    -- Order Details
    order_type ENUM('dine_in', 'takeaway', 'delivery') DEFAULT 'dine_in',
    status ENUM('pending', 'confirmed', 'preparing', 'ready', 'delivered', 'completed', 'cancelled') DEFAULT 'pending',
    
    -- Pricing
    subtotal DECIMAL(10,2) NOT NULL,
    tax_amount DECIMAL(10,2) DEFAULT 0.00,
    service_charge DECIMAL(10,2) DEFAULT 0.00,
    discount_amount DECIMAL(10,2) DEFAULT 0.00,
    total_amount DECIMAL(10,2) NOT NULL,
    
    -- Payment
    payment_status ENUM('pending', 'paid', 'failed', 'refunded') DEFAULT 'pending',
    payment_method ENUM('cash', 'card', 'transfer', 'online') DEFAULT 'cash',
    payment_reference VARCHAR(100),
    
    -- Special Instructions
    special_instructions TEXT,
    internal_notes TEXT,
    
    -- Delivery (if applicable)
    delivery_address TEXT,
    delivery_fee DECIMAL(10,2),
    estimated_delivery_time DATETIME,
    
    -- AI Session Reference
    session_id CHAR(36),
    
    -- Timestamps
    confirmed_at TIMESTAMP NULL,
    completed_at TIMESTAMP NULL,
    cancelled_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE,
    INDEX idx_business_id (business_id),
    INDEX idx_order_number (order_number),
    INDEX idx_status (status),
    INDEX idx_created_at (created_at),
    INDEX idx_customer_phone (customer_phone)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 8. ORDER ITEMS TABLE
-- ============================================
CREATE TABLE order_items (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    order_id CHAR(36) NOT NULL,
    menu_item_id CHAR(36) NOT NULL,
    
    item_name VARCHAR(255) NOT NULL, -- Snapshot of item name
    item_price DECIMAL(10,2) NOT NULL, -- Snapshot of price
    quantity INT NOT NULL DEFAULT 1,
    subtotal DECIMAL(10,2) NOT NULL,
    
    -- Modifiers
    modifiers JSON, -- Selected modifiers for this item
    special_instructions TEXT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (menu_item_id) REFERENCES menu_items(id) ON DELETE RESTRICT,
    INDEX idx_order_id (order_id),
    INDEX idx_menu_item_id (menu_item_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 9. RESERVATIONS TABLE
-- ============================================
CREATE TABLE reservations (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    business_id CHAR(36) NOT NULL,
    reservation_code VARCHAR(50) UNIQUE NOT NULL,
    
    -- Customer Information
    customer_name VARCHAR(255) NOT NULL,
    customer_phone VARCHAR(20) NOT NULL,
    customer_email VARCHAR(255),
    
    -- Reservation Details
    reservation_date DATE NOT NULL,
    reservation_time TIME NOT NULL,
    party_size INT NOT NULL,
    table_number VARCHAR(20),
    
    -- Status
    status ENUM('pending', 'confirmed', 'seated', 'completed', 'cancelled', 'no_show') DEFAULT 'pending',
    
    -- Special Requests
    special_requests TEXT,
    occasion VARCHAR(100), -- birthday, anniversary, etc.
    internal_notes TEXT,
    
    -- Payment (if deposit required)
    requires_deposit BOOLEAN DEFAULT FALSE,
    deposit_amount DECIMAL(10,2),
    deposit_paid BOOLEAN DEFAULT FALSE,
    
    -- AI Session Reference
    session_id CHAR(36),
    
    -- Reminders
    reminder_sent BOOLEAN DEFAULT FALSE,
    reminder_sent_at TIMESTAMP NULL,
    
    -- Timestamps
    confirmed_at TIMESTAMP NULL,
    cancelled_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE,
    INDEX idx_business_id (business_id),
    INDEX idx_reservation_code (reservation_code),
    INDEX idx_reservation_date (reservation_date),
    INDEX idx_status (status),
    INDEX idx_customer_phone (customer_phone)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 10. AI CHAT SESSIONS TABLE
-- Track user interaction sessions
-- ============================================
CREATE TABLE chat_sessions (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    business_id CHAR(36) NOT NULL,
    
    session_identifier VARCHAR(100), -- Anonymous identifier (table_5_guest)
    user_agent TEXT,
    ip_address VARCHAR(45),
    
    -- Session Stats
    message_count INT DEFAULT 0,
    total_duration_seconds INT DEFAULT 0,
    
    -- Context
    table_number VARCHAR(20),
    customer_name VARCHAR(255),
    customer_phone VARCHAR(20),
    
    -- Session Outcome
    resulted_in_order BOOLEAN DEFAULT FALSE,
    resulted_in_reservation BOOLEAN DEFAULT FALSE,
    played_game BOOLEAN DEFAULT FALSE,
    
    started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_activity_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    ended_at TIMESTAMP NULL,
    
    FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE,
    INDEX idx_business_id (business_id),
    INDEX idx_started_at (started_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 11. CHAT MESSAGES TABLE
-- Store conversation history
-- ============================================
CREATE TABLE chat_messages (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    session_id CHAR(36) NOT NULL,
    business_id CHAR(36) NOT NULL,
    
    role ENUM('user', 'assistant', 'system') NOT NULL,
    content TEXT NOT NULL,
    
    -- AI Metadata
    intent VARCHAR(100), -- Detected user intent
    confidence DECIMAL(3,2), -- AI confidence score
    ai_provider VARCHAR(50), -- groq, gemini
    ai_model VARCHAR(100),
    tokens_used INT,
    
    -- Context
    context_data JSON, -- Additional context used for this message
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (session_id) REFERENCES chat_sessions(id) ON DELETE CASCADE,
    FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE,
    INDEX idx_session_id (session_id),
    INDEX idx_business_id (business_id),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 12. GAME SESSIONS TABLE
-- Track game interactions
-- ============================================
CREATE TABLE game_sessions (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    business_id CHAR(36) NOT NULL,
    chat_session_id CHAR(36),
    
    game_id VARCHAR(50) NOT NULL, -- quiz, truth_or_dare, trivia, etc.
    game_type ENUM('solo', 'group') NOT NULL,
    
    -- Session Details
    player_count INT DEFAULT 1,
    difficulty_level ENUM('easy', 'medium', 'hard') DEFAULT 'medium',
    
    -- Scoring
    total_questions INT DEFAULT 0,
    correct_answers INT DEFAULT 0,
    final_score INT DEFAULT 0,
    
    -- Status
    status ENUM('active', 'completed', 'abandoned') DEFAULT 'active',
    
    started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP NULL,
    duration_seconds INT,
    
    FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE,
    FOREIGN KEY (chat_session_id) REFERENCES chat_sessions(id) ON DELETE SET NULL,
    INDEX idx_business_id (business_id),
    INDEX idx_game_id (game_id),
    INDEX idx_started_at (started_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 13. NOTIFICATIONS TABLE
-- Track sent notifications
-- ============================================
CREATE TABLE notifications (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    business_id CHAR(36) NOT NULL,
    
    notification_type ENUM('order', 'reservation', 'cancellation', 'system', 'marketing') NOT NULL,
    channel ENUM('whatsapp', 'telegram', 'email', 'sms', 'in_app') NOT NULL,
    
    recipient VARCHAR(255) NOT NULL, -- Phone, email, or chat_id
    subject VARCHAR(255),
    message TEXT NOT NULL,
    
    -- Reference
    reference_type VARCHAR(50), -- order, reservation
    reference_id CHAR(36),
    
    -- Status
    status ENUM('pending', 'sent', 'delivered', 'failed') DEFAULT 'pending',
    sent_at TIMESTAMP NULL,
    delivered_at TIMESTAMP NULL,
    failed_reason TEXT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE,
    INDEX idx_business_id (business_id),
    INDEX idx_status (status),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 14. ANALYTICS TABLE
-- Daily aggregated analytics per business
-- ============================================
CREATE TABLE analytics (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    business_id CHAR(36) NOT NULL,
    date DATE NOT NULL,
    
    -- Orders
    total_orders INT DEFAULT 0,
    completed_orders INT DEFAULT 0,
    cancelled_orders INT DEFAULT 0,
    total_revenue DECIMAL(10,2) DEFAULT 0.00,
    average_order_value DECIMAL(10,2) DEFAULT 0.00,
    
    -- Reservations
    total_reservations INT DEFAULT 0,
    confirmed_reservations INT DEFAULT 0,
    cancelled_reservations INT DEFAULT 0,
    no_shows INT DEFAULT 0,
    
    -- AI Interactions
    total_chat_sessions INT DEFAULT 0,
    total_messages INT DEFAULT 0,
    average_session_duration_seconds INT DEFAULT 0,
    
    -- Games
    total_game_sessions INT DEFAULT 0,
    unique_players INT DEFAULT 0,
    
    -- Popular Items (JSON)
    popular_items JSON,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE,
    UNIQUE KEY unique_business_date (business_id, date),
    INDEX idx_business_id (business_id),
    INDEX idx_date (date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 15. ONBOARDING QUESTIONNAIRE TABLE
-- Store onboarding responses
-- ============================================
CREATE TABLE onboarding_questionnaires (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    business_id CHAR(36) UNIQUE NOT NULL,
    
    -- Business Vibe Questions
    business_atmosphere ENUM('casual', 'upscale', 'lively', 'intimate', 'family_friendly') NOT NULL,
    target_audience VARCHAR(255), -- young professionals, families, students, etc.
    price_range ENUM('budget', 'moderate', 'premium', 'luxury') NOT NULL,
    
    -- AI Personality Questions
    preferred_ai_name VARCHAR(100),
    ai_gender ENUM('male', 'female', 'neutral') DEFAULT 'neutral',
    preferred_communication_style TEXT,
    
    -- Service Style
    service_speed ENUM('quick', 'standard', 'relaxed') DEFAULT 'standard',
    interaction_preference ENUM('minimal', 'helpful', 'conversational', 'entertaining') DEFAULT 'helpful',
    
    -- Unique Characteristics
    signature_items TEXT, -- What makes your business special
    house_specialties TEXT,
    customer_favorites TEXT,
    
    -- Rules & Policies
    dress_code VARCHAR(255),
    age_restrictions VARCHAR(255),
    special_policies TEXT,
    
    -- Marketing Focus
    primary_goal ENUM('increase_sales', 'improve_service', 'engage_customers', 'all') DEFAULT 'all',
    upsell_focus BOOLEAN DEFAULT TRUE,
    
    -- Additional Context
    additional_instructions TEXT,
    raw_responses JSON, -- Store all responses
    
    completed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE,
    INDEX idx_business_id (business_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- INDEXES FOR PERFORMANCE
-- ============================================

-- Composite indexes for common queries
CREATE INDEX idx_orders_business_status ON orders(business_id, status);
CREATE INDEX idx_orders_business_date ON orders(business_id, created_at);
CREATE INDEX idx_reservations_business_date ON reservations(business_id, reservation_date);
CREATE INDEX idx_chat_sessions_business_date ON chat_sessions(business_id, started_at);

-- ============================================
-- SAMPLE DATA INSERT
-- ============================================

-- Insert a sample business for testing
INSERT INTO businesses (
    id, subdomain, business_name, business_type, slug,
    email, phone, city, state, country,
    description, subscription_plan, is_active, onboarding_completed
) VALUES (
    UUID(), 'demo', 'Demo Lounge', 'lounge', 'demo-lounge',
    'demo@agmbar.com', '+2348012345678', 'Lagos', 'Lagos', 'Nigeria',
    'A demo lounge for testing AGM BAR platform', 'trial', TRUE, TRUE
);

-- Get the business_id for use in subsequent inserts
SET @demo_business_id = (SELECT id FROM businesses WHERE subdomain = 'demo');

-- Insert AI personality for demo business
INSERT INTO ai_personalities (
    id, business_id, personality_name, personality_type, tone,
    greeting_message, introduction,
    friendliness_level, formality_level, humor_level,
    custom_instructions
) VALUES (
    UUID(), @demo_business_id, 'Alex', 'friendly', 'balanced',
    'Hey there! 👋 Welcome to Demo Lounge! I\'m Alex, your virtual assistant.',
    'I\'m here to help you with our menu, take your orders, make reservations, or even play some fun games while you wait!',
    8, 5, 6,
    'Always be welcoming and enthusiastic. Help customers discover our best items. Make the experience fun and memorable.'
);

-- Insert business settings
INSERT INTO business_settings (
    id, business_id, currency, timezone,
    enable_ai_chat, enable_ordering, enable_reservations, enable_games
) VALUES (
    UUID(), @demo_business_id, 'NGN', 'Africa/Lagos',
    TRUE, TRUE, TRUE, TRUE
);

-- Insert sample menu categories
INSERT INTO menu_categories (id, business_id, name, display_order) VALUES
(UUID(), @demo_business_id, 'Drinks', 1),
(UUID(), @demo_business_id, 'Food', 2),
(UUID(), @demo_business_id, 'Cocktails', 3);

-- ============================================
-- STORED PROCEDURES (Optional)
-- ============================================

DELIMITER //

-- Procedure to generate unique order number
CREATE PROCEDURE generate_order_number(
    IN p_business_id CHAR(36),
    OUT p_order_number VARCHAR(50)
)
BEGIN
    DECLARE v_count INT;
    DECLARE v_date_prefix VARCHAR(10);
    
    SET v_date_prefix = DATE_FORMAT(NOW(), '%Y%m%d');
    
    SELECT COUNT(*) + 1 INTO v_count
    FROM orders
    WHERE business_id = p_business_id
    AND DATE(created_at) = CURDATE();
    
    SET p_order_number = CONCAT('ORD-', v_date_prefix, '-', LPAD(v_count, 4, '0'));
END //

-- Procedure to generate unique reservation code
CREATE PROCEDURE generate_reservation_code(
    OUT p_reservation_code VARCHAR(50)
)
BEGIN
    SET p_reservation_code = CONCAT('RES-', UPPER(SUBSTRING(MD5(RAND()), 1, 8)));
END //

DELIMITER ;

-- ============================================
-- VIEWS FOR COMMON QUERIES
-- ============================================

-- View for active orders with business info
CREATE VIEW v_active_orders AS
SELECT 
    o.*,
    b.business_name,
    b.subdomain,
    COUNT(oi.id) as item_count
FROM orders o
JOIN businesses b ON o.business_id = b.id
LEFT JOIN order_items oi ON o.id = oi.order_id
WHERE o.status NOT IN ('completed', 'cancelled')
GROUP BY o.id;

-- View for today's reservations
CREATE VIEW v_todays_reservations AS
SELECT 
    r.*,
    b.business_name,
    b.subdomain
FROM reservations r
JOIN businesses b ON r.business_id = b.id
WHERE r.reservation_date = CURDATE()
AND r.status IN ('pending', 'confirmed');

-- ============================================
-- TRIGGERS
-- ============================================

DELIMITER //

-- Trigger to update order item subtotal
CREATE TRIGGER calculate_order_item_subtotal
BEFORE INSERT ON order_items
FOR EACH ROW
