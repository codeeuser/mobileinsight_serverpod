import 'package:mobileinsightserverpod/logger.dart';
import 'package:mobileinsightserverpod/my_service_key_manager.dart';
import 'package:mobileinsightserverpod/utils/constants.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';
import 'package:serverpod_service_client/serverpod_service_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

const tag = 'initializeServerpodClient';
Future<Client?> initializeServerpodClient(SharedPreferences prefs) async {
  var host = prefs.getString(Prefs.serverpodServiceServerUrl);
  final key = prefs.getString(Prefs.serverpodServiceServerSecretKey);
  host = (host?.endsWith('/') == false) ? '$host/' : host;
  Logger.log(tag, message: 'host: $host, key: $key');
  // Sets up a singleton client object that can be used to talk to the server from
  // anywhere in our app. The client is generated from your server code.
  // The client is set up to connect to a Serverpod running on a local server on
  // the default port. You will need to modify this to connect to staging or
  // production servers.
  if (host == null || key == null) {
    return null;
  }
  try {
    return Client(
      host,
      authenticationKeyManager: MyServiceKeyManager(
        '0',
        key,
      ),
    )..connectivityMonitor = FlutterConnectivityMonitor();
  } catch (e) {
    return null;
  }
}
