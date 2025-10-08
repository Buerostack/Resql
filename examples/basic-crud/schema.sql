-- Schema for Basic CRUD Example
-- Run this script to create the required database table

CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    status VARCHAR(50) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create index on email for faster lookups
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);

-- Create index on status for filtering
CREATE INDEX IF NOT EXISTS idx_users_status ON users(status);

-- Insert some sample data
INSERT INTO users (name, email, status) VALUES
    ('Alice Smith', 'alice@example.com', 'active'),
    ('Bob Johnson', 'bob@example.com', 'active'),
    ('Charlie Brown', 'charlie@example.com', 'inactive')
ON CONFLICT (email) DO NOTHING;
