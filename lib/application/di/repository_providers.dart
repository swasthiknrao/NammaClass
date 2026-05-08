import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/dio_client.dart';
import '../../core/providers/secure_storage_provider.dart';
import '../../core/storage/app_database.dart';
import '../../data/repositories/attendance_repository_impl.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/fees_repository_impl.dart';
import '../../data/repositories/student_repository_impl.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/fees_repository.dart';
import '../../domain/repositories/student_repository.dart';
import '../../domain/usecases/attendance/mark_class_attendance_usecase.dart';
import '../../domain/usecases/auth/login_demo_usecase.dart';
import '../../domain/usecases/auth/logout_usecase.dart';
import '../../domain/usecases/auth/send_otp_usecase.dart';
import '../../domain/usecases/auth/verify_otp_usecase.dart';
import '../../domain/usecases/fees/get_fees_usecase.dart';
import '../../domain/usecases/student/get_students_page_usecase.dart';
import '../sync/sync_queue_service.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(
    dio: ref.watch(dioProvider),
    secureStorage: ref.watch(secureStorageProvider),
  ),
);

final attendanceRepositoryProvider = Provider<AttendanceRepository>(
  (ref) => AttendanceRepositoryImpl(
    db: ref.watch(appDatabaseProvider),
    dio: ref.watch(dioProvider),
  ),
);

final studentRepositoryProvider = Provider<StudentRepository>(
  (ref) => StudentRepositoryImpl(ref.watch(dioProvider)),
);

final feesRepositoryProvider = Provider<FeesRepository>(
  (ref) => FeesRepositoryImpl(ref.watch(dioProvider)),
);

final loginDemoUseCaseProvider = Provider<LoginDemoUseCase>(
  (ref) => LoginDemoUseCase(ref.watch(authRepositoryProvider)),
);

final logoutUseCaseProvider = Provider<LogoutUseCase>(
  (ref) => LogoutUseCase(ref.watch(authRepositoryProvider)),
);

final sendOtpUseCaseProvider = Provider<SendOtpUseCase>(
  (ref) => SendOtpUseCase(ref.watch(authRepositoryProvider)),
);

final verifyOtpUseCaseProvider = Provider<VerifyOtpUseCase>(
  (ref) => VerifyOtpUseCase(ref.watch(authRepositoryProvider)),
);

final getStudentsPageUseCaseProvider = Provider<GetStudentsPageUseCase>(
  (ref) => GetStudentsPageUseCase(ref.watch(studentRepositoryProvider)),
);

final markClassAttendanceUseCaseProvider = Provider<MarkClassAttendanceUseCase>(
  (ref) => MarkClassAttendanceUseCase(ref.watch(attendanceRepositoryProvider)),
);

final getFeesUseCaseProvider = Provider<GetFeesUseCase>(
  (ref) => GetFeesUseCase(ref.watch(feesRepositoryProvider)),
);

final syncQueueServiceProvider = Provider<SyncQueueService>(
  (ref) =>
      SyncQueueService(ref.watch(appDatabaseProvider), ref.watch(dioProvider)),
);
