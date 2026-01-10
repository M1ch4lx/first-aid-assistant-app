import 'package:flutter/material.dart';
import 'procedure_detail_screen.dart';
import 'models/procedure.dart';

class CatalogTab extends StatefulWidget {
  const CatalogTab({super.key});

  @override
  State<CatalogTab> createState() => _CatalogTabState();
}

class _CatalogTabState extends State<CatalogTab> {
  final List<Procedure> _allProcedures = [
    Procedure(
      title: 'RKO u Dorosłych',
      description: 'Resuscytacja krążeniowo-oddechowa (30 uciśnięć : 2 oddechy).',
      icon: Icons.favorite,
      color: Colors.red,
      warnings: ['Upewnij się, że miejsce jest bezpieczne.', 'Zadzwoń pod 112/999.'],
      steps: [
        'Sprawdź przytomność (potrząśnij za ramiona).',
        'Udrożnij drogi oddechowe (odchyl głowę do tyłu).',
        'Sprawdź oddech (patrz, słuchaj, wyczuwaj przez 10 sek).',
        'Jeśli nie oddycha, wykonaj 30 mocnych uciśnięć klatki piersiowej.',
        'Wykonaj 2 oddechy ratownicze (jeśli potrafisz).',
        'Kontynuuj do przyjazdu pogotowia lub użycia AED.'
      ],
    ),
    Procedure(
      title: 'Zadławienie',
      description: 'Pomoc przy nagłej niedrożności dróg oddechowych.',
      icon: Icons.air,
      color: Colors.blue,
      warnings: ['Nie uderzaj w plecy, gdy osoba kaszle efektywnie.', 'Rękoczyn Heimlicha tylko u przytomnych.'],
      steps: [
        'Zachęcaj do kaszlu.',
        'Wykonaj 5 mocnych uderzeń w okolicę międzyłopatkową.',
        'Jeśli nie pomogło, wykonaj 5 uciśnięć nadbrzusza (Rękoczyn Heimlicha).',
        'Powtarzaj cykl 5:5 do skutku.',
        'Jeśli straci przytomność, zacznij RKO.'
      ],
    ),
    Procedure(
      title: 'Krwotok Zewnętrzny',
      description: 'Tamowanie silnych krwawień i amputacji.',
      icon: Icons.bloodtype,
      color: Colors.red.shade900,
      warnings: ['Zawsze zakładaj rękawiczki.', 'Nie usuwaj ciał obcych z rany.'],
      steps: [
        'Zastosuj bezpośredni ucisk palcami lub dłonią (przez gazę).',
        'Załóż opatrunek uciskowy (kilka warstw gazy i bandaż).',
        'Jeśli przesiąka, nie zdejmuj – dołóż kolejną warstwę.',
        'Unieś kończynę powyżej poziomu serca.',
        'W skrajnych przypadkach (amputacja) użyj stazy taktycznej.'
      ],
    ),
    Procedure(
      title: 'Udar Mózgu (FAST)',
      description: 'Rozpoznawanie objawów udaru i szybka reakcja.',
      icon: Icons.psychology,
      color: Colors.purple,
      warnings: ['Liczy się każda minuta (czas to mózg).', 'Nie podawaj nic do picia ani jedzenia.'],
      steps: [
        'F (Face) - Poproś o uśmiech (sprawdź czy opada kącik ust).',
        'A (Arms) - Poproś o podniesienie obu rąk (sprawdź czy jedna opada).',
        'S (Speech) - Poproś o powtórzenie prostego zdania (sprawdź czy mowa jest bełkotliwa).',
        'T (Time) - Jeśli widzisz któryś z objawów, natychmiast dzwoń pod 112.'
      ],
    ),
    Procedure(
      title: 'Pozycja Bezpieczna',
      description: 'Dla osób nieprzytomnych, ale oddychających.',
      icon: Icons.person_pin,
      color: Colors.green,
      warnings: ['Nie stosuj przy podejrzeniu urazu kręgosłupa (chyba że konieczne).', 'Monitoruj oddech co minutę.'],
      steps: [
        'Ułóż rękę bliższą Tobie pod kątem prostym do ciała.',
        'Drugą rękę włóż pod policzek poszkodowanego.',
        'Zegnij dalszą nogę w kolanie i pociągnij za nią, obracając osobę na bok.',
        'Odchyl lekko głowę do tyłu (drożność).',
      ],
    ),
  ];

  List<Procedure> _filteredProcedures = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredProcedures = _allProcedures;
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
      body: CustomScrollView(
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
            sliver: SliverList(
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