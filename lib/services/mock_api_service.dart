import '../models/api_response.dart';
import '../models/company.dart';
import '../models/job.dart';
import '../models/job_filter.dart';
import '../models/user.dart';
import 'api_service.dart';

class MockApiService implements ApiService {
  static const _delay = Duration(milliseconds: 800);

  User? _currentUser;
  final Set<String> _favoriteJobIds = {};
  final Set<String> _appliedJobIds = {};

  final List<Company> _mockCompanies = [
    Company(
      id: 'company_1', name: 'شرکت نمونه', slug: 'sample-company',
      industry: 'کامپیوتر، فناوری اطلاعات و اینترنت',
      description: 'شرکت نمونه یک شرکت فعال در حوزه فناوری اطلاعات است. این شرکت با بیش از ۱۰ سال سابقه، خدمات متنوعی در حوزه نرم‌افزار و وب ارائه می‌دهد.',
      location: 'تهران', employeeCount: 50, website: 'sample-co.com',
      popularity: 9, jobVariety: 8, resumeReview: 10,
      coverUrl: 'https://via.placeholder.com/768x200/4A90D9/ffffff?text=Sample+Company',
    ),
    Company(
      id: 'company_2', name: 'تیم نرم‌افزاری پیشرو', slug: 'tech-team',
      industry: 'نرم‌افزار',
      description: 'تیم نرم‌افزاری پیشرو در زمینه اپلیکیشن‌های موبایل فعالیت دارد. ما به دنبال افراد خلاق و باانگیزه هستیم.',
      location: 'اصفهان', employeeCount: 20, website: 'tech-team.ir',
      popularity: 8, jobVariety: 7, resumeReview: 9,
    ),
    Company(
      id: 'company_3', name: 'شرکت ابری نوین', slug: 'cloud-co',
      industry: 'زیرساخت ابری',
      description: 'شرکت ابری نوین ارائه‌دهنده خدمات ابری در ایران است. بزرگترین تیم DevOps کشور را داریم.',
      location: 'مشهد', employeeCount: 100, website: 'cloudco.ir',
      popularity: 7, jobVariety: 8, resumeReview: 8,
    ),
    Company(
      id: 'company_4', name: 'فناپ', slug: 'fanap',
      industry: 'کامپیوتر، فناوری اطلاعات و اینترنت',
      description: 'فناپ یکی از بزرگترین شرکت‌های فناوری اطلاعات ایران است.',
      location: 'تهران', employeeCount: 500, website: 'fanap.ir',
      popularity: 10, jobVariety: 9, resumeReview: 10,
    ),
    Company(
      id: 'company_5', name: 'دیجیکالا', slug: 'digikala',
      industry: 'تجارت الکترونیک',
      description: 'دیجیکالا بزرگترین فروشگاه اینترنتی ایران است.',
      location: 'تهران', employeeCount: 2000, website: 'digikala.com',
      popularity: 9, jobVariety: 8, resumeReview: 9,
    ),
    Company(
      id: 'company_6', name: 'کتابراه', slug: 'ketabrah',
      industry: 'نرم‌افزار',
      description: 'کتابراه پلتفرم خرید و مطالعه کتاب الکترونیک است.',
      location: 'تهران', employeeCount: 30, website: 'ketabrah.ir',
      popularity: 8, jobVariety: 6, resumeReview: 8,
    ),
    Company(
      id: 'company_7', name: 'اسنپ', slug: 'snapp',
      industry: 'کامپیوتر، فناوری اطلاعات و اینترنت',
      description: 'اسنپ بزرگترین سامانه هوشمند حمل و نقل و خدمات آنلاین در ایران است.',
      location: 'تهران', employeeCount: 1500, website: 'snapp.ir',
      popularity: 10, jobVariety: 9, resumeReview: 8,
    ),
    Company(
      id: 'company_8', name: 'تپسی', slug: 'tapsi',
      industry: 'کامپیوتر، فناوری اطلاعات و اینترنت',
      description: 'تپسی یکی از محبوب‌ترین سامانه‌های درخواست آنلاین خودرو در ایران است.',
      location: 'تهران', employeeCount: 800, website: 'tapsi.ir',
      popularity: 9, jobVariety: 7, resumeReview: 9,
    ),
    Company(
      id: 'company_9', name: 'آینده‌سازان', slug: 'ayande-sazan',
      industry: 'آموزش',
      description: 'مجموعه آینده‌سازان با هدف توسعه آموزش آنلاین در کشور فعالیت می‌کند.',
      location: 'اصفهان', employeeCount: 40, website: 'ayande.ir',
      popularity: 7, jobVariety: 6, resumeReview: 7,
    ),
    Company(
      id: 'company_10', name: 'راهکارهای داده‌ور', slug: 'data-var',
      industry: 'IT / DevOps / Server',
      description: 'راهکارهای داده‌ور ارائه‌دهنده خدمات زیرساخت ابری و دیتاسنتر در ایران است.',
      location: 'شیراز', employeeCount: 80, website: 'datavar.ir',
      popularity: 7, jobVariety: 5, resumeReview: 8,
    ),
    Company(
      id: 'company_11', name: 'نوین پرداخت', slug: 'novin-pardakht',
      industry: 'مالی و بانکی',
      description: 'نوین پرداخت ارائه‌دهنده خدمات پرداخت الکترونیک و درگاه پرداخت اینترنتی است.',
      location: 'تهران', employeeCount: 300, website: 'novinpardakht.ir',
      popularity: 8, jobVariety: 7, resumeReview: 7,
    ),
    Company(
      id: 'company_12', name: 'گروه نرم‌افزاری هامون', slug: 'hamun',
      industry: 'نرم‌افزار',
      description: 'هامون تولیدکننده نرم‌افزارهای سازمانی و ابری در ایران است.',
      location: 'مشهد', employeeCount: 60, website: 'hamun.ir',
      popularity: 6, jobVariety: 5, resumeReview: 8,
    ),
  ];

