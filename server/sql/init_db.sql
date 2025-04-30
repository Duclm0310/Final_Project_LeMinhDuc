-- Enable UUID generation
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

INSERT INTO users (user_id, name, username, password, email, phone, address, is_verified, created_at, updated_at)
VALUES 
(uuid_generate_v4(), "John Doe", 'john_doe', '$2a$10$K1fznyUc2l3FG2KYmMe9tOcJJYLVarwnHMzDg0R0Y3K6gOZm3lKE.', 'john@example.com', '1234567890', '123 Main St', true, NOW(), NOW()),
(uuid_generate_v4(), "Jane Smith", 'jane_smith', '$2a$10$K1fznyUc2l3FG2KYmMe9tOcJJYLVarwnHMzDg0R0Y3K6gOZm3lKE.', 'jane@example.com', '0987654321', '456 Elm St', true, NOW(), NOW());

INSERT INTO roles (role_id, role_name, role_description, created_at, updated_at)
VALUES 
(uuid_generate_v4(), 'admin', 'Administrator role', NOW(), NOW()),
(uuid_generate_v4(), 'user', 'Standard user role', NOW(), NOW());

INSERT INTO permissions (permission_id, permission_name, permission_description, created_at, updated_at)
VALUES 
(uuid_generate_v4(), 'CREATE', 'Allows creating a resource', NOW(), NOW()),
(uuid_generate_v4(), 'READ', 'Allows reading a resource', NOW(), NOW()),
(uuid_generate_v4(), 'UPDATE', 'Allows updating a resource', NOW(), NOW()),
(uuid_generate_v4(), 'DELETE', 'Allows deleting a resource', NOW(), NOW());

-- User_roles junction table, no id column needed.
INSERT INTO user_roles (user_id, role_id, created_at, updated_at)
VALUES 
((SELECT user_id FROM users WHERE username = 'john_doe'), (SELECT role_id FROM roles WHERE role_name = 'admin'), NOW(), NOW()),
((SELECT user_id FROM users WHERE username = 'jane_smith'), (SELECT role_id FROM roles WHERE role_name = 'user'), NOW(), NOW());

-- role_permissions junction table, no id column needed.
INSERT INTO role_permissions (id, resource_name, role_id, permission_id, created_at, updated_at)
VALUES 
(uuid_generate_v4(), 'DEVICE', (SELECT role_id FROM roles WHERE role_name = 'admin'), (SELECT permission_id FROM permissions WHERE permission_name = 'CREATE'), NOW(), NOW()),
(uuid_generate_v4(), 'DEVICE', (SELECT role_id FROM roles WHERE role_name = 'admin'), (SELECT permission_id FROM permissions WHERE permission_name = 'READ'), NOW(), NOW()),
(uuid_generate_v4(), 'DEVICE', (SELECT role_id FROM roles WHERE role_name = 'admin'), (SELECT permission_id FROM permissions WHERE permission_name = 'UPDATE'), NOW(), NOW()),
(uuid_generate_v4(), 'DEVICE', (SELECT role_id FROM roles WHERE role_name = 'admin'), (SELECT permission_id FROM permissions WHERE permission_name = 'DELETE'), NOW(), NOW()),
(uuid_generate_v4(), 'DEVICE', (SELECT role_id FROM roles WHERE role_name = 'user'), (SELECT permission_id FROM permissions WHERE permission_name = 'READ'), NOW(), NOW());

INSERT INTO houses (house_id, house_name, house_address, owner_id, created_at, updated_at)
VALUES 
(uuid_generate_v4(), 'Doe Residence', '123 Main St', (SELECT user_id FROM users WHERE username = 'john_doe'), NOW(), NOW()),
(uuid_generate_v4(), 'Smith House', '456 Elm St', (SELECT user_id FROM users WHERE username = 'jane_smith'), NOW(), NOW());

INSERT INTO house_residents (user_id, house_id, created_at, updated_at)
VALUES 
((SELECT user_id FROM users WHERE username = 'john_doe'), (SELECT house_id FROM houses WHERE house_name = 'Doe Residence'), NOW(), NOW()),
((SELECT user_id FROM users WHERE username = 'jane_smith'), (SELECT house_id FROM houses WHERE house_name = 'Smith House'), NOW(), NOW());

INSERT INTO rooms (room_id, room_name, room_description, house_id, created_at, updated_at)
VALUES 
(uuid_generate_v4(), 'Living Room', 'Main living area', (SELECT house_id FROM houses WHERE house_name = 'Doe Residence'), NOW(), NOW()),
(uuid_generate_v4(), 'Bedroom', 'Master bedroom', (SELECT house_id FROM houses WHERE house_name = 'Smith House'), NOW(), NOW());

INSERT INTO devices (device_id, room_id, device_name, device_type, device_description, status, is_active, user_id, created_at, updated_at)
VALUES 
(uuid_generate_v4(), (SELECT room_id FROM rooms WHERE room_name = 'Living Room'), 'Smart TV', 'Television', 'Living room TV', 'off', false, (SELECT user_id FROM users WHERE username = 'john_doe'), NOW(), NOW()),
(uuid_generate_v4(), (SELECT room_id FROM rooms WHERE room_name = 'Bedroom'), 'AC Unit', 'Air Conditioner', 'Bedroom air conditioner', 'off', false, (SELECT user_id FROM users WHERE username = 'jane_smith'), NOW(), NOW());

INSERT INTO device_logs (device_log_id, device_id, energy_used, created_date, updated_date, created_at, updated_at)
VALUES 
(uuid_generate_v4(), (SELECT device_id FROM devices WHERE device_name = 'Smart TV'), 0.5, NOW(), NOW(), NOW(), NOW()),
(uuid_generate_v4(), (SELECT device_id FROM devices WHERE device_name = 'AC Unit'), 1.2, NOW(), NOW(), NOW(), NOW());
