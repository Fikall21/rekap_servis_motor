import 'package:flutter/material.dart';

void main() {
  runApp(const SmartMotoCareApp());
}

class SmartMotoCareApp extends StatelessWidget {
  const SmartMotoCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart MotoCare',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    DashboardPage(),
    FormLogServisPage(),
    LaporanAnalyticsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Smart MotoCare',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1E293B),
        centerTitle: true,
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blueAccent,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.build_circle_rounded),
            label: 'Log Servis',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_rounded),
            label: 'Laporan',
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 1. DASHBOARD UTAMA
// -----------------------------------------------------------------------------
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Card Info Motor
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Yamaha NMAX 155',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Odometer: 18.250 km',
                    style: TextStyle(fontSize: 15, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          const Text(
            'Status Perawatan Komponen',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // Peringatan 1: Oli Mesin (Bahaya / Servis Sekarang)
          Card(
            color: Colors.red.shade50,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.red.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const ListTile(
              leading: Icon(Icons.circle, color: Colors.red, size: 16),
              title: Text(
                'Oli Mesin: Servis Sekarang!',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
              ),
            ),
          ),

          // Peringatan 2: Kampas Rem (Peringatan)
          Card(
            color: Colors.orange.shade50,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.orange.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const ListTile(
              leading: Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
              title: Text(
                'Kampas Rem: 500 km lagi',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
              ),
            ),
          ),

          // Peringatan 3: Filter Udara (Aman)
          Card(
            color: Colors.green.shade50,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.green.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const ListTile(
              leading: Icon(Icons.check_circle_outline, color: Colors.green, size: 20),
              title: Text(
                'Filter Udara: Aman',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 2. FORM LOG SERVIS
// -----------------------------------------------------------------------------
class FormLogServisPage extends StatefulWidget {
  const FormLogServisPage({super.key});

  @override
  State<FormLogServisPage> createState() => _FormLogServisPageState();
}

class _FormLogServisPageState extends State<FormLogServisPage> {
  final _tanggalController = TextEditingController(text: '14/10/2026');
  final _odometerController = TextEditingController(text: '18250');
  final _itemController = TextEditingController(text: 'Ganti Oli + Busi');
  final _biayaController = TextEditingController(text: '210000');

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Tambah Catatan Log Servis',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Input Tanggal
          TextField(
            controller: _tanggalController,
            decoration: const InputDecoration(
              labelText: 'Tanggal',
              prefixIcon: Icon(Icons.calendar_today),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),

          // Input Odometer
          TextField(
            controller: _odometerController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Odometer (km)',
              prefixIcon: Icon(Icons.speed),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),

          // Input Item Servis
          TextField(
            controller: _itemController,
            decoration: const InputDecoration(
              labelText: 'Item Servis / Suku Cadang',
              prefixIcon: Icon(Icons.build),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),

          // Input Biaya
          TextField(
            controller: _biayaController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Biaya (Rp)',
              prefixIcon: Icon(Icons.attach_money),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),

          // Tombol Simpan
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Log Servis Berhasil Disimpan!')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Simpan Log',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 3. LAPORAN & ANALYTICS
// -----------------------------------------------------------------------------
class LaporanAnalyticsPage extends StatelessWidget {
  const LaporanAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Total Biaya
          Card(
            color: Colors.blue.shade50,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Biaya Okt 2026:',
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Rp 420.000',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          const Text(
            'Pie Chart Breakdown:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // Breakdown Biaya Oli & Pelumas
          Card(
            elevation: 1,
            child: const ListTile(
              leading: Icon(Icons.pie_chart, color: Colors.blue),
              title: Text('Oli & Pelumas'),
              trailing: Text(
                '45%',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),

          // Breakdown Biaya Suku Cadang
          Card(
            elevation: 1,
            child: const ListTile(
              leading: Icon(Icons.pie_chart, color: Colors.orange),
              title: Text('Suku Cadang'),
              trailing: Text(
                '55%',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}