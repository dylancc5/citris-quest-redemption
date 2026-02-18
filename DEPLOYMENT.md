# CITRIS Quest Merch Redemption Shop - Deployment Guide

## Prerequisites

Before deploying, ensure you have:

1. **Supabase Project** - Same instance as main CITRIS Quest game
2. **Printify Account** - With API access enabled
3. **GitHub Repository** - With GitHub Pages enabled
4. **Product Setup** - Printify products created and variant IDs obtained

---

## Step 1: Database Setup

### Apply Migration to Supabase

1. Log in to your Supabase dashboard
2. Navigate to **SQL Editor**
3. Open `supabase/migrations/20260210000000_create_merch_orders.sql`
4. Copy the entire contents and paste into the SQL editor
5. Click **Run** to execute the migration
6. Verify the `merch_orders` table appears in **Table Editor**

### Verify RLS Policies

Run this query to confirm Row Level Security is enabled:

```sql
SELECT policyname, cmd FROM pg_policies WHERE tablename = 'merch_orders';
```

Expected output: 3 policies (SELECT, INSERT, UPDATE)

---

## Step 2: Printify Setup

### Get API Credentials

1. Log in to **Printify Dashboard**
2. Navigate to **Settings** → **API**
3. Generate a new API token
4. Copy your **Shop ID** from the dashboard URL

### Create Products

For each merch item (shirt, magnet, sticker, keychain):

1. Create the product in Printify
2. Set up variants (sizes for shirt: S, M, L, XL, 2XL)
3. Copy the **Product ID** and **Variant IDs**

### Update MerchConfig

Edit `lib/core/constants/merch_config.dart`:

```dart
// Replace placeholder IDs with real Printify IDs
MerchItem(
  id: 'shirt',
  // ... other fields ...
  printifyProductId: 'YOUR_ACTUAL_PRINTIFY_PRODUCT_ID',
),
```

Also update variant IDs in `PrintifyService._getVariantId()`:

```dart
// In lib/backend/services/printify_service.dart
int _getVariantId(CartItem cartItem) {
  if (cartItem.item.id == 'shirt' && cartItem.selectedSize != null) {
    switch (cartItem.selectedSize) {
      case 'S': return 12345;  // Replace with real variant ID
      case 'M': return 12346;  // Replace with real variant ID
      case 'L': return 12347;  // Replace with real variant ID
      case 'XL': return 12348; // Replace with real variant ID
      case '2XL': return 12349; // Replace with real variant ID
    }
  }
  // ... other items ...
}
```

---

## Step 3: GitHub Repository Setup

### Enable GitHub Pages

1. Go to **Settings** → **Pages**
2. Under "Build and deployment":
   - Source: **GitHub Actions**
3. Save changes

### Add Secrets

Go to **Settings** → **Secrets and variables** → **Actions**

Add the following repository secrets:

| Secret Name | Value | Where to Find |
|-------------|-------|---------------|
| `SUPABASE_URL` | `https://xxxxx.supabase.co` | Supabase Dashboard → Settings → API |
| `SUPABASE_ANON_KEY` | `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...` | Supabase Dashboard → Settings → API |
| `PRINTIFY_API_TOKEN` | `Bearer xxxxx` | Printify Dashboard → Settings → API |
| `PRINTIFY_SHOP_ID` | `123456` | Printify Dashboard URL |

---

## Step 4: Deploy

### Automatic Deployment

The workflow is configured to deploy automatically on push to `main`:

```bash
git add .
git commit -m "Deploy merch shop"
git push origin main
```

### Manual Deployment

Trigger a manual deployment:

1. Go to **Actions** tab in GitHub
2. Select **Deploy CITRIS Quest Merch Shop to GitHub Pages**
3. Click **Run workflow**
4. Select branch: `main`
5. Click **Run workflow**

### Monitor Deployment

1. Go to **Actions** tab
2. Click on the latest workflow run
3. Monitor the build and deploy jobs
4. Wait for both jobs to complete (typically 3-5 minutes)

---

## Step 5: Verify Deployment

### Access the Site

Your site will be available at:

```
https://<username>.github.io/citris-quest-redemption/
```

Replace `<username>` with your GitHub username.

### Test the Application

**Test Flow:**

1. ✅ Browse merch items on landing page
2. ✅ View item details, select shirt size
3. ✅ Add items to cart
4. ✅ View cart, adjust quantities
5. ✅ Login with game credentials
6. ✅ Proceed to checkout
7. ✅ Fill address form (use test address)
8. ✅ Confirm order
9. ✅ Verify order appears in Printify dashboard
10. ✅ Check merch_orders table in Supabase
11. ✅ Verify coins deducted from user_profiles
12. ✅ View order in Order History

