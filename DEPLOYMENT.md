# 🚀 Dolcera - دليل النشر على Cloudflare Pages

## 📋 المتطلبات

### 1. إعداد Cloudflare Pages

#### الخطوة الأولى: ربط المستودع
1. اذهب إلى [Cloudflare Dashboard](https://dash.cloudflare.com/)
2. اختر **Pages** من القائمة الجانبية
3. اضغط **Create a project**
4. اختر **Connect to Git** وربط حسابك على GitHub
5. اختر المستودع الخاص بـ Dolcera

#### الخطوة الثانية: إعدادات البناء
```yaml
Build command: (اتركه فارغاً - الموقع static HTML)
Build output directory: / 
Root directory: /
```

#### الخطوة الثالثة: إضافة متغيرات البيئة
في **Settings** > **Environment variables**، أضف:

```bash
# Supabase Configuration
VITE_SUPABASE_URL=https://huokcqhzfeleqkzfkgpv.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

# (اختياري) Google Analytics
GA_MEASUREMENT_ID=G-XXXXXXXXXX
```

---

## 🗄️ إعداد قاعدة البيانات Supabase

### الجداول المطلوبة:

#### 1. جدول المنتجات (products)
```sql
CREATE TABLE products (
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
  status text DEFAULT 'active',
  created_at timestamptz DEFAULT now()
);
```

#### 2. جدول الحجوزات (bookings)
```sql
CREATE TABLE bookings (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  booking_number text UNIQUE NOT NULL,
  product_id uuid REFERENCES products(id),
  user_id uuid REFERENCES auth.users(id),
  
  -- تواريخ الحجز
  start_date date NOT NULL,
  end_date date NOT NULL,
  days integer NOT NULL,
  
  -- بيانات العميل
  customer_name text NOT NULL,
  customer_phone text NOT NULL,
  customer_email text NOT NULL,
  customer_city text,
  customer_city_id uuid REFERENCES locations(id),
  address text,
  notes text,
  lat numeric,
  lng numeric,
  
  -- الأسعار
  rental_price numeric NOT NULL,
  delivery_price numeric DEFAULT 0,
  discount numeric DEFAULT 0,
  vat numeric DEFAULT 0,
  insurance numeric DEFAULT 200,
  total_price numeric NOT NULL,
  deposit_amount numeric,
  remaining_amount numeric,
  
  -- طريقة الدفع
  payment_method text NOT NULL,
  payment_type text NOT NULL,
  receipt_image text,
  
  -- الحالة
  status text DEFAULT 'pending',
  package_name text,
  
  -- التواريخ
  created_at timestamptz DEFAULT now(),
  paid_at timestamptz
);
```

#### 3. جدول المدن (locations)
```sql
CREATE TABLE locations (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  city_name text NOT NULL,
  delivery_price numeric NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- إضافة بيانات أولية
INSERT INTO locations (city_name, delivery_price) VALUES
('الرياض', 100),
('جدة', 150),
('الدمام', 120),
('مكة المكرمة', 140),
('المدينة المنورة', 160),
('بريدة', 80),
('تبوك', 200),
('أبها', 180);
```

#### 4. جدول العملاء (customers)
```sql
CREATE TABLE customers (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  full_name text NOT NULL,
  phone text NOT NULL,
  orders_count integer DEFAULT 0,
  total_spent numeric DEFAULT 0,
  created_at timestamptz DEFAULT now()
);
```

#### 5. جدول مكتبة الصور (media)
```sql
CREATE TABLE media (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  name text NOT NULL,
  url text NOT NULL,
  type text DEFAULT 'url',
  created_at timestamptz DEFAULT now()
);
```

#### 6. جدول الإعدادات (settings)
```sql
CREATE TABLE settings (
  id integer PRIMARY KEY DEFAULT 1,
  data jsonb NOT NULL,
  updated_at timestamptz DEFAULT now(),
  CONSTRAINT single_row CHECK (id = 1)
);

-- إضافة صف الإعدادات الافتراضي
INSERT INTO settings (id, data) VALUES (1, '{
  "settings": {
    "storeName": "دولسيرا",
    "whatsApp": "0550303349",
    "theme": "gold"
  },
  "coupons": [],
  "bankAccounts": []
}'::jsonb);
```

---

## 🔐 تفعيل Google OAuth

1. اذهب إلى [Google Cloud Console](https://console.cloud.google.com/)
2. أنشئ مشروع جديد أو اختر مشروع موجود
3. فعّل **Google+ API**
4. انتقل إلى **Credentials** > **Create Credentials** > **OAuth 2.0 Client ID**
5. أضف Authorized redirect URIs:
   ```
   https://huokcqhzfeleqkzfkgpv.supabase.co/auth/v1/callback
   ```
6. انسخ **Client ID** و **Client Secret**
7. في Supabase Dashboard:
   - اذهب لـ **Authentication** > **Providers**
   - فعّل **Google**
   - الصق Client ID و Client Secret

---

## 🌐 إعداد الدومين المخصص

### في Cloudflare Pages:
1. اذهب لـ **Custom domains**
2. اضغط **Set up a custom domain**
3. أدخل: `dolcera.me`
4. اتبع التعليمات لإضافة DNS records

### في Cloudflare DNS:
سيتم إضافة هذه السجلات تلقائياً:
```
Type: CNAME
Name: @
Content: dolcera-me.pages.dev
Proxy status: Proxied (برتقالي)
```

---

## 📦 هيكل المشروع

```
dolcera/
├── index.html                 # الملف الرئيسي (v9)
├── README.md                  # دليل المشروع
├── DEPLOYMENT.md              # هذا الملف
└── .env.example              # مثال لمتغيرات البيئة
```

---

## 🔄 التحديثات التلقائية

عند عمل **commit** جديد على GitHub:
1. Cloudflare Pages يكتشف التغيير تلقائياً
2. يقوم ببناء ونشر النسخة الجديدة
3. الموقع يتحدث خلال 1-2 دقيقة

### أمثلة على الـ Commits:
```bash
git add .
git commit -m "feat: add new product images"
git push origin main

git commit -m "fix: resolve mobile responsive issues"
git push origin main

git commit -m "update: change delivery prices"
git push origin main
```

---

## ✅ قائمة التحقق قبل الإطلاق

- [ ] رفع `dolcera_v9_updated.html` كـ `index.html` على GitHub
- [ ] إنشاء جميع جداول Supabase
- [ ] إضافة متغيرات البيئة في Cloudflare
- [ ] ربط الدومين `dolcera.me`
- [ ] تفعيل Google OAuth
- [ ] إضافة بيانات المدن الأولية
- [ ] اختبار نموذج الحجز
- [ ] اختبار تسجيل الدخول
- [ ] اختبار زر الواتساب
- [ ] فحص الموقع على الجوال
- [ ] تفعيل SSL (تلقائي من Cloudflare)

---

## 🆘 الدعم

### مشاكل شائعة:

**1. الموقع لا يتحدث بعد Commit:**
- تحقق من **Deployments** في Cloudflare Pages
- راجع **Build logs** للأخطاء

**2. خطأ في الاتصال بـ Supabase:**
- تأكد من صحة `SUPABASE_URL` و `SUPABASE_ANON_KEY`
- تحقق من Row Level Security policies

**3. Google OAuth لا يعمل:**
- تحقق من Redirect URI في Google Console
- تأكد من تفعيل Provider في Supabase

---

## 📞 معلومات الاتصال

- **الواتساب:** 0550303349
- **الموقع:** https://dolcera.me
- **Supabase Project:** huokcqhzfeleqkzfkgpv

---

**آخر تحديث:** مارس 2026  
**الإصدار:** v9.0
