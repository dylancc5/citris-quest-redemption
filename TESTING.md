# Testing Guide - CITRIS Quest Merch Redemption

This guide provides comprehensive testing procedures for the CITRIS Quest Merch Redemption web application.

## Prerequisites

- Flutter SDK 3.0+ installed
- Access to Supabase dashboard
- Printify test account with API access
- Test user account with sufficient XP and coins

## Environment Setup for Testing

### 1. Local Development Testing

```bash
# Set environment variables for local testing
flutter run -d chrome \
  --dart-define=SUPABASE_URL=your_supabase_url \
  --dart-define=SUPABASE_ANON_KEY=your_anon_key \
  --dart-define=PRINTIFY_API_TOKEN=your_printify_token \
  --dart-define=PRINTIFY_SHOP_ID=your_shop_id
```

### 2. Build for Testing

```bash
# Build production version locally
flutter build web --release \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY \
  --dart-define=PRINTIFY_API_TOKEN=$PRINTIFY_API_TOKEN \
  --dart-define=PRINTIFY_SHOP_ID=$PRINTIFY_SHOP_ID

# Serve locally
cd build/web
python3 -m http.server 8000
# Visit http://localhost:8000
```

## Test Scenarios

### 1. Authentication Flow

#### Test Case 1.1: Successful Login
**Steps:**
1. Navigate to the merch redemption site
2. Click "Login" button
3. Enter valid credentials:
   - Username: (test user with 250k+ XP)
   - Password: (valid password)
4. Click "Login"

**Expected Results:**
- Redirected to landing screen
- User's XP and coins displayed in app bar
- Cart icon visible in app bar
- No error messages

**Edge Cases to Test:**
- User with less than 250,000 XP (should see XP gate message)
- Invalid username
- Invalid password
- Empty fields (validation should prevent submission)

#### Test Case 1.2: XP Gate Validation
**Steps:**
1. Login with user having < 250,000 XP

**Expected Results:**
- Error message: "You need at least 250,000 XP to access the merch shop. Keep playing to unlock!"
- User not logged in
- Remains on login screen

### 2. Product Browsing

#### Test Case 2.1: Landing Page Display
**Steps:**
1. Login successfully
2. Observe landing page

**Expected Results:**
- 4 product cards displayed (shirt, magnet, sticker, keychain)
- Each card shows:
  - Product icon
  - Product name
  - Coin price
  - "View Details" button
- Responsive layout (test on mobile, tablet, desktop)

#### Test Case 2.2: Item Detail View
**Steps:**
1. Click "View Details" on any product
2. Observe item detail screen

**Expected Results:**
- Product icon and name displayed
- Full description shown
- Size selector dropdown (for shirt only)
- Current price displayed
- "Add to Cart" button visible
- "Back to Shop" button visible

**Size Selector Test (Shirt Only):**
- Dropdown shows sizes: S, M, L, XL, XXL
- Default selection: M
- Changing size updates the selected size
- Non-shirt items: No size selector displayed

### 3. Shopping Cart

#### Test Case 3.1: Add Items to Cart
**Steps:**
1. From item detail screen, click "Add to Cart"
2. Observe cart badge in app bar

**Expected Results:**
- Cart badge shows item count
- Success feedback (animation or message)
- Can navigate back and add more items
- Cart persists across navigation

#### Test Case 3.2: Cart Screen Display
**Steps:**
1. Add multiple items to cart
2. Click cart icon in app bar

**Expected Results:**
- All cart items listed
- Each item shows:
  - Product name
  - Size (if applicable)
  - Unit price
  - Quantity controls (- and +)
  - Total per item
- Cart summary shows:
  - Subtotal
  - Total items count
- "Proceed to Checkout" button enabled if items exist
- "Continue Shopping" button visible

#### Test Case 3.3: Quantity Management
**Steps:**
1. In cart screen, click "+" button
2. Click "-" button
3. Try to reduce quantity below 1

**Expected Results:**
- "+" increases quantity
- "-" decreases quantity
- Quantity cannot go below 1
- Item automatically removed when quantity reaches 0
- Totals update in real-time

#### Test Case 3.4: Empty Cart
**Steps:**
1. Remove all items from cart
2. Observe cart screen

