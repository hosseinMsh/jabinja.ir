class JobFilter {
  final String? keyword;
  final String? location;
  final String? category;
  final String? contractType;
  final String? sortBy;
  final bool? isRemote;
  final bool? hasMilitaryPlacement;
  final bool? hasLoan;
  final bool? hasProject;
  final bool? hasBonus;
  final bool? hasCommission;
  final bool? hasOvertime;
  final bool? hasAfternoonShift;
  final bool? hasPromotion;
  final bool? hasPartTime;
  final bool? hasFlexibleHours;
  final bool? hasSupplementaryInsurance;
  final bool? hasEsop;
  final bool? hasBusinessTrip;
  final bool? hasDisabilitySupport;
  final bool? hasUsd;
  final int? minSalary;
  final int? maxSalary;
  final int page;

  JobFilter({
    this.keyword,
    this.location,
    this.category,
    this.contractType,
    this.sortBy,
    this.isRemote,
    this.hasMilitaryPlacement,
    this.hasLoan,
    this.hasProject,
    this.hasBonus,
    this.hasCommission,
    this.hasOvertime,
    this.hasAfternoonShift,
    this.hasPromotion,
    this.hasPartTime,
    this.hasFlexibleHours,
    this.hasSupplementaryInsurance,
    this.hasEsop,
    this.hasBusinessTrip,
    this.hasDisabilitySupport,
    this.hasUsd,
    this.minSalary,
    this.maxSalary,
    this.page = 1,
  });

  JobFilter copyWith({int? page}) {
    return JobFilter(
      keyword: keyword,
      location: location,
      category: category,
      contractType: contractType,
      sortBy: sortBy,
      isRemote: isRemote,
      hasMilitaryPlacement: hasMilitaryPlacement,
      hasLoan: hasLoan,
      hasProject: hasProject,
      hasBonus: hasBonus,
      hasCommission: hasCommission,
      hasOvertime: hasOvertime,
      hasAfternoonShift: hasAfternoonShift,
      hasPromotion: hasPromotion,
      hasPartTime: hasPartTime,
      hasFlexibleHours: hasFlexibleHours,
      hasSupplementaryInsurance: hasSupplementaryInsurance,
      hasEsop: hasEsop,
      hasBusinessTrip: hasBusinessTrip,
      hasDisabilitySupport: hasDisabilitySupport,
      hasUsd: hasUsd,
      minSalary: minSalary,
      maxSalary: maxSalary,
      page: page ?? this.page,
    );
  }

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};
    if (keyword != null && keyword!.isNotEmpty) params['keyword'] = keyword;
    if (location != null && location!.isNotEmpty) params['location'] = location;
    if (category != null && category!.isNotEmpty) params['category'] = category;
    if (contractType != null && contractType!.isNotEmpty) params['contract_type'] = contractType;
    if (sortBy != null && sortBy!.isNotEmpty) params['sort_by'] = sortBy;
    if (isRemote == true) params['remote'] = 1;
    if (hasUsd == true) params['has_usd'] = 1;
    if (hasMilitaryPlacement == true) params['has_military_placement'] = 1;
    if (hasLoan == true) params['has_loan'] = 1;
    if (hasProject == true) params['has_project'] = 1;
    if (hasBonus == true) params['has_bonus'] = 1;
    if (hasCommission == true) params['has_commission'] = 1;
    if (hasOvertime == true) params['has_overtime'] = 1;
    if (hasAfternoonShift == true) params['has_afternoon_shift'] = 1;
    if (hasPromotion == true) params['has_promotion'] = 1;
    if (hasPartTime == true) params['has_part_time'] = 1;
    if (hasFlexibleHours == true) params['has_flexible_hours'] = 1;
    if (hasSupplementaryInsurance == true) params['has_supplementary_insurance'] = 1;
    if (hasEsop == true) params['has_esop'] = 1;
    if (hasBusinessTrip == true) params['has_business_trip'] = 1;
    if (hasDisabilitySupport == true) params['has_disability_support'] = 1;
    params['page'] = page;
    return params;
  }

  bool get hasActiveFilters =>
      keyword != null || location != null || category != null ||
      contractType != null || isRemote == true || hasUsd == true ||
      hasMilitaryPlacement == true || hasLoan == true ||
      hasProject == true || hasBonus == true || hasCommission == true ||
      hasOvertime == true || hasAfternoonShift == true ||
      hasPromotion == true || hasPartTime == true ||
      hasFlexibleHours == true || hasSupplementaryInsurance == true ||
      hasEsop == true || hasBusinessTrip == true ||
      hasDisabilitySupport == true;
}
