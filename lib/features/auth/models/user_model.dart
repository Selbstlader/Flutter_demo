class User {
  final int id;
  final String username;
  final String? nickname;
  final DateTime? createTime;
  final String? email;
  final String? supabaseId; // Supabase UUID

  User({
    required this.id,
    required this.username,
    this.nickname,
    this.createTime,
    this.email,
    this.supabaseId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] is String ? json['id'].hashCode : (json['id'] ?? 0),
      username: json['username'] ?? json['email'] ?? '',
      nickname: json['nickname'],
      email: json['email'],
      supabaseId: json['supabaseId'] ?? json['id']?.toString(),
      createTime: json['createTime'] != null 
          ? (json['createTime'] is String 
              ? DateTime.parse(json['createTime'])
              : DateTime.fromMillisecondsSinceEpoch(json['createTime']))
          : (json['createdAt'] != null 
              ? DateTime.parse(json['createdAt'])
              : (json['updatedAt'] != null 
                  ? DateTime.parse(json['updatedAt'])
                  : null)),
    );
  }

  // 从Supabase User创建
  factory User.fromSupabaseUser(dynamic supabaseUser) {
    return User(
      id: supabaseUser.id.hashCode,
      username: supabaseUser.email ?? '',
      email: supabaseUser.email,
      nickname: supabaseUser.userMetadata?['nickname'],
      supabaseId: supabaseUser.id,
      createTime: DateTime.parse(supabaseUser.createdAt),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'nickname': nickname,
      'email': email,
      'supabaseId': supabaseId,
      'createTime': createTime?.toIso8601String(),
    };
  }

  // 复制方法，用于更新用户信息
  User copyWith({
    int? id,
    String? username,
    String? nickname,
    String? email,
    String? supabaseId,
    DateTime? createTime,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      nickname: nickname ?? this.nickname,
      email: email ?? this.email,
      supabaseId: supabaseId ?? this.supabaseId,
      createTime: createTime ?? this.createTime,
    );
  }
}

class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

class RegisterRequest {
  final String email;
  final String password;
  final String confirmPassword;
  final String? nickname;

  RegisterRequest({
    required this.email,
    required this.password,
    required this.confirmPassword,
    this.nickname,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'confirmPassword': confirmPassword,
      if (nickname != null) 'nickname': nickname,
    };
  }
}

class RegisterResponse {
  final int id;
  final String? username;
  final String? nickname;
  final DateTime? createTime;
  final User? user; // 添加用户信息

  RegisterResponse({
    required this.id,
    this.username,
    this.nickname,
    this.createTime,
    this.user,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    // 适配新的响应格式：{"user": {...}}
    final userJson = json['user'] ?? json;
    return RegisterResponse(
      id: userJson['id'] ?? 0,
      username: userJson['username'],
      nickname: userJson['nickname'],
      createTime: userJson['createdAt'] != null 
          ? DateTime.parse(userJson['createdAt'])
          : null,
      user: userJson != null ? User.fromJson(userJson) : null,
    );
  }
}

class LoginResponse {
  final int userId;
  final String accessToken;
  final String? refreshToken;
  final DateTime? expiresTime;
  final String? openid;
  final User? user; // 添加用户信息

  LoginResponse({
    required this.userId,
    required this.accessToken,
    this.refreshToken,
    this.expiresTime,
    this.openid,
    this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    // 适配新的响应格式：{"user": {...}, "accessToken": "..."}
    final userJson = json['user'];
    return LoginResponse(
      userId: userJson?['id'] ?? 0,
      accessToken: json['accessToken'] ?? '',
      refreshToken: null, // 新格式中没有refreshToken
      expiresTime: null,
      openid: null,
      user: userJson != null ? User.fromJson(userJson) : null,
    );
  }
}