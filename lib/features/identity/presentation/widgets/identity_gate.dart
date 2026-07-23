import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/routes/app_router.dart';
import '../../../shifts/presentation/providers/shifts_providers.dart';
import '../providers/identity_providers.dart';
import 'who_are_you_sheet.dart';

/// Envuelve la app entera (ver `main.dart`) y, una vez que los
/// participantes cargaron, si el dispositivo todavía no tiene dueño
/// asignado, dispara `WhoAreYouSheet` una sola vez por sesión. También
/// mantiene sincronizado el token FCM del dispositivo con la identidad
/// elegida (ver `PushTokenService`).
class IdentityGate extends ConsumerStatefulWidget {
  final Widget child;

  const IdentityGate({super.key, required this.child});

  @override
  ConsumerState<IdentityGate> createState() => _IdentityGateState();
}

class _IdentityGateState extends ConsumerState<IdentityGate> {
  bool _promptShown = false;
  StreamSubscription<String>? _tokenRefreshSub;

  @override
  void initState() {
    super.initState();
    // Silencioso si Firebase no está configurado en esta plataforma (ver
    // main.dart) o si nadie eligió identidad todavía.
    try {
      _tokenRefreshSub = FirebaseMessaging.instance.onTokenRefresh.listen((
        token,
      ) {
        final myId = ref.read(myParticipantIdProvider);
        if (myId != null) {
          ref.read(pushTokenServiceProvider)?.onTokenRefreshed(myId, token);
        }
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _tokenRefreshSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final myId = ref.watch(myParticipantIdProvider);
    final ui = ref.watch(turnosViewModelProvider);

    ref.listen<String?>(myParticipantIdProvider, (previous, next) {
      if (next != null) {
        ref.read(pushTokenServiceProvider)?.registerFor(next);
      }
    });

    if (myId == null && !ui.loading && !_promptShown) {
      final participants = ui.data.participants;
      if (participants.isNotEmpty) {
        _promptShown = true;
        // `context` acá vive en el `builder` de MaterialApp.router, fuera
        // del Navigator que arma el router — hay que usar el del propio
        // Navigator raíz para poder abrir el bottom sheet.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final navContext = rootNavigatorKey.currentContext;
          if (mounted && navContext != null) {
            showWhoAreYouSheet(navContext, participants);
          }
        });
      }
    }

    return widget.child;
  }
}
