# 🚀 نشر سريع - Dolcera على Cloudflare Pages

## خطوات النشر في 5 دقائق

### 1️⃣ تحضير الملفات
```bash
# استنسخ المستودع
git clone https://github.com/YOUR_USERNAME/dolcera.git
cd dolcera

# تأكد من وجود هذه الملفات:
# ✅ index.html (غيّر اسم dolcera_v9_updated.html إلى index.html)
# ✅ _redirects
# ✅ _headers
# ✅ .gitignore
```

### 2️⃣ إعداد Supabase
```bash
# افتح Supabase Dashboard
# اذهب لـ SQL Editor
# انسخ والصق محتوى setup.sql
# اضغط Run
```

### 3️⃣ ربط Cloudflare Pages
1. سجل دخول: https://dash.cloudflare.com/
2. اختر **Pages** > **Create a project**
3. اربط GitHub repository
4. اختر المستودع `dolcera`

### 4️⃣ إعدادات البناء
```
Framework preset: None
Build command: (اتركه فارغاً)
Build output directory: /
Root directory: /
```

### 5️⃣ متغيرات البيئة
```bash
# اذهب لـ Settings > Environment variables
# أضف:
VITE_SUPABASE_URL=https://huokcqhzfeleqkzfkgpv.supabase.co
VITE_SUPABASE_ANON_KEY=<your-key-here>
```

### 6️⃣ النشر
```bash
# ادفع الكود
git add .
git commit -m "Initial deployment"
git push origin main

# Cloudflare ينشر تلقائياً خلال 1-2 دقيقة
```

### 7️⃣ ربط الدومين
```
1. Custom domains > Set up a custom domain
2. أدخل: dolcera.me
3. اتبع التعليمات (تلقائي في الأغلب)
```

---

## ✅ التحقق من النجاح

زر الموقع: https://dolcera.me
يجب أن ترى:
- ✅ الصفحة الرئيسية تظهر
- ✅ الباقات تُحمّل من Supabase
- ✅ نموذج الحجز يعمل
- ✅ زر تسجيل الدخول يظهر
- ✅ HTTPS مفعّل

---

## 🔧 تحديث الموقع

```bash
# عدّل index.html
# ثم:
git add index.html
git commit -m "update: feature description"
git push origin main

# Cloudflare يحدّث تلقائياً!
```

---

## 📞 دعم

واجهت مشكلة؟
- 📖 راجع [DEPLOYMENT.md](./DEPLOYMENT.md)
- 💬 واتساب: 0550303349
- 🐛 افتح Issue على GitHub

---

**وقت النشر المتوقع:** 5-10 دقائق ⏱️
