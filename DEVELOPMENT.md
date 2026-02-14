# Development Guide - CITRIS Quest Merch Redemption

This guide helps developers set up their local environment and understand the codebase architecture.

## Prerequisites

### Required Software
- **Flutter SDK** 3.0 or higher ([installation guide](https://docs.flutter.dev/get-started/install))
- **Dart SDK** (included with Flutter)
- **Git** for version control
- **Chrome** or **Edge** for web debugging (recommended)
- **VS Code** or **Android Studio** with Flutter extensions

### Optional Tools
- **Postman** or **Insomnia** for API testing
- **Supabase CLI** for database management
- **Flutter DevTools** for debugging

## Initial Setup

### 1. Clone the Repository

```bash
cd citris-quest
# The redemption app is in a subdirectory
cd citris-quest-redemption
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Verify Installation

```bash
flutter doctor
```

Ensure all checks pass, especially:
- ✓ Flutter (Channel stable)
- ✓ Chrome - web development enabled
- ✓ VS Code / Android Studio

### 4. Configure Environment Variables

Create a `.env.local` file (DO NOT commit this):

```bash
# .env.local
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
PRINTIFY_API_TOKEN=your-printify-token-here
PRINTIFY_SHOP_ID=your-shop-id-here
```

Load these into your shell:

```bash
source .env.local
```

Or create shell scripts for convenience:

```bash
# run-dev.sh
#!/bin/bash
flutter run -d chrome \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY \
  --dart-define=PRINTIFY_API_TOKEN=$PRINTIFY_API_TOKEN \
  --dart-define=PRINTIFY_SHOP_ID=$PRINTIFY_SHOP_ID
```

```bash
chmod +x run-dev.sh
./run-dev.sh
```

## Development Workflow

### Running the App Locally

```bash
# Hot reload enabled (recommended)
flutter run -d chrome \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY \
  --dart-define=PRINTIFY_API_TOKEN=$PRINTIFY_API_TOKEN \
  --dart-define=PRINTIFY_SHOP_ID=$PRINTIFY_SHOP_ID

# Build and serve static files
flutter build web --release \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY \
  --dart-define=PRINTIFY_API_TOKEN=$PRINTIFY_API_TOKEN \
  --dart-define=PRINTIFY_SHOP_ID=$PRINTIFY_SHOP_ID

cd build/web && python3 -m http.server 8000
```

### Hot Reload Best Practices

- Press `r` in terminal to hot reload
- Press `R` for hot restart (clears state)
- Press `q` to quit
- Hot reload preserves widget state
- Use `StatefulWidget` with care - state persists across reloads

### Debugging

#### Chrome DevTools

1. Run app in debug mode
2. Open Chrome DevTools (F12)
3. Sources tab: Set breakpoints
4. Console tab: View print() statements
5. Network tab: Monitor API calls

#### Flutter DevTools

```bash
flutter pub global activate devtools
flutter pub global run devtools
```

Features:
- Widget inspector
- Memory profiler
- Network profiler
- Logging view

#### Print Debugging

```dart
// Use debugPrint for production-safe logging
debugPrint('Cart items: ${CartService().items}');

// For development only
print('Debug: XP = $xp, Coins = $coins');
```

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── core/                        # Shared configuration
│   ├── theme.dart               # AppTheme class with colors
│   ├── typography.dart          # Font definitions (Micro 5)
│   ├── breakpoints.dart         # Responsive breakpoints
│   └── constants/
│       ├── env.dart             # Environment variables
│       └── merch_config.dart    # Pricing, XP gate, catalog
├── backend/
│   ├── domain/models/           # Data models
│   │   ├── cart_item.dart
│   │   ├── merch_item.dart
│   │   ├── merch_order.dart
│   │   ├── order_result.dart
│   │   └── shipping_address.dart
│   ├── data/                    # Supabase data services
│   │   ├── auth_service.dart
│   │   ├── user_profiles_service.dart
│   │   └── merch_orders_service.dart
│   └── services/                # Business logic services
│       ├── cart_service.dart
│       ├── validation_service.dart
│       ├── printify_service.dart
│       └── order_processing_service.dart
├── ui/
│   ├── screens/                 # Full-page screens
│   │   ├── landing_screen.dart
│   │   ├── login_screen.dart
│   │   ├── item_detail_screen.dart
│   │   ├── cart_screen.dart
│   │   ├── checkout_screen.dart
│   │   ├── success_screen.dart
│   │   └── order_history_screen.dart
│   └── widgets/                 # Reusable components
│       ├── navigation/
│       │   └── app_bar.dart
│       └── merch/
│           └── merch_item_card.dart
└── painters/                    # Custom painters from landing site
    ├── pixelated_border_painter.dart
    ├── corner_brackets_painter.dart
    ├── starfield_painter.dart
    └── ...
```

## Architecture Patterns

### Singleton Services

All services use the singleton pattern for shared state:

```dart
class MyService {
  // Private constructor
  MyService._internal();

  // Singleton instance
  static final MyService _instance = MyService._internal();

  // Factory constructor returns singleton
  factory MyService() => _instance;

  // Shared state
  int _counter = 0;

  // Methods
  void increment() => _counter++;
}

// Usage anywhere in the app
MyService().increment();
```

**Why Singleton?**
- Simple state management without complex dependency injection
- Shared state across the entire app
- Consistent with main CITRIS Quest app architecture

### Reactive State with ValueNotifier

For UI updates, services use ValueNotifier:

```dart
class CartService {
  // Observable state
  final ValueNotifier<List<CartItem>> itemsNotifier = ValueNotifier([]);

  List<CartItem> get items => itemsNotifier.value;

  void addItem(CartItem item) {
    itemsNotifier.value = [...itemsNotifier.value, item];
  }
}

// In UI
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  @override
  void initState() {
    super.initState();
    // Listen to changes
    CartService().itemsNotifier.addListener(_onCartChanged);
  }

  @override
  void dispose() {
    CartService().itemsNotifier.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() {
    setState(() {}); // Rebuild UI
  }

  @override
  Widget build(BuildContext context) {
    final items = CartService().items;
    return Text('Cart has ${items.length} items');
  }
}
```

### Atomic Transactions with Rollback

Critical for preventing data inconsistencies:

```dart
Future<OrderResult> processOrder() async {
  String? printifyOrderId;

  try {
    // Step 1: Create Printify order
    final printifyResponse = await PrintifyService().createOrder(...);
    printifyOrderId = printifyResponse.id;

    // Step 2: Deduct coins (with optimistic locking)
    final success = await UserProfilesService().deductCoins(...);
    if (!success) {
      // Rollback: Cancel Printify order
      await PrintifyService().cancelOrder(printifyOrderId);
      return OrderResult.failure('Coin deduction failed');
    }

    // Step 3: Save order to database
    await MerchOrdersService().createOrder(...);

    return OrderResult.success(order);
  } catch (e) {
    // Rollback on any error
    if (printifyOrderId != null) {
      await PrintifyService().cancelOrder(printifyOrderId);
    }
    return OrderResult.failure(e.toString());
  }
}
```

### Responsive Design with Breakpoints

```dart
class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 1200;

  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobile;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobile && width < tablet;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tablet;
  }
}

// Usage in layouts
Widget build(BuildContext context) {
  if (Breakpoints.isMobile(context)) {
    return _buildMobileLayout();
  } else if (Breakpoints.isTablet(context)) {
    return _buildTabletLayout();
  } else {
    return _buildDesktopLayout();
  }
}
```

## Code Style Guide

### General Principles

- **Follow official Dart style guide**: https://dart.dev/guides/language/effective-dart/style
- **Use descriptive names**: `userCoins` not `uc`, `calculateTotal` not `calc`
- **Keep functions small**: < 50 lines ideally
- **Single responsibility**: Each class/function does one thing well
- **Avoid deep nesting**: Max 3 levels of indentation

### Naming Conventions

```dart
// Classes: UpperCamelCase
class OrderProcessingService {}

// Functions/variables: lowerCamelCase
void processOrder() {}
int totalCoins = 0;

// Private members: _underscore prefix
String _apiToken;
void _validateInput() {}

// Constants: lowerCamelCase (Dart convention, not SCREAMING_SNAKE_CASE)
const int xpGateThreshold = 250000;
const String appTitle = 'CITRIS Quest Merch';

// Files: snake_case
order_processing_service.dart
merch_item_card.dart
```

### Documentation Comments

```dart
/// Validates if the user has sufficient XP to access the merch shop.
///
/// Returns `true` if [currentXp] is greater than or equal to the
/// [MerchConfig.xpGateThreshold] (250,000 XP).
///
/// Example:
/// ```dart
/// final canAccess = ValidationService().validateXpGate(300000);
/// ```
bool validateXpGate(int currentXp) {
  return currentXp >= MerchConfig.xpGateThreshold;
}
```

### Error Handling

```dart
// Use try-catch for async operations
try {
  final result = await apiCall();
  return result;
} catch (e) {
  debugPrint('Error in apiCall: $e');
  return null; // or throw custom error
}

// Validate inputs early
if (items.isEmpty) {
  return OrderResult.failure('Cart is empty');
}

// Use meaningful error messages
throw Exception('Insufficient coins: need $required but have $available');
```

## Adding New Features

### 1. Adding a New Product

**Step 1:** Update `MerchConfig`:

```dart
// lib/core/constants/merch_config.dart
static const Map<String, int> pricing = {
  'shirt': 2500,
  'magnet': 500,
  'sticker': 300,
  'keychain': 800,
  'new_item': 1200, // Add here
};

static final List<MerchItem> items = [
  // ... existing items
  MerchItem(
    id: 'new_item',
    name: 'New Item',
    description: 'Description here',
    price: pricing['new_item']!,
    icon: Icons.new_item,
    printifyVariantId: 'printify_variant_id_here',
  ),
];
```

**Step 2:** Add icon or image asset (if needed)

**Step 3:** Test display on landing page (automatic if using `MerchConfig.items`)

### 2. Adding a New Validation Rule

**Step 1:** Update `ValidationService`:

```dart
// lib/backend/services/validation_service.dart
class ValidationService {
  // ... existing methods

  /// New validation rule
  bool validateNewRule(String input) {
    if (input.isEmpty) {
      return false;
    }
    // Validation logic
    return true;
  }
}
```

**Step 2:** Call validation in checkout flow:

```dart
// lib/backend/services/order_processing_service.dart
Future<OrderResult> processOrder(...) async {
  // Existing validations
  if (!ValidationService().validateXpGate(userXp)) {
    return OrderResult.failure('XP gate not met');
  }

  // New validation
  if (!ValidationService().validateNewRule(input)) {
    return OrderResult.failure('New validation failed');
  }

  // Continue with order processing
}
```

**Step 3:** Add unit tests

### 3. Adding a New Screen

**Step 1:** Create screen file:

```dart
// lib/ui/screens/new_screen.dart
import 'package:flutter/material.dart';
import '../../core/theme.dart';

class NewScreen extends StatelessWidget {
  const NewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Screen'),
        backgroundColor: AppTheme.primary,
      ),
      body: Center(
        child: Text(
          'New Screen Content',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
      ),
    );
  }
}
```

**Step 2:** Add navigation:

```dart
// From another screen
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const NewScreen()),
);
```

**Step 3:** Update app bar menu if needed

## Database Development

### Local Supabase Setup (Optional)

For fully local development:

```bash
# Install Supabase CLI
npm install -g supabase

