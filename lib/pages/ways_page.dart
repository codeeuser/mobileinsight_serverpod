// ignore_for_file: unnecessary_null_comparison

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobileinsightserverpod/commons/no_data.dart';
import 'package:mobileinsightserverpod/logger.dart';
import 'package:mobileinsightserverpod/pages/log_detail_page.dart';
import 'package:mobileinsightserverpod/pages/server_config_page.dart';
import 'package:mobileinsightserverpod/serverpod_client.dart';
import 'package:mobileinsightserverpod/utils/constants.dart';
import 'package:mobileinsightserverpod/utils/functions.dart';
import 'package:serverpod_service_client/serverpod_service_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ScreenName { main, config }

class WaysPage extends StatefulWidget {
  final SharedPreferences prefs;
  const WaysPage({super.key, required this.prefs});

  @override
  State<WaysPage> createState() => _WaysPageState();
}

class _WaysPageState extends State<WaysPage> {
  static const String tag = "WaysPage";
  static const int numEntries = 20;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  final ValueNotifier<SessionLogFilter> _filter =
      ValueNotifier(SessionLogFilter(open: false, slow: false, error: false));
  final ValueNotifier<bool> _open = ValueNotifier(false);
  final ValueNotifier<bool> _slow = ValueNotifier(false);
  final ValueNotifier<bool> _error = ValueNotifier(false);
  final ValueNotifier<ScreenName> _screen = ValueNotifier(ScreenName.main);

  String? _endpoint;

  @override
  void initState() {
    super.initState();
    final prefs = widget.prefs;
    var url = prefs.getString(Prefs.serverpodServiceServerUrl);
    final key = prefs.getString(Prefs.serverpodServiceServerSecretKey);
    if (url == null ||
        key == null ||
        url.isEmpty == true ||
        key.isEmpty == true) {
      _screen.value = ScreenName.config;
    }
    _initialize();
  }

  Future<void> _initialize() async {
    Logger.log(tag, message: '_initialize---');
  }

