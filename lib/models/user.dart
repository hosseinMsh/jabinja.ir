class User {
  final int id;
  final String name;
  final String email;
  final String? token;
  final String? phone;
  final String? avatarUrl;
  final String? resumeSlug;
  final int? resumeScore;
  final int? appliedJobsCount;
  final int? savedJobsCount;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.token,
    this.phone,
    this.avatarUrl,
    this.resumeSlug,
    this.resumeScore,
    this.appliedJobsCount,
    this.savedJobsCount,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      token: json['token'],
      phone: json['phone'],
      avatarUrl: json['avatar_url'],
      resumeSlug: json['resume_slug'],
      resumeScore: json['resume_score'],
      appliedJobsCount: json['applied_jobs_count'],
      savedJobsCount: json['saved_jobs_count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'token': token,
      'phone': phone,
      'avatar_url': avatarUrl,
      'resume_slug': resumeSlug,
      'resume_score': resumeScore,
      'applied_jobs_count': appliedJobsCount,
      'saved_jobs_count': savedJobsCount,
    };
  }
}
