import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int? _userId;
  String _userName = '';
  List<dynamic> _servisList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSessionAndData();
  }

  Future<void> _loadSessionAndData() async {
    final session = await ApiService.getUserSession();
    if (session != null) {
      setState(() {
        _userId = session['id'];
        _userName = session['nama'] ?? '';
      });
      await _fetchServis();
    } else {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  Future<void> _fetchServis() async {
    if (_userId == null) return;
    setState(() => _isLoading = true);
    final data = await ApiService.getServisByUser(_userId!);
    setState(() {
      _servisList = data;
      _isLoading = false;
    });
  }

  Future<void> _logout() async {
    await ApiService.logout();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  Future<void> _confirmDelete(int id, String namaMotor) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Data Servis'),
        content: Text('Yakin ingin menghapus riwayat servis $namaMotor?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await ApiService.hapusServis(id);
      if (success) {
        _fetchServis();
      }
    }
  }

  void _showFormDialog({Map<String, dynamic>? item}) {
    final motorCtrl = TextEditingController(text: item?['nama_motor'] ?? '');
    final platCtrl = TextEditingController(text: item?['plat_nomor'] ?? '');
    final jenisCtrl = TextEditingController(text: item?['jenis_servis'] ?? '');
    final biayaCtrl =
        TextEditingController(text: item?['biaya']?.toString() ?? '');
    final catatanCtrl = TextEditingController(text: item?['catatan'] ?? '');
    final tanggalCtrl = TextEditingController(
      text: item != null
          ? item['tanggal_servis'].toString().substring(0, 10)
          : DateTime.now().toIso8601String().substring(0, 10),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item == null ? 'Tambah Servis Motor' : 'Edit Servis Motor'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: motorCtrl,
                decoration: const InputDecoration(
                    labelText: 'Nama Motor (misal: Vario 160)'),
              ),
              TextField(
                controller: platCtrl,
                decoration: const InputDecoration(
                    labelText: 'Plat Nomor (misal: D 1234 ABC)'),
              ),
              TextField(
                controller: jenisCtrl,
                decoration: const InputDecoration(
                    labelText: 'Jenis Servis (misal: Ganti Oli & CVT)'),
              ),
              TextField(
                controller: biayaCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Biaya (Rp)'),
              ),
              TextField(
                controller: tanggalCtrl,
                decoration:
                    const InputDecoration(labelText: 'Tanggal (YYYY-MM-DD)'),
              ),
              TextField(
                controller: catatanCtrl,
                decoration: const InputDecoration(labelText: 'Catatan'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (motorCtrl.text.isEmpty ||
                  platCtrl.text.isEmpty ||
                  jenisCtrl.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Nama motor, plat, dan jenis wajib diisi!')),
                );
                return;
              }

              final payload = {
                'user_id': _userId,
                'nama_motor': motorCtrl.text.trim(),
                'plat_nomor': platCtrl.text.trim(),
                'jenis_servis': jenisCtrl.text.trim(),
                'biaya': int.tryParse(biayaCtrl.text.trim()) ?? 0,
                'tanggal_servis': tanggalCtrl.text.trim(),
                'catatan': catatanCtrl.text.trim(),
              };

              bool success;
              if (item == null) {
                success = await ApiService.tambahServis(payload);
              } else {
                success = await ApiService.updateServis(item['id'], payload);
              }

              if (!context.mounted) return;
              if (success) {
                Navigator.pop(context);
                _fetchServis();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Gagal menyimpan data ke server'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Halo, $_userName'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchServis,
            tooltip: 'Refresh Data',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _servisList.isEmpty
              ? const Center(
                  child: Text(
                    'Belum ada riwayat servis.\nTekan tombol + di bawah untuk menambah data.',
                    textAlign: TextAlign.center,
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchServis,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80, top: 8),
                    itemCount: _servisList.length,
                    itemBuilder: (context, index) {
                      final item = _servisList[index];
                      final tanggal =
                          item['tanggal_servis'].toString().substring(0, 10);
                      final catatan = (item['catatan'] ?? '').toString();

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        child: ListTile(
                          title: Text(
                            '${item['nama_motor']} (${item['plat_nomor']})',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${item['jenis_servis']} â€¢ Rp ${item['biaya']}\nTgl: $tanggal${catatan.isNotEmpty ? ' â€¢ $catatan' : ''}',
                          ),
                          isThreeLine: true,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit,
                                    color: Colors.orange),
                                onPressed: () => _showFormDialog(item: item),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _confirmDelete(
                                    item['id'], item['nama_motor']),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFormDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
