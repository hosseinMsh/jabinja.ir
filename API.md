# طراحی و پیاده‌سازی اپلیکیشن موبایل جابینجا

## Jobinja Mobile Application

---

## ۱. مقدمه

در این مینی‌لب، دانشجویان باید یک اپلیکیشن موبایل مشابه نسخه ساده‌شده‌ی سامانه کاریابی **جابینجا** را با استفاده از زبان برنامه‌نویسی **Dart** و فریم‌ورک **Flutter** طراحی و پیاده‌سازی کنند.

هدف اصلی این مینی‌لب، آشنایی عملی دانشجویان با طراحی اپلیکیشن‌های موبایل، ارتباط با API، مدیریت صفحات مختلف، رعایت اصول برنامه‌نویسی شیءگرا و پیاده‌سازی ساختارمند پروژه بر اساس معماری **MVP** است.

این اپلیکیشن باید قابلیت اجرا روی سیستم‌عامل‌های **Android** و **iOS** را داشته باشد.

## ۲. اهداف آموزشی

- آشنایی با توسعه اپلیکیشن موبایل با Flutter
- استفاده از زبان Dart در یک پروژه واقعی
- طراحی چند صفحه کاربردی در اپلیکیشن موبایل
- کار با API و دریافت داده از سرور
- مدیریت داده‌های دریافتی از API
- رعایت اصول برنامه‌نویسی شیءگرا
- جداسازی مسئولیت‌ها در کد
- پیاده‌سازی معماری MVP
- طراحی رابط کاربری تمیز، ساده و قابل استفاده
- افزایش توانایی کار گروهی و مستندسازی پروژه

## ۳. مشخصات کلی پروژه

اپلیکیشن موبایل با عنوان **Jobinja Mobile Application** شامل چند صفحه اصلی: ثبت‌نام، ورود، لیست موقعیت‌های شغلی، جزئیات شغل، صفحه شرکت و پروفایل کاربر.

## ۴. تکنولوژی‌های مورد استفاده

- زبان: **Dart**
- فریم‌ورک: **Flutter**
- معماری: **MVP**
- پلتفرم: **Android + iOS**

---

## ۵. مستندات API

> **نکته مهم:** جابینجا **API عمومی رسمی** ندارد. صفحه جستجوی مشاغل (`/jobs`) به صورت **Server-Side Rendering (SSR)** کار می‌کند و خروجی HTML برمی‌گرداند. APIهای زیر (`api/v10`) برای بخش‌های خاص و احراز هویت‌شده استفاده می‌شوند. برای پروژه دانشجویی، از **یک API ساختگی (Mock)** مطابق ساختار واقعی استفاده می‌شود.

**Base URL:** `https://jobinja.ir`
**API Base:** `https://jobinja.ir/api/v10`
**Content-Type:** `application/json`
**Auth:** Bearer Token (Sanctum)

---

### ۵.۱. Search Jobs (صفحه جستجوی HTML)

**جابینجا API جستجوی JSON ندارد.** صفحه جستجو به صورت HTML از طریق `GET /jobs` با پارامترهای زیر رندر می‌شود:

```
GET /jobs?filters[keywords][0]=python&filters[locations][0]=تهران&page=1&sort_by=published_at_desc
```

**پارامترهای جستجو:**

