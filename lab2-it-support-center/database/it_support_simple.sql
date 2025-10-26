-- IT Support Database Schema - Simplified Version

-- Users table
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
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

-- Tickets table
CREATE TABLE IF NOT EXISTS tickets (
    id SERIAL PRIMARY KEY,
    ticket_number VARCHAR(20) UNIQUE NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    category VARCHAR(50) NOT NULL,
    priority VARCHAR(20) NOT NULL,
    status VARCHAR(20) DEFAULT 'open',
    requester_id INTEGER REFERENCES users(id),
    assigned_to INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    closed_at TIMESTAMP,
    resolution_time INTEGER,
    
    CHECK (category IN ('hardware', 'software', 'network', 'account', 'other')),
    CHECK (priority IN ('low', 'medium', 'high', 'critical')),
    CHECK (status IN ('open', 'in_progress', 'pending', 'resolved', 'closed'))
);

-- Ticket comments
CREATE TABLE IF NOT EXISTS ticket_comments (
    id SERIAL PRIMARY KEY,
    ticket_id INTEGER REFERENCES tickets(id) ON DELETE CASCADE,
    user_id INTEGER REFERENCES users(id),
    comment TEXT NOT NULL,
    is_internal BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Hardware inventory
CREATE TABLE IF NOT EXISTS hardware_inventory (
    id SERIAL PRIMARY KEY,
    asset_tag VARCHAR(50) UNIQUE NOT NULL,
    type VARCHAR(50) NOT NULL,
    manufacturer VARCHAR(100),
    model VARCHAR(100),
    serial_number VARCHAR(100),
    assigned_to INTEGER REFERENCES users(id),
    purchase_date DATE,
    status VARCHAR(20) DEFAULT 'active',
    location VARCHAR(100),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CHECK (type IN ('desktop', 'laptop', 'server', 'printer', 'monitor', 'network_device', 'other')),
    CHECK (status IN ('active', 'in_repair', 'retired', 'lost', 'disposed'))
);

-- Knowledge base
CREATE TABLE IF NOT EXISTS knowledge_base (
    id SERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    category VARCHAR(50) NOT NULL,
    problem_description TEXT NOT NULL,
    solution TEXT NOT NULL,
    keywords TEXT[],
    author_id INTEGER REFERENCES users(id),
    views INTEGER DEFAULT 0,
    helpful_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert sample data
INSERT INTO users (username, email, full_name, department, role) VALUES
    ('admin', 'admin@company.com', 'System Administrator', 'IT', 'admin'),
    ('tech1', 'tech1@company.com', 'John Technician', 'IT', 'technician'),
    ('user1', 'user1@company.com', 'Alice User', 'Sales', 'user'),
    ('user2', 'user2@company.com', 'Bob Manager', 'Marketing', 'user');

-- Sample knowledge base articles
INSERT INTO knowledge_base (title, category, problem_description, solution, keywords, author_id) VALUES
    ('Password Reset Procedure', 'account', 'User cannot login due to forgotten password', '1. Verify user identity 2. Access admin panel 3. Reset password 4. Notify user', '{"password","reset","login"}', 1),
    ('Printer Offline', 'hardware', 'Network printer shows as offline', '1. Check network connection 2. Restart printer 3. Verify print queue 4. Update drivers', '{"printer","offline","network"}', 2),
    ('Slow Computer Performance', 'software', 'Computer running slowly, applications taking long to load', '1. Check task manager for high resource usage 2. Clear temporary files 3. Run disk cleanup 4. Check for malware', '{"slow","performance","optimization"}', 2);

-- Create indexes
CREATE INDEX idx_tickets_status ON tickets(status);
CREATE INDEX idx_tickets_priority ON tickets(priority);
CREATE INDEX idx_tickets_created ON tickets(created_at);
CREATE INDEX idx_hardware_assigned ON hardware_inventory(assigned_to);
CREATE INDEX idx_kb_category ON knowledge_base(category);
