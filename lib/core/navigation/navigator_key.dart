import 'package:flutter/material.dart';

/// Key navigator global untuk mendukung redirect sesi (mis. saat HTTP 401)
/// dari lapisan layanan tanpa bergantung pada [BuildContext] lokal.
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();