**Expected Results:**
- Empty cart message displayed
- "Proceed to Checkout" button disabled or hidden
- Cart badge shows 0 or hidden

### 4. Checkout Process

#### Test Case 4.1: Checkout Form Validation
**Steps:**
1. From cart screen, click "Proceed to Checkout"
2. Try submitting with empty fields
3. Enter invalid data:
   - Invalid email format
   - ZIP code with letters
   - Phone number with letters
4. Enter valid data

**Expected Results:**
- Empty fields prevent submission with error messages
- Email must match format: name@domain.com
- ZIP code must be 5 digits
- Phone number must be 10 digits
- State must be selected from dropdown
- Validation errors shown in red below fields
- Valid form allows submission

**Valid Test Data:**
```
Full Name: John Doe
Email: john.doe@example.com
Phone: 5551234567
Address Line 1: 123 Main St
Address Line 2: Apt 4B (optional)
City: Berkeley
State: California
ZIP Code: 94720
```

#### Test Case 4.2: Insufficient Coins
**Steps:**
1. Fill checkout form with cart total > user's coin balance
2. Click "Place Order"

**Expected Results:**
- Error message: "Insufficient coins! You have X coins but need Y coins."
- Order not placed
- User remains on checkout screen
- No coins deducted

#### Test Case 4.3: Successful Order Placement
**Steps:**
1. Fill valid checkout form
2. Ensure sufficient coins
3. Click "Place Order"
4. Wait for processing

**Expected Results:**
- Loading spinner shown
- "Processing order..." message
- After processing:
  - Redirected to success screen
  - Order confirmation displayed
  - Printify order ID shown
  - Items list displayed
  - Shipping address shown
- Coins deducted from user balance
- Cart cleared
- App bar shows updated coin balance

#### Test Case 4.4: Printify API Failure
**Steps:**
1. Simulate Printify API failure (disconnect internet or use invalid API token)
2. Submit order

**Expected Results:**
- Error message shown
- No coins deducted (rollback successful)
- User remains on checkout screen
- Cart items preserved
- Can retry after fixing issue

#### Test Case 4.5: Atomic Transaction Rollback
**Steps:**
1. Simulate failure during order processing (e.g., database error)

**Expected Results:**
- Printify order cancelled if created
- Coins not deducted from user
- Order not saved to database
- Cart items preserved
- User can retry

### 5. Order History

#### Test Case 5.1: View Order History
**Steps:**
1. From app bar menu, select "Order History"
2. Observe order history screen

**Expected Results:**
- All user's past orders listed
- Most recent orders first
- Each order card shows:
  - Order date
  - Order ID
  - Printify order ID
  - Status badge (pending/processing/shipped/delivered)
  - Total coins spent
  - Item count
  - Expandable details

#### Test Case 5.2: Order Details Expansion
**Steps:**
1. Click on an order card to expand

**Expected Results:**
- Expands to show:
  - Full items list with quantities
  - Shipping address
  - Tracking number (if available)
  - Detailed status
- Click again to collapse

#### Test Case 5.3: Empty Order History
**Steps:**
1. Login with user who has no orders

**Expected Results:**
- Empty state message: "No orders yet"
- "Start Shopping" button to return to landing

#### Test Case 5.4: Refresh Order History
**Steps:**
1. Pull to refresh or click refresh button
2. Observe loading state

**Expected Results:**
- Loading indicator shown
- Fresh data fetched from Supabase
- Order statuses updated if changed

### 6. Responsive Design

#### Test Case 6.1: Mobile Layout (< 600px)
**Steps:**
1. Resize browser to 375px width (iPhone SE)
2. Navigate through all screens

**Expected Results:**
- Single column layouts
- Touch-friendly button sizes (min 44x44)
- Readable text (min 14px)
- No horizontal scrolling
- App bar collapses appropriately
- Forms stack vertically

#### Test Case 6.2: Tablet Layout (600-1200px)
**Steps:**
1. Resize browser to 768px (iPad)
2. Navigate through all screens

**Expected Results:**
- 2-column product grid on landing
- Forms use moderate width
- Adequate spacing and padding
- App bar shows all elements

#### Test Case 6.3: Desktop Layout (> 1200px)
**Steps:**
1. Full desktop browser (1920px)
2. Navigate through all screens