  final List<Job> _mockJobs = [];

  void _initJobs() {
    if (_mockJobs.isNotEmpty) return;

    final jobs = [
      Job(
        id: 'job_1', shortId: 'tZPK',
        title: 'توسعه‌دهنده پایتون',
        company: _mockCompanies[0],
        location: 'تهران، تهران',
        contractType: 'تمام‌وقت',
        salaryDisplay: 'حقوق توافقی',
        experienceLevel: 'کمتر از سه سال',
        publishedAt: '۱۴۰۵/۰۳/۱۰',
        relativeTime: '(امروز)',
        isPremium: true,
        category: 'وب، برنامه‌نویسی و نرم‌افزار',
        description: 'شرکت نمونه جهت تکمیل کادر فنی خود به یک توسعه‌دهنده پایتون مسلط به جنگو نیازمند است.\n\nشرایط:\n- تسلط به Python و Django\n- آشنایی با PostgreSQL\n- تجربه کار با Git\n- روحیه کار تیمی\n\nمزایا:\n- بیمه تکمیلی\n- ساعت کاری شناور\n- محیط پویا و جوان',
        skills: ['Python', 'Django', 'PostgreSQL', 'Git', 'Linux'],
        benefits: ['بیمه تکمیلی', 'ساعت شناور', 'صبحانه رایگان'],
      ),
      Job(
        id: 'job_2', shortId: 'tk6D',
        title: 'برنامه‌نویس فلاتر',
        company: _mockCompanies[1],
        location: 'اصفهان',
        contractType: 'دورکاری',
        salaryDisplay: '۱۵-۲۵ میلیون تومان',
        experienceLevel: 'یک تا سه سال',
        publishedAt: '۱۴۰۵/۰۳/۰۸',
        relativeTime: '(۲ روز پیش)',
        isPremium: false,
        category: 'وب، برنامه‌نویسی و نرم‌افزار',
        description: 'به دنبال برنامه‌نویس فلاتر مسلط به معماری MVP و BLoC هستیم.\n\nتسلط به:\n- Flutter و Dart\n- معماری MVP و BLoC\n- اتصال به REST API\n- تجربه انتشار اپ در بازار',
        skills: ['Flutter', 'Dart', 'MVP', 'BLoC', 'REST API'],
        benefits: ['دورکاری', 'بیمه'],
      ),
      Job(
        id: 'job_3', shortId: 'twzo',
        title: 'مهندس DevOps',
        company: _mockCompanies[2],
        location: 'مشهد',
        contractType: 'تمام‌وقت',
        salaryDisplay: '۲۰-۳۵ میلیون تومان',
        experienceLevel: 'سه تا پنج سال',
        publishedAt: '۱۴۰۵/۰۳/۰۵',
        relativeTime: '(۵ روز پیش)',
        isPremium: true,
        category: 'IT / DevOps / Server',
        description: 'مسلط به Docker، Kubernetes، CI/CD و ابزارهای مدیریت سرور.\n\nمسئولیت‌ها:\n- مدیریت زیرساخت ابری\n- پیاده‌سازی CI/CD\n- مانیتورینگ سرورها\n- بهینه‌سازی هزینه‌ها',
        skills: ['Docker', 'Kubernetes', 'Linux', 'AWS', 'Terraform', 'GitLab CI'],
        benefits: ['بیمه تکمیلی', 'سهام تشویقی', 'سفر کاری'],
      ),
      Job(
        id: 'job_4', shortId: 'tkUV',
        title: 'تحلیلگر داده',
        company: _mockCompanies[0],
        location: 'تهران',
        contractType: 'تمام‌وقت',
        salaryDisplay: '۱۲-۲۰ میلیون تومان',
        experienceLevel: 'یک تا سه سال',
        publishedAt: '۱۴۰۵/۰۳/۰۳',
        relativeTime: '(۷ روز پیش)',
        isPremium: false,
        category: 'تحقیق بازار و تحلیل اقتصادی',
        description: 'شرکت نمونه برای تیم تحلیل داده خود به یک تحلیلگر داده مسلط به SQL و Python نیاز دارد.',
        skills: ['Python', 'SQL', 'Tableau', 'Machine Learning'],
      ),
      Job(
        id: 'job_5', shortId: 'ARNJ',
        title: 'طراح UI/UX',
        company: _mockCompanies[1],
        location: 'تهران',
        contractType: 'پروژه‌ای',
        salaryDisplay: 'حقوق توافقی',
        experienceLevel: 'کمتر از سه سال',
        publishedAt: '۱۴۰۵/۰۲/۲۸',
        relativeTime: '(۱۲ روز پیش)',
        isPremium: false,
        category: 'طراحی',
        description: 'به یک طراح UI/UX خلاق برای طراحی رابط کاربری اپلیکیشن موبایل نیاز داریم.',
        skills: ['Figma', 'Adobe XD', 'UI Design', 'UX Research'],
        benefits: ['پروژه‌ای', 'ساعت شناور'],
      ),
      Job(
        id: 'job_6', shortId: 'tVou',
        title: 'مدیر محصول',
        company: _mockCompanies[3],
        location: 'تهران',
        contractType: 'تمام‌وقت',
        salaryDisplay: '۳۰-۵۰ میلیون تومان',
        experienceLevel: 'پنج تا ده سال',
        publishedAt: '۱۴۰۵/۰۳/۰۹',
        relativeTime: '(۱ روز پیش)',
        isPremium: true,
        category: 'مدیر محصول',
        description: 'فناپ به دنبال یک مدیر محصول با تجربه برای مدیریت محصولات فناوری اطلاعات خود می‌باشد.',
        skills: ['Product Management', 'Agile', 'JIRA', 'Analytics', 'UX'],
        benefits: ['بیمه تکمیلی', 'سهام تشویقی', 'بونوس', 'سفر کاری'],
      ),
      Job(
        id: 'job_7', shortId: 'tOhN',
        title: 'برنامه‌نویس بک‌اند (Node.js)',
        company: _mockCompanies[4],
        location: 'تهران',
        contractType: 'تمام‌وقت',
        salaryDisplay: '۲۰-۴۰ میلیون تومان',
        experienceLevel: 'سه تا پنج سال',
        publishedAt: '۱۴۰۵/۰۳/۰۷',
        relativeTime: '(۳ روز پیش)',
        isPremium: true,
        category: 'وب، برنامه‌نویسی و نرم‌افزار',
        description: 'دیجیکالا به دنبال برنامه‌نویس بک‌اند مسلط به Node.js برای تیم فنی خود می‌باشد.',
        skills: ['Node.js', 'Express', 'MongoDB', 'Redis', 'Microservices'],
        benefits: ['بیمه تکمیلی', 'سهام تشویقی', 'باشگاه ورزشی', 'سرویس رفت و آمد'],
      ),
      Job(
        id: 'job_8', shortId: 'tr56',
        title: 'کارشناس تامین و خرید',
        company: _mockCompanies[5],
        location: 'تهران',
        contractType: 'تمام‌وقت',
        salaryDisplay: 'برای مشاهده حقوق وارد شوید',
        experienceLevel: 'یک تا سه سال',
        publishedAt: '۱۴۰۵/۰۳/۰۹',
        relativeTime: '(۱ روز پیش)',
        isPremium: true,
        category: 'خرید و بازرگانی',
        description: 'کتابراه به یک کارشناس تامین و خرید با تجربه نیاز دارد.',
        skills: ['خرید', 'بازرگانی', 'مذاکره', 'Excel'],
        benefits: ['بیمه', 'پاداش'],
      ),
      Job(
        id: 'job_9', shortId: 'trJt',
        title: 'کارشناس فروش',
        company: _mockCompanies[3],
        location: 'تهران',
        contractType: 'تمام‌وقت',
        salaryDisplay: '۱۰-۲۰ میلیون تومان',
        experienceLevel: 'کمتر از سه سال',
        publishedAt: '۱۴۰۵/۰۲/۲۵',
        relativeTime: '(۱۵ روز پیش)',
        isPremium: false,
        category: 'فروش و بازاریابی',
        description: 'فناپ به یک کارشناس فروش مسلط به فروش راهکارهای سازمانی نیاز دارد.',
        skills: ['فروش', 'مذاکره', 'CRM', 'ارائه'],
        benefits: ['پورسانت', 'بیمه'],
      ),
      Job(
        id: 'job_10', shortId: 'trk5',
        title: 'متخصص امنیت سایبری',
        company: _mockCompanies[2],
        location: 'مشهد',
        contractType: 'تمام‌وقت',
        salaryDisplay: '۴۰-۶۰ میلیون تومان',
        experienceLevel: 'پنج تا ده سال',
        publishedAt: '۱۴۰۵/۰۳/۰۱',
        relativeTime: '(۹ روز پیش)',
        isPremium: true,
        category: 'IT / DevOps / Server',
        description: 'شرکت ابری نوین به یک متخصص امنیت سایبری برای تیم امنیت خود نیاز دارد.',
        skills: ['Network Security', 'Penetration Testing', 'SIEM', 'ISO 27001'],
        benefits: ['بیمه تکمیلی', 'سهام تشویقی', 'اضافه‌کاری'],
      ),
      Job(
        id: 'job_11', shortId: 'tZSn',
        title: 'برنامه‌نویس بک‌اند (پایتون)',
        company: _mockCompanies[6],
        location: 'تهران',
        contractType: 'تمام‌وقت',
        salaryDisplay: '۲۵-۴۵ میلیون تومان',
        experienceLevel: 'سه تا پنج سال',
        publishedAt: '۱۴۰۵/۰۳/۱۱',
        relativeTime: '(امروز)',
        isPremium: true,
        category: 'وب، برنامه‌نویسی و نرم‌افزار',
        description: 'اسنپ به دنبال برنامه‌نویس بک‌اند مسلط به پایتون برای تیم فنی خود می‌باشد.\n\nمسئولیت‌ها:\n- طراحی و پیاده‌سازی API\n- بهینه‌سازی سرویس‌ها\n- همکاری با تیم محصول\n\nمزایا:\n- بیمه تکمیلی\n- سهام تشویقی\n- سرویس رفت و آمد',
        skills: ['Python', 'Django', 'Microservices', 'Redis', 'PostgreSQL'],
        benefits: ['بیمه تکمیلی', 'سهام تشویقی', 'سرویس رفت و آمد', 'باشگاه ورزشی'],
      ),
      Job(
        id: 'job_12', shortId: 'tZTm',
        title: 'مهندس داده',
        company: _mockCompanies[6],
        location: 'تهران',
        contractType: 'تمام‌وقت',
        salaryDisplay: '۳۰-۵۰ میلیون تومان',
        experienceLevel: 'سه تا پنج سال',
        publishedAt: '۱۴۰۵/۰۳/۱۰',
        relativeTime: '(۱ روز پیش)',
        isPremium: true,
        category: 'IT / DevOps / Server',
        description: 'اسنپ به یک مهندس داده مسلط به Big Data و Spark نیاز دارد.',
        skills: ['Spark', 'Hadoop', 'Python', 'SQL', 'Airflow'],
        benefits: ['بیمه تکمیلی', 'سهام تشویقی', 'صبحانه رایگان'],
      ),
      Job(
        id: 'job_13', shortId: 'tZUh',
        title: 'طراح محصول',
        company: _mockCompanies[7],
        location: 'تهران',
        contractType: 'تمام‌وقت',
        salaryDisplay: '۲۰-۳۵ میلیون تومان',
        experienceLevel: 'یک تا سه سال',
        publishedAt: '۱۴۰۵/۰۳/۰۹',
        relativeTime: '(۲ روز پیش)',
        isPremium: false,
        category: 'طراحی',
        description: 'تپسی به یک طراح محصول با تجربه در طراحی اپلیکیشن‌های موبایل نیاز دارد.',
        skills: ['Figma', 'Product Design', 'UX Research', 'Prototyping'],
        benefits: ['بیمه', 'ساعت شناور'],
      ),
      Job(
        id: 'job_14', shortId: 'tZVi',
        title: 'کارشناس پشتیبانی فنی',
        company: _mockCompanies[8],
        location: 'اصفهان',
        contractType: 'تمام‌وقت',
        salaryDisplay: '۸-۱۲ میلیون تومان',
        experienceLevel: 'کمتر از یک سال',
        publishedAt: '۱۴۰۵/۰۳/۰۸',
        relativeTime: '(۳ روز پیش)',
        isPremium: false,
        category: 'پشتیبانی و امور مشتریان',
        description: 'آینده‌سازان به یک کارشناس پشتیبانی فنی برای پاسخگویی به کاربران نیاز دارد.',
        skills: ['ارتباط موثر', 'آشنایی با وردپرس', 'حل مسئله'],
        benefits: ['بیمه', 'پاداش'],
      ),
      Job(
        id: 'job_15', shortId: 'tZWj',
        title: 'مدیر پروژه فناوری اطلاعات',
        company: _mockCompanies[9],
        location: 'شیراز',
        contractType: 'تمام‌وقت',
        salaryDisplay: '۱۸-۳۰ میلیون تومان',
        experienceLevel: 'سه تا پنج سال',
        publishedAt: '۱۴۰۵/۰۳/۰۷',
        relativeTime: '(۴ روز پیش)',
        isPremium: true,
        category: 'IT / DevOps / Server',
        description: 'راهکارهای داده‌ور به یک مدیر پروژه با تجربه در حوزه IT نیاز دارد.',
        skills: ['Project Management', 'Agile', 'Scrum', 'JIRA', 'PMP'],
        benefits: ['بیمه تکمیلی', 'پاداش', 'سفر کاری'],
      ),
      Job(
        id: 'job_16', shortId: 'tZXk',
        title: 'توسعه‌دهنده فرانت‌اند (React)',
        company: _mockCompanies[10],
        location: 'تهران',
        contractType: 'دورکاری',
        salaryDisplay: '۲۰-۳۵ میلیون تومان',
        experienceLevel: 'دو تا چهار سال',
        publishedAt: '۱۴۰۵/۰۳/۰۶',
        relativeTime: '(۵ روز پیش)',
        isPremium: false,
        category: 'وب، برنامه‌نویسی و نرم‌افزار',
        description: 'نوین پرداخت به یک توسعه‌دهنده فرانت‌اند مسلط به React و TypeScript نیاز دارد.',
        skills: ['React', 'TypeScript', 'Next.js', 'Tailwind CSS'],
        benefits: ['دورکاری', 'بیمه'],
      ),
      Job(
        id: 'job_17', shortId: 'tZYl',
        title: 'کارشناس دیجیتال مارکتینگ',
        company: _mockCompanies[11],
        location: 'مشهد',
        contractType: 'تمام‌وقت',
        salaryDisplay: '۱۲-۱۸ میلیون تومان',
        experienceLevel: 'یک تا سه سال',
        publishedAt: '۱۴۰۵/۰۳/۰۵',
        relativeTime: '(۶ روز پیش)',
        isPremium: false,
        category: 'دیجیتال مارکتینگ',
        description: 'گروه نرم‌افزاری هامون به یک کارشناس دیجیتال مارکتینگ مسلط به سئو و تبلیغات آنلاین نیاز دارد.',
        skills: ['SEO', 'Google Ads', 'Social Media', 'Content Marketing', 'Analytics'],
        benefits: ['بیمه', 'پاداش'],
      ),
      Job(
        id: 'job_18', shortId: 'tZZm',
        title: 'برنامه‌نویس جاوا (Java)',
        company: _mockCompanies[3],
        location: 'تهران',
        contractType: 'تمام‌وقت',
        salaryDisplay: '۲۵-۴۰ میلیون تومان',
        experienceLevel: 'سه تا پنج سال',
        publishedAt: '۱۴۰۵/۰۳/۰۴',
        relativeTime: '(۷ روز پیش)',
        isPremium: true,
        category: 'وب، برنامه‌نویسی و نرم‌افزار',
        description: 'فناپ به یک برنامه‌نویس جاوا مسلط به Spring Boot برای تیم فنی خود نیاز دارد.',
        skills: ['Java', 'Spring Boot', 'Microservices', 'Kafka', 'Oracle'],
        benefits: ['بیمه تکمیلی', 'سهام تشویقی', 'سرویس رفت و آمد', 'باشگاه ورزشی'],
      ),
      Job(
        id: 'job_19', shortId: 'tZAn',
        title: 'کارشناس منابع انسانی',
        company: _mockCompanies[4],
        location: 'تهران',
        contractType: 'تمام‌وقت',
        salaryDisplay: '۱۵-۲۵ میلیون تومان',
        experienceLevel: 'دو تا چهار سال',
        publishedAt: '۱۴۰۵/۰۳/۰۳',
        relativeTime: '(۸ روز پیش)',
        isPremium: false,
        category: 'منابع انسانی و کارگزینی',
        description: 'دیجیکالا به یک کارشناس منابع انسانی با تجربه در جذب و استخدام نیاز دارد.',
        skills: ['استخدام', 'مصاحبه', 'کارنامه', 'قوانین کار'],
        benefits: ['بیمه تکمیلی', 'باشگاه ورزشی', 'سرویس'],
      ),
      Job(
        id: 'job_20', shortId: 'tZBo',
        title: 'متخصص هوش مصنوعی',
        company: _mockCompanies[6],
        location: 'تهران',
        contractType: 'تمام‌وقت',
        salaryDisplay: '۵۰-۸۰ میلیون تومان',
        experienceLevel: 'پنج تا ده سال',
        publishedAt: '۱۴۰۵/۰۳/۰۲',
        relativeTime: '(۹ روز پیش)',
        isPremium: true,
        category: 'وب، برنامه‌نویسی و نرم‌افزار',
        description: 'اسنپ به یک متخصص هوش مصنوعی برای تیم داده و هوش مصنوعی خود نیاز دارد.',
        skills: ['Machine Learning', 'Deep Learning', 'NLP', 'TensorFlow', 'PyTorch'],
        benefits: ['بیمه تکمیلی', 'سهام تشویقی', 'سفر کاری'],
      ),
    ];

    _mockJobs.addAll(jobs);
  }

