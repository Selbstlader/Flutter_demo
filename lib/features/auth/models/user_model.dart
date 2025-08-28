class User {
  final int id;
  final String username;
  final String? nickname;
  final DateTime? createTime;

  User({
    required this.id,
    required this.username,
    this.nickname,
    this.createTime,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      nickname: json['nickname'],
      createTime: json['createTime'] != null 
          ? DateTime.parse(json['createTime']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'nickname': nickname,
      'createTime': createTime?.toIso8601String(),
    };
  }
}

class LoginRequest {
  final String mobile;
  final String password;

  LoginRequest({
    required this.mobile,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'mobile': mobile,
      'password': password,
    };
  }
}

class RegisterRequest {
  final String username;
  final String password;
  final String confirmPassword;
  final String? nickname;

  RegisterRequest({
    required this.username,
    required this.password,
    required this.confirmPassword,
    this.nickname,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
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

  RegisterResponse({
    required this.id,
    this.username,
    this.nickname,
    this.createTime,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      id: json['id'],
      username: json['username'],
      nickname: json['nickname'],
      createTime: json['createTime'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['createTime'])
          : null,
    );
  }
}

class LoginResponse {
  final int userId;
  final String accessToken;
  final String refreshToken;
  final DateTime? expiresTime;
  final String? openid;

  LoginResponse({
    required this.userId,
    required this.accessToken,
    required this.refreshToken,
    this.expiresTime,
    this.openid,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      userId: json['userId'],
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
      expiresTime: json['expiresTime'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['expiresTime'])
          : null,
      openid: json['openid'],
    );
  }
}