# Initialize project
supabase init

# Start local Supabase
supabase start

# Apply migrations
supabase db reset
```

Use local Supabase URL in development:
```
SUPABASE_URL=http://localhost:54321
```

### Running Migrations

Migrations are in `supabase/migrations/`:

```bash
# Apply migrations to production (via Supabase dashboard)
# OR use Supabase CLI:
supabase db push

# Create new migration
supabase migration new add_new_column
```

### Querying Database Directly

From Supabase Dashboard → SQL Editor:

```sql
-- Check user profiles
SELECT username, xp, bits FROM user_profiles LIMIT 10;

-- View recent orders
SELECT * FROM merch_orders ORDER BY created_at DESC LIMIT 20;

-- Check order totals by user
SELECT
  up.username,
  COUNT(mo.id) as order_count,
  SUM(mo.total_coins) as total_spent
FROM merch_orders mo
JOIN user_profiles up ON mo.user_id = up.player_id
GROUP BY up.username
ORDER BY total_spent DESC;
```

## Testing

### Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/services/validation_service_test.dart

# Run with coverage
flutter test --coverage
```

### Writing Unit Tests

```dart
// test/services/validation_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:citris_quest_redemption/backend/services/validation_service.dart';

void main() {
  group('ValidationService', () {
    test('validateXpGate returns true for XP >= 250000', () {
      final service = ValidationService();
      expect(service.validateXpGate(250000), true);
      expect(service.validateXpGate(300000), true);
    });

    test('validateXpGate returns false for XP < 250000', () {
      final service = ValidationService();
      expect(service.validateXpGate(249999), false);
      expect(service.validateXpGate(0), false);
    });
  });
}
```

