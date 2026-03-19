import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

void main() {
  runApp(const FloodApp());
}

class FloodApp extends StatefulWidget {
  const FloodApp({super.key});

  @override
  State<FloodApp> createState() => _FloodAppState();
}

class _FloodAppState extends State<FloodApp> {
  bool isDark = true;
  void toggleTheme() => setState(() => isDark = !isDark);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flood Prediction System',
      debugShowCheckedModeBanner: false,
      theme: isDark ? _dark() : _light(),
      home: HomePage(isDark: isDark, toggleTheme: toggleTheme),
    );
  }

  ThemeData _dark() => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF080d1c),
    colorScheme: const ColorScheme.dark(surface: Color(0xFF080d1c), primary: Color(0xFF06b6d4)),
    useMaterial3: true,
  );
  ThemeData _light() => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF0F4F8),
    colorScheme: const ColorScheme.light(surface: Color(0xFFF0F4F8), primary: Color(0xFF0284c7)),
    useMaterial3: true,
  );
}

class SensorNode {
  final int id;
  final String name;
  final String river;
  final String location;
  double waterLevel;
  double temperature;
  double humidity;
  double soilMoisture;
  double rainfall;
  double pressure;
  int battery;
  bool online;
  DateTime lastUpdate;

  SensorNode({
    required this.id,
    required this.name,
    required this.river,
    required this.location,
    this.waterLevel = 100,
    this.temperature = 30,
    this.humidity = 60,
    this.soilMoisture = 40,
    this.rainfall = 5,
    this.pressure = 1013,
    this.battery = 85,
    this.online = true,
    DateTime? lastUpdate,
  }) : lastUpdate = lastUpdate ?? DateTime.now();

  String get alertStatus {
    if (waterLevel > 380) return 'EVACUATE';
    if (waterLevel > 300) return 'EMERGENCY';
    if (waterLevel > 200) return 'WARNING';
    if (waterLevel > 150) return 'WATCH';
    return 'SAFE';
  }

  int get alertLevel {
    if (waterLevel > 380) return 4;
    if (waterLevel > 300) return 3;
    if (waterLevel > 200) return 2;
    if (waterLevel > 150) return 1;
    return 0;
  }

  Color get alertColor {
    if (waterLevel > 380) return const Color(0xFFb71c1c);
    if (waterLevel > 300) return const Color(0xFFef4444);
    if (waterLevel > 200) return const Color(0xFFf59e0b);
    if (waterLevel > 150) return const Color(0xFFeab308);
    return const Color(0xFF10b981);
  }

  double get pred24h => waterLevel * 1.05;
  double get pred48h => waterLevel * 1.12;
  double get pred72h => waterLevel * 1.20;
}

class HomePage extends StatefulWidget {
  final bool isDark;
  final VoidCallback toggleTheme;
  const HomePage({super.key, required this.isDark, required this.toggleTheme});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _currentIndex = 0;
  int _selectedNode = 0;
  final Random _rng = Random();
  late AnimationController _pulseCtrl;
  Timer? _autoTimer;

  late List<SensorNode> nodes;

  @override
  void initState() {
    super.initState();
    nodes = [
      SensorNode(id: 1, name: 'Node 1 - Upstream', river: 'Kosi River', location: '26.12°N, 86.00°E',
          waterLevel: 175, temperature: 31.5, humidity: 72, soilMoisture: 58, rainfall: 8.5, pressure: 1010, battery: 87),
      SensorNode(id: 2, name: 'Node 2 - Downstream', river: 'Kosi River', location: '26.08°N, 86.05°E',
          waterLevel: 142, temperature: 32.8, humidity: 68, soilMoisture: 45, rainfall: 5.2, pressure: 1012, battery: 92),
    ];
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _autoTimer = Timer.periodic(const Duration(seconds: 5), (_) => _autoUpdate());
  }

