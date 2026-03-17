-- ═══════════════════════════════════════════════════════
-- DOLCERA DATABASE SETUP SCRIPT
-- Supabase PostgreSQL Schema
-- Version: 9.0
-- ═══════════════════════════════════════════════════════

-- ═══ ENABLE EXTENSIONS ═══
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- ═══ 1. PRODUCTS TABLE ═══
CREATE TABLE IF NOT EXISTS products (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  slug text UNIQUE,
  name text NOT NULL,
  name_en text,
  description text,
  base_price numeric NOT NULL,
  insurance_fee numeric DEFAULT 200,
  stock_quantity integer DEFAULT 1,
  images jsonb DEFAULT '[]'::jsonb,
  contents jsonb DEFAULT '[]'::jsonb,
  featured boolean DEFAULT false,
  category text DEFAULT 'عام',
  status text DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'draft')),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_products_status ON products(status);
CREATE INDEX IF NOT EXISTS idx_products_featured ON products(featured) WHERE featured = true;
CREATE INDEX IF NOT EXISTS idx_products_category ON products(category);

-- ═══ 2. LOCATIONS TABLE ═══
CREATE TABLE IF NOT EXISTS locations (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  city_name text NOT NULL UNIQUE,
  delivery_price numeric NOT NULL CHECK (delivery_price >= 0),
  active boolean DEFAULT true,
  created_at timestamptz DEFAULT now()
);

-- Create index
CREATE INDEX IF NOT EXISTS idx_locations_active ON locations(active) WHERE active = true;

-- Insert default cities
INSERT INTO locations (city_name, delivery_price) VALUES
('الرياض', 100),
('جدة', 150),
('الدمام', 120),
('مكة المكرمة', 140),
('المدينة المنورة', 160),
('بريدة', 80),
('تبوك', 200),
('أبها', 180),
('الخبر', 120),
('الطائف', 140),
('حائل', 180),
('القصيم', 80)
ON CONFLICT (city_name) DO NOTHING;