  @override
  void dispose() {
    _filter.dispose();
    _open.dispose();
    _slow.dispose();
    _error.dispose();
    _screen.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: true,
        child: Scaffold(
            key: _scaffoldKey,
            body: SafeArea(
              child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                return ValueListenableBuilder<ScreenName>(
                    valueListenable: _screen,
                    builder: (context, screen, _) {
                      if (screen == ScreenName.main) {
                        return _buildContent();
                      } else if (screen == ScreenName.config) {
                        return ServerConfigPage(
                          prefs: widget.prefs,
                          callback: (ScreenName screenName) {
                            _screen.value = screenName;
                          },
                        );
                      }
                      return _buildContent();
                    });
              }),
            )));
  }

  Widget _buildContent() {
    return FutureBuilder<Client?>(
        future: initializeServerpodClient(widget.prefs),
        builder: (context, snapshotClient) {
          if (snapshotClient.hasData) {
            final client = snapshotClient.data;
            Logger.log(tag, message: 'client: $client');
            if (client == null) {
              return const NoData();
            }
            Logger.log(tag, message: 'client: ${client.connectionTimeout}');
            return ValueListenableBuilder<SessionLogFilter>(
                valueListenable: _filter,
                builder: (context, filter, _) {
                  return FutureBuilder<SessionLogResult>(
                      future: client.insights.getSessionLog(numEntries, filter),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final result = snapshot.data;
                          if (result == null) {
                            return const NoData();
                          }
                          final logs = result.sessionLog;
                          return Column(
                            children: [
                              _buildHeader(client),
                              const SizedBox(height: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildDropdown(client),
                                  const SizedBox(height: 4),
                                  _buildFilter(),
                                ],
                              ),
                              Expanded(
                                child: ListView.builder(
                                    itemCount: logs.length,
                                    itemBuilder:
                                        (BuildContext ctxt, int index) {
                                      return _buildLogItem(
                                          logs.elementAt(index));
                                    }),
                              ),
                            ],
                          );
                        }
                        return Column(
                          children: [
                            _buildHeader(client),
                            Expanded(child: Utils.loadingScreen()),
                          ],
                        );
                      });
                });
          }
          return Utils.loadingScreen();
        });
  }

  Widget _buildHeader(client) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Serverpod Insight (MAX:$numEntries)'),
        TextButton(
          child: const Text('Logout'),
          onPressed: () async {
            await widget.prefs.clear();
            client?.close();
            _screen.value = ScreenName.config;
          },
        ),
      ],
    );
  }

  Widget _buildDropdown(Client? client) {
    return FutureBuilder<List<TableDefinition>>(
        future: client?.insights.getTargetTableDefinition(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final defs = snapshot.data;
            if (defs == null) {
              return const SizedBox();
            }
            final list = [];
            for (var def in defs) {
              if (def.module?.startsWith('serverpod') == true) continue;
              list.add((def.dartName ?? '').toUnCapitalized());
            }
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  DropdownMenu(
                      label: const Text('Endpoint'),
                      onSelected: (String? endpoint) {
                        endpoint = (endpoint == '') ? null : endpoint;
                        _endpoint = endpoint;
                        _filter.value = SessionLogFilter(
                            slow: _slow.value,
                            error: _error.value,
                            open: _open.value,
                            endpoint: endpoint);
                      },
                      dropdownMenuEntries: [
                        const DropdownMenuEntry<String>(
                            value: '', label: 'Any'),
                        ...list.map((e) {
                          return DropdownMenuEntry<String>(value: e, label: e);
                        }),
                      ])
                ],
              ),
            );
          }
          return const SizedBox();
        });
  }

  Widget _buildFilter() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Row(
            children: [
              const Text('Open'),
              const SizedBox(width: 2),
              ValueListenableBuilder<bool>(
                  valueListenable: _open,
                  builder: (context, open, _) {
                    return Checkbox(
                        value: open,
                        onChanged: (value) {
                          _open.value = value ?? false;
                          _filter.value = SessionLogFilter(
                              slow: _slow.value,
                              error: _error.value,
                              open: _open.value,
                              endpoint: _endpoint);
                        });
                  }),
              const SizedBox(width: 8),
              const Text('Slow'),
              const SizedBox(width: 2),
              ValueListenableBuilder<bool>(
                  valueListenable: _slow,
                  builder: (context, slow, _) {
                    return Checkbox(
                        value: slow,
                        onChanged: (value) {
                          _slow.value = value ?? false;
                          _filter.value = SessionLogFilter(
                              slow: _slow.value,
                              error: _error.value,
                              open: _open.value,
                              endpoint: _endpoint);
                        });
                  }),
              const SizedBox(width: 8),
              const Text('Error'),
              const SizedBox(width: 2),
              ValueListenableBuilder<bool>(
                  valueListenable: _error,
                  builder: (context, error, _) {
                    return Checkbox(
                        value: error,
                        onChanged: (value) {
                          _error.value = value ?? false;
                          _filter.value = SessionLogFilter(
                              slow: _slow.value,
                              error: _error.value,
                              open: _open.value,
                              endpoint: _endpoint);
                        });
                  }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogItem(SessionLogInfo log) {
    SessionLogEntry logEntry = log.sessionLogEntry;
    return Card(
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text(
                '${logEntry.id}: ${logEntry.endpoint} : ${logEntry.method}'),
            subtitle: _buildSuntitle(logEntry),
            trailing: const Icon(CupertinoIcons.chevron_right),
            onTap: () {
              Utils.pushPage(context, LogDetailPage(log: log), 'LogDetailPage');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSuntitle(SessionLogEntry log) {
    double? duration = log.duration;
    DateTime dt = log.time;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Server ID: ${log.serverId}'),
        const SizedBox(height: 4),
        Text(
            '${DateFormat.yMd().format(dt.toLocal())} ${DateFormat.jms().format(dt.toLocal())}'),
        if (duration != null) ...[
          const SizedBox(height: 4),
          Text('$duration'),
        ],
      ],
    );
  }
}
