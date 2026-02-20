# Supabase Migrations for CITRIS Quest Merch Redemption

This directory contains database migrations that must be applied to the **same Supabase instance** used by the main CITRIS Quest game.

## Applying Migrations

### Option 1: Supabase Dashboard (Recommended for Single Migration)

1. Log in to your Supabase project dashboard
2. Navigate to **SQL Editor**
3. Click **New Query**
4. Copy the entire contents of `migrations/20260210000000_create_merch_orders.sql`
5. Paste into the SQL editor
6. Click **Run** to execute the migration
7. Verify the `merch_orders` table appears in **Table Editor**

### Option 2: Supabase CLI (If Using Local Development)

```bash
# From the main CITRIS Quest project root
supabase db push

# Or apply this specific migration
supabase migration up
```

## Migration Details

### 20260210000000_create_merch_orders.sql

Creates the `merch_orders` table with the following structure:

- **Table:** `merch_orders`
- **Purpose:** Track merchandise redemption orders
- **Relationships:** Foreign key to `user_profiles(player_id)`
- **Security:** Row Level Security (RLS) enabled
  - Users can only view/insert their own orders
  - Service role can update orders (for Printify webhooks)

**Indexes:**
- `user_id` - Fast user order lookups
- `username` - Username-based queries
- `status` - Filter by order status
- `created_at` - Chronological sorting
- `printify_order_id` - Unique constraint for Printify integration

## Verification

After applying the migration, verify with this query:

```sql
-- Check table exists
SELECT table_name FROM information_schema.tables
WHERE table_schema = 'public' AND table_name = 'merch_orders';

-- Check RLS policies
SELECT policyname, cmd, qual FROM pg_policies
WHERE tablename = 'merch_orders';

-- Check indexes
SELECT indexname FROM pg_indexes
WHERE tablename = 'merch_orders';
```

Expected output:
- 1 table: `merch_orders`
- 3 RLS policies
- 5 indexes

## Rollback (If Needed)

To rollback this migration:

```sql
DROP TABLE IF EXISTS merch_orders CASCADE;
```

**Warning:** This will permanently delete all order records. Use with caution.

## Notes for Dylan

- This migration references `user_profiles(player_id)` from the main game database
- Ensure the main game's Supabase instance is used (not a separate project)
- The `bits` column in `user_profiles` is used for coin balance (deducted on purchase)
- The `xp` column in `user_profiles` is checked for the 250K XP gate (but NOT deducted)