-- ═══ 3. BOOKINGS TABLE ═══
CREATE TABLE IF NOT EXISTS bookings (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  booking_number text UNIQUE NOT NULL,
  product_id uuid REFERENCES products(id) ON DELETE SET NULL,
  user_id uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  
  -- Dates
  start_date date NOT NULL,
  end_date date NOT NULL,
  days integer NOT NULL CHECK (days > 0),
  
  -- Customer Info
  customer_name text NOT NULL,
  customer_phone text NOT NULL,
  customer_email text NOT NULL,
  customer_city text,
  customer_city_id uuid REFERENCES locations(id) ON DELETE SET NULL,
  address text NOT NULL,
  notes text,
  lat numeric,
  lng numeric,
  
  -- Pricing
  rental_price numeric NOT NULL CHECK (rental_price >= 0),
  delivery_price numeric DEFAULT 0 CHECK (delivery_price >= 0),
  discount numeric DEFAULT 0 CHECK (discount >= 0),
  vat numeric DEFAULT 0 CHECK (vat >= 0),
  insurance numeric DEFAULT 200 CHECK (insurance >= 0),
  total_price numeric NOT NULL CHECK (total_price >= 0),
  deposit_amount numeric CHECK (deposit_amount >= 0),
  remaining_amount numeric CHECK (remaining_amount >= 0),
  
  -- Payment
  payment_method text NOT NULL CHECK (payment_method IN ('mada', 'visa', 'apple', 'bank')),
  payment_type text NOT NULL CHECK (payment_type IN ('full', 'deposit')),
  receipt_image text,
  
  -- Status
  status text DEFAULT 'pending' CHECK (status IN ('pending', 'review', 'confirmed', 'delivery', 'returned', 'completed', 'cancelled')),
  package_name text,
  
  -- Timestamps
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  paid_at timestamptz
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_bookings_status ON bookings(status);
CREATE INDEX IF NOT EXISTS idx_bookings_user ON bookings(user_id) WHERE user_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_bookings_product ON bookings(product_id);
CREATE INDEX IF NOT EXISTS idx_bookings_dates ON bookings(start_date, end_date);
CREATE INDEX IF NOT EXISTS idx_bookings_created ON bookings(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_bookings_phone ON bookings(customer_phone);

-- Function to generate booking number
CREATE OR REPLACE FUNCTION generate_booking_number()
RETURNS text AS $$
DECLARE
  new_number text;
  counter integer;
BEGIN
  SELECT COUNT(*) + 1 INTO counter FROM bookings;
  new_number := 'B' || LPAD(counter::text, 4, '0');
  RETURN new_number;
END;
$$ LANGUAGE plpgsql;

-- Trigger to auto-generate booking number
CREATE OR REPLACE FUNCTION set_booking_number()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.booking_number IS NULL THEN
    NEW.booking_number := generate_booking_number();
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_set_booking_number
BEFORE INSERT ON bookings
FOR EACH ROW
EXECUTE FUNCTION set_booking_number();

-- ═══ 4. CUSTOMERS TABLE ═══
CREATE TABLE IF NOT EXISTS customers (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  full_name text NOT NULL,
  phone text NOT NULL UNIQUE,
  email text,
  orders_count integer DEFAULT 0 CHECK (orders_count >= 0),
  total_spent numeric DEFAULT 0 CHECK (total_spent >= 0),
  created_at timestamptz DEFAULT now(),
  last_order_at timestamptz
);

-- Create index
CREATE INDEX IF NOT EXISTS idx_customers_phone ON customers(phone);

-- ═══ 5. MEDIA LIBRARY TABLE ═══
CREATE TABLE IF NOT EXISTS media (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  name text NOT NULL,
  url text NOT NULL,
  type text DEFAULT 'url' CHECK (type IN ('url', 'upload')),
  size_bytes bigint,
  mime_type text,
  created_at timestamptz DEFAULT now()
);

-- Create index
CREATE INDEX IF NOT EXISTS idx_media_type ON media(type);

-- ═══ 6. SETTINGS TABLE ═══
CREATE TABLE IF NOT EXISTS settings (
  id integer PRIMARY KEY DEFAULT 1,
  data jsonb NOT NULL DEFAULT '{}'::jsonb,
  updated_at timestamptz DEFAULT now(),
  CONSTRAINT single_row CHECK (id = 1)
);

-- Insert default settings
INSERT INTO settings (id, data) VALUES (1, '{
  "settings": {
    "storeName": "دولسيرا",
    "whatsApp": "0550303349",
    "bufferHours": 12,
    "weekendMarkup": 15,
    "vatRate": 15,
    "vatEnabled": true,
    "insuranceFee": 200,
    "depositPct": 30,
    "theme": "gold",
    "heroImage": "",
    "logoUrl": "",
    "bannerEnabled": false,
    "bannerText": "🎉 خصم 20% على جميع الباقات",
    "bannerColor": "#c8a14c"
  },
  "coupons": [
    {
      "code": "DOLCERA10",
      "type": "percentage",
      "value": 10,
      "active": true,
      "usageCount": 0,
      "maxUsage": 100
    }
  ],
  "bankAccounts": [
    {
      "id": "ba1",
      "bankName": "الراجحي",
      "iban": "SA27800002526080546658",
      "accountHolder": "فيصل إبراهيم التويجري",
      "active": true
    }
  ],
  "socialLinks": [
    {
      "id": "sl1",
      "icon": "💬",
      "label": "واتساب",
      "url": "https://wa.me/966550303349",
      "active": true
    },
    {
      "id": "sl2",
      "icon": "📷",
      "label": "انستقرام",
      "url": "https://instagram.com/dolcera",
      "active": true
    }
  ],
  "notifications": [],
  "customPages": [],
  "testimonials": [],
  "steps": []
}'::jsonb)
ON CONFLICT (id) DO NOTHING;

-- ═══ 7. ROW LEVEL SECURITY (RLS) POLICIES ═══

-- Enable RLS on all tables
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE locations ENABLE ROW LEVEL SECURITY;
ALTER TABLE bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE media ENABLE ROW LEVEL SECURITY;
ALTER TABLE settings ENABLE ROW LEVEL SECURITY;

-- Products: Public read, authenticated write
CREATE POLICY "Products are viewable by everyone" ON products
  FOR SELECT USING (true);

CREATE POLICY "Products are editable by authenticated users" ON products
  FOR ALL USING (auth.role() = 'authenticated');

-- Locations: Public read
CREATE POLICY "Locations are viewable by everyone" ON locations
  FOR SELECT USING (active = true);

CREATE POLICY "Locations are editable by authenticated users" ON locations
  FOR ALL USING (auth.role() = 'authenticated');

-- Bookings: Users can view their own, admins can view all
CREATE POLICY "Users can view own bookings" ON bookings
  FOR SELECT USING (
    auth.uid() = user_id OR
    auth.role() = 'service_role'
  );

CREATE POLICY "Anyone can create bookings" ON bookings
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Admins can update bookings" ON bookings
  FOR UPDATE USING (auth.role() = 'authenticated');

-- Customers: Public create, authenticated read/update
CREATE POLICY "Customers viewable by authenticated" ON customers
  FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Anyone can create customer" ON customers
  FOR INSERT WITH CHECK (true);

-- Media: Public read, authenticated write
CREATE POLICY "Media viewable by everyone" ON media
  FOR SELECT USING (true);

CREATE POLICY "Media editable by authenticated" ON media
  FOR ALL USING (auth.role() = 'authenticated');

-- Settings: Public read, authenticated write
CREATE POLICY "Settings viewable by everyone" ON settings
  FOR SELECT USING (true);

CREATE POLICY "Settings editable by authenticated" ON settings
  FOR ALL USING (auth.role() = 'authenticated');

-- ═══ 8. FUNCTIONS ═══

-- Update timestamp function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply to tables
CREATE TRIGGER update_products_updated_at BEFORE UPDATE ON products
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_bookings_updated_at BEFORE UPDATE ON bookings
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ═══ 9. VIEWS (Optional - for reporting) ═══

CREATE OR REPLACE VIEW booking_summary AS
SELECT 
  DATE(created_at) as date,
  COUNT(*) as total_bookings,
  SUM(total_price) as total_revenue,
  COUNT(*) FILTER (WHERE status = 'confirmed') as confirmed_bookings,
  COUNT(*) FILTER (WHERE status = 'pending') as pending_bookings
FROM bookings
WHERE status != 'cancelled'
GROUP BY DATE(created_at)
ORDER BY date DESC;

-- ═══ SETUP COMPLETE ═══
-- Run this script in Supabase SQL Editor
-- All tables, indexes, and policies are now created
