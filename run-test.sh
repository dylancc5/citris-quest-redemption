#!/bin/bash
flutter run -d chrome \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key \
  --dart-define=PRINTIFY_API_TOKEN=test-token \
  --dart-define=PRINTIFY_SHOP_ID=test-shop-id