  void _autoUpdate() {
    setState(() {
      for (var n in nodes) {
        n.waterLevel = (n.waterLevel + (_rng.nextDouble() - 0.45) * 8).clamp(30, 480);
        n.temperature = (n.temperature + (_rng.nextDouble() - 0.5) * 1).clamp(18, 48);
        n.humidity = (n.humidity + (_rng.nextDouble() - 0.5) * 3).clamp(20, 100);
        n.soilMoisture = (n.soilMoisture + (_rng.nextDouble() - 0.5) * 2).clamp(5, 100);
        n.rainfall = (n.rainfall + (_rng.nextDouble() - 0.4) * 2).clamp(0, 80);
        n.pressure = (n.pressure + (_rng.nextDouble() - 0.5) * 1).clamp(980, 1030);
        n.lastUpdate = DateTime.now();
      }
    });
  }

  void _simulateFlood(int nodeIdx) {
    setState(() {
      nodes[nodeIdx].waterLevel = 320 + _rng.nextDouble() * 100;
      nodes[nodeIdx].rainfall = 40 + _rng.nextDouble() * 30;
      nodes[nodeIdx].soilMoisture = 80 + _rng.nextDouble() * 20;
      nodes[nodeIdx].humidity = 85 + _rng.nextDouble() * 15;
      nodes[nodeIdx].lastUpdate = DateTime.now();
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _autoTimer?.cancel();
    super.dispose();
  }

  SensorNode get activeNode => nodes[_selectedNode];
  int get maxAlertLevel => nodes.map((n) => n.alertLevel).reduce((a, b) => a > b ? a : b);
  Color get maxAlertColor => nodes.map((n) => n.alertColor).reduce((a, b) {
    int al(Color c) => c == const Color(0xFFb71c1c) ? 4 : c == const Color(0xFFef4444) ? 3 : c == const Color(0xFFf59e0b) ? 2 : c == const Color(0xFFeab308) ? 1 : 0;
    return al(a) >= al(b) ? a : b;
  });
  String get maxAlertStatus {
    int l = maxAlertLevel;
    if (l >= 4) return 'EVACUATE';
    if (l >= 3) return 'EMERGENCY';
    if (l >= 2) return 'WARNING';
    if (l >= 1) return 'WATCH';
    return 'SAFE';
  }

  Color get cardBg => widget.isDark ? const Color(0xFF101829) : Colors.white;
  Color get borderClr => widget.isDark ? const Color(0xFF1e293b) : const Color(0xFFe2e8f0);
  Color get txt1 => widget.isDark ? Colors.white : const Color(0xFF1e293b);
  Color get txt2 => widget.isDark ? const Color(0xFF94a3b8) : const Color(0xFF64748b);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: Column(children: [
        _header(),
        _nodeSelector(),
        Expanded(child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _currentIndex == 0 ? _dashboard() :
                 _currentIndex == 1 ? _alerts() :
                 _currentIndex == 2 ? _prediction() :
                 _settings(),
        )),
      ])),
      bottomNavigationBar: _bottomNav(),
      floatingActionButton: _sosBtn(),
    );
  }

  Widget _header() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: BoxDecoration(color: cardBg, border: Border(bottom: BorderSide(color: borderClr, width: 0.5))),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF06b6d4), Color(0xFF3b82f6)]),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.water, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Flood Prediction', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: txt1)),
          Text('${nodes.where((n) => n.online).length}/${nodes.length} Nodes Online', style: TextStyle(fontSize: 10, color: txt2)),
        ])),
        IconButton(
          onPressed: widget.toggleTheme, icon: Icon(widget.isDark ? Icons.light_mode : Icons.dark_mode, color: const Color(0xFFf59e0b), size: 20),
        ),
        AnimatedBuilder(animation: _pulseCtrl, builder: (ctx, _) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: maxAlertColor.withValues(alpha: 0.1 + _pulseCtrl.value * 0.15),
              border: Border.all(color: maxAlertColor), borderRadius: BorderRadius.circular(16),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 6, height: 6, decoration: BoxDecoration(color: maxAlertColor, shape: BoxShape.circle)),
              const SizedBox(width: 4),
              Text(maxAlertStatus, style: TextStyle(color: maxAlertColor, fontWeight: FontWeight.w800, fontSize: 10)),
            ]),
          );
        }),
      ]),
    );
  }

  Widget _nodeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(children: [
        ...List.generate(nodes.length, (i) {
          final n = nodes[i];
          final sel = _selectedNode == i;
          return Expanded(child: GestureDetector(
            onTap: () => setState(() => _selectedNode = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: EdgeInsets.only(right: i < nodes.length - 1 ? 8 : 0),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: sel ? n.alertColor.withValues(alpha: widget.isDark ? 0.15 : 0.1) : cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: sel ? n.alertColor : borderClr, width: sel ? 1.5 : 1),
              ),
              child: Row(children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: n.alertColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: n.alertColor, width: 2),
                  ),
                  child: Center(child: Text('${n.id}', style: TextStyle(color: n.alertColor, fontWeight: FontWeight.w900, fontSize: 14))),
                ),
                const SizedBox(width: 8),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(n.name, style: TextStyle(color: txt1, fontWeight: FontWeight.w700, fontSize: 11), overflow: TextOverflow.ellipsis),
                  Text('${n.waterLevel.toStringAsFixed(0)}cm • ${n.alertStatus}',
                      style: TextStyle(color: n.alertColor, fontSize: 10, fontWeight: FontWeight.w600)),
                ])),
              ]),
            ),
          ));
        }),
      ]),
    );
  }

  Widget _sensorCard(String title, double value, String unit, IconData icon, Color color, double maxVal) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: widget.isDark ? [] : [BoxShadow(color: color.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Container(padding: const EdgeInsets.all(5), decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(7)),
            child: Icon(icon, color: color, size: 15)),
          Text(value.toStringAsFixed(1), style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: color)),
        ]),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(color: txt1, fontSize: 11, fontWeight: FontWeight.w600)),
          Text(unit, style: TextStyle(color: txt2, fontSize: 9)),
        ]),
        ClipRRect(borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(value: (value / maxVal).clamp(0, 1), backgroundColor: widget.isDark ? Colors.white10 : Colors.black12,
            valueColor: AlwaysStoppedAnimation(color.withValues(alpha: 0.7)), minHeight: 3)),
      ]),
    );
  }

  Widget _dashboard() {
    final n = activeNode;
    return SingleChildScrollView(
      key: const ValueKey('dash'),
      padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Water Level Hero
        Container(
          width: double.infinity, padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [n.alertColor.withValues(alpha: widget.isDark ? 0.2 : 0.12), n.alertColor.withValues(alpha: 0.03)]),
            borderRadius: BorderRadius.circular(18), border: Border.all(color: n.alertColor.withValues(alpha: 0.3)),
          ),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(n.name, style: TextStyle(color: txt2, fontSize: 12)),
                Text(n.river, style: TextStyle(color: txt2, fontSize: 10)),
                const SizedBox(height: 4),
                Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(n.waterLevel.toStringAsFixed(1), style: TextStyle(fontSize: 38, fontWeight: FontWeight.w900, color: n.alertColor, height: 1)),
                  Padding(padding: const EdgeInsets.only(bottom: 5, left: 3),
                    child: Text('cm', style: TextStyle(fontSize: 14, color: txt2))),
                ]),
              ]),
              Container(width: 60, height: 60,
                decoration: BoxDecoration(shape: BoxShape.circle, color: n.alertColor.withValues(alpha: 0.15), border: Border.all(color: n.alertColor, width: 2.5)),
                child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text('L${n.alertLevel}', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: n.alertColor)),
                  Text(n.alertStatus, style: TextStyle(fontSize: 6.5, fontWeight: FontWeight.w700, color: n.alertColor)),
                ])),
              ),
            ]),
            const SizedBox(height: 12),
            ClipRRect(borderRadius: BorderRadius.circular(5),
              child: LinearProgressIndicator(value: (n.waterLevel / 500).clamp(0, 1), backgroundColor: widget.isDark ? Colors.white10 : Colors.black12,
                valueColor: AlwaysStoppedAnimation(n.alertColor), minHeight: 7)),
            const SizedBox(height: 5),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('0', style: TextStyle(fontSize: 8, color: txt2)),
              const Text('150', style: TextStyle(fontSize: 8, color: Color(0xFFeab308))),
              const Text('300', style: TextStyle(fontSize: 8, color: Color(0xFFf59e0b))),
              const Text('380', style: TextStyle(fontSize: 8, color: Color(0xFFef4444))),
              Text('500', style: TextStyle(fontSize: 8, color: txt2)),
            ]),
          ]),
        ),
        const SizedBox(height: 10),

        // Stats Row
        Row(children: [
          _chip(Icons.cell_tower, '${nodes.length} Nodes', const Color(0xFF06b6d4)),
          const SizedBox(width: 6),
          _chip(Icons.battery_charging_full, '${n.battery}%', const Color(0xFF10b981)),
          const SizedBox(width: 6),
          _chip(Icons.location_on, n.location, const Color(0xFF8b5cf6)),
        ]),
        const SizedBox(height: 12),

        // Sensor Grid
        Text('Sensor Readings — ${n.name}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: txt1)),
        const SizedBox(height: 8),
        GridView.count(crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 1.4, children: [
          _sensorCard('Temperature', n.temperature, 'Celsius', Icons.thermostat, const Color(0xFFf97316), 50),
          _sensorCard('Humidity', n.humidity, '% RH', Icons.water_drop, const Color(0xFF06b6d4), 100),
          _sensorCard('Soil Moisture', n.soilMoisture, '% sat', Icons.grass, const Color(0xFF84cc16), 100),
          _sensorCard('Rainfall', n.rainfall, 'mm/hr', Icons.umbrella, const Color(0xFF8b5cf6), 80),
          _sensorCard('Pressure', n.pressure, 'hPa', Icons.speed, const Color(0xFF14b8a6), 1050),
          _floodSimBtn(),
        ]),
        const SizedBox(height: 12),

        // Mini Prediction
        Container(padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: borderClr)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.auto_graph, color: Color(0xFF8b5cf6), size: 16),
              const SizedBox(width: 6),
              Text('72-Hour Forecast — ${n.name}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: txt1)),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              _predChip('24h', '${n.pred24h.toStringAsFixed(0)}cm', const Color(0xFF10b981)),
              const SizedBox(width: 6),
              _predChip('48h', '${n.pred48h.toStringAsFixed(0)}cm', const Color(0xFFf59e0b)),
              const SizedBox(width: 6),
              _predChip('72h', '${n.pred72h.toStringAsFixed(0)}cm', const Color(0xFFef4444)),
            ]),
          ]),
        ),

        // Node Comparison
        const SizedBox(height: 12),
        Container(padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: borderClr)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.compare_arrows, color: Color(0xFF06b6d4), size: 16),
              const SizedBox(width: 6),
              Text('Node Comparison', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: txt1)),
            ]),
            const SizedBox(height: 10),
            ...nodes.map((nd) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(children: [
                Container(width: 24, height: 24, decoration: BoxDecoration(shape: BoxShape.circle, color: nd.alertColor.withValues(alpha: 0.15),
                  border: Border.all(color: nd.alertColor, width: 1.5)),
                  child: Center(child: Text('${nd.id}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: nd.alertColor)))),
                const SizedBox(width: 8),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(nd.name, style: TextStyle(fontSize: 11, color: txt1, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 3),
                  ClipRRect(borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(value: (nd.waterLevel / 500).clamp(0, 1),
                      backgroundColor: widget.isDark ? Colors.white10 : Colors.black12,
                      valueColor: AlwaysStoppedAnimation(nd.alertColor), minHeight: 5)),
                ])),
                const SizedBox(width: 8),
                Text('${nd.waterLevel.toStringAsFixed(0)}cm', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: nd.alertColor)),
              ]),
            )),
          ]),
        ),
      ]),
    );
  }

  Widget _floodSimBtn() {
    return GestureDetector(
      onTap: () => _simulateFlood(_selectedNode),
      child: Container(padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFFef4444), Color(0xFFf97316)]),
          borderRadius: BorderRadius.circular(14)),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.flood, color: Colors.white, size: 26),
          const SizedBox(height: 6),
          const Text('Simulate', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
          Text('Flood N${activeNode.id}', style: const TextStyle(color: Colors.white70, fontSize: 10)),
        ]),
      ),
    );
  }

  Widget _chip(IconData icon, String text, Color color) {
    return Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(color: color.withValues(alpha: widget.isDark ? 0.08 : 0.06),
        borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withValues(alpha: 0.2))),
      child: Column(children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(height: 3),
        Text(text, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w700), textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
      ]),
    ));
  }

  Widget _predChip(String label, String value, Color color) {
    return Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(color: color.withValues(alpha: widget.isDark ? 0.1 : 0.06),
        borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withValues(alpha: 0.25))),
      child: Column(children: [
        Text(label, style: TextStyle(color: txt2, fontSize: 10)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.w900)),
      ]),
    ));
  }

  Widget _alerts() {
    List<Map<String, dynamic>> allAlerts = [];
    for (var n in nodes) {
      if (n.alertLevel >= 2) {
        allAlerts.add({'node': n.name, 'level': n.alertStatus, 'msg': 'Water level: ${n.waterLevel.toStringAsFixed(1)}cm', 'color': n.alertColor, 'icon': Icons.water, 'time': 'Live'});
      }
    }
    allAlerts.addAll([
      {'node': 'Node 1', 'level': 'WARNING', 'msg': 'Water level crossed 200cm', 'color': const Color(0xFFf59e0b), 'icon': Icons.water, 'time': '10:30 AM'},
      {'node': 'Node 2', 'level': 'WATCH', 'msg': 'Heavy rainfall detected - 25mm/hr', 'color': const Color(0xFFeab308), 'icon': Icons.umbrella, 'time': '09:15 AM'},
      {'node': 'System', 'level': 'SAFE', 'msg': 'All sensors operating normally', 'color': const Color(0xFF10b981), 'icon': Icons.check_circle, 'time': '08:00 AM'},
      {'node': 'Node 1', 'level': 'EMERGENCY', 'msg': 'Water level reached 350cm', 'color': const Color(0xFFef4444), 'icon': Icons.dangerous, 'time': 'Yesterday'},
      {'node': 'Node 2', 'level': 'WARNING', 'msg': 'Soil saturation above 90%', 'color': const Color(0xFFf59e0b), 'icon': Icons.grass, 'time': 'Yesterday'},
    ]);

    return ListView(key: const ValueKey('alerts'), padding: const EdgeInsets.all(12), children: [
      Text('Alert History — All Nodes', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: txt1)),
      const SizedBox(height: 10),
      ...allAlerts.map((a) => Container(
        margin: const EdgeInsets.only(bottom: 6), padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(12),
          border: Border.all(color: (a['color'] as Color).withValues(alpha: 0.25))),
        child: Row(children: [
          Container(padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(color: (a['color'] as Color).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(9)),
            child: Icon(a['icon'] as IconData, color: a['color'] as Color, size: 18)),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Row(children: [
                Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: (a['color'] as Color).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                  child: Text(a['level'] as String, style: TextStyle(color: a['color'] as Color, fontWeight: FontWeight.w800, fontSize: 9))),
                const SizedBox(width: 6),
                Text(a['node'] as String, style: TextStyle(color: txt2, fontSize: 10)),
              ]),
              Text(a['time'] as String, style: TextStyle(color: txt2, fontSize: 9)),
            ]),
            const SizedBox(height: 4),
            Text(a['msg'] as String, style: TextStyle(color: txt1, fontSize: 11)),
          ])),
        ]),
      )),
    ]);
  }

  Widget _prediction() {
    return SingleChildScrollView(key: const ValueKey('pred'), padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF8b5cf6), Color(0xFFec4899)]),
              borderRadius: BorderRadius.circular(9)),
            child: const Icon(Icons.psychology, color: Colors.white, size: 18)),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('AI Flood Prediction', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: txt1)),
            Text('LSTM + Attention | RMSE: 8.34cm', style: TextStyle(fontSize: 10, color: txt2)),
          ]),
        ]),
        const SizedBox(height: 14),

        ...nodes.map((n) => Container(
          margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: borderClr)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(width: 26, height: 26,
                decoration: BoxDecoration(shape: BoxShape.circle, color: n.alertColor.withValues(alpha: 0.15),
                  border: Border.all(color: n.alertColor, width: 1.5)),
                child: Center(child: Text('${n.id}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: n.alertColor)))),
              const SizedBox(width: 8),
              Text(n.name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: txt1)),
              const Spacer(),
              Text('Now: ${n.waterLevel.toStringAsFixed(0)}cm', style: TextStyle(fontSize: 11, color: n.alertColor, fontWeight: FontWeight.w700)),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              _predCard('24h', n.pred24h, const Color(0xFF10b981), '95%'),
              const SizedBox(width: 6),
              _predCard('48h', n.pred48h, const Color(0xFFf59e0b), '88%'),
              const SizedBox(width: 6),
              _predCard('72h', n.pred72h, const Color(0xFFef4444), '79%'),
            ]),
          ]),
        )),

        Container(padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [const Color(0xFFef4444).withValues(alpha: widget.isDark ? 0.12 : 0.06), const Color(0xFFef4444).withValues(alpha: 0.02)]),
            borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFef4444).withValues(alpha: 0.3))),
          child: Row(children: [
            const Icon(Icons.warning_amber, color: Color(0xFFef4444), size: 22),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('AI Advisory', style: TextStyle(color: const Color(0xFFef4444), fontWeight: FontWeight.w700, fontSize: 12)),
              Text('Monitor both nodes closely. Upstream rise will impact downstream in 6-12 hours.',
                style: TextStyle(color: txt1, fontSize: 10)),
            ])),
          ]),
        ),
      ]),
    );
  }

  Widget _predCard(String label, double value, Color color, String conf) {
    return Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(color: color.withValues(alpha: widget.isDark ? 0.1 : 0.06),
        borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withValues(alpha: 0.25))),
      child: Column(children: [
        Text(label, style: TextStyle(color: txt2, fontSize: 10)),
        Text('${value.toStringAsFixed(0)}cm', style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w900)),
        Text(conf, style: TextStyle(color: txt2, fontSize: 9)),
      ]),
    ));
  }

  Widget _settings() {
    return ListView(key: const ValueKey('settings'), padding: const EdgeInsets.all(12), children: [
      Text('Settings', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: txt1)),
      const SizedBox(height: 12),
      _sGroup('Node Configuration', [
        ...nodes.map((n) => _sTile(n.name, '${n.river} • ${n.location}', Icons.cell_tower, n.alertColor)),
      ]),
      const SizedBox(height: 10),
      _sGroup('Alerts', [
        _sTile('Alert Level', 'All alerts enabled', Icons.notifications, const Color(0xFFf59e0b)),
        _sTile('Emergency', 'NDRF: 9711077372', Icons.phone, const Color(0xFFef4444)),
        _sTile('SMS Alerts', 'SIM800L GSM Module', Icons.sms, const Color(0xFF10b981)),
      ]),
      const SizedBox(height: 10),
      _sGroup('App', [
        _sTile('Theme', widget.isDark ? 'Dark Mode' : 'Light Mode', Icons.palette, const Color(0xFF8b5cf6)),
        _sTile('Language', 'English / Hindi', Icons.language, const Color(0xFF06b6d4)),
        _sTile('Auto Refresh', 'Every 5 seconds', Icons.refresh, const Color(0xFF14b8a6)),
      ]),
      const SizedBox(height: 10),
      _sGroup('AI Model', [
        _sTile('Architecture', 'LSTM + Attention (84K params)', Icons.psychology, const Color(0xFFec4899)),
        _sTile('24h RMSE', '8.34 cm — EXCELLENT', Icons.analytics, const Color(0xFF10b981)),
        _sTile('Training', '43,800 points • 19 epochs • T4 GPU', Icons.storage, const Color(0xFFf97316)),
      ]),
      const SizedBox(height: 16),
      Center(child: Column(children: [
        Text('Flood Prediction System v3.0', style: TextStyle(color: txt2, fontWeight: FontWeight.w600)),
        Text('Ayush Deep | GEC Vaishali', style: TextStyle(color: txt2, fontSize: 11)),
        Text('B.Tech CSE (IoT) | 2022-2026', style: TextStyle(color: txt2, fontSize: 10)),
        Text('Guide: Asst. Prof. Aparna Kamal', style: TextStyle(color: txt2, fontSize: 10)),
      ])),
    ]);
  }

  Widget _sGroup(String title, List<Widget> tiles) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: txt2)),
      const SizedBox(height: 6),
      Container(decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: borderClr)),
        child: Column(children: tiles)),
    ]);
  }

  Widget _sTile(String title, String sub, IconData icon, Color color) {
    return Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(7)),
          child: Icon(icon, color: color, size: 16)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(color: txt1, fontWeight: FontWeight.w600, fontSize: 12)),
          Text(sub, style: TextStyle(color: txt2, fontSize: 10)),
        ])),
        Icon(Icons.chevron_right, color: txt2, size: 16),
      ]),
    );
  }

  Widget _bottomNav() {
    return Container(
      decoration: BoxDecoration(color: cardBg, border: Border(top: BorderSide(color: borderClr, width: 0.5))),
      child: BottomNavigationBar(currentIndex: _currentIndex, onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed, backgroundColor: Colors.transparent, elevation: 0,
        selectedItemColor: const Color(0xFF06b6d4), unselectedItemColor: txt2, selectedFontSize: 10, unselectedFontSize: 10,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.warning_amber_rounded), label: 'Alerts'),
          BottomNavigationBarItem(icon: Icon(Icons.auto_graph_rounded), label: 'Predict'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: 'Settings'),
        ]),
    );
  }

  Widget _sosBtn() {
    return Container(
      decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: const Color(0xFFef4444).withValues(alpha: 0.4), blurRadius: 12, spreadRadius: 2)]),
      child: FloatingActionButton(onPressed: () {
        showDialog(context: context, builder: (ctx) => AlertDialog(
          backgroundColor: cardBg, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Row(children: [const Icon(Icons.emergency, color: Color(0xFFef4444), size: 26), const SizedBox(width: 8),
            Text('Emergency SOS', style: TextStyle(color: txt1, fontWeight: FontWeight.w800))]),
          content: Text('Alert NDRF + district authorities with location and current sensor data from all ${nodes.length} nodes.',
            style: TextStyle(color: txt2)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: TextStyle(color: txt2))),
            ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFef4444)),
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('SOS Sent! NDRF + authorities notified.'), backgroundColor: Color(0xFFef4444)));
              },
              child: const Text('SEND SOS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800))),
          ],
        ));
      }, backgroundColor: const Color(0xFFef4444),
        child: const Icon(Icons.emergency, color: Colors.white, size: 24)),
    );
  }
}