**Test Credentials:**

Create a test user in the main game with:
- ≥250,000 XP (to pass XP gate)
- ≥3,000 coins (to test purchases)

---

## Step 6: Production Considerations

### Security

- ✅ Supabase anon key is safe to expose (RLS policies protect data)
- ✅ Printify API token is injected at build time (not in client code)
- ✅ All transactions use Row Level Security
- ✅ User can only view/modify their own data

### Monitoring

**Check regularly:**

1. **Printify Account Balance** - Ensure sufficient funds
2. **Supabase Usage** - Monitor API calls and storage
3. **GitHub Actions Minutes** - Track deployment usage

**Set up alerts:**

- Printify low balance notification
- Supabase quota warnings

### Maintenance

**Weekly:**
- Review merch_orders table for failed orders
- Check Printify dashboard for stuck orders
- Verify order status updates

**Monthly:**
- Update Printify product IDs if products change
- Review and update pricing in MerchConfig
- Check for Flutter/dependency updates

---

## Troubleshooting

### Build Fails

**Error:** "Environment variables not configured"

**Solution:** Verify all 4 secrets are added to GitHub repository settings

---

**Error:** "Flutter command not found"

**Solution:** Workflow uses `subosito/flutter-action@v2` - ensure workflow file is correct

---

### Login Fails

**Error:** "Invalid username or password"

**Solution:**
- Verify Supabase URL and anon key are correct
- Ensure user exists in main game database
- Check RLS policies on user_profiles table

---

### Orders Not Creating

**Error:** "Order processing failed"

**Solution:**
1. Check browser console for API errors
2. Verify Printify API token is valid
3. Ensure product IDs are correct
4. Check Printify account has sufficient balance
5. Verify merch_orders table exists in Supabase

---

### Coins Not Deducting

**Solution:**
1. Check user_profiles table has `bits` column
2. Verify RLS policies allow UPDATE
3. Check AuthService is fetching user ID correctly
4. Review Supabase logs for errors

---

## Custom Domain (Optional)

To use a custom domain like `merch.citrisquest.com`:

1. Go to **Settings** → **Pages**
2. Under "Custom domain", enter: `merch.citrisquest.com`
3. Add DNS records at your domain registrar:
   ```
   Type: CNAME
   Name: merch
   Value: <username>.github.io
   ```
4. Wait for DNS propagation (up to 24 hours)
5. Enable **Enforce HTTPS** once DNS is verified

---

## Rollback Procedure

If deployment fails or introduces bugs:

### Quick Rollback

1. Go to **Actions** → **Workflows**
2. Find the last successful deployment
3. Click **Re-run all jobs**

### Manual Rollback

```bash
git revert HEAD
git push origin main
```

---

## Support

**For issues with:**

- **Flutter/Deployment:** Check GitHub Actions logs
- **Supabase:** Review Supabase dashboard logs
- **Printify:** Contact Printify support with order IDs
- **App Bugs:** Check browser console for errors

---

## Production Checklist

Before going live:

- [ ] Database migration applied to production Supabase
- [ ] All 4 GitHub secrets configured
- [ ] Printify products created with correct IDs
- [ ] Printify account funded (≥$500 recommended)
- [ ] MerchConfig updated with real product IDs
- [ ] Test purchase completed successfully
- [ ] Order appears in Printify dashboard
- [ ] Coins deducted correctly from user
- [ ] Order visible in Order History
- [ ] Error handling tested (insufficient coins, failed API, etc.)
- [ ] Mobile responsiveness verified
- [ ] GitHub Pages deployment successful
- [ ] Custom domain configured (if applicable)

---

## Post-Launch Monitoring

**Week 1:**
- Monitor every order manually
- Check Printify fulfillment status daily
- Verify coin deductions are accurate
- Watch for error patterns

**Week 2+:**
- Review order analytics weekly
- Monitor Printify account balance
- Check for abandoned carts (users not completing checkout)
- Gather user feedback

---

## Analytics (Future Enhancement)

Consider adding:
- Google Analytics for page views
- Conversion tracking (cart → checkout → purchase)
- Printify webhook integration for automatic order status updates
- Email confirmations via SendGrid/Mailgun

---

## Backup Strategy

**Database:**
- Supabase auto-backups (7-day retention)
- Manual exports: SQL Editor → Export query results

**Code:**
- GitHub repository is version-controlled
- Tag releases: `git tag v1.0.0 && git push --tags`

---

## Support Contact

**For production issues, contact:**
- Dylan (Project Lead)
- Supabase Support: support@supabase.io
- Printify Support: https://help.printify.com/
