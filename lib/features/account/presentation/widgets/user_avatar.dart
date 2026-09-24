import 'package:flutter/material.dart';
import '../../../../core/network/asset_url.dart';
import '../../../auth/domain/auth_user.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.user, this.radius = 24});

  final AuthUser user;
  final double radius;

  String get _initial {
    final source = (user.name?.trim().isNotEmpty ?? false) ? user.name!.trim() : user.email;
    return source.characters.first.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final initial = CircleAvatar(radius: radius, child: Text(_initial));
    final url = user.avatarUrl;
    if (url == null) return initial;
    return ClipOval(
      child: Image.network(
        resolveAssetUrl(url),
        width: radius * 2,
        height: radius * 2,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => initial,
      ),
    );
  }
}
