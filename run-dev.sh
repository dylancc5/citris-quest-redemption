#!/bin/bash
# Load environment variables
set -a
source .env.complete
set +a

# Run the app
flutter run -d chrome \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY \
  --dart-define=PRINTIFY_API_TOKEN=$PRINTIFY_API_TOKEN \
  --dart-define=PRINTIFY_SHOP_ID=$PRINTIFY_SHOP_ID
