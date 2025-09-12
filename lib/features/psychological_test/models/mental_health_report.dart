class MentalHealthReport {
  final BasicInformation basicInformation;
  final OverallAssessment overallAssessment;
  final DimensionalAnalysis dimensionalAnalysis;
  final PersonalizedInsights personalizedInsights;
  final ProfessionalRecommendations professionalRecommendations;
  final ActionPlan actionPlan;
  final String? additionalNotes;

  MentalHealthReport({
    required this.basicInformation,
    required this.overallAssessment,
    required this.dimensionalAnalysis,
    required this.personalizedInsights,
    required this.professionalRecommendations,
    required this.actionPlan,
    this.additionalNotes,
  });

  factory MentalHealthReport.fromJson(Map<String, dynamic> json) {
    return MentalHealthReport(
      basicInformation: BasicInformation.fromJson(json['basicInformation']),
      overallAssessment: OverallAssessment.fromJson(json['overallAssessment']),
      dimensionalAnalysis: DimensionalAnalysis.fromJson(json['dimensionalAnalysis']),
      personalizedInsights: PersonalizedInsights.fromJson(json['personalizedInsights']),
      professionalRecommendations: ProfessionalRecommendations.fromJson(json['professionalRecommendations']),
      actionPlan: ActionPlan.fromJson(json['actionPlan']),
      additionalNotes: json['additionalNotes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'basicInformation': basicInformation.toJson(),
      'overallAssessment': overallAssessment.toJson(),
      'dimensionalAnalysis': dimensionalAnalysis.toJson(),
      'personalizedInsights': personalizedInsights.toJson(),
      'professionalRecommendations': professionalRecommendations.toJson(),
      'actionPlan': actionPlan.toJson(),
      'additionalNotes': additionalNotes,
    };
  }
}

class BasicInformation {
  final int age;
  final String gender;
  final String educationLevel;
  final String maritalStatus;
  final String livingSituation;
  final String occupation;
  final String assessmentDate;

  BasicInformation({
    required this.age,
    required this.gender,
    required this.educationLevel,
    required this.maritalStatus,
    required this.livingSituation,
    required this.occupation,
    required this.assessmentDate,
  });

  factory BasicInformation.fromJson(Map<String, dynamic> json) {
    return BasicInformation(
      age: json['age'],
      gender: json['gender'],
      educationLevel: json['educationLevel'],
      maritalStatus: json['maritalStatus'],
      livingSituation: json['livingSituation'],
      occupation: json['occupation'],
      assessmentDate: json['assessmentDate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'age': age,
      'gender': gender,
      'educationLevel': educationLevel,
      'maritalStatus': maritalStatus,
      'livingSituation': livingSituation,
      'occupation': occupation,
      'assessmentDate': assessmentDate,
    };
  }
}

class OverallAssessment {
  final int totalScore;
  final String riskLevel;
  final String mainCharacteristics;

  OverallAssessment({
    required this.totalScore,
    required this.riskLevel,
    required this.mainCharacteristics,
  });

  factory OverallAssessment.fromJson(Map<String, dynamic> json) {
    return OverallAssessment(
      totalScore: json['totalScore'],
      riskLevel: json['riskLevel'],
      mainCharacteristics: json['mainCharacteristics'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalScore': totalScore,
      'riskLevel': riskLevel,
      'mainCharacteristics': mainCharacteristics,
    };
  }
}

class DimensionalAnalysis {
  final DimensionScore emotionalState;
  final DimensionScore stressLevel;
  final DimensionScore interpersonalRelationships;
  final DimensionScore selfAwareness;
  final DimensionScore copingStrategies;

  DimensionalAnalysis({
    required this.emotionalState,
    required this.stressLevel,
    required this.interpersonalRelationships,
    required this.selfAwareness,
    required this.copingStrategies,
  });

  factory DimensionalAnalysis.fromJson(Map<String, dynamic> json) {
    return DimensionalAnalysis(
      emotionalState: DimensionScore.fromJson(json['emotionalState']),
      stressLevel: DimensionScore.fromJson(json['stressLevel']),
      interpersonalRelationships: DimensionScore.fromJson(json['interpersonalRelationships']),
      selfAwareness: DimensionScore.fromJson(json['selfAwareness']),
      copingStrategies: DimensionScore.fromJson(json['copingStrategies']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'emotionalState': emotionalState.toJson(),
      'stressLevel': stressLevel.toJson(),
      'interpersonalRelationships': interpersonalRelationships.toJson(),
      'selfAwareness': selfAwareness.toJson(),
      'copingStrategies': copingStrategies.toJson(),
    };
  }
}

class DimensionScore {
  final int score;
  final String analysis;

  DimensionScore({
    required this.score,
    required this.analysis,
  });

  factory DimensionScore.fromJson(Map<String, dynamic> json) {
    return DimensionScore(
      score: json['score'],
      analysis: json['analysis'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'analysis': analysis,
    };
  }
}

class PersonalizedInsights {
  final String backgroundAnalysis;
  final List<String> potentialRisks;
  final List<String> strengthsAndResources;

  PersonalizedInsights({
    required this.backgroundAnalysis,
    required this.potentialRisks,
    required this.strengthsAndResources,
  });

  factory PersonalizedInsights.fromJson(Map<String, dynamic> json) {
    return PersonalizedInsights(
      backgroundAnalysis: json['backgroundAnalysis'],
      potentialRisks: List<String>.from(json['potentialRisks']),
      strengthsAndResources: List<String>.from(json['strengthsAndResources']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'backgroundAnalysis': backgroundAnalysis,
      'potentialRisks': potentialRisks,
      'strengthsAndResources': strengthsAndResources,
    };
  }
}

class ProfessionalRecommendations {
  final List<String> improvementSuggestions;
  final List<String> maintenanceMethods;
  final String professionalCounseling;

  ProfessionalRecommendations({
    required this.improvementSuggestions,
    required this.maintenanceMethods,
    required this.professionalCounseling,
  });

  factory ProfessionalRecommendations.fromJson(Map<String, dynamic> json) {
    return ProfessionalRecommendations(
      improvementSuggestions: List<String>.from(json['improvementSuggestions']),
      maintenanceMethods: List<String>.from(json['maintenanceMethods']),
      professionalCounseling: json['professionalCounseling'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'improvementSuggestions': improvementSuggestions,
      'maintenanceMethods': maintenanceMethods,
      'professionalCounseling': professionalCounseling,
    };
  }
}

class ActionPlan {
  final List<String> shortTermGoals;
  final List<String> mediumTermGoals;
  final List<String> longTermGoals;

  ActionPlan({
    required this.shortTermGoals,
    required this.mediumTermGoals,
    required this.longTermGoals,
  });

  factory ActionPlan.fromJson(Map<String, dynamic> json) {
    return ActionPlan(
      shortTermGoals: List<String>.from(json['shortTermGoals']),
      mediumTermGoals: List<String>.from(json['mediumTermGoals']),
      longTermGoals: List<String>.from(json['longTermGoals']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shortTermGoals': shortTermGoals,
      'mediumTermGoals': mediumTermGoals,
      'longTermGoals': longTermGoals,
    };
  }
}