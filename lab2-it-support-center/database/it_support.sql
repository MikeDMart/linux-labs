-- IT Support Database Schema - Enhanced Version
-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table with enhanced security
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    uuid UUID DEFAULT uuid_generate_v4(),
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    department VARCHAR(50),
    role VARCHAR(20) DEFAULT 'user',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP,
    CHECK (role IN ('admin', 'technician', 'user'))
);

-- Enhanced tickets table with SLA tracking
CREATE TABLE IF NOT EXISTS tickets (
    id SERIAL PRIMARY KEY,
    uuid UUID DEFAULT uuid_generate_v4(),
    ticket_number VARCHAR(20) UNIQUE NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    category VARCHAR(50) NOT NULL,
    priority VARCHAR(20) NOT NULL,
    status VARCHAR(20) DEFAULT 'open',
    requester_id INTEGER REFERENCES users(id),
    assigned_to INTEGER REFERENCES users(id),
    sla_deadline TIMESTAMP,
    actual_response_time INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    closed_at TIMESTAMP,
    resolution_time INTEGER,
    satisfaction_rating INTEGER,
    CHECK (category IN ('hardware', 'software', 'network', 'account', 'security', 'other')),
    CHECK (priority IN ('low', 'medium', 'high', 'critical')),
    CHECK (status IN ('open', 'in_progress', 'pending', 'resolved', 'closed')),
    CHECK (satisfaction_rating BETWEEN 1 AND 5 OR satisfaction_rating IS NULL)
);

-- Ticket comments with attachments support
CREATE TABLE IF NOT EXISTS ticket_comments (
    id SERIAL PRIMARY KEY,
    uuid UUID DEFAULT uuid_generate_v4(),
    ticket_id INTEGER REFERENCES tickets(id) ON DELETE CASCADE,
    user_id INTEGER REFERENCES users(id),
    comment TEXT NOT NULL,
    is_internal BOOLEAN DEFAULT FALSE,
    attachment_path VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Enhanced hardware inventory with maintenance tracking
CREATE TABLE IF NOT EXISTS hardware_inventory (
    id SERIAL PRIMARY KEY,
    uuid UUID DEFAULT uuid_generate_v4(),
    asset_tag VARCHAR(50) UNIQUE NOT NULL,
    type VARCHAR(50) NOT NULL,
    manufacturer VARCHAR(100),
    model VARCHAR(100),
    serial_number VARCHAR(100),
    specifications JSONB,
    assigned_to INTEGER REFERENCES users(id),
    purchase_date DATE,
    warranty_expiry DATE,
    status VARCHAR(20) DEFAULT 'active',
    location VARCHAR(100),
    ip_address INET,
    mac_address MACADDR,
    last_maintenance DATE,
    next_maintenance DATE,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CHECK (type IN ('desktop', 'laptop', 'server', 'printer', 'monitor', 'network_device', 'mobile', 'other')),
    CHECK (status IN ('active', 'in_repair', 'retired', 'lost', 'disposed', 'maintenance'))
);

-- Knowledge base with versioning
CREATE TABLE IF NOT EXISTS knowledge_base (
    id SERIAL PRIMARY KEY,
    uuid UUID DEFAULT uuid_generate_v4(),
    title VARCHAR(200) NOT NULL,
    category VARCHAR(50) NOT NULL,
    problem_description TEXT NOT NULL,
    solution TEXT NOT NULL,
    steps JSONB,
    keywords TEXT[],
    author_id INTEGER REFERENCES users(id),
    views INTEGER DEFAULT 0,
    helpful_count INTEGER DEFAULT 0,
    not_helpful_count INTEGER DEFAULT 0,
    is_published BOOLEAN DEFAULT TRUE,
    version INTEGER DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- System metrics and reporting
CREATE TABLE IF NOT EXISTS system_metrics (
    id SERIAL PRIMARY KEY,
    metric_type VARCHAR(50) NOT NULL,
    metric_value DECIMAL(10,2),
    metric_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    details JSONB
);

-- Performance indexes
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_tickets_status_priority ON tickets(status, priority);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_tickets_created_sla ON tickets(created_at, sla_deadline);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_tickets_requester_created ON tickets(requester_id, created_at);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_hardware_status_location ON hardware_inventory(status, location);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_kb_category_keywords ON knowledge_base(category, keywords);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_metrics_timestamp_type ON system_metrics(metric_timestamp, metric_type);

-- Insert initial data
INSERT INTO users (username, email, full_name, department, role) VALUES
    ('admin', 'admin@company.com', 'System Administrator', 'IT', 'admin'),
    ('tech1', 'tech1@company.com', 'John Technician', 'IT', 'technician'),
    ('user1', 'user1@company.com', 'Alice User', 'Sales', 'user'),
    ('user2', 'user2@company.com', 'Bob Manager', 'Marketing', 'user');

-- Sample knowledge base articles
INSERT INTO knowledge_base (title, category, problem_description, solution, keywords, author_id) VALUES
    ('Password Reset Procedure', 'account', 'User cannot login due to forgotten password', '1. Verify user identity 2. Access admin panel 3. Reset password 4. Notify user', '{"password","reset","login"}', 1),
    ('Printer Offline', 'hardware', 'Network printer shows as offline', '1. Check network connection 2. Restart printer 3. Verify print queue 4. Update drivers', '{"printer","offline","network"}', 2);

-- Timestamp update trigger
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_tickets_updated_at BEFORE UPDATE ON tickets
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_hardware_updated_at BEFORE UPDATE ON hardware_inventory
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_kb_updated_at BEFORE UPDATE ON knowledge_base
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
