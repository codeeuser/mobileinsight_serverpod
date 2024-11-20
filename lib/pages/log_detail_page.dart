import 'package:flutter/material.dart';
import 'package:mobileinsightserverpod/logger.dart';
import 'package:serverpod_service_client/serverpod_service_client.dart';

class LogDetailPage extends StatefulWidget {
  final SessionLogInfo log;
  const LogDetailPage({super.key, required this.log});

  @override
  State<LogDetailPage> createState() => _LogDetailPageState();
}

class _LogDetailPageState extends State<LogDetailPage> {
  static const String tag = "LogDetailPage";

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: true,
        child: Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(title: const Text('Log Details')),
            body: SafeArea(
              child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                return _buildContent();
              }),
            )));
  }

  Widget _buildContent() {
    final log = widget.log;
    List<LogEntry> entries = log.logs;
    List<MessageLogEntry> messages = log.messages;
    List<QueryLogEntry> queries = log.queries;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildInfo(log),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildEntry(entries),
                _buildMessage(messages),
                _buildQueries(queries),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _buildInfo(SessionLogInfo info) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ServerID: ${info.sessionLogEntry.serverId}'),
            const SizedBox(height: 4),
            Text('Endpoint: ${info.sessionLogEntry.endpoint}'),
            const SizedBox(height: 4),
            Text('Method: ${info.sessionLogEntry.method}'),
          ],
        ),
      ),
    );
  }

  Widget _buildEntry(List<LogEntry> entries) {
    Logger.log(tag, message: 'entriesLEN: ${entries.length}');
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Entries'),
          const SizedBox(height: 4),
          ...entries.map((e) {
            return ListTile(
              title: Text('[${e.logLevel}] ${e.message}'),
            );
          }),
        ]),
      ),
    );
  }

  Widget _buildMessage(List<MessageLogEntry> messages) {
    Logger.log(tag, message: 'messagesLEN: ${messages.length}');
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Messages'),
          const SizedBox(height: 4),
          ...messages.map((e) {
            return ListTile(
              title: Text(e.messageName),
            );
          }),
        ]),
      ),
    );
  }

  Widget _buildQueries(List<QueryLogEntry> queries) {
    Logger.log(tag, message: 'queriesLEN: ${queries.length}');
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Queries'),
          const SizedBox(height: 4),
          ...queries.map((e) {
            return ListTile(
              title: Text(e.toString()),
            );
          }),
        ]),
      ),
    );
  }
}
