import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/providers/data_sync_provider.dart';

/// Info returned when looking up a person by ID, barcode, or roll number.
class CanteenPersonInfo {
  const CanteenPersonInfo({
    required this.personId,
    required this.personName,
    required this.type,
    required this.info,
    required this.walletBalancePaise,
    this.subscription,
    this.barcode,
  });

  final String personId;
  final String personName;
  final String type; // student | staff
  final String info; // classSection or department
  final int walletBalancePaise;
  final MockCanteenSubscription? subscription;
  final String? barcode;
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    for (final e in this) return e;
    return null;
  }
}

/// Lookup person by ID, barcode (BAR-xxx), roll number, or name.
CanteenPersonInfo? lookupCanteenPerson(String query) {
  if (query.trim().isEmpty) return null;
  final q = query.trim().toLowerCase();
  final qRaw = query.trim();

  // BAR-s01, BAR-st01, BAR-usr_xxx format
  final barPrefix = q.startsWith('bar-') ? q.substring(4) : null;

  // UserModel IDs (app login ids) — map to person info
  if (q == 'usr_student_001' || barPrefix == 'usr_student_001') {
    return lookupCanteenPerson('s01'); // Arjun Kumar
  }
  if (q == 'usr_staff_001' || barPrefix == 'usr_staff_001') {
    final w = MockData.campusWallets
        .where((x) => x.personId == 'usr_staff_001')
        .firstOrNull;
    return CanteenPersonInfo(
      personId: 'usr_staff_001',
      personName: 'Rajesh Gowda',
      type: 'staff',
      info: 'Staff',
      walletBalancePaise: w?.balancePaise ?? 50000,
      barcode: 'BAR-usr_staff_001',
    );
  }
  if (q == 'usr_parent_001' || barPrefix == 'usr_parent_001') {
    final w = MockData.campusWallets
        .where((x) => x.personId == 'usr_parent_001')
        .firstOrNull;
    return CanteenPersonInfo(
      personId: 'usr_parent_001',
      personName: 'Suresh Kumar',
      type: 'parent',
      info: 'Parent',
      walletBalancePaise: w?.balancePaise ?? 25000,
      barcode: 'BAR-usr_parent_001',
    );
  }

  for (final s in MockData.students) {
    if (s.id.toLowerCase() == q ||
        barPrefix == s.id.toLowerCase() ||
        s.rollNo == qRaw ||
        s.name.toLowerCase().contains(q)) {
      final pid = s.id;
      final wallet = MockData.campusWallets
          .where(
            (w) =>
                w.personId == pid ||
                (pid == 's01' && w.personId == 'usr_student_001'),
          )
          .firstOrNull;
      final bal = wallet?.balancePaise ?? 0;
      final sub = MockData.canteenSubscriptions
          .where((x) => x.personId == pid)
          .firstOrNull;
      return CanteenPersonInfo(
        personId: pid,
        personName: s.name,
        type: 'student',
        info: s.classSection,
        walletBalancePaise: bal,
        subscription: sub,
        barcode: 'BAR-$pid',
      );
    }
  }

  for (final s in MockData.staff) {
    if (s.id.toLowerCase() == q ||
        barPrefix == s.id.toLowerCase() ||
        s.name.toLowerCase().contains(q)) {
      final pid = s.id;
      final wallet = MockData.campusWallets
          .where(
            (w) =>
                w.personId == pid ||
                (pid == 'st01' && w.personId == 'usr_staff_001'),
          )
          .firstOrNull;
      final bal = wallet?.balancePaise ?? 50000;
      final sub = MockData.canteenSubscriptions
          .where((x) => x.personId == pid)
          .firstOrNull;
      return CanteenPersonInfo(
        personId: pid,
        personName: s.name,
        type: 'staff',
        info: s.department,
        walletBalancePaise: bal,
        subscription: sub,
        barcode: 'BAR-$pid',
      );
    }
  }

  return null;
}

/// Canonical personId for wallet lookup (UserModel id -> MockData id).
String? canonicalPersonId(String? userId) {
  if (userId == null) return null;
  final u = userId.toLowerCase();
  if (u == 'usr_student_001') return 's01';
  if (u == 'usr_staff_001') return 'st01';
  if (u == 'usr_parent_001') return 'usr_parent_001';
  return userId;
}

/// Mutable canteen state for counter.
class CanteenStateNotifier extends StateNotifier<CanteenState> {
  CanteenStateNotifier(this._ref) : super(CanteenState());

  final Ref _ref;

  void setScannedPerson(CanteenPersonInfo? p) {
    state = CanteenState(scannedPerson: p);
  }

  void addOrder(
    String personId,
    List<MockCanteenOrderItem> items,
    int totalPaise,
  ) {
    final personName = _personNameFor(personId);
    final order = MockCanteenOrder(
      id: 'ord_${DateTime.now().millisecondsSinceEpoch}',
      personId: personId,
      personName: personName,
      items: items,
      totalPaise: totalPaise,
      paymentStatus: 'paid',
      createdAt: DateTime.now(),
    );
    MockData.canteenOrders.insert(0, order);
    final wallet = MockData.campusWallets
        .where(
          (w) =>
              w.personId == personId ||
              (personId == 's01' && w.personId == 'usr_student_001'),
        )
        .firstOrNull;
    if (wallet != null) {
      wallet.balancePaise -= totalPaise;
    }
    final newBal = wallet?.balancePaise ?? 0;
    state = CanteenState(
      scannedPerson: state.scannedPerson != null
          ? CanteenPersonInfo(
              personId: state.scannedPerson!.personId,
              personName: state.scannedPerson!.personName,
              type: state.scannedPerson!.type,
              info: state.scannedPerson!.info,
              walletBalancePaise: newBal,
              subscription: state.scannedPerson!.subscription,
              barcode: state.scannedPerson!.barcode,
            )
          : null,
    );
    _ref.read(dataSyncProvider.notifier).bump();
  }