**Expected Results:**
- 4-column product grid on landing
- Forms centered with max-width
- Generous spacing
- All app bar elements visible
- Hover effects on buttons

### 7. Error Handling

#### Test Case 7.1: Network Disconnection
**Steps:**
1. Disconnect internet
2. Try to browse products, add to cart, checkout

**Expected Results:**
- Offline error messages shown
- Cached data displayed if available
- Clear error messages: "Network error. Please check your connection."
- Retry options provided

#### Test Case 7.2: Session Expiration
**Steps:**
1. Login successfully
2. Wait for session to expire (or manually invalidate token)
3. Try to perform action

**Expected Results:**
- Redirected to login screen
- Session expired message shown
- User can login again
- No data loss in cart (if using local storage)

#### Test Case 7.3: Invalid Environment Configuration
**Steps:**
1. Build with missing environment variables
2. Launch app

**Expected Results:**
- Error message shown on launch
- Clear indication of which variables are missing
- App prevents usage until configured

### 8. Database Testing

#### Test Case 8.1: Concurrent Purchase Prevention
**Steps:**
1. Open two browser tabs with same user
2. In both tabs, add items to cart
3. In both tabs, simultaneously click "Place Order"

**Expected Results:**
- Only one order succeeds
- Second order fails with "insufficient coins" or "concurrent modification" error
- Optimistic locking prevents double-deduction
- User's final coin balance is correct

#### Test Case 8.2: Order Record Integrity
**Steps:**
1. Place an order
2. Check database directly in Supabase dashboard

**Expected Results:**
- Record exists in `merch_orders` table
- All fields populated correctly:
  - `user_id` matches logged-in user
  - `items` JSONB contains correct cart items
  - `shipping_address` JSONB contains form data
  - `printify_order_id` is unique
  - `total_coins` matches cart total
  - `status` is 'pending'
  - `created_at` is current timestamp

#### Test Case 8.3: Row Level Security
**Steps:**
1. Login as User A
2. Note User A's order IDs
3. Logout and login as User B
4. View order history

**Expected Results:**
- User B sees only their own orders
- User B cannot see User A's orders
- Direct API calls with User B's token cannot access User A's data

### 9. Printify Integration

#### Test Case 9.1: Balance Check
**Steps:**
1. Before checkout, ensure Printify balance check occurs

**Expected Results:**
- If insufficient Printify balance:
  - Error message: "Insufficient Printify account balance"
  - Order not placed
  - User notified to contact support
- If sufficient balance:
  - Checkout proceeds normally

#### Test Case 9.2: Order Creation Format
**Steps:**
1. Place an order
2. Check Printify dashboard for created order

**Expected Results:**
- Order appears in Printify dashboard
- Line items match cart items
- Shipping address correct
- Recipient email matches user's email
- All required fields populated

#### Test Case 9.3: Order Cancellation on Failure
**Steps:**
1. Simulate coin deduction failure after Printify order created
2. Check Printify dashboard

**Expected Results:**
- Printify order is cancelled via API
- Order status in Printify shows cancelled
- No charges incurred

### 10. Performance Testing

#### Test Case 10.1: Page Load Times
**Benchmarks:**
- Landing page: < 2 seconds
- Item detail: < 1 second
- Cart screen: < 1 second
- Checkout screen: < 1 second
- Order submission: < 5 seconds

**Tools:**
- Chrome DevTools Network tab
- Lighthouse performance audit

#### Test Case 10.2: Bundle Size
**Steps:**
1. Build production version
2. Check `build/web/main.dart.js` size

**Expected:**
- Total bundle size < 5MB
- Gzipped size < 2MB

**Optimize if needed:**
```bash
flutter build web --release --tree-shake-icons
```

### 11. Accessibility Testing

#### Test Case 11.1: Keyboard Navigation
**Steps:**
1. Navigate entire app using only Tab, Enter, Space, Esc
2. Test form inputs, buttons, links

**Expected Results:**
- All interactive elements reachable via Tab
- Focus indicators visible
- Logical tab order
- Enter activates buttons
- Esc closes modals/dialogs

#### Test Case 11.2: Screen Reader Compatibility
**Steps:**
1. Enable screen reader (VoiceOver on Mac, NVDA on Windows)
2. Navigate through app

