-- V1: the core tables. Users, the parking spots they own,
-- and the time windows when each spot can be booked.
--
-- Ids are text with a prefix (user_..., spot_...) created by the application,
-- so the API never exposes database row numbers (Chapter 2).

CREATE TABLE users (
    id              VARCHAR(40)  PRIMARY KEY,
    google_subject  VARCHAR(255) NOT NULL UNIQUE,  -- the "sub" claim of the Google ID token
    email           VARCHAR(320) NOT NULL,
    display_name    VARCHAR(200),
    created_at      TIMESTAMPTZ  NOT NULL DEFAULT now()
);

CREATE TABLE parking_spots (
    id              VARCHAR(40)   PRIMARY KEY,
    owner_id        VARCHAR(40)   NOT NULL REFERENCES users (id),
    title           VARCHAR(120)  NOT NULL,
    description     VARCHAR(2000),
    address         VARCHAR(300)  NOT NULL,
    photo_url       TEXT,
    price_per_hour  NUMERIC(10, 2) NOT NULL CHECK (price_per_hour > 0),
    parking_type    VARCHAR(20)   CHECK (parking_type IN ('driveway', 'privateLot', 'garage', 'other')),
    restrictions    VARCHAR(1000),
    active          BOOLEAN       NOT NULL DEFAULT TRUE,  -- false = deactivated, no new reservations
    created_at      TIMESTAMPTZ   NOT NULL DEFAULT now()
);

CREATE INDEX idx_parking_spots_owner ON parking_spots (owner_id);

-- When the owner says the spot can be booked. A spot has one or more windows.
CREATE TABLE availability_windows (
    id          BIGSERIAL   PRIMARY KEY,
    spot_id     VARCHAR(40) NOT NULL REFERENCES parking_spots (id) ON DELETE CASCADE,
    start_time  TIMESTAMPTZ NOT NULL,
    end_time    TIMESTAMPTZ NOT NULL,
    CHECK (end_time > start_time)
);

CREATE INDEX idx_availability_windows_spot ON availability_windows (spot_id);