### Widget Tests

```dart
// test/widgets/merch_item_card_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:citris_quest_redemption/ui/widgets/merch/merch_item_card.dart';

void main() {
  testWidgets('MerchItemCard displays product info', (WidgetTester tester) async {
    final item = MerchItem(
      id: 'test',
      name: 'Test Item',
      price: 100,
      // ...
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MerchItemCard(item: item),
        ),
      ),
    );

    expect(find.text('Test Item'), findsOneWidget);
    expect(find.text('100 coins'), findsOneWidget);
  });
}
```

## Performance Optimization

### Build Performance

```bash
# Analyze build size
flutter build web --release --analyze-size

# Profile mode (better performance than debug)
flutter run -d chrome --profile

# Release mode (production performance)
flutter run -d chrome --release
```

### Code Optimization Tips

1. **Const Constructors**: Use `const` wherever possible
   ```dart
   const Text('Hello') // Better
   Text('Hello')        // Worse
   ```

2. **Lazy Loading**: Don't load all data upfront
   ```dart
   // Load order history only when screen is viewed
   ```

3. **Debouncing**: Limit expensive operations
   ```dart
   Timer? _debounce;
   void onSearchChanged(String query) {
     _debounce?.cancel();
     _debounce = Timer(const Duration(milliseconds: 500), () {
       performSearch(query);
     });
   }
   ```

