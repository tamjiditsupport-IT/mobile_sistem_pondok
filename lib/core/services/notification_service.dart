import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Service untuk local notifications.
/// Digunakan untuk notifikasi perizinan, tagihan, pengumuman, dll.
class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/launcher_icon');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permission Android 13+
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _initialized = true;
  }

  static void _onNotificationTapped(NotificationResponse response) {
    // Handle navigation dari notifikasi jika diperlukan
    // ignore: avoid_print
    print('[Notif] Tapped: ${response.payload}');
  }

  /// Tampilkan notifikasi umum
  static Future<void> show({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_initialized) await init();

    const androidDetails = AndroidNotificationDetails(
      'pondok_general',
      'Notifikasi Umum',
      channelDescription: 'Notifikasi umum aplikasi Pondok Mobile',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/launcher_icon',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);
    await _plugin.show(id, title, body, details, payload: payload);
  }

  /// Notifikasi perizinan berhasil diajukan
  static Future<void> showPerizinanSubmitted(String namaSantri) async {
    await show(
      id: 1001,
      title: '✅ Perizinan Terkirim',
      body: 'Pengajuan izin untuk $namaSantri telah dikirim dan menunggu persetujuan.',
      payload: 'perizinan',
    );
  }

  /// Notifikasi perizinan disetujui
  static Future<void> showPerizinanApproved(String namaSantri) async {
    await show(
      id: 1002,
      title: '🎉 Perizinan Disetujui',
      body: 'Izin untuk $namaSantri telah disetujui.',
      payload: 'perizinan',
    );
  }

  /// Notifikasi tagihan baru
  static Future<void> showTagihanBaru(String namaTagihan, String jumlah) async {
    await show(
      id: 2001,
      title: '💳 Tagihan Baru',
      body: '$namaTagihan — $jumlah',
      payload: 'tagihan',
    );
  }

  /// Notifikasi pengumuman
  static Future<void> showPengumuman(String judul, String isi) async {
    await show(
      id: 3001,
      title: '📢 $judul',
      body: isi,
      payload: 'pengumuman',
    );
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
