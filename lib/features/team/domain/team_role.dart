enum TeamRole { owner, member, accountant }

TeamRole teamRoleFromJson(String value) => switch (value) {
      'owner' => TeamRole.owner,
      'member' => TeamRole.member,
      'accountant' => TeamRole.accountant,
      _ => throw ArgumentError('Unknown team role: $value'),
    };

String teamRoleToJson(TeamRole value) => switch (value) {
      TeamRole.owner => 'owner',
      TeamRole.member => 'member',
      TeamRole.accountant => 'accountant',
    };

// Requests use the backend's uppercase enum, unlike its lowercase responses,
// and the owner is never assignable, failing loudly here beats sending a
// request the server would reject.
String teamRoleToRequest(TeamRole role) => switch (role) {
      TeamRole.member => 'MEMBER',
      TeamRole.accountant => 'ACCOUNTANT',
      TeamRole.owner => throw ArgumentError('An owner role can never be assigned or invited'),
    };