| پارامتر | نوع | مثال |
|---------|------|-------|
| `filters[keywords][0]` | string | `python`, `برنامه‌نویس` |
| `filters[locations][0..31]` | string[] | `تهران`, `اصفهان` |
| `filters[job_categories][0..47]` | string[] | شماره دسته‌بندی |
| `filters[job_types][0..3]` | string[] | نوع قرارداد |
| `filters[remote]` | checkbox | `1` (دورکاری) |
| `filters[internship]` | checkbox | `1` (کارآموزی) |
| `filters[has_usd]` | checkbox | `1` (پرداخت دلاری) |
| `filters[has_military_placement]` | checkbox | `1` (امریه سربازی) |
| `filters[has_loan]` | checkbox | `1` (وام) |
| `filters[has_project]` | checkbox | `1` (پروژه‌ای) |
| `filters[has_bonus]` | checkbox | `1` (پاداش) |
| `filters[has_commission]` | checkbox | `1` (پورسانت) |
| `filters[has_overtime_offering]` | checkbox | `1` (اضافه‌کاری) |
| `filters[has_afternoon_shift]` | checkbox | `1` (شیفت عصر) |
| `filters[has_promotion]` | checkbox | `1` (ترفیع شغلی) |
| `filters[has_part_time]` | checkbox | `1` (پاره‌وقت) |
| `filters[has_disability_support]` | checkbox | `1` (استخدام معلولین) |
| `filters[has_flexible_hours]` | checkbox | `1` (ساعت شناور) |
| `filters[has_supplementary_insurance]` | checkbox | `1` (بیمه تکمیلی) |
| `filters[has_esop]` | checkbox | `1` (سهام تشویقی) |
| `filters[has_business_trip]` | checkbox | `1` (سفر کاری) |
| `filters[sal_min][0..14]` | string[] | حداقل حقوق |
| `filters[w_e][]` | string[] | سابقه کار |
| `sort_by` | string | `published_at_desc` (جدیدترین), `salary_desc` (بیشترین حقوق) |
| `page` | integer | شماره صفحه |

**پاسخ:** `200 OK` - کد HTML کامل صفحه

> **در پروژه دانشجویی، از یک Mock API با ساختار JSON شبیه‌سازی‌شده استفاده می‌شود.**

---

### ۵.۲. Meta / Reference Data (نیاز به احراز هویت ندارند)

#### GET /api/v10/job/categories

لیست دسته‌بندی‌های شغلی

**Response:** `200 OK`
```json
[
  {
    "id": 1,
    "machine_name": "وب،-برنامه‌نویسی-و-نرم‌افزار",
    "name": "وب، برنامه‌نویسی و نرم‌افزار",
    "english_name": "web, software development",
    "icon": null,
    "popularity": 9,
    "home_popularity": 10
  }
]
```

#### GET /api/v10/job_search_meta

داده‌های متا برای جستجو (دسته‌بندی‌ها، استان‌ها، شهرها، تعداد شغل‌ها)

**Response:** `200 OK` - شامل `job_categories`, `company_categories`, `locations`, `company_sizes` با تعداد شغل‌ها

#### GET /api/v10/region/province

لیست استان‌ها

**Response:** `200 OK`
```json
{
  "data": [
    {
      "id": 1,
      "english_name": "East Azerbaijan",
      "name": "آذربایجان شرقی",
      "slug": "آذربايجان-شرقي"
    }
  ]
}
```

#### GET /api/v10/job-skills/search?q={keyword}

جستجوی مهارت‌ها

**Response:** `200 OK`
```json
[
  {
    "id": 472,
    "name": "Python",
    "suggested": false,
    "is_new": false,
    "active": 1,
    "total": 13001
  }
]
```

#### GET /api/v10/utils/last-applied-job

آخرین شغلی که کاربر به آن رزومه فرستاده (نیاز به کوکی دارد)

---

### ۵.۳. Authentication (با کوکی/CSRF)

سیستم احراز هویت جابینجا مبتنی بر **Sanctum (Laravel)** و **Session/Cookie** است:

#### GET /login/user

صفحه ورود - دریافت `csrf_token` و `JSESSID` و `XSRF-TOKEN`

**Response:** `200 OK` - HTML حاوی `<meta name="csrf-token" content="...">`

#### POST /login/user

ارسال درخواست ورود

**Headers:**
```
Cookie: XSRF-TOKEN={token}; JSESSID={session}
Content-Type: application/x-www-form-urlencoded
```

**Body:**
```
_token={csrf_token}&redirect_url=&identifier={email}&password={password}&remember_me=on
```

**Response Success:** `302 Redirect` → Location به صفحه اصلی
**Response Fail:** `302 Redirect` → Location به `/login/user` (همان صفحه)

#### GET /join/user

صفحه ثبت‌نام

#### POST /join/user

ثبت‌نام کاربر جدید (مشابه لاگین)

#### GET /auth/google?

ورود با گوگل

#### GET /auth/linkedin?

ورود با لینکدین

---

### ۵.۴. Resume / Profile (نیاز به احراز هویت)

> همه endpointهای زیر نیاز به `Authorization: Bearer {token}` یا Session Cookie دارند.

