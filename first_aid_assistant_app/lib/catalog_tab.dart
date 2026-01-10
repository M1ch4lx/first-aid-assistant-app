import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Potrzebne do rootBundle
import 'procedure_detail_screen.dart';
import 'models/procedure.dart';

class CatalogTab extends StatefulWidget {
  const CatalogTab({super.key});

  @override
  State<CatalogTab> createState() => _CatalogTabState();
}

class _CatalogTabState extends State<CatalogTab> {
  List<Procedure> _allProcedures = [];
  List<Procedure> _filteredProcedures = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProcedures();
  }

  Future<void> _loadProcedures() async {
    try {
      final String response = await rootBundle.loadString('assets/data/procedures.json');
      final List<dynamic> data = json.decode(response);
      
      setState(() {
        _allProcedures = data.map((json) => Procedure.fromJson(json)).toList();
        _filteredProcedures = _allProcedures;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Błąd ładowania procedur: $e");
      setState(() => _isLoading = false);
    }
  }

  void _filterProcedures(String query) {
    setState(() {
      _filteredProcedures = _allProcedures
          .where((p) => p.title.toLowerCase().contains(query.toLowerCase()) || 
                       p.description.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 40, 20, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Katalog Pierwszej Pomocy', 
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.red.shade900)),
                      const SizedBox(height: 20),
                      
                      TextField(
                        controller: _searchController,
                        onChanged: _filterProcedures,
                        decoration: InputDecoration(
                          hintText: 'Szukaj procedury...',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey.shade200)),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: _filteredProcedures.isEmpty 
                  ? const SliverToBoxAdapter(child: Center(child: Text("Brak wyników")))
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final proc = _filteredProcedures[index];
                          return _buildProcedureCard(context, procedure: proc);
                        },
                        childCount: _filteredProcedures.length,
                      ),
                    ),
              ),
            ],
          ),
    );
  }

  Widget _buildProcedureCard(BuildContext context, {required Procedure procedure}) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: procedure.color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(procedure.icon, color: procedure.color, size: 30),
        ),
        title: Text(procedure.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(procedure.description, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProcedureDetailScreen(
                title: procedure.title,
                description: procedure.description,
                warnings: procedure.warnings,
                steps: procedure.steps,
              ),
            ),
          );
        },
      ),
    );
  }
}