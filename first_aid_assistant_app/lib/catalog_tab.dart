import 'package:flutter/material.dart';
import 'procedure_detail_screen.dart';

class CatalogTab extends StatelessWidget {
  const CatalogTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
        slivers: [
          // Nagłówek i wyszukiwarka
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Katalog Pierwszej Pomocy',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Przeglądaj scenariusze awaryjne i procedury',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Pasek wyszukiwania
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Szukaj procedury...',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Lista procedur (Mockup)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildProcedureCard(
                  context,
                  title: 'RKO u Dorosłych',
                  description: 'Resuscytacja krążeniowo-oddechowa w przypadku zatrzymania krążenia.',
                  icon: Icons.favorite,
                  color: Colors.red,
                ),
                _buildProcedureCard(
                  context,
                  title: 'Zadławienie',
                  description: 'Postępowanie przy niedrożności dróg oddechowych u dorosłych i dzieci.',
                  icon: Icons.air,
                  color: Colors.blue,
                ),
                _buildProcedureCard(
                  context,
                  title: 'Krwotok Zewnętrzny',
                  description: 'Techniki tamowania silnych krwawień i zakładanie opatrunków uciskowych.',
                  icon: Icons.bloodtype,
                  color: Colors.red.shade700,
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // Funkcja pomocnicza do budowania kart
  Widget _buildProcedureCard(BuildContext context, 
      {required String title, required String description, required IconData icon, required Color color}) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 30),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            description,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProcedureDetailScreen(
                title: title,
                description: description,
              ),
            ),
          );
        },
      ),
    );
  }
}