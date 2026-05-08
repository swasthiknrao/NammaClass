import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/secure_storage.dart';

final secureStorageProvider = Provider<SecureStorage>((ref) => SecureStorage());
