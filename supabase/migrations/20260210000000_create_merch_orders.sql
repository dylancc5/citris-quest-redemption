-- CITRIS Quest Merch Redemption - Merch Orders Table
-- This migration creates the merch_orders table for tracking merchandise redemptions
-- Apply this to the same Supabase instance as the main CITRIS Quest game

-- Create merch_orders table
CREATE TABLE merch_orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES user_profiles(player_id) ON DELETE CASCADE,
  username TEXT NOT NULL,
  items JSONB NOT NULL,  -- Array of {item_id, item_name, quantity, size?, coin_price}
  total_coins INTEGER NOT NULL CHECK (total_coins >= 0),
  shipping_address JSONB NOT NULL,  -- {first_name, last_name, address_line_1, address_line_2?, city, state, zip_code, phone_number?}
  printify_order_id TEXT NOT NULL UNIQUE,
  status TEXT NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending', 'processing', 'shipped', 'delivered', 'failed', 'cancelled')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  shipped_at TIMESTAMPTZ,
  delivered_at TIMESTAMPTZ,
  tracking_number TEXT,
  error_message TEXT
);

-- Create indexes for efficient queries
CREATE INDEX idx_merch_orders_user_id ON merch_orders(user_id);
CREATE INDEX idx_merch_orders_username ON merch_orders(username);
CREATE INDEX idx_merch_orders_status ON merch_orders(status);
CREATE INDEX idx_merch_orders_created_at ON merch_orders(created_at DESC);
CREATE INDEX idx_merch_orders_printify_order_id ON merch_orders(printify_order_id);

-- Enable Row Level Security
ALTER TABLE merch_orders ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can read their own orders
CREATE POLICY "Users can read own merch orders"
  ON merch_orders FOR SELECT
  USING (auth.uid() = user_id);

-- RLS Policy: Users can insert their own orders (during checkout)
CREATE POLICY "Users can insert own merch orders"
  ON merch_orders FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- RLS Policy: Service role can update orders (for Printify webhook updates)
CREATE POLICY "Service role can update merch orders"
  ON merch_orders FOR UPDATE
  USING (auth.role() = 'service_role');

-- Add comment to table
COMMENT ON TABLE merch_orders IS 'Stores merchandise redemption orders for CITRIS Quest players';
COMMENT ON COLUMN merch_orders.items IS 'JSONB array of order line items with quantities and sizes';
COMMENT ON COLUMN merch_orders.shipping_address IS 'JSONB object containing full US shipping address';
COMMENT ON COLUMN merch_orders.printify_order_id IS 'External Printify order ID for fulfillment tracking';
COMMENT ON COLUMN merch_orders.total_coins IS 'Total coins spent on this order (deducted from user_profiles.bits)';