| Method | Endpoint | توضیح |
|--------|----------|-------|
| GET | `/api/v10/resume` | لیست رزومه‌ها |
| POST | `/api/v10/resume` | ایجاد رزومه جدید |
| GET | `/api/v10/resume/fa/personal-info` | اطلاعات شخصی |
| PUT | `/api/v10/resume/fa/personal-info` | ویرایش اطلاعات شخصی |
| GET/PUT | `/api/v10/resume/en/personal-info` | اطلاعات شخصی (انگلیسی) |
| GET | `/api/v10/resume/fa/link` | لینک رزومه |
| GET | `/api/v10/resume/translation?lang=` | ترجمه رزومه |
| GET/PUT | `/api/v10/jobseeker-app/cv-builder/{cv_id}/basic-data` | اطلاعات پایه رزومه |
| GET/PUT | `/api/v10/jobseeker-app/cv-builder/{cv_id}/personal` | اطلاعات شخصی در CV Builder |
| GET/PUT | `/api/v10/jobseeker-app/cv-builder/{cv_id}/education` | تحصیلات |
| DELETE | `/api/v10/jobseeker-app/cv-builder/{cv_id}/education/{id}` | حذف تحصیلات |
| GET/PUT | `/api/v10/jobseeker-app/cv-builder/{cv_id}/experience` | سوابق شغلی |
| DELETE | `/api/v10/jobseeker-app/cv-builder/{cv_id}/experience/{id}` | حذف سابقه شغلی |
| GET/PUT | `/api/v10/jobseeker-app/cv-builder/{cv_id}/language` | زبان‌ها |
| GET/PUT | `/api/v10/jobseeker-app/cv-builder/{cv_id}/skills` | مهارت‌ها |
| GET | `/api/v10/jobseeker-app/cv-builder/{cv_id}/score` | امتیاز رزومه |
| POST | `/api/v10/jobseeker-app/cv-builder/{cv_id}/avatar` | آپلود عکس |
| POST | `/api/v10/jobseeker-app/cv-builder/{cv_id}/cv-file` | آپلود فایل رزومه |
| PUT | `/api/v10/jobseeker-app/cv-builder/{cv_id}/slug` | تنظیم slug رزومه |
| PUT | `/api/v10/jobseeker-app/cv-builder/{cv_id}/switch-publicity-status` | تغییر وضعیت عمومی/خصوصی |
| PUT | `/api/v10/jobseeker-app/cv-builder/{cv_id}/switch-search-status` | تغییر وضعیت جستجو |

#### Resume Model (CV Builder)

| فیلد | توضیح |
|------|-------|
| `basic_data` | نام، تاریخ تولد، جنسیت، وضعیت سربازی، ایمیل، تلفن |
| `personal` | اطلاعات تکمیلی شخصی |
| `education` | لیست تحصیلات (مقطع، رشته، دانشگاه، سال شروع/پایان) |
| `experience` | لیست سوابق شغلی (شرکت، موقعیت، تاریخ شروع/پایان، توضیحات) |
| `language` | لیست زبان‌ها (زبان، سطح) |
| `skills` | لیست مهارت‌ها (با ترتیب) |
| `preference` | ترجیحات شغلی (دسته‌بندی، استان، حقوق مورد انتظار) |
| `about` | خلاصه / درباره من |
| `public_contact` | اطلاعات تماس عمومی |
| `avatar` | تصویر پروفایل |
| `score` | امتیاز کامل بودن رزومه |
| `slug` | لینک اختصاصی رزومه |

---

### ۵.۵. Applications / Applied Jobs (نیاز به احراز هویت)

| Method | Endpoint | توضیح |
|--------|----------|-------|
| GET | `/api/v10/jobs/applied` | لیست شغل‌هایی که رزومه ارسال شده |
| GET | `/api/v10/jobseeker-app/applications/{app_id}` | جزئیات یک درخواست |
| POST | `/api/v10/jobseeker-app/applications/{app_id}/cover-letter-upload` | آپلود کاورلتر |
| PUT | `/api/v10/jobseeker-app/applications/{app_id}/update-cover-letter` | ویرایش کاورلتر |
| PUT | `/api/v10/jobs/applied/{applicationId}/canceled` | لغو درخواست |

---

### ۵.۶. Companies (نیاز به احراز هویت)

