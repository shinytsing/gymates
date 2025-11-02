/// Generic API Response wrapper
/// Provides type-safe success and error handling
class ApiResult<T> {
  final T? data;
  final String? error;
  final int? statusCode;
  final bool isSuccess;

  ApiResult._({
    this.data,
    this.error,
    this.statusCode,
    required this.isSuccess,
  });

  /// Create a successful result
  factory ApiResult.success(T data) {
    return ApiResult._(
      data: data,
      isSuccess: true,
    );
  }

  /// Create an error result
  factory ApiResult.error(String message, {int? statusCode}) {
    return ApiResult._(
      error: message,
      statusCode: statusCode,
      isSuccess: false,
    );
  }

  /// Check if result is error
  bool get isError => !isSuccess;

  /// Get data or throw error
  T get dataOrThrow {
    if (isSuccess && data != null) {
      return data!;
    }
    throw Exception(error ?? 'Unknown error');
  }

  /// Get data or return default value
  T getOrElse(T defaultValue) {
    return data ?? defaultValue;
  }

  /// Transform data with a function
  ApiResult<R> map<R>(R Function(T) transform) {
    if (isSuccess && data != null) {
      try {
        return ApiResult.success(transform(data as T));
      } catch (e) {
        return ApiResult.error('Transform failed: ${e.toString()}');
      }
    }
    return ApiResult.error(error ?? 'No data to transform', statusCode: statusCode);
  }

  /// Handle result with callbacks
  R when<R>({
    required R Function(T data) success,
    required R Function(String error) failure,
  }) {
    if (isSuccess && data != null) {
      return success(data as T);
    }
    return failure(error ?? 'Unknown error');
  }
}

/// Pagination information
class PaginationInfo {
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final bool hasMore;

  PaginationInfo({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.hasMore,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      total: json['total'] ?? 0,
      totalPages: json['total_pages'] ?? 0,
      hasMore: json['has_more'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'limit': limit,
      'total': total,
      'total_pages': totalPages,
      'has_more': hasMore,
    };
  }
}

/// Paginated response wrapper
class PaginatedResponse<T> {
  final List<T> items;
  final PaginationInfo pagination;

  PaginatedResponse({
    required this.items,
    required this.pagination,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) itemFromJson,
  ) {
    final itemsJson = json['items'] as List? ?? json['data'] as List? ?? [];
    final items = itemsJson
        .map((item) => itemFromJson(item as Map<String, dynamic>))
        .toList();

    final pagination = PaginationInfo.fromJson(json['pagination'] ?? {});

    return PaginatedResponse(
      items: items,
      pagination: pagination,
    );
  }

  bool get hasMore => pagination.hasMore;
  int get currentPage => pagination.page;
  int get totalItems => pagination.total;
}

