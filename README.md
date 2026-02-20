# CITRIS Quest Merch Redemption Shop

A Flutter web application that allows CITRIS Quest players to redeem in-game coins for physical merchandise rewards through Printify fulfillment.

![Flutter](https://img.shields.io/badge/Flutter-3.9.2-blue)
![Supabase](https://img.shields.io/badge/Supabase-2.12.0-green)

---

## Overview

Players who have earned coins by scanning artworks in the CITRIS Quest mobile game can redeem their coins for exclusive merch:

- **T-Shirts** (2,500 coins) - Available in sizes S-2XL
- **Magnets** (500 coins)
- **Stickers** (300 coins)
- **Keychains** (800 coins)

**Requirements:**
- 250,000+ XP to unlock merch redemption
- Sufficient coin balance
- US shipping address

---

## Features

### 🛍️ Shopping Experience
- Browse 4 merch items with responsive grid layout
- View product details with descriptions
- Select size (for shirts)
- Add to cart with quantity controls
- Edit cart before checkout

### 🔐 Authentication
- Login with game username/password
- Session persistence across page reloads
- Automatic coin balance updates

### 💳 Checkout
- XP gate validation (≥250,000 XP)
- Coin balance validation
- US address form with validation
- Order summary with non-refundable notice
- Real-time transaction processing

### 📦 Order Management
- Order confirmation with Printify order ID
- Order history with status tracking
- Status badges (Pending/Processing/Shipped/Delivered)

### 🔒 Transaction Safety
- Atomic coin deduction (with optimistic locking)
- Automatic rollback on failures
- Printify balance checks before checkout
- Critical error logging for admin alerts

---

## Quick Start

### Local Development

```bash
# Install dependencies
flutter pub get

# Run with environment variables
flutter run -d chrome \
  --dart-define=SUPABASE_URL=your_url \
  --dart-define=SUPABASE_ANON_KEY=your_key \
  --dart-define=PRINTIFY_API_TOKEN=your_token \
  --dart-define=PRINTIFY_SHOP_ID=your_shop_id
```

### Deployment

See [DEPLOYMENT.md](DEPLOYMENT.md) for comprehensive deployment instructions.

**Quick Deploy:**
1. Add secrets to GitHub repository
2. Push to `main` branch
3. GitHub Actions automatically builds and deploys

---

## Architecture

- **Frontend**: Flutter Web with Material Design 3
- **Backend**: Supabase (PostgreSQL + Auth)
- **Fulfillment**: Printify API
- **State Management**: Singleton services with ValueNotifiers
- **Deployment**: GitHub Actions → GitHub Pages

---

## Documentation

- **[PROJECT_STATUS.md](PROJECT_STATUS.md)** - 📊 Complete implementation status and handoff guide
- **[DEPLOYMENT.md](DEPLOYMENT.md)** - 🚀 Complete deployment guide with production setup
- **[DEVELOPMENT.md](DEVELOPMENT.md)** - 🔧 Local development setup and architecture guide
- **[TESTING.md](TESTING.md)** - ✅ Comprehensive testing procedures and test cases
- [CLAUDE.md](../CLAUDE.md) - Project architecture (main game)
- [supabase/README.md](supabase/README.md) - Database migration guide

**Start here:** Read [PROJECT_STATUS.md](PROJECT_STATUS.md) for a complete overview of what's implemented and what's needed for deployment.

---

## Support

**For issues contact:**
- Dylan (Project Lead)
- GitHub Issues (for bugs)

---

## License

Proprietary - CITRIS Quest Project