| Method | Endpoint | توضیح |
|--------|----------|-------|
| GET | `/api/v10/companies/{company_id}/jobs` | لیست شغل‌های یک شرکت |
| GET | `/api/v10/companies/{company_id}/jobs/{job_id}/apply` | داده‌های مورد نیاز برای ارسال رزومه |
| GET | `/api/v10/companies/{company_slug}/jobs/{job_slug}` | جزئیات شغل |

---

### ۵.۷. Job Alerts (نیاز به احراز هویت)

| Method | Endpoint | توضیح |
|--------|----------|-------|
| GET | `/api/v10/job-alert` | لیست هشدارهای شغلی |
| POST | `/api/v10/job-alert` | ایجاد هشدار جدید |
| DELETE | `/api/v10/job-alert/{alert_id}` | حذف هشدار |
| GET | `/api/v10/job-alert/meta` | متادیتای هشدار (گزینه‌های فرکانس و ...) |

---

### ۵.۸. Utility (عمومی)

| Method | Endpoint | توضیح |
|--------|----------|-------|
| POST | `/api/v10/utils/email-checker` | بررسی اعتبار ایمیل |
| GET | `/api/v10/utils/last-applied-job` | آخرین شغل اقدام‌شده |
| POST | `/api/v10/contact` | ارسال فرم تماس |
| POST | `/api/v10/feedback` | ارسال بازخورد |
| GET | `/api/v10/feedback-result/{id}` | مشاهده نتیجه بازخورد |
| POST | `/api/v10/fcm/device` | ثبت دستگاه برای نوتیفیکیشن |
| POST | `/api/v10/register-device` | ثبت دستگاه |
| POST | `/api/v10/violation-report/job/{jobId}` | گزارش تخلف آگهی |
| GET | `/api/v10/violation-report/all-reasons` | لیست دلایل گزارش تخلف |
| POST | `/api/v10/doc-notification-cookie/` | ثبت کوکی نوتیفیکیشن |
| POST | `/api/v10/notifications/employee/seen` | مشاهده شده‌ها |

---

### ۵.۹. Error Responses

#### `401 Unauthorized` / `403 Forbidden`
```json
{
  "message": "messages.api_access_denied"
}
```

#### `404 Not Found`
```json
{
  "message": "messages.api_not_found"
}
```

#### `500 Error`
```json
{
  "message": "مشکلی در پردازش درخواست شما وجود داشت."
}
```

---

## ۶. معماری Mock API پیشنهادی برای پروژه

از آنجایی که جابینجا API عمومی ندارد، یک **Mock API** درون اپلیکیشن یا یک سرویس JSON ساده بسازید:

```
MOCK_BASE_URL = http://localhost:3000/api
```

| Method | Endpoint | توضیح |
|--------|----------|-------|
| POST | `/api/auth/signup` | ثبت‌نام |
| POST | `/api/auth/login` | ورود |
| POST | `/api/auth/logout` | خروج |
| GET | `/api/jobs?keyword=&location=&page=` | لیست شغل‌ها (JSON) |
| GET | `/api/jobs/{id}` | جزئیات شغل |
| GET | `/api/companies/{slug}` | اطلاعات شرکت |
| GET | `/api/companies/{slug}/jobs` | شغل‌های یک شرکت |
| GET | `/api/user/profile` | پروفایل کاربر |
| GET | `/api/user/applied-jobs` | شغل‌های اقدام‌شده |
| GET | `/api/jobs/categories` | دسته‌بندی‌ها |
| GET | `/api/jobs/locations` | استان‌ها |
| GET | `/api/job-skills/search?q=` | جستجوی مهارت |

### نمونه پاسخ Mock برای GET /api/jobs

```json
{
  "data": [
    {
      "id": "job_1",
      "title": "توسعه‌دهنده پایتون",
      "company": {
        "id": "company_1",
        "name": "شرکت نمونه",
        "slug": "sample-company",
        "logo": null,
        "industry": "کامپیوتر، فناوری اطلاعات و اینترنت"
      },
      "location": {
        "province": "تهران",
        "city": "تهران"
      },
      "contract_type": "تمام‌وقت",
      "salary": {
        "amount": null,
        "is_negotiable": true,
        "display": "حقوق توافقی"
      },
      "experience_level": "کمتر از سه سال",
      "published_at": "۱۴۰۵/۰۳/۱۰",
      "is_remote": false
    }
  ],
  "meta": {
    "current_page": 1,
    "last_page": 10,
    "per_page": 20,
    "total": 200
  }
}
```

