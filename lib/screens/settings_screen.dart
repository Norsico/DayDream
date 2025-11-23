import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            '主题',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          SwitchListTile.adaptive(
            title: const Text('暗色模式'),
            subtitle: const Text('切换应用的配色方案'),
            value: themeProvider.isDarkMode,
            onChanged: (_) => themeProvider.toggleTheme(),
          ),
          const SizedBox(height: 24),
          Text(
            'AI配置 (开发中)',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: Icon(Icons.smart_toy_outlined, color: theme.colorScheme.primary),
              title: const Text('AI助手即将上线'),
              subtitle: const Text('敬请期待更多智能功能'),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '关于作者',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: theme.colorScheme.primary.withOpacity(0.08),
                backgroundImage: const AssetImage('logo.png'),
                radius: 24,
              ),
              title: const Text('作者名称: Norsico'),
              subtitle: const Text('Github主页: https://github.com/Norsico'),
            ),
          ),
        ],
      ),
    );
  }
}
