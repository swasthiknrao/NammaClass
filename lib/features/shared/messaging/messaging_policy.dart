import '../../../core/mock/mock_data.dart';
import '../../../core/models/user_model.dart';

/// Who is using the School Comms composer (routes / shell).
enum SchoolCommsAccess { admin, principal, hod, teacher }

/// One-tap message starters (playbooks).
class CommsPlaybook {
  const CommsPlaybook({
    required this.title,
    required this.body,
    required this.category,
    required this.iconName,
  });

  final String title;
  final String body;
  final String category;
  final String iconName;
}

/// Role-based messaging rules + demo recipient directory.
abstract final class MessagingPolicy {
  static const playbooks = <CommsPlaybook>[
    CommsPlaybook(
      title: 'Fee / subscription reminder',
      body:
          'This is a friendly reminder that your fee instalment is due soon. '
          'You can pay online from the Fees section in the app. Thank you.',
      category: 'Finance',
      iconName: 'payments',
    ),
    CommsPlaybook(
      title: 'PTM invitation',
      body:
          'You are invited to the upcoming Parent–Teacher meeting. '
          'Please check the schedule and confirm your slot in the app.',
      category: 'Academic',
      iconName: 'groups',
    ),
    CommsPlaybook(
      title: 'Canteen wallet low',
      body:
          'The canteen wallet balance for the linked student is running low. '
          'Top up from the Canteen section to avoid interruption.',
      category: 'Canteen',
      iconName: 'restaurant',
    ),
    CommsPlaybook(
      title: 'Bus route delay',
      body:
          'The school bus on your route is running approximately 10–15 minutes late today. '
          'Live tracking is updated in the Bus section.',
      category: 'Transport',
      iconName: 'directions_bus',
    ),
    CommsPlaybook(
      title: 'Library due date',
      body:
          'A borrowed library item is due for return soon. '
          'Please renew or return it to avoid overdue fines.',
      category: 'Library',
      iconName: 'local_library',
    ),
  ];

  /// Demo portal accounts (stable `UserModel.id` for [MockNotice.targetUserId]).
  static const List<UserModel> portalDemoUsers = [
    UserModel.parent,
    UserModel.teacher,
    UserModel.student,
    UserModel.admin,
    UserModel.principal,
    UserModel.support,
    UserModel.staff,
    UserModel.driver,
    UserModel.librarian,
    UserModel.warden,
    UserModel.canteenStaff,
    UserModel.accountant,
    UserModel.hod,
  ];

  static List<UserModel> visibleRecipients({
    required UserModel sender,
    required SchoolCommsAccess access,
  }) {
    switch (access) {
      case SchoolCommsAccess.admin:
      case SchoolCommsAccess.principal:
        return List.of(portalDemoUsers);
      case SchoolCommsAccess.hod:
        return portalDemoUsers
            .where((u) => u.id != sender.id)
            .where(
              (u) =>
                  u.role != UserRole.superAdmin && (_hodCanMessage(sender, u)),
            )
            .toList();
      case SchoolCommsAccess.teacher:
        return portalDemoUsers
            .where((u) => u.id != sender.id)
            .where((u) => _teacherCanMessage(sender, u))
            .toList();
    }
  }

  static bool _teacherCanMessage(UserModel teacher, UserModel target) {
    final cs = teacher.classSection;
    if (cs == null || cs.isEmpty) return false;
    if (target.role == UserRole.student && target.classSection == cs) {
      return true;
    }
    if (target.role == UserRole.parent) {
      return MockData.students.any(
        (s) =>
            s.classSection == cs &&
            s.parentName != null &&
            s.parentName!.trim().isNotEmpty &&
            s.parentName!.trim() == target.name.trim(),
      );
    }
    if (target.role == UserRole.teacher || target.role == UserRole.hod) {
      return target.classSection == cs;
    }
    return false;
  }

  static bool _hodCanMessage(UserModel hod, UserModel target) {
    final cs = hod.classSection;
    if (target.role == UserRole.parent) {
      if (cs == null || cs.isEmpty) return true;
      return MockData.students.any(
        (s) =>
            s.classSection == cs &&
            s.parentName != null &&
            s.parentName!.trim().isNotEmpty &&
            s.parentName!.trim() == target.name.trim(),
      );
    }
    if (cs != null && cs.isNotEmpty && target.classSection == cs) {
      return true;
    }
    return const {
      UserRole.teacher,
      UserRole.staff,
      UserRole.librarian,
      UserRole.accountant,
      UserRole.support,
      UserRole.driver,
      UserRole.warden,
      UserRole.canteenStaff,
      UserRole.admin,
      UserRole.principal,
    }.contains(target.role);
  }