---

## ۷. صفحات موردنیاز اپلیکیشن

1. **Sign-up Screen** - فرم ثبت‌نام با اعتبارسنجی
2. **Login Screen** - فرم ورود با اعتبارسنجی
3. **Home Screen** - لیست شغل‌ها با جستجو و فیلتر
4. **Profile Screen** - اطلاعات کاربر + دکمه خروج
5. **Job Detail Screen** - جزئیات کامل شغل + دکمه ارسال رزومه
6. **Company Screen** - اطلاعات شرکت + لیست شغل‌های شرکت

---

## ۸. ساختار پروژه (MVP)

```
lib/
├── main.dart
├── models/
│   ├── user.dart
│   ├── job.dart
│   ├── company.dart
│   ├── login_request.dart
│   ├── signup_request.dart
│   └── api_response.dart
├── views/
│   ├── signup_screen.dart
│   ├── login_screen.dart
│   ├── home_screen.dart
│   ├── profile_screen.dart
│   ├── job_detail_screen.dart
│   └── company_screen.dart
├── presenters/
│   ├── auth_presenter.dart
│   ├── job_presenter.dart
│   ├── profile_presenter.dart
│   └── company_presenter.dart
├── services/
│   ├── api_service.dart
│   └── mock_api_service.dart
├── widgets/
│   ├── job_card.dart
│   ├── custom_button.dart
│   ├── custom_text_field.dart
│   └── loading_widget.dart
└── utils/
    ├── constants.dart
    └── validators.dart
```

---

## ۹. نمونه کد Mock ApiService

```dart
class MockApiService {
  static const String baseUrl = 'http://localhost:3000/api';

  Future<List<Job>> getJobs({int page = 1, String? keyword}) async {
    // Mock implementation - returns static data
    await Future.delayed(const Duration(seconds: 1));
    return [
      Job(
        id: 'job_1',
        title: 'توسعه‌دهنده پایتون',
        companyName: 'شرکت نمونه',
        location: 'تهران',
        contractType: 'تمام‌وقت',
        salaryDisplay: 'حقوق توافقی',
        publishedAt: '۱۴۰۵/۰۳/۱۰',
      ),
    ];
  }

  Future<User> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    return User(id: 1, name: 'کاربر تست', email: email);
  }

  Future<User> signup(String name, String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    return User(id: 1, name: name, email: email);
  }
}
```

---

## ۱۰. الزامات کدنویسی و رابط کاربری

- کد تمیز، خوانا، با نام‌گذاری معنادار
- رعایت اصول OOP و جداسازی responsibilityها
- View هرگز مستقیماً API صدا نزند
- مدیریت خطا (قطع اینترنت، خطای سرور)
- نمایش loading و حالت خطا در همه صفحات
- طراحی ساده، کاربرپسند، واکنش‌گرا

---

## ۱۱. گروه‌بندی و خروجی‌ها

- گروه‌های حداکثر **۳ نفره**
- فایل `team.txt` در روت پروژه (شماره دانشجویی هر نفر در یک خط)
- **سورس‌کد کامل پروژه Flutter**
- **گزارش PDF** شامل معرفی پروژه، صفحات، معماری MVP، تصاویر، نقش اعضا
- **ویدئوی حداکثر ۱ دقیقه** از اجرای اپلیکیشن و توضیح معماری

---

## ۱۲. معیارهای ارزیابی

| بخش | نمره |
|-----|-----:|
| پیاده‌سازی صحیح صفحات اصلی | ۲۰ |
| ارتباط صحیح با API | ۲۰ |
| رعایت معماری MVP | ۲۰ |
| رعایت اصول OOP و Clean Code | ۱۵ |
| طراحی رابط کاربری مناسب | ۱۰ |
| مدیریت خطاها و وضعیت loading | ۵ |
| گزارش پروژه | ۵ |
| ویدئوی ارائه و اجرای برنامه | ۵ |
| **جمع کل** | **۱۰۰** |
