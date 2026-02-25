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
      articles: json['articles'] as String? ?? 'N/A',
      risques: json['risques'] as String? ?? 'N/A',
      conseils: json['conseils'] as String? ?? 'N/A',
    );
  }
}
