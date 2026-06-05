# jobinja_app

نسخه‌ی جدید اپلیکیشن Flutter جابینجا با تمرکز روی حذف mock data، اتصال به API واقعی، session پایدار و تکمیل مسیرهای اصلی کارجو.

## تغییرات اعمال‌شده

- حذف fallback به `MockApiService` از `RealApiService`؛ داده‌ها از API خوانده می‌شوند.
- اضافه شدن مدیریت session با `shared_preferences` و ذخیره token/user پس از ورود.
- اضافه شدن Splash Screen برای ورود خودکار در اجرای بعدی برنامه.
- یکپارچه‌سازی RTL و بهبود Theme اصلی برنامه.
- فعال بودن مسیرهای Profile، رزومه‌ساز، نشان‌شده‌ها و درخواست‌های من.
- حذف متن ورود تستی از صفحه Login.

## اجرا

```bash
flutter pub get
flutter run
```

## نکته API

مسیرهای رایج API در `lib/services/real_api_service.dart` پشتیبانی شده‌اند. اگر backend مسیر متفاوتی دارد، مقدار `apiBase` یا endpointهای همان فایل را مطابق مستندات backend تنظیم کنید.