**Expected Results:**
- All content announced
- Buttons have descriptive labels
- Form fields have labels
- Error messages announced
- Status changes announced

#### Test Case 11.3: Color Contrast
**Tools:**
- Chrome DevTools Lighthouse
- WebAIM Contrast Checker

**Expected Results:**
- All text meets WCAG AA standards (4.5:1 for normal text)
- Interactive elements distinguishable
- Error states visible to colorblind users

## Regression Testing Checklist

Before each release, run through this checklist:

- [ ] Authentication works (login/logout)
- [ ] XP gate validation enforced
- [ ] All products display correctly
- [ ] Cart operations work (add, remove, update quantity)
- [ ] Checkout form validation works
- [ ] Order placement succeeds with valid data
- [ ] Coins deducted correctly
- [ ] Order appears in history
- [ ] Printify order created successfully
- [ ] Responsive design works on mobile/tablet/desktop
- [ ] Error messages display appropriately
- [ ] Session handling works correctly
- [ ] RLS policies prevent unauthorized access
- [ ] No console errors in browser
- [ ] Build succeeds without warnings

## Automated Testing (Future Enhancement)

### Unit Tests
```dart
// Example: test/services/validation_service_test.dart
test('validateXpGate returns false when XP < 250000', () {
  expect(ValidationService().validateXpGate(100000), false);
});
```

### Integration Tests
```dart
// Example: test/integration/checkout_flow_test.dart
testWidgets('Complete checkout flow', (WidgetTester tester) async {
  // 1. Login
  // 2. Add items to cart
  // 3. Fill checkout form
  // 4. Submit order
  // 5. Verify success screen
});
```

### E2E Tests
Consider using Selenium or Playwright for full browser automation.

## Known Issues and Limitations

1. **Placeholder Icons**: Currently using Material Icons instead of custom product images
2. **Placeholder Printify IDs**: Need to update with real product variant IDs
3. **No Order Cancellation**: Users cannot cancel orders after placement
4. **No Order Status Updates**: Manual sync required from Printify
5. **Cart Persistence**: Cart clears on logout (could use local storage)

## Support and Troubleshooting

### Common Issues

**Issue**: "Environment variables not configured"
**Solution**: Ensure all 4 environment variables are set at build time

**Issue**: "XP gate blocks access"
**Solution**: Verify user has 250,000+ XP in `user_profiles` table

**Issue**: "Insufficient coins" error
**Solution**: Check `user_profiles.bits` column matches expected balance

**Issue**: "Printify order creation failed"
**Solution**: Verify Printify API token, shop ID, and product variant IDs

**Issue**: Coins deducted but order not saved
**Solution**: Check database logs, may need manual refund

### Debug Mode

Enable debug logging by uncommenting print statements in services:
- `lib/backend/services/order_processing_service.dart`
- `lib/backend/services/printify_service.dart`
- `lib/backend/data/user_profiles_service.dart`

### Database Queries for Debugging

```sql
-- Check user's coin balance
SELECT username, bits, xp FROM user_profiles WHERE username = 'testuser';

-- View recent orders
SELECT * FROM merch_orders WHERE user_id = 'user-uuid-here' ORDER BY created_at DESC LIMIT 10;

-- Check for duplicate Printify order IDs
SELECT printify_order_id, COUNT(*) FROM merch_orders GROUP BY printify_order_id HAVING COUNT(*) > 1;
```

## Test Data Setup

### Create Test Users

```sql
-- High XP user (can access shop)
INSERT INTO user_profiles (player_id, username, email, xp, bits)
VALUES (gen_random_uuid(), 'test_rich', 'test.rich@example.com', 500000, 10000);

-- Low XP user (cannot access shop)
INSERT INTO user_profiles (player_id, username, email, xp, bits)
VALUES (gen_random_uuid(), 'test_poor', 'test.poor@example.com', 100000, 5000);

-- User with insufficient coins
INSERT INTO user_profiles (player_id, username, email, xp, bits)
VALUES (gen_random_uuid(), 'test_broke', 'test.broke@example.com', 300000, 100);
```

## Contact

For questions about testing procedures, contact the development team or refer to [DEPLOYMENT.md](DEPLOYMENT.md) for production deployment testing.
