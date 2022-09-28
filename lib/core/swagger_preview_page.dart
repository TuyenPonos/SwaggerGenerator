import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../swagger_generator.dart';

class SwaggerPreviewPage extends StatelessWidget {
  const SwaggerPreviewPage({Key? key}) : super(key: key);

  Future<void> _openSync(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => const _GitAuthenticationDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Swagger Generator'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: StreamBuilder<Swagger?>(
          stream: SwaggerGenerator.instance.stream,
          builder: (_, snapshot) {
            final data = snapshot.hasData ? snapshot.data : null;
            if (data == null) {
              return const Center(
                child: Text(
                  'No data',
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
              );
            }
            return SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: Text(
                          data.prettyJson(),
                          style: const TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Clipboard.setData(
                                  ClipboardData(text: data.prettyJson()));
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text('Copied to clipboard'),
                                behavior: SnackBarBehavior.floating,
                              ));
                            },
                            child: const Text('Copy'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              _openSync(context);
                            },
                            child: const Text('Sync'),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _GitAuthenticationDialog extends StatefulWidget {
  const _GitAuthenticationDialog({Key? key}) : super(key: key);

  @override
  State<_GitAuthenticationDialog> createState() =>
      __GitAuthenticationDialogState();
}

class __GitAuthenticationDialogState extends State<_GitAuthenticationDialog> {
  final TextEditingController _domainCtrl = TextEditingController();
  final TextEditingController _projectIdCtrl = TextEditingController();
  final TextEditingController _accessTokenCtrl = TextEditingController();
  final TextEditingController _commitMessageCtrl = TextEditingController();
  final TextEditingController _branchCtrl = TextEditingController();
  bool _isSyncing = false;
  bool? _status;

  @override
  void initState() {
    super.initState();
    final lastInfo = SwaggerGenerator.instance.gitInformation;
    _domainCtrl.text = lastInfo['domain'] ?? '';
    _projectIdCtrl.text = lastInfo['project_id'] ?? '';
    _accessTokenCtrl.text = lastInfo['access_token'] ?? '';
    _branchCtrl.text = lastInfo['branch'] ?? '';
  }

  Future<void> _sync() async {
    setState(() {
      _isSyncing = true;
      _status = null;
    });
    final resp = await SwaggerGenerator.instance.syncToGitlab(
      domain: _domainCtrl.text,
      projectId: _projectIdCtrl.text,
      accessToken: _accessTokenCtrl.text,
      message: _commitMessageCtrl.text,
      branch: _branchCtrl.text,
    );
    setState(() {
      _status = resp;
      _isSyncing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _domainCtrl,
              decoration: const InputDecoration(
                labelText: 'Domain',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _projectIdCtrl,
              decoration: const InputDecoration(
                labelText: 'Porject ID',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _accessTokenCtrl,
              decoration: const InputDecoration(
                labelText: 'Access token',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _branchCtrl,
              decoration: const InputDecoration(
                labelText: 'Branch',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _commitMessageCtrl,
              decoration: const InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.auto,
                labelText: 'Commit message (Optional)',
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Builder(
                    builder: (context) {
                      String message = '';
                      if (_isSyncing) {
                        message = 'Syncing';
                      } else if (_status == true) {
                        message = 'Success';
                      } else if (_status == false) {
                        message = 'Failed';
                      }
                      return Text(
                        'Status: $message',
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      );
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _sync();
                  },
                  child: const Text('Sync now'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
