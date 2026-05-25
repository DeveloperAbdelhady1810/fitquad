class InBodyModel {
  final String? id;
  final DateTime? recordedAt;

  // Body Composition
  final double? weight;
  final double? bmi;
  final double? bodyFatPct;
  final double? muscleMass;
  final double? fatMass;
  final double? fatFreeMass;

  // Body Water
  final double? totalBodyWater;
  final double? intracellularWater;
  final double? extracellularWater;

  // Nutrition
  final double? protein;
  final double? mineral;

  // Metabolic
  final double? bmr;
  final double? visceralFat;
  final double? bodyWaterPct;

  // Score & Goals
  final double? inbodyScore;
  final double? targetWeight;
  final String? notes;

  const InBodyModel({
    this.id,
    this.recordedAt,
    this.weight,
    this.bmi,
    this.bodyFatPct,
    this.muscleMass,
    this.fatMass,
    this.fatFreeMass,
    this.totalBodyWater,
    this.intracellularWater,
    this.extracellularWater,
    this.protein,
    this.mineral,
    this.bmr,
    this.visceralFat,
    this.bodyWaterPct,
    this.inbodyScore,
    this.targetWeight,
    this.notes,
  });

  factory InBodyModel.fromJson(Map<String, dynamic> json) {
    return InBodyModel(
      id: json['id']?.toString(),
      recordedAt: json['recorded_at'] != null
          ? DateTime.tryParse(json['recorded_at'].toString())
          : null,
      weight: (json['weight'] as num?)?.toDouble(),
      bmi: (json['bmi'] as num?)?.toDouble(),
      bodyFatPct: (json['body_fat_pct'] as num?)?.toDouble(),
      muscleMass: (json['muscle_mass'] as num?)?.toDouble(),
      fatMass: (json['fat_mass'] as num?)?.toDouble(),
      fatFreeMass: (json['fat_free_mass'] as num?)?.toDouble(),
      totalBodyWater: (json['total_body_water'] as num?)?.toDouble(),
      intracellularWater: (json['intracellular_water'] as num?)?.toDouble(),
      extracellularWater: (json['extracellular_water'] as num?)?.toDouble(),
      protein: (json['protein'] as num?)?.toDouble(),
      mineral: (json['mineral'] as num?)?.toDouble(),
      bmr: (json['bmr'] as num?)?.toDouble(),
      visceralFat: (json['visceral_fat'] as num?)?.toDouble(),
      bodyWaterPct: (json['body_water_pct'] as num?)?.toDouble(),
      inbodyScore: (json['inbody_score'] as num?)?.toDouble(),
      targetWeight: (json['target_weight'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (recordedAt != null) 'recorded_at': recordedAt!.toIso8601String(),
      if (weight != null) 'weight': weight,
      if (bmi != null) 'bmi': bmi,
      if (bodyFatPct != null) 'body_fat_pct': bodyFatPct,
      if (muscleMass != null) 'muscle_mass': muscleMass,
      if (fatMass != null) 'fat_mass': fatMass,
      if (fatFreeMass != null) 'fat_free_mass': fatFreeMass,
      if (totalBodyWater != null) 'total_body_water': totalBodyWater,
      if (intracellularWater != null)
        'intracellular_water': intracellularWater,
      if (extracellularWater != null)
        'extracellular_water': extracellularWater,
      if (protein != null) 'protein': protein,
      if (mineral != null) 'mineral': mineral,
      if (bmr != null) 'bmr': bmr,
      if (visceralFat != null) 'visceral_fat': visceralFat,
      if (bodyWaterPct != null) 'body_water_pct': bodyWaterPct,
      if (inbodyScore != null) 'inbody_score': inbodyScore,
      if (targetWeight != null) 'target_weight': targetWeight,
      if (notes != null) 'notes': notes,
    };
  }

  InBodyModel copyWith({
    String? id,
    DateTime? recordedAt,
    double? weight,
    double? bmi,
    double? bodyFatPct,
    double? muscleMass,
    double? fatMass,
    double? fatFreeMass,
    double? totalBodyWater,
    double? intracellularWater,
    double? extracellularWater,
    double? protein,
    double? mineral,
    double? bmr,
    double? visceralFat,
    double? bodyWaterPct,
    double? inbodyScore,
    double? targetWeight,
    String? notes,
  }) {
    return InBodyModel(
      id: id ?? this.id,
      recordedAt: recordedAt ?? this.recordedAt,
      weight: weight ?? this.weight,
      bmi: bmi ?? this.bmi,
      bodyFatPct: bodyFatPct ?? this.bodyFatPct,
      muscleMass: muscleMass ?? this.muscleMass,
      fatMass: fatMass ?? this.fatMass,
      fatFreeMass: fatFreeMass ?? this.fatFreeMass,
      totalBodyWater: totalBodyWater ?? this.totalBodyWater,
      intracellularWater: intracellularWater ?? this.intracellularWater,
      extracellularWater: extracellularWater ?? this.extracellularWater,
      protein: protein ?? this.protein,
      mineral: mineral ?? this.mineral,
      bmr: bmr ?? this.bmr,
      visceralFat: visceralFat ?? this.visceralFat,
      bodyWaterPct: bodyWaterPct ?? this.bodyWaterPct,
      inbodyScore: inbodyScore ?? this.inbodyScore,
      targetWeight: targetWeight ?? this.targetWeight,
      notes: notes ?? this.notes,
    );
  }
}
