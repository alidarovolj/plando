import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plando/core/api/api_client.dart'; // Импорт ApiClient
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Провайдер для отправки запроса
final requestCodeProvider =
    Provider<RequestCodeService>((ref) => RequestCodeService(ApiClient().dio));

class RequestCodeService {
  final Dio _dio;
  final _storage = const FlutterSecureStorage();

  RequestCodeService(Dio dio) : _dio = dio;

  Future<Response?> userProfile(String phoneNumber) async {
    try {
      final response = await _dio.get('/auth/me');
      return response;
    } catch (e) {
      print('Ошибка при запросе кода: $e');
      return null;
    }
  }

  Future<Response?> sendCodeRequest(String phoneNumber) async {
    try {
      final response = await _dio.post(
        '/login/send-message',
        queryParameters: {'phone': phoneNumber}, // Параметры запроса
      );
      return response;
    } catch (e) {
      print('Ошибка при запросе кода: $e');
      return null;
    }
  }

  Future<Response?> signUp(
      String phone, String firstName, String lastName, String birthDate) async {
    try {
      final response = await _dio.post(
        '/sign-up',
        data: {
          'phone': phone,
          'first_name': firstName,
          'last_name': lastName,
          'birth_date': birthDate,
        },
      );
      return response;
    } catch (e) {
      print('Ошибка при запросе кода: $e');
      return null;
    }
  }

