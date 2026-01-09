import 'package:flutter/material.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  String _selectedVoice = 'Żeński';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
        slivers: [
          // Nagłówek główny
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ustawienia',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Skonfiguruj swojego asystenta pierwszej pomocy',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          _buildStickyHeader('Głos i Dźwięk', Icons.volume_up),
          SliverList(
            delegate: SliverChildListDelegate([
              _buildSettingTile(
                title: 'Typ głosu',
                subtitle: _selectedVoice,
                icon: Icons.record_voice_over,
                trailing: DropdownButton<String>(
                  value: _selectedVoice,
                  underline: const SizedBox(), // Usuwa dolną linię
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedVoice = newValue!;
                    });
                  },
                  items: <String>['Żeński', 'Męski']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ]),
          ),

          _buildStickyHeader('Ogólne', Icons.settings),
          SliverList(
            delegate: SliverChildListDelegate([
              _buildSettingTile(
                title: 'Polityka i prywatność',
                icon: Icons.privacy_tip_outlined,
                onTap: () {},
              ),
              _buildSettingTile(
                title: 'Pomoc i Wsparcie',
                icon: Icons.help_outline,
                onTap: () {},
              ),
            ]),
          ),

          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    'Asystent Pierwszej Pomocy',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  Text(
                    'Wersja 1.0.0',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyHeader(String title, IconData icon) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _StickyHeaderDelegate(
        title: title,
        icon: icon,
      ),
    );
  }

  // Buduje pojedynczy wiersz ustawień
  Widget _buildSettingTile({
    required String title,
    String? subtitle,
    required IconData icon,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      color: Colors.white,
      child: ListTile(
        leading: Icon(icon, color: Colors.red.shade900),
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: trailing ?? const Icon(Icons.chevron_right, size: 20),
        onTap: onTap,
      ),
    );
  }
}

// Klasa pomocnicza do obsługi Sticky Header
class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String title;
  final IconData icon;

  _StickyHeaderDelegate({required this.title, required this.icon});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.grey.shade100,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade700),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 40.0;
  @override
  double get minExtent => 40.0;
  @override
  bool shouldRebuild(covariant _StickyHeaderDelegate oldDelegate) => false;
}