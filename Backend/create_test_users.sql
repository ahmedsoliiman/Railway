-- =====================================================
-- CREATE TEST USERS FOR TRAIN BOOKING SYSTEM
-- =====================================================
-- Run these queries if you need to manually create test users
-- Note: If you run "npm run setup", these users are already created

-- =====================================================
-- ADMIN USER
-- =====================================================
-- Email: admin@trainbooking.com
-- Password: Admin@123
INSERT INTO users (full_name, email, password, role, is_verified, created_at, updated_at) 
VALUES (
  'Admin User', 
  'admin@trainbooking.com', 
  '$2a$10$bh109kA/QD5lhAwJQhtJ8exYGOcNUhLSSx.n7P3BPR09AjUba2ED.', 
  'admin', 
  true, 
  NOW(), 
  NOW()
)
ON CONFLICT (email) DO NOTHING;

-- =====================================================
-- TEST USER
-- =====================================================
-- Email: test@trainbooking.com
-- Password: Test@123
INSERT INTO users (full_name, email, password, role, is_verified, created_at, updated_at) 
VALUES (
  'Test User', 
  'test@trainbooking.com', 
  '$2a$10$5Z7QX8Z8Z8Z8Z8Z8Z8Z8ZuK5Y5Y5Y5Y5Y5Y5Y5Y5Y5Y5Y5Y5Y5Y5Y5', 
  'user', 
  true, 
  NOW(), 
  NOW()
)
ON CONFLICT (email) DO NOTHING;

-- =====================================================
-- VERIFY USERS WERE CREATED
-- =====================================================
SELECT id, full_name, email, role, is_verified, created_at 
FROM users 
WHERE email IN ('admin@trainbooking.com', 'test@trainbooking.com')
ORDER BY role DESC;
