import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppException implements Exception {
  const AppException(this.userMessage, [this.technicalMessage]);
  final String userMessage;
  final String? technicalMessage;
}

class MissingSessionException extends AppException {
  const MissingSessionException()
    : super('انتهت الجلسة. سجّلي الدخول مرة أخرى.');
}

class MissingChildException extends AppException {
  const MissingChildException() : super('اختاري طفلًا أولًا للمتابعة.');
}

class RequestTimeoutException extends AppException {
  const RequestTimeoutException()
    : super('استغرق الطلب وقتًا طويلًا. تحققي من اتصالك وحاولي مرة أخرى.');
}

class NoInternetException extends AppException {
  const NoInternetException()
    : super(
        'لا يوجد اتصال بالإنترنت. احتفظنا بالنص ويمكنكِ المحاولة مرة أخرى.',
      );
}

class InvalidSessionException extends AppException {
  const InvalidSessionException()
    : super('انتهت الجلسة. سجّلي الدخول مرة أخرى.');
}

class UnauthorizedChildException extends AppException {
  const UnauthorizedChildException()
    : super('ليس لديكِ صلاحية للوصول إلى بيانات هذا الطفل.');
}

class RateLimitException extends AppException {
  const RateLimitException([String? message])
    : super(message ?? 'حاولي مرة أخرى بعد دقيقة.');
}

class InvalidAiResponseException extends AppException {
  const InvalidAiResponseException([String? message])
    : super(message ?? 'لم أتمكن من فهم الرد الآن. حاولي مرة أخرى.');
}

class AiUnavailableException extends AppException {
  const AiUnavailableException() : super('تعذر الحصول على رد من المساعد الآن.');
}

class EmergencyDetectedException extends AppException {
  const EmergencyDetectedException()
    : super(
        'هذه حالة طارئة. اتصلي بالطوارئ أو بالطبيب فورًا. لا تنتظري ردًا من المساعد.',
      );
}

class LocalValidationException extends AppException {
  const LocalValidationException([String? message])
    : super(message ?? 'لم أتمكن من فهم تسجيل كامل. يمكنكِ تعديله يدويًا.');
}

class OfflineCareEventQueuedException extends AppException {
  const OfflineCareEventQueuedException()
    : super('تم حفظ التسجيل مؤقتًا، وسيتم رفعه تلقائيًا عند عودة الاتصال.');
}

String readableError(Object error) {
  if (error is AppException) return error.userMessage;
  if (error is AuthException) return _authError(error.message);
  if (error is PostgrestException) {
    return 'تعذر تنفيذ الطلب الآن. حاولي مرة أخرى.';
  }
  final message = error.toString().toLowerCase();
  if (message.contains('timeout') || message.contains('timed out')) {
    return const RequestTimeoutException().userMessage;
  }
  if (message.contains('socket') ||
      message.contains('network') ||
      message.contains('failed host lookup')) {
    return 'تعذر الاتصال بالخادم. تحققي من الإنترنت.';
  }
  return 'حدث خطأ غير متوقع. حاولي مرة أخرى.';
}

String _authError(String message) {
  final normalized = message.toLowerCase();
  if (normalized.contains('invalid login credentials')) {
    return 'البريد الإلكتروني أو كلمة المرور غير صحيحة.';
  }
  if (normalized.contains('email not confirmed')) {
    return 'يرجى تأكيد البريد الإلكتروني قبل تسجيل الدخول.';
  }
  if (normalized.contains('already registered')) {
    return 'هذا البريد الإلكتروني مسجل بالفعل.';
  }
  if (normalized.contains('password')) {
    return 'تحققي من كلمة المرور. يجب أن تكون 6 أحرف على الأقل.';
  }
  return 'تعذر إتمام عملية الحساب. حاولي مرة أخرى.';
}

void logError(Object error, StackTrace stackTrace) {
  if (!kDebugMode) return;
  debugPrint('Error type: ${error.runtimeType}');
  if (error is AuthException) {
    debugPrint('Auth message: ${error.message}');
    debugPrint('Auth statusCode: ${error.statusCode}');
  } else if (error is PostgrestException) {
    debugPrint('Postgrest code: ${error.code}');
    debugPrint('Postgrest message: ${error.message}');
    debugPrint('Postgrest details: ${error.details}');
    debugPrint('Postgrest hint: ${error.hint}');
  } else {
    debugPrint('Error message: $error');
  }
  debugPrintStack(stackTrace: stackTrace);
}
