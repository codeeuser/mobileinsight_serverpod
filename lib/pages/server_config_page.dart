import 'package:flutter/material.dart';
import 'package:mobileinsightserverpod/logger.dart';
import 'package:mobileinsightserverpod/pages/ways_page.dart';
import 'package:mobileinsightserverpod/utils/constants.dart';
import 'package:mobileinsightserverpod/utils/validation_function.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef ActionCallback = void Function(ScreenName screenName);

class ServerConfigPage extends StatefulWidget {
  final SharedPreferences prefs;
  final ActionCallback callback;
  const ServerConfigPage(
      {super.key, required this.prefs, required this.callback});

  @override
  State<ServerConfigPage> createState() => _ServerConfigPageState();
}

class _ServerConfigPageState extends State<ServerConfigPage> {
  static const String tag = "ServerConfigPage";

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _keyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // _urlController.text = '';
    // _keyController.text = '';
  }

  @override
  void dispose() {
    _urlController.dispose();
    _keyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildContent();
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 40),
          const Text('Serverpod Service Server'),
          const SizedBox(height: 40),
          Expanded(child: _buildForm()),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Card(
      child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              TextFormField(
                controller: _urlController,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  icon:
                      Icon(Icons.web, color: Colors.grey, semanticLabel: 'Url'),
                  hintText: 'What is the URL?',
                  labelText: 'URL',
                ),
                validator: (value) => validateUrl(value),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _keyController,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  icon:
                      Icon(Icons.key, color: Colors.grey, semanticLabel: 'Key'),
                  hintText: 'What is the Secret Key?',
                  labelText: 'Secret Key',
                ),
                validator: (value) => validateNotEmpty(value),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                child: const Text('Login'),
                onPressed: () async {
                  if (_formKey.currentState?.validate() == false) {
                    return;
                  }
                  String url = _urlController.text.trim();
                  String key = _keyController.text.trim();
                  Logger.log(tag, message: 'url: $url, key: $key');
                  if (url.isEmpty && key.isEmpty) {
                    return;
                  }
                  final prefs = widget.prefs;
                  await prefs.setString(Prefs.serverpodServiceServerUrl, url);
                  await prefs.setString(
                      Prefs.serverpodServiceServerSecretKey, key);
                  widget.callback(ScreenName.main);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
