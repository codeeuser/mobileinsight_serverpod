import 'package:serverpod_client/serverpod_client.dart';

class MyServiceKeyManager extends AuthenticationKeyManager {
  final String name;
  final String serviceSecret;

  MyServiceKeyManager(this.name, this.serviceSecret);

  @override
  Future<String> get() async {
    return 'name:$serviceSecret';
  }

  @override
  Future<void> put(String key) async {}

  @override
  Future<void> remove() async {}
}
