import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers.dart';
import 'source_provider.dart';

class SourcePage extends ConsumerStatefulWidget {
  const SourcePage({super.key});

  @override
  ConsumerState<SourcePage> createState() => _SourcePageState();
}

class _SourcePageState extends ConsumerState<SourcePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sourcePageProvider.notifier).loadSources();
    });
  }

  void _toggleSource(String sourceId, bool enabled) {
    ref.read(sourcePageProvider.notifier).toggleSource(sourceId, enabled);
  }

  void _deleteSource(String sourceId) {
    ref.read(sourcePageProvider.notifier).deleteSource(sourceId);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sourcePageProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('书源管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => ref.read(sourcePageProvider.notifier).addSource(),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.sources.isEmpty
              ? const Center(
                  child: Text('暂无书源'),
                )
              : ListView.builder(
                  itemCount: state.sources.length,
                  itemBuilder: (context, index) {
                    final source = state.sources[index];
                    return ListTile(
                      title: Text(source.name),
                      subtitle: Text(source.url),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Switch(
                            value: source.enabled,
                            onChanged: (value) =>
                                _toggleSource(source.id, value),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteSource(source.id),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}