import 'dart:io';
import 'dart:math';
import 'package:device_info_plus/device_info_plus.dart';

class RandomDeviceUserAgent {
  static final _rand = Random.secure();
  static final _devInfo = DeviceInfoPlugin();

  static Future<String> next() async {
    if (Platform.isAndroid) return _android();
    if (Platform.isIOS) return _ios();
    if (Platform.isMacOS)
      return _desktop('Macintosh; Intel Mac OS X', _safari());
    if (Platform.isWindows)
      return _desktop('Windows NT 10.0; Win64; x64', _chrome());
    return _desktop('X11; Linux x86_64', _chrome());
  }

  static Future<String> nextForVideo() async {
    return Platform.isIOS
        ? await _ios(mobileOnly: true)
        : await _android(mobileOnly: true);
  }

  static Future<String> _android({bool mobileOnly = false}) async {
    try {
      final a = await _devInfo.androidInfo;
      final ver = a.version.release;
      final mdl = a.model;
      final chr = _chrome();
      final mob = mobileOnly || !_isTablet(a) ? ' Mobile' : '';
      return 'Mozilla/5.0 (Linux; Android $ver; $mdl)'
          ' AppleWebKit/537.36 (KHTML, like Gecko) '
          'Chrome/$chr$mob Safari/537.36';
    } catch (e) {
      return _fallbackAndroid();
    }
  }

  static Future<String> _ios({bool mobileOnly = false}) async {
    try {
      final i = await _devInfo.iosInfo;
      final ver = i.systemVersion.replaceAll('.', '_');
      final dev = i.model.toLowerCase().contains('ipad') && !mobileOnly
          ? 'iPad; CPU OS'
          : 'iPhone; CPU iPhone OS';
      final saf = _safari();
      return 'Mozilla/5.0 ($dev $ver like Mac OS X) '
          'AppleWebKit/605.1.15 (KHTML, like Gecko) '
          'Version/$saf Mobile/15E148 Safari/604.1';
    } catch (e) {
      return _fallbackIOS();
    }
  }

  static String _desktop(String os, String browser) =>
      'Mozilla/5.0 ($os) AppleWebKit/537.36 (KHTML, like Gecko) $browser';

  static bool _isTablet(AndroidDeviceInfo a) =>
      !a.systemFeatures.contains('android.hardware.telephony');

  static String _chrome() {
    const majors = [121, 120, 119, 118, 117];
    final major = majors[_rand.nextInt(majors.length)];
    final build1 = 5000 + _rand.nextInt(800);
    final build2 = 100 + _rand.nextInt(800);
    return '$major.0.$build1.$build2';
  }

  static String _safari() {
    const vers = ['17.3', '17.2', '17.1', '17.0', '16.6'];
    return vers[_rand.nextInt(vers.length)];
  }

  static String _fallbackAndroid() =>
      'Mozilla/5.0 (Linux; Android 12; SM-G998B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/${_chrome()} Mobile Safari/537.36';

  static String _fallbackIOS() =>
      'Mozilla/5.0 (iPhone; CPU iPhone OS 16_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/${_safari()} Mobile/15E148 Safari/604.1';
}
