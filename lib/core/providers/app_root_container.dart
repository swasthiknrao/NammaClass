import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data_sync_provider.dart';

/// Root [ProviderContainer] so non-widget code can bump sync after mutating
/// [MockData].
ProviderContainer? appRootContainer;

void bumpGlobalDataSync() {
  appRootContainer?.read(dataSyncProvider.notifier).bump();
}
