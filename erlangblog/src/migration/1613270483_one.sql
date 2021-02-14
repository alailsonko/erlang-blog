-- Create users table
-- :up
CREATE TABLE users(
  id serial NOT NULL,
  username character varying(255) NOT NULL UNIQUE,
  email character varying(255) NOT NULL UNIQUE,
  password character varying(255) NOT NULL,
  CONSTRAINT users_pkey PRIMARY KEY (id)
);


-- Drop users in downgrade
-- :down
DROP TABLE users;