  MockApiService() {
    _initJobs();
  }

  Future<void> _delayCall() => Future.delayed(_delay);

  @override
  Future<ApiResponse<User>> login(String email, String password) async {
    await _delayCall();
    if (email == 'test@test.com' && password == '123456') {
      _currentUser = User(
        id: 1,
        name: 'کاربر تست',
        email: email,
        token: 'mock_token_123',
        phone: '۰۹۱۲۳۴۵۶۷۸۹',
        resumeSlug: 'test-user',
        resumeScore: 75,
        appliedJobsCount: _appliedJobIds.length,
        savedJobsCount: _favoriteJobIds.length,
      );
      return ApiResponse.success(_currentUser!, message: 'به جابینجا خوش آمدید');
    }
    return ApiResponse.error('ایمیل یا رمز عبور اشتباه است', statusCode: 401);
  }

  @override
  Future<ApiResponse<User>> signup(String name, String email, String password) async {
    await _delayCall();
    _currentUser = User(
      id: 2, name: name, email: email, token: 'mock_token_456',
      phone: '', resumeSlug: name.replaceAll(' ', '-'),
      appliedJobsCount: 0, savedJobsCount: 0,
    );
    return ApiResponse.success(_currentUser!, message: 'ثبت‌نام با موفقیت انجام شد');
  }

