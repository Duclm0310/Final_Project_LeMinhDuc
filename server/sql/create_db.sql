BEGIN;

CREATE SCHEMA IF NOT EXISTS "public";

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE IF NOT EXISTS public.users (
    user_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    username VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(255) NOT NULL,
    address VARCHAR(255) NOT NULL,
    is_verified BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE,
    deleted_at TIMESTAMP WITH TIME ZONE
);

CREATE TABLE IF NOT EXISTS public.roles (
    role_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    role_name VARCHAR(255) NOT NULL,
    role_description VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE
);

CREATE TABLE IF NOT EXISTS public.permissions (
    permission_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    permission_name VARCHAR(255) NOT NULL,
    permission_description VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE
);

CREATE TABLE IF NOT EXISTS public.user_roles (
    user_id uuid REFERENCES public.users(user_id) ON UPDATE CASCADE ON DELETE CASCADE,
    role_id uuid REFERENCES public.roles(role_id) ON UPDATE CASCADE ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL,
    PRIMARY KEY (role_id, user_id)
);

CREATE TABLE IF NOT EXISTS public.role_permissions (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    role_id uuid REFERENCES public.roles(role_id) ON UPDATE CASCADE ON DELETE CASCADE,
    permission_id uuid REFERENCES public.permissions(permission_id) ON UPDATE CASCADE ON DELETE CASCADE,
    resource_name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL,
    PRIMARY KEY (permission_id, role_id)
);

CREATE TABLE IF NOT EXISTS public.houses (
    house_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    house_name VARCHAR(255) NOT NULL,
    house_address VARCHAR(255) NOT NULL,
    owner_id uuid REFERENCES public.users(user_id) ON UPDATE CASCADE ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL
);

CREATE TABLE IF NOT EXISTS public.house_residents (
    user_id uuid REFERENCES public.users(user_id) ON UPDATE CASCADE ON DELETE CASCADE,
    house_id uuid REFERENCES public.houses(house_id) ON UPDATE CASCADE ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL,
    PRIMARY KEY (user_id, house_id)
);

CREATE TABLE IF NOT EXISTS public.rooms (
    room_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    room_name VARCHAR(255) NOT NULL,
    room_description VARCHAR(255),
    room_residents uuid[],
    house_id uuid REFERENCES public.houses(house_id) ON UPDATE CASCADE ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL
);

CREATE TABLE IF NOT EXISTS public.devices (
    device_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    room_id uuid REFERENCES public.rooms(room_id) ON UPDATE CASCADE ON DELETE CASCADE,
    device_name VARCHAR(255) NOT NULL,
    device_type VARCHAR(255) NOT NULL,
    device_description VARCHAR(255),
    status VARCHAR(255) NOT NULL DEFAULT 'off',
    is_active BOOLEAN NOT NULL DEFAULT false,
    user_id uuid REFERENCES public.users(user_id) ON UPDATE CASCADE ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE
);

CREATE TABLE IF NOT EXISTS public.device_logs (
    log_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    device_id uuid REFERENCES public.devices(device_id) ON UPDATE CASCADE ON DELETE CASCADE,
    energy_used DOUBLE PRECISION NOT NULL,
    created_date TIMESTAMP WITH TIME ZONE NOT NULL,
    updated_date TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL
);

CREATE TABLE IF NOT EXISTS public.notifications (
    notification_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    type VARCHAR(255) NOT NULL,
    message VARCHAR(255) NOT NULL,
    status VARCHAR(255) NOT NULL,
    user_id uuid REFERENCES public.users(user_id) ON UPDATE CASCADE ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL
);

CREATE TABLE IF NOT EXISTS public.otpusers (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    user_id uuid NOT NULL,
    otp VARCHAR(255) NOT NULL,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL
);

END;