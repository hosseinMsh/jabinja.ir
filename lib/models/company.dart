class Company {
  final String id;
  final String name;
  final String slug;
  final String? logoUrl;
  final String? coverUrl;
  final String? industry;
  final String? description;
  final String? website;
  final String? location;
  final int? employeeCount;
  final int? popularity;
  final int? jobVariety;
  final int? resumeReview;

  Company({
    required this.id,
    required this.name,
    required this.slug,
    this.logoUrl,
    this.coverUrl,
    this.industry,
    this.description,
    this.website,
    this.location,
    this.employeeCount,
    this.popularity,
    this.jobVariety,
    this.resumeReview,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      logoUrl: json['logo_url'],
      coverUrl: json['cover_url'],
      industry: json['industry'],
      description: json['description'],
      website: json['website'],
      location: json['location'],
      employeeCount: json['employee_count'],
      popularity: json['popularity'],
      jobVariety: json['job_variety'],
      resumeReview: json['resume_review'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'logo_url': logoUrl,
      'cover_url': coverUrl,
      'industry': industry,
      'description': description,
      'website': website,
      'location': location,
      'employee_count': employeeCount,
      'popularity': popularity,
      'job_variety': jobVariety,
      'resume_review': resumeReview,
    };
  }
}