  /// Maps broadcast UI labels to [UserRole.name] keys (lowercase).
  static List<String> roleKeysFromAudienceLabels(Set<String> labels) {
    final keys = <String>{};
    for (final label in labels) {
      switch (label) {
        case 'Parents':
          keys.add(UserRole.parent.name);
        case 'Teachers':
          keys.add(UserRole.teacher.name);
        case 'Students':
          keys.add(UserRole.student.name);
        case 'All Staff':
          keys.addAll({
            UserRole.teacher.name,
            UserRole.staff.name,
            UserRole.librarian.name,
            UserRole.driver.name,
            UserRole.warden.name,
            UserRole.canteenStaff.name,
            UserRole.accountant.name,
            UserRole.support.name,
            UserRole.hod.name,
            UserRole.principal.name,
            UserRole.admin.name,
          });
      }
    }
    return keys.toList()..sort();
  }

  static int estimateAnnouncementRecipients({
    required List<String> audienceRoleKeys,
    String? classSection,
  }) {
    if (audienceRoleKeys.isEmpty) return 0;
    var n = 0;
    for (final u in portalDemoUsers) {
      if (_userMatchesAnnouncementAudience(
        u,
        audienceRoleKeys: audienceRoleKeys,
        classSection: classSection,
      )) {
        n++;
      }
    }
    n += _mockStudentsMatching(
      audienceRoleKeys: audienceRoleKeys,
      classSection: classSection,
    );
    return n;
  }

  static int _mockStudentsMatching({
    required List<String> audienceRoleKeys,
    String? classSection,
  }) {
    if (!audienceRoleKeys.contains(UserRole.student.name)) return 0;
    var c = 0;
    for (final s in MockData.students) {
      if (classSection != null &&
          classSection.isNotEmpty &&
          s.classSection != classSection) {
        continue;
      }
      if (!portalDemoUsers.any(
        (u) => u.role == UserRole.student && u.name == s.name,
      )) {
        c++;
      }
    }
    return c;
  }

  static bool _userMatchesAnnouncementAudience(
    UserModel u, {
    required List<String> audienceRoleKeys,
    String? classSection,
  }) {
    if (!audienceRoleKeys.contains(u.role.name)) return false;
    if (classSection == null || classSection.isEmpty) return true;
    if (u.role == UserRole.parent) {
      return MockData.students.any(
        (s) =>
            s.classSection == classSection &&
            s.parentName != null &&
            s.parentName!.trim() == u.name.trim(),
      );
    }
    return u.classSection == classSection;
  }

  /// Strips announcement role keys that the sender role is not allowed to use.
  static List<String> filterAnnouncementKeysForAccess(
    List<String> keys,
    SchoolCommsAccess access,
  ) {
    switch (access) {
      case SchoolCommsAccess.teacher:
        return keys
            .where(
              (k) => k == UserRole.parent.name || k == UserRole.student.name,
            )
            .toList();
      case SchoolCommsAccess.hod:
      case SchoolCommsAccess.admin:
      case SchoolCommsAccess.principal:
        return keys;
    }
  }

  /// Validates direct-message recipient for the current composer.
  static bool canSendDirectTo({
    required UserModel sender,
    required SchoolCommsAccess access,
    required UserModel recipient,
  }) {
    return visibleRecipients(
      sender: sender,
      access: access,
    ).any((u) => u.id == recipient.id);
  }

  /// In-app visibility for segmented / school-wide notices ([targetUserId] null).
  static bool announcementVisibleToUser({
    required MockNotice notice,
    required UserModel user,
  }) {
    if (notice.targetUserId != null) return false;
    if (notice.audienceRoleKeys.isEmpty &&
        (notice.audienceClassSection == null ||
            notice.audienceClassSection!.isEmpty)) {
      return true;
    }
    if (notice.audienceRoleKeys.isNotEmpty &&
        !notice.audienceRoleKeys.contains(user.role.name)) {
      return false;
    }
    final cs = notice.audienceClassSection;
    if (cs == null || cs.isEmpty) return true;
    return _userMatchesAnnouncementAudience(
      user,
      audienceRoleKeys: notice.audienceRoleKeys.isEmpty
          ? [user.role.name]
          : notice.audienceRoleKeys,
      classSection: cs,
    );
  }

  /// Direct / targeted notice: [targetUserId] matches portal user or legacy ids.
  static bool directNoticeMatchesUser({
    required MockNotice notice,
    required UserModel? user,
    required String? borrowerId,
    required String? userName,
  }) {
    final t = notice.targetUserId;
    if (t == null) return false;
    if (user != null && t == user.id) return true;
    if (user?.studentId != null && t == user!.studentId) return true;
    if (borrowerId != null && t == borrowerId) return true;
    if (userName != null && t == userName) return true;
    return false;
  }
}
