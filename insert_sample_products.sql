-- ═══════════════════════════════════════════════════════
-- DOLCERA - INSERT SAMPLE PRODUCTS DATA
-- Run this in Supabase SQL Editor to add demo packages
-- ═══════════════════════════════════════════════════════

-- Clear existing products (optional - remove if you want to keep existing)
-- DELETE FROM products;

-- Insert sample products/packages
INSERT INTO products (
  slug, 
  name, 
  name_en, 
  description, 
  base_price, 
  insurance_fee, 
  stock_quantity, 
  images, 
  contents, 
  featured, 
  category, 
  status
) VALUES 

-- Package 1: رويال (Royal)
(
  'royal-hospitality-table',
  'باقة رويال الفاخرة',
  'Royal Hospitality Package',
  'طاولة استقبال فاخرة بتصميم كلاسيكي أنيق. مثالية للمناسبات الرسمية والأفراح. تتضمن جميع المستلزمات من صحون وأكواب فاخرة.',
  1500,
  200,
  3,
  '["https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=800", "https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?w=800", "https://images.unsplash.com/photo-1530103862676-de8c9debad1d?w=800"]'::jsonb,
  '["طاولة رئيسية فاخرة", "صحون ×24 قطعة", "أكواب قهوة ×24", "أكواب عصير ×24", "ملاعق وشوك ×24", "فناجين قهوة ×12", "مناديل فاخرة", "ترامس قهوة ×2"]'::jsonb,
  true,
  'فاخر',
  'active'
),

-- Package 2: لاتيه (Latte)
(
  'latte-modern-table',
  'باقة لاتيه العصرية',
  'Latte Modern Package',
  'تصميم عصري بألوان هادئة. مثالية للمناسبات العائلية والتجمعات الصغيرة. توفر تجربة ضيافة راقية بسعر مناسب.',
  1200,
  200,
  5,
  '["https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?w=800", "https://images.unsplash.com/photo-1478146059778-26028b07395a?w=800"]'::jsonb,
  '["طاولة عصرية", "صحون ×20 قطعة", "أكواب ×20", "فناجين قهوة ×10", "ملاعق ×20", "ترامس قهوة"]'::jsonb,
  true,
  'عصري',
  'active'
),

-- Package 3: أوبال (Opal)
(
  'opal-elegant-table',
  'باقة أوبال الأنيقة',
  'Opal Elegant Package',
  'تصميم راقي بلمسات ذهبية. مناسبة للحفلات المتوسطة والمناسبات الخاصة. تجمع بين الأناقة والعملية.',
  1350,
  200,
  4,
  '["https://images.unsplash.com/photo-1478146059778-26028b07395a?w=800", "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800"]'::jsonb,
  '["طاولة أنيقة", "صحون ×22 قطعة", "أكواب ×22", "فناجين ×12", "ملاعق وشوك ×22", "ترامس ×2", "مناديل"]'::jsonb,
  false,
  'أنيق',
  'active'
),

-- Package 4: فلفت (Velvet)
(
  'velvet-luxury-table',
  'باقة فلفت الملكية',
  'Velvet Royal Package',
  'تصميم ملكي فاخر بتفاصيل دقيقة. للمناسبات الكبيرة والحفلات الراقية. تضمن تجربة ضيافة لا تُنسى.',
  1800,
  200,
  2,
  '["https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800", "https://images.unsplash.com/photo-1533777857889-4be7c70b33f7?w=800"]'::jsonb,
  '["طاولة ملكية فاخرة", "صحون ×30 قطعة", "أكواب قهوة ×30", "أكواب عصير ×30", "ملاعق وشوك ×30", "فناجين ×15", "ترامس ×3", "مناديل فاخرة", "ديكور مميز"]'::jsonb,
  true,
  'ملكي',
  'active'
),

-- Package 5: مينيمال (Minimal)
(
  'minimal-simple-table',
  'باقة مينيمال البسيطة',
  'Minimal Simple Package',
  'تصميم بسيط وعملي. مثالية للتجمعات الصغيرة والمناسبات العائلية. خيار اقتصادي بجودة ممتازة.',
  900,
  200,
  6,
  '["https://images.unsplash.com/photo-1533777857889-4be7c70b33f7?w=800"]'::jsonb,
  '["طاولة بسيطة", "صحون ×16 قطعة", "أكواب ×16", "فناجين ×8", "ملاعق ×16", "ترامس قهوة"]'::jsonb,
  false,
  'بسيط',
  'active'
),

-- Package 6: كريستال (Crystal)
(
  'crystal-premium-table',
  'باقة كريستال الفاخرة',
  'Crystal Premium Package',
  'تصميم كريستالي فاخر يضيف لمسة من الفخامة لمناسبتك. مثالية للأعراس والمناسبات الرسمية الكبيرة.',
  2000,
  200,
  2,
  '["https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=800", "https://images.unsplash.com/photo-1530103862676-de8c9debad1d?w=800"]'::jsonb,
  '["طاولة كريستال فاخرة", "صحون كريستال ×30", "أكواب كريستال ×30", "فناجين كريستال ×15", "ملاعق فضية ×30", "ترامس ×3", "ديكور فاخر", "مناديل حريرية"]'::jsonb,
  true,
  'فاخر',
  'active'
);

-- Verify insertion
SELECT COUNT(*) as total_products FROM products;
SELECT name, base_price, stock_quantity, featured FROM products ORDER BY base_price;