4. **Avoid Rebuilds**: Use `ValueNotifier` or `setState` scoped to minimal subtree

## Common Issues and Solutions

### Issue: Hot Reload Not Working

**Solution:**
- Use `R` (hot restart) instead of `r` (hot reload)
- Some changes (e.g., adding new files, changing dependencies) require full restart
- Try: `flutter clean && flutter pub get && flutter run`

### Issue: Environment Variables Not Loading

**Solution:**
- Verify `--dart-define` flags in run command
- Check `Env` class is using `String.fromEnvironment`
- Ensure no typos in variable names
- Try hard restart (stop and rerun)

### Issue: CORS Errors in Browser

**Solution:**
- Supabase anon key should allow CORS by default
- For Printify, may need to whitelist `localhost:*` in Printify dashboard
- Use `--web-browser-flag="--disable-web-security"` for local testing (NOT production)

### Issue: Supabase RLS Blocking Queries

**Solution:**
- Check RLS policies in Supabase dashboard
- Ensure user is authenticated (`SELECT auth.uid()` returns user ID)
- Verify JWT token is valid (check in Supabase Auth → Users)

## Best Practices

1. **Always test with real data**: Don't rely only on placeholder data
2. **Handle errors gracefully**: Show user-friendly messages
3. **Validate on both client and server**: Never trust client-side validation alone
4. **Keep secrets secure**: Never commit `.env` files or hardcode API keys
5. **Write self-documenting code**: Good names > comments
6. **Test edge cases**: Empty carts, insufficient coins, network failures
7. **Use version control**: Commit often with clear messages
8. **Review before pushing**: Check diffs, run tests, verify no debug code

## Useful Commands

```bash
# Format all Dart code
flutter format .

# Analyze code for issues
flutter analyze

# Check for unused dependencies
flutter pub deps

# Update dependencies
flutter pub upgrade

# Clear build cache
flutter clean

# Generate app icon (if using flutter_launcher_icons)
flutter pub run flutter_launcher_icons:main

# Run on different browsers
flutter run -d edge
flutter run -d web-server --web-port=8080
```

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Supabase Flutter Quickstart](https://supabase.com/docs/guides/getting-started/quickstarts/flutter)
- [Printify API Documentation](https://developers.printify.com/)
- [Material Design 3](https://m3.material.io/)
- [Flutter DevTools](https://docs.flutter.dev/development/tools/devtools/overview)

## Contributing

1. Create feature branch: `git checkout -b feature/new-feature`
2. Make changes and test thoroughly
3. Format code: `flutter format .`
4. Run tests: `flutter test`
5. Commit with clear message: `git commit -m "feat: add new feature"`
6. Push and create pull request

## Contact

For questions or issues, refer to the main CITRIS Quest repository documentation or contact the development team.