  @override
  Future<ApiResponse<void>> logout() async {
    await _delayCall();
    _currentUser = null;
    return ApiResponse.success(null, message: 'با موفقیت خارج شدید');
  }

  @override
  Future<ApiResponse<List<Job>>> getJobs({int page = 1, String? keyword, String? location}) async {
    await _delayCall();
    var jobs = List<Job>.from(_mockJobs);

    if (keyword != null && keyword.isNotEmpty) {
      jobs = jobs.where((j) =>
        j.title.contains(keyword) || j.company.name.contains(keyword)
      ).toList();
    }

    if (location != null && location.isNotEmpty) {
      jobs = jobs.where((j) => j.location.contains(location)).toList();
    }

    return ApiResponse.success(jobs);
  }

  Future<ApiResponse<List<Job>>> getJobsWithFilter(JobFilter filter) async {
    await _delayCall();
    var jobs = List<Job>.from(_mockJobs);

    if (filter.keyword != null && filter.keyword!.isNotEmpty) {
      jobs = jobs.where((j) =>
        j.title.contains(filter.keyword!) ||
        j.company.name.contains(filter.keyword!)
      ).toList();
    }

    if (filter.location != null && filter.location!.isNotEmpty) {
      jobs = jobs.where((j) => j.location.contains(filter.location!)).toList();
    }

    if (filter.category != null && filter.category!.isNotEmpty && filter.category != 'همه') {
      jobs = jobs.where((j) => (j.category ?? '').contains(filter.category!)).toList();
    }

    if (filter.contractType != null && filter.contractType!.isNotEmpty) {
      jobs = jobs.where((j) => (j.contractType ?? '').contains(filter.contractType!)).toList();
    }

    if (filter.isRemote == true) {
      jobs = jobs.where((j) => j.isRemote).toList();
    }

    return ApiResponse.success(jobs);
  }

