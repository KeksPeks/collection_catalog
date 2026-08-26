-- User accounts and personal collection state.
-- Общий каталог остаётся в collection_types/categories/collections/items.
-- Один item может быть связан с большим количеством пользователей.

BEGIN;

CREATE TABLE IF NOT EXISTS users (
    id BIGSERIAL PRIMARY KEY,
    username VARCHAR(100) NOT NULL,
    email VARCHAR(320) NOT NULL,
    password_hash TEXT NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT users_username_key UNIQUE (username),
    CONSTRAINT users_email_key UNIQUE (email)
);

CREATE TABLE IF NOT EXISTS user_items (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    item_id BIGINT NOT NULL REFERENCES items(id) ON DELETE CASCADE,
    owned BOOLEAN NOT NULL DEFAULT FALSE,
    quantity INTEGER NOT NULL DEFAULT 0,
    wishlist BOOLEAN NOT NULL DEFAULT FALSE,
    condition VARCHAR(100),
    purchase_price NUMERIC(14, 2),
    purchase_date DATE,
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT user_items_quantity_check CHECK (quantity >= 0),
    CONSTRAINT user_items_purchase_price_check CHECK (purchase_price IS NULL OR purchase_price >= 0),
    CONSTRAINT user_items_user_item_key UNIQUE (user_id, item_id)
);

CREATE INDEX IF NOT EXISTS idx_user_items_user ON user_items(user_id);
CREATE INDEX IF NOT EXISTS idx_user_items_item ON user_items(item_id);
CREATE INDEX IF NOT EXISTS idx_user_items_owned ON user_items(user_id, owned);
CREATE INDEX IF NOT EXISTS idx_user_items_wishlist ON user_items(user_id, wishlist);

COMMIT;
