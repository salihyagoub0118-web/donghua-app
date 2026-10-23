import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://zpzcdapnfyhaonpngkhg.supabase.co',
    anonKey: 'sb_publishable_W-WcxSU0WbFMfEpH7vG2rg_j5KqZGgl',
  );
  
  runApp(const DonghuaApp());
}

class DonghuaApp extends StatelessWidget {
  const DonghuaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Donghua Hub',
      theme: ThemeData.dark().copyWith(
        primaryColor: const Color(0xFFE94560),
        scaffoldBackgroundColor: const Color(0xFF0A0A0E),
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final supabase = Supabase.instance.client;
  List<dynamic> _donghuaList = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final response = await supabase
          .from('donghua')
          .select()
          .eq('is_published', true)
          .order('created_at', ascending: false);
      
      setState(() {
        _donghuaList = response;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      debugPrint('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Donghua Hub', style: TextStyle(color: Color(0xFFE94560), fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF12121A),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE94560)))
          : _donghuaList.isEmpty
              ? const Center(child: Text('لا توجد أعمال مضافة', style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _donghuaList.length,
                  itemBuilder: (context, index) {
                    final item = _donghuaList[index];
                    return Card(
                      color: const Color(0xFF12121A),
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            if (item['cover_url'] != null && item['cover_url'].toString().isNotEmpty)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  item['cover_url'],
                                  width: 80,
                                  height: 110,
                                  fit: BoxFit.cover,
                                  errorBuilder: (c, e, s) => Container(width: 80, height: 110, color: Colors.grey[800]),
                                ),
                              )
                            else
                              Container(width: 80, height: 110, color: Colors.grey[800], child: const Icon(Icons.image_not_supported)),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['title_ar'] ?? 'بدون اسم',
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item['title_en'] ?? '',
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE94560).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: const Color(0xFFE94560).withOpacity(0.5)),
                                    ),
                                    child: Text(
                                      item['status'] == 'ongoing' ? 'مستمر' : 'مكتمل',
                                      style: const TextStyle(fontSize: 10, color: Color(0xFFE94560)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
