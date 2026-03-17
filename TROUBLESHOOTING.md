# 🔧 دليل حل المشاكل - Dolcera Troubleshooting

## مشكلة: الموقع يتوقف عند شاشة التحميل (Spinner)

### الأعراض:
- الأيقونة تنبض ولا تختفي
- Console يظهر أخطاء CSP
- الموقع لا يحمل أبداً

### الحل:
✅ **تم إصلاحه في v9.1**

1. **تأكد من وجود CSP Meta Tag في `<head>`:**
```html
<meta http-equiv="Content-Security-Policy" content="default-src 'self' https: 'unsafe-inline' 'unsafe-eval'; img-src 'self' data: https:; media-src 'self' https://huokcqhzfeleqkzfkgpv.supabase.co https:; connect-src 'self' https://huokcqhzfeleqkzfkgpv.supabase.co https:;">
```

2. **تحقق من Supabase credentials:**
```javascript
// يجب أن تكون:
URL: https://huokcqhzfeleqkzfkgpv.supabase.co
Anon Key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imh1b2txaHpmZWxlcWt6ZmtncHYiLCJyb2xlIjoiYW5vbiIsImlhdCI6MTcxMDY5MDY4NSwiZXhwIjoyMDI2MjY2Njg1fQ.X_Lz5-vR-Z9n8Xm-u8L-5Xn-z9_r8X-m7z_p-8Xm-u3I
```

3. **افتح Console (F12) وابحث عن:**
```
🔗 Supabase Config: {url: "...", keyLength: ...}
🔄 Starting Supabase data load...
```

إذا لم تظهر هذه الرسائل، المشكلة في الاتصال.

---

## مشكلة: "Failed to fetch" في Console

### الحل:
1. تحقق من Supabase Project Status
2. تأكد من RLS Policies:
```sql
-- في Supabase SQL Editor
SELECT * FROM pg_policies;
```

3. تحقق من CORS في Supabase:
   - Dashboard > Settings > API
   - Allowed Origins: `*` أو `https://dolcera.me`

---

## مشكلة: البيانات لا تظهر (فارغة)

### الحل:
1. **تحقق من وجود بيانات في Supabase:**
```sql
SELECT COUNT(*) FROM products;
SELECT COUNT(*) FROM locations;
```

2. **أضف بيانات تجريبية:**
```sql
-- قم بتشغيل setup.sql كاملاً
```

3. **افحص Console:**
```
✅ Products loaded: X
✅ Locations loaded: Y
```

إذا كان الرقم 0، لا توجد بيانات.

---

## مشكلة: نموذج الحجز لا يعمل

### الأعراض:
- زر "إضافة باقة" لا يفتح
- المدن لا تظهر في القائمة
- "تم الحجز" لكن لا شيء في Supabase

### الحل:

**1. تحقق من جدول locations:**
```sql
SELECT * FROM locations;
```
يجب أن يحتوي على مدن.

**2. تحقق من RLS Policy على bookings:**
```sql
-- يجب السماح بالإدراج للجميع
CREATE POLICY "Anyone can create bookings" ON bookings
  FOR INSERT WITH CHECK (true);
```

**3. افحص Console عند الحجز:**
```
📦 Creating booking...
✅ Booking created: B0001
```

---

## مشكلة: تسجيل الدخول لا يعمل

### Google OAuth:
1. **تحقق من Redirect URI:**
   - Google Console: `https://huokcqhzfeleqkzfkgpv.supabase.co/auth/v1/callback`

2. **تأكد من تفعيل Provider في Supabase:**
   - Authentication > Providers > Google > Enabled ✅

### Email/Password:
1. **تحقق من Email Confirmation:**
   - Supabase > Authentication > Email Templates
   - تأكد من إرسال رسائل التأكيد

---

## مشكلة: Admin Panel لا يظهر

### الحل:
1. **أضف `?admin` للرابط:**
```
https://dolcera.me?admin
```

2. **سجل دخول بـ:**
```
اليوزر: admin
الباسورد: (الافتراضي في الكود)
```

3. **تحقق من Console:**
```
window._adminMode = true
```

---

## مشكلة: الصور لا تحمل

### الحل:
1. **تحقق من Firebase Storage rules:**
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

2. **أو استخدم روابط خارجية:**
```javascript
// في Media Library
{url: "https://images.unsplash.com/..."}
```

---

## مشكلة: Environment Variables لا تعمل

### في Cloudflare Pages:

1. **تأكد من الأسماء الصحيحة:**
```
VITE_SUPABASE_URL (ليس SUPABASE_URL)
VITE_SUPABASE_ANON_KEY (ليس SUPABASE_KEY)
```

2. **Redeploy بعد إضافة المتغيرات:**
```
Settings > Functions > Redeploy
```

3. **تحقق في Console:**
```javascript
console.log(import.meta.env.VITE_SUPABASE_URL)
// يجب أن يطبع القيمة
```

---

## مشكلة: الموقع يعمل محلياً لكن لا يعمل على Cloudflare

### الحل:
1. **تحقق من Build Logs:**
   - Cloudflare Pages > Deployments > View build log

2. **تأكد من وجود جميع الملفات:**
```
✅ index.html
✅ _redirects
✅ _headers
```

3. **تحقق من CSP:**
   - افتح Console في Production
   - ابحث عن أخطاء CSP

---

## نصائح التشخيص السريع

### 1. فحص الاتصال بـ Supabase:
```javascript
// افتح Console في الموقع واكتب:
fetch('https://huokcqhzfeleqkzfkgpv.supabase.co/rest/v1/products', {
  headers: {
    'apikey': 'YOUR_ANON_KEY',
    'Authorization': 'Bearer YOUR_ANON_KEY'
  }
})
.then(r => r.json())
.then(d => console.log(d))
```

### 2. مسح الـ Cache:
```
Ctrl + Shift + R (Windows)
Cmd + Shift + R (Mac)
```

### 3. وضع Incognito:
```
Ctrl + Shift + N (Windows)
Cmd + Shift + N (Mac)
```

### 4. فحص Network Tab:
```
F12 > Network > تحديث الصفحة
ابحث عن طلبات فاشلة (أحمر)
```

---

## أدوات مساعدة

### Supabase Logs:
```
Dashboard > Logs > Query Logs
```

### Cloudflare Analytics:
```
Analytics > Web Analytics
```

### Browser Console Commands:
```javascript
// عرض البيانات المحلية
console.log(D)

// عرض إعدادات Supabase
console.log({SB_URL, SB_KEY})

// إعادة تحميل من Supabase
loadAllFromSB()

// مسح localStorage
localStorage.clear()
```

---

## 🆘 لا يزال لا يعمل؟

1. **افتح Issue على GitHub** مع:
   - لقطة شاشة للـ Console
   - رابط الموقع
   - وصف المشكلة

2. **تواصل عبر واتساب:**
   - 0550303349
   - أرسل رابط الموقع + لقطة Console

3. **تحقق من الوثائق:**
   - [DEPLOYMENT.md](./DEPLOYMENT.md)
   - [README.md](./README.md)

---

**آخر تحديث:** 2026-03-17  
**الإصدار:** v9.1
