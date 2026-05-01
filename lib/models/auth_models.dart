import 'user_profile_model.dart';

enum AuthMethod { emailPassword, phoneOtp }

enum OtpPurpose { signUp, login }

class OtpChallenge {
  final String id;
  final String userId;
  final String destination;
  final String channel;
  final String codeDebug;
  final OtpPurpose purpose;
  final DateTime expiresAt;
  final String deliveryStatus;
  final String deliveryMessage;

  const OtpChallenge({
    required this.id,
    required this.userId,
    required this.destination,
    required this.channel,
    required this.codeDebug,
    required this.purpose,
    required this.expiresAt,
    this.deliveryStatus = 'developerPreview',
    this.deliveryMessage = '',
  });

  factory OtpChallenge.fromApiJson(
    Map<String, dynamic> json, {
    required OtpPurpose purpose,
  }) {
    return OtpChallenge(
      id: json['challengeId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      destination: json['maskedDestination']?.toString() ??
          json['destination']?.toString() ??
          '',
      channel: json['channel']?.toString() ?? 'email',
      codeDebug: json['debugCode']?.toString() ?? '',
      purpose: purpose,
      expiresAt: DateTime.tryParse(json['expiresAt']?.toString() ?? '') ??
          DateTime.now(),
      deliveryStatus:
          json['deliveryStatus']?.toString() ?? 'developerPreview',
      deliveryMessage: json['deliveryMessage']?.toString() ?? '',
    );
  }

  String get maskedDestination {
    if (channel == 'sms') {
      if (destination.length <= 4) {
        return destination;
      }
      return '${destination.substring(0, 3)}*****${destination.substring(destination.length - 2)}';
    }

    if (!destination.contains('@')) {
      return destination;
    }
    final parts = destination.split('@');
    final local = parts.first;
    final visible = local.length <= 2 ? local : '${local[0]}${local[1]}';
    return '$visible***@${parts.last}';
  }
}

class AppLaunchState {
  final AppUser? user;
  final bool needsOnboarding;

  const AppLaunchState({
    required this.user,
    required this.needsOnboarding,
  });
}

class OtpVerificationResult {
  final AppUser user;
  final bool needsOnboarding;

  const OtpVerificationResult({
    required this.user,
    required this.needsOnboarding,
  });
}