  String _personNameFor(String personId) {
    final fromState = state.scannedPerson?.personName;
    if (fromState != null && state.scannedPerson?.personId == personId) {
      return fromState;
    }
    final student = MockData.students
        .where((s) => s.id == personId)
        .firstOrNull;
    if (student != null) return student.name;
    final staff = MockData.staff.where((s) => s.id == personId).firstOrNull;
    if (staff != null) return staff.name;
    final wallet = MockData.campusWallets
        .where((w) => w.personId == personId)
        .firstOrNull;
    if (wallet != null) return wallet.personName;
    return 'Unknown';
  }

  void clearScannedPerson() {
    state = CanteenState(scannedPerson: null);
  }
}

class CanteenState {
  const CanteenState({this.scannedPerson});
  final CanteenPersonInfo? scannedPerson;
}

final canteenStateProvider =
    StateNotifierProvider<CanteenStateNotifier, CanteenState>(
      (ref) => CanteenStateNotifier(ref),
    );

/// Canteen menu for ordering — shared by students, staff, parents.
final canteenMenuProvider = FutureProvider<List<MockCanteenItem>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 150));
  return MockData.canteenMenu;
});

/// Get wallet balance for current user.
int walletBalanceForUser(String? userId) {
  final pid = canonicalPersonId(userId) ?? userId;
  if (pid == null) return 0;
  final w = MockData.campusWallets
      .where(
        (x) =>
            x.personId == pid ||
            (pid == 's01' && x.personId == 'usr_student_001'),
      )
      .firstOrNull;
  return w?.balancePaise ?? 0;
}

/// Get orders for person (supports both s01 and usr_student_001).
List<MockCanteenOrder> ordersForPerson(String? personId) {
  if (personId == null) return [];
  final canonical = canonicalPersonId(personId) ?? personId;
  return MockData.canteenOrders
      .where((o) => o.personId == personId || o.personId == canonical)
      .toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
}

class StudentMealCombo {
  const StudentMealCombo({
    required this.id,
    required this.personId,
    required this.name,
    required this.items,
    this.autoBillDaily = false,
    this.lastAutoBilledOn,
  });

  final String id;
  final String personId;
  final String name;
  final List<MockCanteenOrderItem> items;
  final bool autoBillDaily;
  final DateTime? lastAutoBilledOn;

  int get totalPaise =>
      items.fold(0, (sum, item) => sum + (item.pricePaise * item.qty));

  StudentMealCombo copyWith({
    String? id,
    String? personId,
    String? name,
    List<MockCanteenOrderItem>? items,
    bool? autoBillDaily,
    DateTime? lastAutoBilledOn,
    bool clearLastAutoBilledOn = false,
  }) {
    return StudentMealCombo(
      id: id ?? this.id,
      personId: personId ?? this.personId,
      name: name ?? this.name,
      items: items ?? this.items,
      autoBillDaily: autoBillDaily ?? this.autoBillDaily,
      lastAutoBilledOn: clearLastAutoBilledOn
          ? null
          : (lastAutoBilledOn ?? this.lastAutoBilledOn),
    );
  }
}

enum ComboBillResult { success, insufficientBalance, comboNotFound }

class StudentMealComboNotifier extends StateNotifier<List<StudentMealCombo>> {
  StudentMealComboNotifier(this._ref) : super(const []);

  final Ref _ref;

  List<StudentMealCombo> combosForPerson(String personId) =>
      state.where((c) => c.personId == personId).toList();

  void saveCombo({
    required String personId,
    required String name,
    required List<MockCanteenOrderItem> items,
  }) {
    final combo = StudentMealCombo(
      id: 'cmb_${DateTime.now().millisecondsSinceEpoch}',
      personId: personId,
      name: name,
      items: items,
    );
    state = [combo, ...state];
  }

  void setAutoBillDaily(String comboId, bool enabled) {
    state = state
        .map((c) => c.id == comboId ? c.copyWith(autoBillDaily: enabled) : c)
        .toList();
  }

  ComboBillResult billComboNow(String comboId) {
    final combo = state.where((c) => c.id == comboId).firstOrNull;
    if (combo == null) return ComboBillResult.comboNotFound;
    final balance = walletBalanceForUser(combo.personId);
    final total = combo.totalPaise;
    if (balance < total) return ComboBillResult.insufficientBalance;

    _ref
        .read(canteenStateProvider.notifier)
        .addOrder(combo.personId, combo.items, total);
    return ComboBillResult.success;
  }

  ComboBillResult runAutoBillForToday(String personId) {
    var result = ComboBillResult.comboNotFound;
    final now = DateTime.now();
    for (final combo in combosForPerson(
      personId,
    ).where((c) => c.autoBillDaily)) {
      final last = combo.lastAutoBilledOn;
      final alreadyBilledToday =
          last != null &&
          last.year == now.year &&
          last.month == now.month &&
          last.day == now.day;
      if (alreadyBilledToday) continue;

      final billed = billComboNow(combo.id);
      if (billed == ComboBillResult.success) {
        state = state
            .map(
              (c) => c.id == combo.id ? c.copyWith(lastAutoBilledOn: now) : c,
            )
            .toList();
        result = ComboBillResult.success;
      } else if (result != ComboBillResult.success) {
        result = billed;
      }
    }
    return result;
  }

  void deleteCombo(String comboId) {
    state = state.where((c) => c.id != comboId).toList();
  }
}

final studentMealComboProvider =
    StateNotifierProvider<StudentMealComboNotifier, List<StudentMealCombo>>(
      (ref) => StudentMealComboNotifier(ref),
    );
