BEGIN;
CREATE TABLE IF NOT EXISTS public.users (
    username character varying NOT NULL,
    password character varying NOT NULL,
);

END;