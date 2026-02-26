-- CITRIS Quest Merch Redemption - Merch Items & Config Tables
-- This migration creates the merch_items table (dynamic catalog) and merch_config table (shop settings)
-- Apply this to the same Supabase instance as the main CITRIS Quest game

-- Create merch_items table (replaces hardcoded MerchConfig.items)
CREATE TABLE merch_items (
  id TEXT PRIMARY KEY,                          -- e.g. 'shirt', 'magnet', 'sticker'
  name TEXT NOT NULL,
  description TEXT NOT NULL,
  coin_price INTEGER NOT NULL CHECK (coin_price > 0),
  image_url TEXT,                                -- Supabase Storage URL or null for placeholder icon
  type TEXT NOT NULL CHECK (type IN ('shirt', 'magnet', 'sticker', 'keychain')),
  sizes JSONB,                                   -- e.g. ["S","M","L","XL","2XL"] or null
  printify_product_id TEXT NOT NULL,
  accent_color TEXT NOT NULL DEFAULT '#00E5FF',  -- hex color for UI theming
  placeholder_icon TEXT NOT NULL DEFAULT 'shopping_bag', -- Material Icon name as fallback
  sort_order INTEGER NOT NULL DEFAULT 0,         -- display order in grid
  is_active BOOLEAN NOT NULL DEFAULT true,       -- soft delete / hide from shop
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create merch_config table (shop-level settings like XP gate, Printify min balance)
CREATE TABLE merch_config (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create indexes
CREATE INDEX idx_merch_items_is_active ON merch_items(is_active);
CREATE INDEX idx_merch_items_sort_order ON merch_items(sort_order);
CREATE INDEX idx_merch_items_type ON merch_items(type);

-- Enable Row Level Security
ALTER TABLE merch_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE merch_config ENABLE ROW LEVEL SECURITY;

-- RLS: Anyone (including anon/non-logged-in visitors) can read merch items
CREATE POLICY "Anyone can read merch items"
  ON merch_items FOR SELECT
  USING (true);

-- RLS: Only service role can modify merch items (admin via dashboard/API)
CREATE POLICY "Service role can manage merch items"
  ON merch_items FOR ALL
  USING (auth.role() = 'service_role');

-- RLS: Anyone can read merch config
CREATE POLICY "Anyone can read merch config"
  ON merch_config FOR SELECT
  USING (true);

-- RLS: Only service role can modify merch config
CREATE POLICY "Service role can manage merch config"
  ON merch_config FOR ALL
  USING (auth.role() = 'service_role');

-- Seed existing merch items
INSERT INTO merch_items (id, name, description, coin_price, image_url, type, sizes, printify_product_id, accent_color, placeholder_icon, sort_order) VALUES
  (
    'shirt',
    'CITRIS Quest T-Shirt',
    'Premium retro pixel-art design celebrating 25 years of CITRIS innovation. Comfortable cotton blend, perfect for scanning artworks in style.',
    2500,
    NULL,
    'shirt',
    '["S", "M", "L", "XL", "2XL"]',
    'PRINTIFY_SHIRT_ID',
    '#00E5FF',
    'checkroom',
    0
  ),
  (
    'magnet',
    'CITRIS Quest Magnet',
    'Space Invader pixel art magnet for your fridge or locker. Show off your CITRIS Quest achievements IRL.',
    500,
    NULL,
    'magnet',
    NULL,
    'PRINTIFY_MAGNET_ID',
    '#FF00B8',
    'rectangle',
    1
  ),
  (
    'sticker',
    'CITRIS Quest Sticker Pack',
    'Weatherproof vinyl stickers featuring retro game characters. Includes 5 unique designs from the CITRIS Quest universe.',
    300,
    NULL,
    'sticker',
    NULL,
    'PRINTIFY_STICKER_ID',
    '#00FF88',
    'star',
    2
  ),
  (
    'keychain',
    'CITRIS Quest Keychain',
    'Premium acrylic keychain with CITRIS branding. Durable and stylish - keep CITRIS Quest with you everywhere.',
    800,
    NULL,
    'keychain',
    NULL,
    'PRINTIFY_KEYCHAIN_ID',
    '#FFD700',
    'vpn_key',
    3
  );

-- Seed shop-level config
INSERT INTO merch_config (key, value) VALUES
  ('xp_gate_threshold', '250000'),
  ('printify_min_balance', '100.0');

-- Add comments
COMMENT ON TABLE merch_items IS 'Dynamic merch catalog for CITRIS Quest redemption shop';
COMMENT ON TABLE merch_config IS 'Key-value shop configuration (XP gate, Printify settings, etc.)';
COMMENT ON COLUMN merch_items.image_url IS 'Supabase Storage URL for product image. NULL = use placeholder_icon fallback';
COMMENT ON COLUMN merch_items.accent_color IS 'Hex color string for UI theming (borders, glows, icons)';
COMMENT ON COLUMN merch_items.placeholder_icon IS 'Material Icon name used when image_url is null';
COMMENT ON COLUMN merch_items.sizes IS 'JSON array of available sizes. NULL if item does not require size selection';
COMMENT ON COLUMN merch_items.is_active IS 'Set to false to hide item from shop without deleting';
