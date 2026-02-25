class ApiResponse {
  final String qualification;
  final String articles;
  final String risques;
  final String conseils;

  ApiResponse({
    required this.qualification,
    required this.articles,
    required this.risques,
    required this.conseils,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      qualification: json['qualification'] as String? ?? 'N/A',

      // On transforme la liste en texte lisible
      articles: (json['applicable_articles'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .join('\n\n') ??
          'N/A',

      risques: json['risks'] as String? ?? 'N/A',

      conseils: json['advice'] as String? ?? 'N/A',
    );
  }
}