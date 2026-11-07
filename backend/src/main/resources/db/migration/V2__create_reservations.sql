-- V2: reservations. A reservation books one parking spot for one time interval.
-- The interval is half-open [start_time, end_time), so a booking that ends at 8 PM
-- does not conflict with one that starts at 8 PM.
--
-- The rule "no two active reservations of the same spot may overlap" is checked by the
-- application while it holds a lock on the parking_spots row (Chapter 7, pessimistic locking).

CREATE TABLE reservations (
    id           VARCHAR(40)    PRIMARY KEY,
    spot_id      VARCHAR(40)    NOT NULL REFERENCES parking_spots (id),
    user_id      VARCHAR(40)    NOT NULL REFERENCES users (id),
    start_time   TIMESTAMPTZ    NOT NULL,
    end_time     TIMESTAMPTZ    NOT NULL,
    status       VARCHAR(20)    NOT NULL
                 CHECK (status IN ('PENDING_PAYMENT', 'CONFIRMED', 'PAYMENT_FAILED', 'CANCELLED')),
    total_price  NUMERIC(10, 2) NOT NULL CHECK (total_price >= 0),
    currency     CHAR(3)        NOT NULL DEFAULT 'CAD',
    created_at   TIMESTAMPTZ    NOT NULL DEFAULT now(),
    CHECK (end_time > start_time)
);

-- Used by the overlap check: "find this spot's reservations that touch this interval".
CREATE INDEX idx_reservations_spot_time ON reservations (spot_id, start_time, end_time);

-- Used by "list my reservations".
CREATE INDEX idx_reservations_user ON reservations (user_id);
