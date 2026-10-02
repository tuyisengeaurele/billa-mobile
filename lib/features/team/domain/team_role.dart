enum TeamRole { owner, member }

// A saved row can still carry a role the server has since retired (accountant), and
// failing the whole team list over a label would be worse than showing a plain member.
TeamRole teamRoleFromJson(String value) => value == 'owner' ? TeamRole.owner : TeamRole.member;

String teamRoleToJson(TeamRole value) => switch (value) {
      TeamRole.owner => 'owner',
      TeamRole.member => 'member',
    };