  @override
  Future<ApiResponse<Job>> getJobDetail(String jobId) async {
    await _delayCall();
    try {
      final job = _mockJobs.firstWhere((j) => j.id == jobId);
      return ApiResponse.success(job);
    } catch (_) {
      return ApiResponse.error('شغل مورد نظر یافت نشد', statusCode: 404);
    }
  }

  @override
  Future<ApiResponse<Company>> getCompany(String slug) async {
    await _delayCall();
    try {
      final company = _mockCompanies.firstWhere((c) => c.slug == slug);
      return ApiResponse.success(company);
    } catch (_) {
      return ApiResponse.error('شرکت مورد نظر یافت نشد', statusCode: 404);
    }
  }

  @override
  Future<ApiResponse<List<Job>>> getCompanyJobs(String slug) async {
    await _delayCall();
    final jobs = _mockJobs.where((j) => j.company.slug == slug).toList();
    return ApiResponse.success(jobs);
  }

  @override
  Future<ApiResponse<User>> getProfile() async {
    await _delayCall();
    if (_currentUser != null) {
      final user = User(
        id: _currentUser!.id,
        name: _currentUser!.name,
        email: _currentUser!.email,
        token: _currentUser!.token,
        phone: _currentUser!.phone ?? '۰۹۱۲۳۴۵۶۷۸۹',
        resumeSlug: _currentUser!.resumeSlug ?? 'test-user',
        resumeScore: _currentUser!.resumeScore ?? 75,
        appliedJobsCount: _appliedJobIds.length,
        savedJobsCount: _favoriteJobIds.length,
      );
      return ApiResponse.success(user);
    }
    return ApiResponse.error('کاربر وارد نشده است', statusCode: 401);
  }

