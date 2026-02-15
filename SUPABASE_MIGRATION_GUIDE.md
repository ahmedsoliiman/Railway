# Supabase Migration Guide

## 1. Setup Supabase Project
1. Go to [database.new](https://database.new) to create a new Supabase project.
2. Once created, go to **Project Settings > API**.
3. Copy the **Project URL** and **anon public** key.

## 2. Configure Flutter App
1. Open `lib/config/app_config.dart`.
2. Replace `YOUR_SUPABASE_URL` with your Project URL.
3. Replace `YOUR_SUPABASE_ANON_KEY` with your anon public key.

## 3. Setup Database Schema
1. In your Supabase Dashboard, go to the **SQL Editor**.
2. Click "New Query".
3. Copy the contents of the file `SUPABASE_SCHEMA.sql` (located in the root of your project) and paste it into the query editor.
4. Click **Run**.
   - This will create all necessary tables (stations, trains, trips, users, bookings).
   - It will also insert some sample data for testing.

## 4. Run the App
1. Run `flutter clean`.
2. Run `flutter pub get`.
3. Run `flutter run`.

## 5. Verification
- **Login/Signup**: Create a new account. It should appear in the `auth.users` table and `public.profiles` table.
- **Trips**: Go to the trips search screen. You should see the sample trips inserted by the schema script.
- **Bookings**: Make a booking. It should appear in `public.reservations`.
