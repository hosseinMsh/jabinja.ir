import 'company.dart';

class Job {
  final String id;
  final String shortId;
  final String title;
  final Company company;
  final String location;
  final String? contractType;
  final String? salaryDisplay;
  final String? experienceLevel;
  final String? publishedAt;
  final String? relativeTime;
  final bool isRemote;
  final bool isPremium;
  final String? category;
  final String? description;
  final List<String>? skills;
  final List<String>? benefits;
  final int? minSalary;
  final int? maxSalary;

  Job({
    required this.id,
    required this.shortId,
    required this.title,
    required this.company,
    required this.location,
    this.contractType,
    this.salaryDisplay,
    this.experienceLevel,
    this.publishedAt,
    this.relativeTime,
    this.isRemote = false,
    this.isPremium = false,
    this.category,
    this.description,
    this.skills,
    this.benefits,
    this.minSalary,
    this.maxSalary,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id']?.toString() ?? '',
      shortId: json['short_id'] ?? '',
      title: json['title'] ?? '',
      company: json['company'] != null
          ? Company.fromJson(json['company'])
          : Company(id: '', name: '', slug: ''),
      location: json['location'] is Map
          ? '${json['location']['province'] ?? ''} ${json['location']['city'] ?? ''}'.trim()
          : (json['location']?.toString() ?? ''),
      contractType: json['contract_type'],
      salaryDisplay: json['salary'] is Map ? json['salary']['display'] : json['salary_display'],
      experienceLevel: json['experience_level'],
      publishedAt: json['published_at'],
      relativeTime: json['relative_time'],
      isRemote: json['is_remote'] ?? false,
      isPremium: json['is_premium'] ?? false,
      category: json['category'],
      description: json['description'],
      skills: json['skills'] != null ? List<String>.from(json['skills']) : null,
      benefits: json['benefits'] != null ? List<String>.from(json['benefits']) : null,
      minSalary: json['min_salary'],
      maxSalary: json['max_salary'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'short_id': shortId,
      'title': title,
      'company': company.toJson(),
      'location': location,
      'contract_type': contractType,
      'salary_display': salaryDisplay,
      'experience_level': experienceLevel,
      'published_at': publishedAt,
      'relative_time': relativeTime,
      'is_remote': isRemote,
      'is_premium': isPremium,
      'category': category,
      'description': description,
      'skills': skills,
      'benefits': benefits,
      'min_salary': minSalary,
      'max_salary': maxSalary,
    };
  }
}