  @override
  Future<ApiResponse<List<Job>>> getAppliedJobs() async {
    await _delayCall();
    return ApiResponse.success(
      _mockJobs.where((j) => _appliedJobIds.contains(j.id)).toList()
    );
  }

  Future<ApiResponse<void>> applyToJob(String jobId) async {
    await _delayCall();
    _appliedJobIds.add(jobId);
    return ApiResponse.success(null, message: 'رزومه با موفقیت ارسال شد');
  }

  Future<ApiResponse<List<Job>>> getFavoriteJobs() async {
    await _delayCall();
    return ApiResponse.success(
      _mockJobs.where((j) => _favoriteJobIds.contains(j.id)).toList()
    );
  }

  Future<ApiResponse<void>> toggleFavorite(String jobId) async {
    await _delayCall();
    if (_favoriteJobIds.contains(jobId)) {
      _favoriteJobIds.remove(jobId);
      return ApiResponse.success(null, message: 'از نشان‌شده‌ها حذف شد');
    } else {
      _favoriteJobIds.add(jobId);
      return ApiResponse.success(null, message: 'به نشان‌شده‌ها اضافه شد');
    }
  }

  bool isFavorited(String jobId) => _favoriteJobIds.contains(jobId);
  bool isApplied(String jobId) => _appliedJobIds.contains(jobId);
  int get appliedCount => _appliedJobIds.length;
  int get favoriteCount => _favoriteJobIds.length;

  @override
  Future<ApiResponse<List<Company>>> getTopCompanies() async {
    await _delayCall();
    return ApiResponse.success(_mockCompanies);
  }

  @override
  Future<ApiResponse<List<Job>>> getRecommendedJobs() async {
    await _delayCall();
    return ApiResponse.success(_mockJobs.take(4).toList());
  }
}