  Future<Response?> sendOTP(String phoneNumber, String code) async {
    try {
      print('Отправка OTP запроса: телефон=$phoneNumber, код=$code');

      final response = await _dio.post(
        '/login',
        data: {
          'phone': phoneNumber,
          'code': code,
        },
        options: Options(
          validateStatus: (status) => true,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          receiveTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 15),
        ),
      );

      print('Ответ от сервера (полный): ${response.toString()}');
      print('Данные ответа: ${response.data}');
      print('Тип данных ответа: ${response.data.runtimeType}');
      if (response.data is Map) {
        print('Токен в ответе: ${response.data['access_token']}');
      }
      print('Статус код: ${response.statusCode}');

      return response;
    } on DioException catch (e) {
      print('DioError при отправке OTP: ${e.message}');
      print('Тип ошибки: ${e.type}');
      print('Ответ: ${e.response}');
      return e.response;
    } catch (e) {
      print('Общая ошибка при отправке OTP: $e');
      return null;
    }
  }

  Future<bool> checkEmailExists(String email) async {
    try {
      print('Checking if email exists: $email');
      final response = await _dio.get(
        '/v1/users/existing',
        queryParameters: {'email': email},
      );

      print('Email check response: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        return data['isExisting'] == true;
      }

      return false;
    } on DioException catch (e) {
      print(
          'DioException in checkEmailExists: ${e.response?.statusCode} - ${e.response?.data}');

      // If the status code is 404, it means the email doesn't exist
      if (e.response?.statusCode == 404) {
        throw EmailNotFoundException('Email not found');
      }

      // For other errors, rethrow
      rethrow;
    } catch (e) {
      print('Error in checkEmailExists: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> checkUsernameExists(String username) async {
    try {
      final response = await _dio.get(
        '/v1/users/existing',
        queryParameters: {'username': username},
      );

      print('Check username response: ${response.data}');
      print('Check username status code: ${response.statusCode}');

      // If the response is successful and contains data
      if (response.statusCode == 200 && response.data != null) {
        // The API should return whether the username exists or not
        return {
          'exists': response.data['isExisting'] ?? false,
          'success': true,
          'message': response.data['message'] ?? 'Username check completed'
        };
      }
      return {
        'exists': false,
        'success': true,
        'message': 'Username is available'
      };
    } on DioException catch (e) {
      print('Error checking username existence: ${e.message}');
      print('Error response: ${e.response?.data}');
      print('Error status code: ${e.response?.statusCode}');

      // Extract error message from response if available
      String errorMessage = 'Failed to check username';
      if (e.response?.statusCode != null && e.response?.data != null) {
        if (e.response!.data is Map) {
          errorMessage = e.response!.data['message'] ?? errorMessage;
        } else if (e.response!.data is String) {
          errorMessage = e.response!.data;
        }
      }

      return {'exists': false, 'success': false, 'message': errorMessage};
    } catch (e) {
      print('General error checking username: $e');
      return {
        'exists': false,
        'success': false,
        'message': 'An unexpected error occurred'
      };
    }
  }

  Future<Map<String, dynamic>> sendRegistrationOtp(String email) async {
    try {
      final response = await _dio.post(
        '/v1/otp/send',
        data: {"email": email, "type": "REGISTRATION"},
      );

      print('Send OTP response: ${response.data}');
      print('Send OTP status code: ${response.statusCode}');

      // If the response is successful
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Check if the response data indicates success
        if (response.data != null && response.data is Map) {
          // The API might return a success field or similar
          return {
            'success': response.data['success'] ?? true,
            'message': response.data['message'] ??
                'Verification code sent successfully'
          };
        }
        return {
          'success': true,
          'message': 'Verification code sent successfully'
        };
      }
      return {'success': false, 'message': 'Failed to send verification code'};
    } on DioException catch (e) {
      print('Error sending registration OTP: ${e.message}');
      print('Error response: ${e.response?.data}');
      print('Error status code: ${e.response?.statusCode}');

      // Extract error message from response if available
      String errorMessage = 'Failed to send verification code';
      bool userExists = false;

      if (e.response?.statusCode == 400 && e.response?.data != null) {
        if (e.response!.data is Map) {
          errorMessage = e.response!.data['message'] ?? errorMessage;
          // Check if the error message indicates that the user already exists
          if (errorMessage.contains('user already exists')) {
            userExists = true;
          }
        } else if (e.response!.data is String) {
          errorMessage = e.response!.data;
          // Check if the error message indicates that the user already exists
          if (errorMessage.contains('user already exists')) {
            userExists = true;
          }
        }
      }

      return {
        'success': false,
        'message': errorMessage,
        'userExists': userExists
      };
    } catch (e) {
      print('General error sending registration OTP: $e');
      return {'success': false, 'message': 'An unexpected error occurred'};
    }
  }

  Future<Map<String, dynamic>> verifyOtpCode(String email, String code,
      {String type = "REGISTRATION"}) async {
    try {
      // Print the request payload for debugging
      print('OTP validation request payload:');
      print({"email": email, "code": code, "type": type});

      final response = await _dio.post(
        '/v1/otp/validate',
        data: {"email": email, "code": code, "type": type},
      );

      print('OTP validation response: ${response.data}');
      print('OTP validation status code: ${response.statusCode}');

      // If the response is successful
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Check if the response data indicates success
        // Adjust this based on the actual API response structure
        if (response.data != null && response.data is Map) {
          // The API might return a success field or similar
          return {
            'success': response.data['success'] ?? true,
            'message': response.data['message'] ?? 'Code verified successfully'
          };
        }
        return {'success': true, 'message': 'Code verified successfully'};
      }
      return {'success': false, 'message': 'Invalid verification code'};
    } on DioException catch (e) {
      print('Error verifying OTP code: ${e.message}');
      print('Error response: ${e.response?.data}');
      print('Error status code: ${e.response?.statusCode}');

      // Extract error message from response if available
      String errorMessage = 'Invalid verification code';
      if (e.response?.statusCode == 400 && e.response?.data != null) {
        if (e.response!.data is Map) {
          errorMessage = e.response!.data['message'] ?? errorMessage;
        } else if (e.response!.data is String) {
          errorMessage = e.response!.data;
        }
      }

      return {'success': false, 'message': errorMessage};
    } catch (e) {
      print('General error verifying OTP code: $e');
      return {'success': false, 'message': 'An unexpected error occurred'};
    }
  }

  Future<Map<String, dynamic>> registerUser(
      String email, String password, String username, String otpCode) async {
    try {
      // Create the request payload
      final Map<String, dynamic> payload = {
        "email": email,
        "password": password,
        "username": username,
        "otpCode": otpCode
      };

      // Print the request payload for debugging
      print('Registration request payload:');
      print(payload);

      final response = await _dio.post(
        '/v1/users/sign-up/regular',
        data: payload,
      );

      print('User registration response: ${response.data}');
      print('User registration status code: ${response.statusCode}');

      // Log specific fields for debugging
      if (response.data != null && response.data is Map) {
        print('Access Token: ${response.data['accessToken']}');
        print('Refresh Token: ${response.data['refreshToken']}');
        print('Token Expiry: ${response.data['expiredAt']}');
      }

      // If the response is successful
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Check if the response data indicates success
        if (response.data != null && response.data is Map) {
          // Save authentication tokens
          await saveAuthTokens(response.data, email: email, username: username);

          // Return success response
          return {
            'success': true,
            'message': 'Registration successful',
            'data': response.data
          };
        }
        return {'success': true, 'message': 'Registration successful'};
      }
      return {'success': false, 'message': 'Registration failed'};
    } on DioException catch (e) {
      print('Error registering user: ${e.message}');
      print('Error response: ${e.response?.data}');
      print('Error status code: ${e.response?.statusCode}');

      // Extract error message from response if available
      String errorMessage = 'Registration failed';
      if (e.response?.statusCode != null && e.response?.data != null) {
        if (e.response!.data is Map) {
          errorMessage = e.response!.data['message'] ?? errorMessage;
        } else if (e.response!.data is String) {
          errorMessage = e.response!.data;
        }
      }

      return {'success': false, 'message': errorMessage};
    } catch (e) {
      print('General error registering user: $e');
      return {'success': false, 'message': 'An unexpected error occurred'};
    }
  }

  // Helper method to save authentication tokens
  Future<void> saveAuthTokens(Map<String, dynamic> userData,
      {String? email, String? username}) async {
    // Save access token if available
    if (userData['accessToken'] != null) {
      await _storage.write(
          key: 'access_token', value: userData['accessToken'].toString());
    }

    // Save refresh token if available
    if (userData['refreshToken'] != null) {
      await _storage.write(
          key: 'refresh_token', value: userData['refreshToken'].toString());
    }

    // Save token expiration date if available
    if (userData['expiredAt'] != null) {
      await _storage.write(
          key: 'token_expiry', value: userData['expiredAt'].toString());
    }

    // Save user email if provided
    if (email != null) {
      await _storage.write(key: 'user_email', value: email);
    }

    // Save username if provided
    if (username != null) {
      await _storage.write(key: 'username', value: username);
    }

    // Mark user as authenticated
    await _storage.write(key: 'is_authenticated', value: 'true');
  }

  // Get the access token from secure storage
  Future<String?> getAccessToken() async {
    return await _storage.read(key: 'access_token');
  }

  // Get the refresh token from secure storage
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: 'refresh_token');
  }

  // Check if the user is authenticated
  Future<bool> isAuthenticated() async {
    final value = await _storage.read(key: 'is_authenticated');
    return value == 'true';
  }

  // Login with email and password
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      print('Login request payload:');
      print({"email": email, "password": password});

      final response = await _dio.post(
        '/v1/users/sign-in/regular',
        data: {"email": email, "password": password},
      );

      print('Login response: ${response.data}');
      print('Login status code: ${response.statusCode}');

      // Log specific fields for debugging
      if (response.data != null && response.data is Map) {
        print('Access Token: ${response.data['accessToken']}');
        print('Refresh Token: ${response.data['refreshToken']}');
        print('Token Expiry: ${response.data['expiredAt']}');
      }

      // If the response is successful
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Check if the response data indicates success
        if (response.data != null && response.data is Map) {
          // Save authentication tokens
          await saveAuthTokens(response.data, email: email);

          // Return success response
          return {
            'success': true,
            'message': 'Login successful',
            'data': response.data
          };
        }
        return {'success': true, 'message': 'Login successful'};
      }
      return {'success': false, 'message': 'Login failed'};
    } on DioException catch (e) {
      print('Error logging in: ${e.message}');
      print('Error response: ${e.response?.data}');
      print('Error status code: ${e.response?.statusCode}');

      // Extract error message from response if available
      String errorMessage = 'Login failed';
      if (e.response?.statusCode != null && e.response?.data != null) {
        if (e.response!.data is Map) {
          errorMessage = e.response!.data['message'] ?? errorMessage;
        } else if (e.response!.data is String) {
          errorMessage = e.response!.data;
        }
      }

      return {
        'success': false,
        'message': errorMessage,
        'error_code': e.response?.statusCode,
        'error_type': 'auth_error'
      };
    } catch (e) {
      print('General error logging in: $e');
      return {'success': false, 'message': 'An unexpected error occurred'};
    }
  }

  // Google Sign-In for existing users
  Future<Map<String, dynamic>> signInWithGoogle(String token) async {
    try {
      print('Sending Google sign-in request with token: $token');

      final response = await _dio.post(
        '/v1/users/sign-in/google',
        data: {"token": token},
      );

      print('Google sign-in response: ${response.data}');
      print('Google sign-in status code: ${response.statusCode}');

      // Log specific fields for debugging
      if (response.data != null && response.data is Map) {
        print('Access Token: ${response.data['accessToken']}');
        print('Refresh Token: ${response.data['refreshToken']}');
        print('Token Expiry: ${response.data['expiredAt']}');
      }

      // If the response is successful
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Check if the response data indicates success
        if (response.data != null && response.data is Map) {
          // Extract email from response if available
          String? email = response.data['email'];

          // Save authentication tokens
          await saveAuthTokens(response.data, email: email);

          // Return success response
          return {
            'success': true,
            'message': 'Google sign-in successful',
            'data': response.data
          };
        }
        return {'success': true, 'message': 'Google sign-in successful'};
      }
      return {'success': false, 'message': 'Google sign-in failed'};
    } on DioException catch (e) {
      print('Error with Google sign-in: ${e.message}');
      print('Error response: ${e.response?.data}');
      print('Error status code: ${e.response?.statusCode}');

      // Extract error message from response if available
      String errorMessage = 'Google sign-in failed';
      if (e.response?.statusCode != null && e.response?.data != null) {
        if (e.response!.data is Map) {
          errorMessage = e.response!.data['message'] ?? errorMessage;
        } else if (e.response!.data is String) {
          errorMessage = e.response!.data;
        }
      }

      return {'success': false, 'message': errorMessage};
    } catch (e) {
      print('General error with Google sign-in: $e');
      return {'success': false, 'message': 'An unexpected error occurred'};
    }
  }

  // Google Sign-Up for new users
  Future<Map<String, dynamic>> signUpWithGoogle(
      String token, String username, String email) async {
    try {
      print('Sending Google sign-up request:');
      print('Token: $token');
      print('Username: $username');
      print('Email: $email');

      final response = await _dio.post(
        '/v1/users/sign-up/google',
        data: {"token": token, "username": username, "email": email},
      );

      print('Google sign-up response: ${response.data}');
      print('Google sign-up status code: ${response.statusCode}');

      // Log specific fields for debugging
      if (response.data != null && response.data is Map) {
        print('Access Token: ${response.data['accessToken']}');
        print('Refresh Token: ${response.data['refreshToken']}');
        print('Token Expiry: ${response.data['expiredAt']}');
      }

      // If the response is successful
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Check if the response data indicates success
        if (response.data != null && response.data is Map) {
          // Save authentication tokens
          await saveAuthTokens(response.data, email: email, username: username);

          // Return success response
          return {
            'success': true,
            'message': 'Google sign-up successful',
            'data': response.data
          };
        }
        return {'success': true, 'message': 'Google sign-up successful'};
      }
      return {'success': false, 'message': 'Google sign-up failed'};
    } on DioException catch (e) {
      print('Error with Google sign-up: ${e.message}');
      print('Error response: ${e.response?.data}');
      print('Error status code: ${e.response?.statusCode}');

      // Extract error message from response if available
      String errorMessage = 'Google sign-up failed';
      if (e.response?.statusCode != null && e.response?.data != null) {
        if (e.response!.data is Map) {
          errorMessage = e.response!.data['message'] ?? errorMessage;
        } else if (e.response!.data is String) {
          errorMessage = e.response!.data;
        }
      }

      return {'success': false, 'message': errorMessage};
    } catch (e) {
      print('General error with Google sign-up: $e');
      return {'success': false, 'message': 'An unexpected error occurred'};
    }
  }

  // Send password reset OTP
  Future<Map<String, dynamic>> sendPasswordResetOtp(String email) async {
    try {
      final response = await _dio.post(
        '/v1/otp/send',
        data: {"email": email, "type": "FORGOT_PASSWORD"},
      );

      print('Send password reset OTP response: ${response.data}');
      print('Send password reset OTP status code: ${response.statusCode}');

      // If the response is successful
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Check if the response data indicates success
        if (response.data != null && response.data is Map) {
          // The API might return a success field or similar
          return {
            'success': response.data['success'] ?? true,
            'message': response.data['message'] ??
                'Password reset code sent successfully'
          };
        }
        return {
          'success': true,
          'message': 'Password reset code sent successfully'
        };
      }
      return {
        'success': false,
        'message': 'Failed to send password reset code'
      };
    } on DioException catch (e) {
      print('Error sending password reset OTP: ${e.message}');
      print('Error response: ${e.response?.data}');
      print('Error status code: ${e.response?.statusCode}');

      // Extract error message from response if available
      String errorMessage = 'Failed to send password reset code';
      if (e.response?.statusCode != null && e.response?.data != null) {
        if (e.response!.data is Map) {
          errorMessage = e.response!.data['message'] ?? errorMessage;
        } else if (e.response!.data is String) {
          errorMessage = e.response!.data;
        }
      }

      return {'success': false, 'message': errorMessage};
    } catch (e) {
      print('General error sending password reset OTP: $e');
      return {'success': false, 'message': 'An unexpected error occurred'};
    }
  }

  // Reset password with OTP
  Future<Map<String, dynamic>> resetPassword(
      String email, String password, String otpCode) async {
    try {
      // Create the request payload
      final Map<String, dynamic> payload = {
        "email": email,
        "password": password,
        "otpCode": otpCode
      };

      // Print the request payload for debugging
      print('Password reset request payload:');
      print(payload);

      final response = await _dio.post(
        '/v1/users/forgot',
        data: payload,
      );

      print('Password reset response: ${response.data}');
      print('Password reset status code: ${response.statusCode}');

      // If the response is successful
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Check if the response data indicates success
        if (response.data != null && response.data is Map) {
          // Save authentication tokens
          await saveAuthTokens(response.data, email: email);

          // Print confirmation of saved tokens
          print('Authentication tokens saved after password reset');

          // Return success response
          return {
            'success': true,
            'message': 'Password reset successful',
            'data': response.data
          };
        }
        return {'success': true, 'message': 'Password reset successful'};
      }
      return {'success': false, 'message': 'Password reset failed'};
    } on DioException catch (e) {
      print('Error resetting password: ${e.message}');
      print('Error response: ${e.response?.data}');
      print('Error status code: ${e.response?.statusCode}');

      // Extract error message from response if available
      String errorMessage = 'Password reset failed';
      if (e.response?.statusCode != null && e.response?.data != null) {
        if (e.response!.data is Map) {
          errorMessage = e.response!.data['message'] ?? errorMessage;
        } else if (e.response!.data is String) {
          errorMessage = e.response!.data;
        }
      }

      return {'success': false, 'message': errorMessage};
    } catch (e) {
      print('General error resetting password: $e');
      return {'success': false, 'message': 'An unexpected error occurred'};
    }
  }

  // Apple Sign-In for existing users
  Future<Map<String, dynamic>> signInWithApple(
      String identityToken, String authorizationCode) async {
    try {
      print('Sending Apple sign-in request:');
      print('Identity Token: $identityToken');
      print('Authorization Code: $authorizationCode');

      final response = await _dio.post(
        '/v1/users/sign-in/google',
        data: {
          "token": identityToken,
        },
      );

      print('Apple sign-in response: ${response.data}');
      print('Apple sign-in status code: ${response.statusCode}');

      // Log specific fields for debugging
      if (response.data != null && response.data is Map) {
        print('Access Token: ${response.data['accessToken']}');
        print('Refresh Token: ${response.data['refreshToken']}');
        print('Token Expiry: ${response.data['expiredAt']}');
      }

      // If the response is successful
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Check if the response data indicates success
        if (response.data != null && response.data is Map) {
          // Extract email from response if available
          String? email = response.data['email'];

          // Save authentication tokens
          await saveAuthTokens(response.data, email: email);

          // Return success response
          return {
            'success': true,
            'message': 'Apple sign-in successful',
            'data': response.data
          };
        }
        return {'success': true, 'message': 'Apple sign-in successful'};
      }
      return {'success': false, 'message': 'Apple sign-in failed'};
    } on DioException catch (e) {
      print('Error with Apple sign-in: ${e.message}');
      print('Error response: ${e.response?.data}');
      print('Error status code: ${e.response?.statusCode}');

      // Extract error message from response if available
      String errorMessage = 'Apple sign-in failed';
      if (e.response?.statusCode != null && e.response?.data != null) {
        if (e.response!.data is Map) {
          errorMessage = e.response!.data['message'] ?? errorMessage;
        } else if (e.response!.data is String) {
          errorMessage = e.response!.data;
        }
      }

      return {'success': false, 'message': errorMessage};
    } catch (e) {
      print('General error with Apple sign-in: $e');
      return {'success': false, 'message': 'An unexpected error occurred'};
    }
  }

  // Apple Sign-Up for new users
  Future<Map<String, dynamic>> signUpWithApple(String identityToken,
      String authorizationCode, String username, String email) async {
    try {
      print('Sending Apple sign-up request:');
      print('Identity Token: $identityToken');
      print('Authorization Code: $authorizationCode');
      print('Username: $username');
      print('Email: $email');

      final response = await _dio.post(
        '/v1/users/sign-up/google',
        data: {"token": identityToken, "username": username, "email": email},
      );

      print('Apple sign-up response: ${response.data}');
      print('Apple sign-up status code: ${response.statusCode}');

      // Log specific fields for debugging
      if (response.data != null && response.data is Map) {
        print('Access Token: ${response.data['accessToken']}');
        print('Refresh Token: ${response.data['refreshToken']}');
        print('Token Expiry: ${response.data['expiredAt']}');
      }

      // If the response is successful
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Check if the response data indicates success
        if (response.data != null && response.data is Map) {
          // Save authentication tokens
          await saveAuthTokens(response.data, email: email, username: username);

          // Return success response
          return {
            'success': true,
            'message': 'Apple sign-up successful',
            'data': response.data
          };
        }
        return {'success': true, 'message': 'Apple sign-up successful'};
      }
      return {'success': false, 'message': 'Apple sign-up failed'};
    } on DioException catch (e) {
      print('Error with Apple sign-up: ${e.message}');
      print('Error response: ${e.response?.data}');
      print('Error status code: ${e.response?.statusCode}');

      // Extract error message from response if available
      String errorMessage = 'Apple sign-up failed';
      if (e.response?.statusCode != null && e.response?.data != null) {
        if (e.response!.data is Map) {
          errorMessage = e.response!.data['message'] ?? errorMessage;
        } else if (e.response!.data is String) {
          errorMessage = e.response!.data;
        }
      }

      return {'success': false, 'message': errorMessage};
    } catch (e) {
      print('General error with Apple sign-up: $e');
      return {'success': false, 'message': 'An unexpected error occurred'};
    }
  }
}

// Custom exception for email not found
class EmailNotFoundException implements Exception {
  final String message;
  EmailNotFoundException([this.message = 'Email not found']);

  @override
  String toString() => message;
}
