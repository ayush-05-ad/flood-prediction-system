import 'package:flutter/material.dart';
import 'dart:math';

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
      theme: isDark ? _darkTheme() : _lightTheme(),
      home: HomePage(isDark: isDark, toggleTheme: toggleTheme),
    );
  }

  ThemeData _darkTheme() => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF080d1c),
    colorScheme: const ColorScheme.dark(
      surface: Color(0xFF080d1c),
      primary: Color(0xFF06b6d4),
      secondary: Color(0xFF8b5cf6),
    ),
    useMaterial3: true,
  );

  ThemeData _lightTheme() => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF0F4F8),
    colorScheme: const ColorScheme.light(
      surface: Color(0xFFF0F4F8),
      primary: Color(0xFF0284c7),
      secondary: Color(0xFF7c3aed),
    ),
    useMaterial3: true,
  );
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
  late AnimationController _pulseController;
  final Random _random = Random();

  double waterLevel = 185.5;
  double temperature = 32.4;
  double humidity = 78.0;
  double soilMoisture = 65.0;
  double rainfall = 12.5;
  double pressure = 1008.3;
  String lastUpdate = 'Just now';
  int nodeCount = 4;
  int activeAlerts = 2;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void simulateData() {
    setState(() {
      waterLevel = 50 + _random.nextDouble() * 400;
      temperature = 20 + _random.nextDouble() * 25;
      humidity = 30 + _random.nextDouble() * 70;
      soilMoisture = 10 + _random.nextDouble() * 90;
      rainfall = _random.nextDouble() * 50;
      pressure = 990 + _random.nextDouble() * 30;
      lastUpdate = 'Just now';
      activeAlerts = waterLevel > 200 ? (waterLevel > 300 ? 3 : 2) : 0;
    });
  }

  String getAlertStatus() {
    if (waterLevel > 380) return 'EVACUATE';
    if (waterLevel > 300) return 'EMERGENCY';
    if (waterLevel > 200) return 'WARNING';
    if (waterLevel > 150) return 'WATCH';
    return 'SAFE';
  }

  int getAlertLevel() {
    if (waterLevel > 380) return 4;
    if (waterLevel > 300) return 3;
    if (waterLevel > 200) return 2;
    if (waterLevel > 150) return 1;
    return 0;
  }

  Color getAlertColor() {
    if (waterLevel > 380) return const Color(0xFFb71c1c);
    if (waterLevel > 300) return const Color(0xFFef4444);
    if (waterLevel > 200) return const Color(0xFFf59e0b);
    if (waterLevel > 150) return const Color(0xFFeab308);
    return const Color(0xFF10b981);
  }

  Color get cardBg => widget.isDark ? const Color(0xFF101829) : Colors.white;
  Color get borderColor => widget.isDark ? const Color(0xFF1e293b) : const Color(0xFFe2e8f0);
  Color get textPrimary => widget.isDark ? Colors.white : const Color(0xFF1e293b);
  Color get textSecondary => widget.isDark ? const Color(0xFF94a3b8) : const Color(0xFF64748b);
  Color get subtleBg => widget.isDark ? const Color(0xFF0f172a) : const Color(0xFFf8fafc);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _currentIndex == 0 ? _buildDashboard() :
                       _currentIndex == 1 ? _buildAlerts() :
                       _currentIndex == 2 ? _buildPrediction() :
                       _buildSettings(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: _buildSOSButton(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: cardBg,
        border: Border(bottom: BorderSide(color: borderColor, width: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF06b6d4), Color(0xFF3b82f6)]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.water, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Flood Prediction', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: textPrimary)),
                Text('Kosi River Basin', style: TextStyle(fontSize: 11, color: textSecondary)),
              ],
            ),
          ),
          IconButton(
            onPressed: widget.toggleTheme,
            icon: Icon(widget.isDark ? Icons.light_mode : Icons.dark_mode, color: const Color(0xFFf59e0b), size: 22),
          ),
          const SizedBox(width: 4),
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: getAlertColor().withValues(alpha: 0.1 + _pulseController.value * 0.15),
                  border: Border.all(color: getAlertColor()),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7, height: 7,
                      decoration: BoxDecoration(color: getAlertColor(), shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 5),
                    Text(getAlertStatus(),
                      style: TextStyle(color: getAlertColor(), fontWeight: FontWeight.w800, fontSize: 11)),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      key: const ValueKey('dashboard'),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWaterLevelHero(),
          const SizedBox(height: 14),
          _buildStatsRow(),
          const SizedBox(height: 14),
          Text('Sensor Readings', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: textPrimary)),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.35,
            children: [
              _sensorCard('Temperature', temperature, 'Celsius', Icons.thermostat, const Color(0xFFf97316), 50),
              _sensorCard('Humidity', humidity, '% RH', Icons.water_drop, const Color(0xFF06b6d4), 100),
              _sensorCard('Soil Moisture', soilMoisture, '% sat', Icons.grass, const Color(0xFF84cc16), 100),
              _sensorCard('Rainfall', rainfall, 'mm/hr', Icons.umbrella, const Color(0xFF8b5cf6), 80),
              _sensorCard('Pressure', pressure, 'hPa', Icons.speed, const Color(0xFF14b8a6), 1050),
              _buildQuickAction(),
            ],
          ),
          const SizedBox(height: 14),
          _buildMiniPrediction(),
        ],
      ),
    );
  }

  Widget _buildWaterLevelHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            getAlertColor().withValues(alpha: widget.isDark ? 0.2 : 0.12),
            getAlertColor().withValues(alpha: widget.isDark ? 0.05 : 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: getAlertColor().withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Water Level', style: TextStyle(color: textSecondary, fontSize: 13)),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(waterLevel.toStringAsFixed(1),
                        style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: getAlertColor(), height: 1)),
                      const SizedBox(width: 4),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text('cm', style: TextStyle(fontSize: 16, color: textSecondary)),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                width: 70, height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: getAlertColor().withValues(alpha: 0.15),
                  border: Border.all(color: getAlertColor(), width: 3),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('L${getAlertLevel()}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: getAlertColor())),
                      Text(getAlertStatus(), style: TextStyle(fontSize: 7, fontWeight: FontWeight.w700, color: getAlertColor())),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (waterLevel / 500).clamp(0, 1),
              backgroundColor: widget.isDark ? Colors.white10 : Colors.black12,
              valueColor: AlwaysStoppedAnimation(getAlertColor()),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0 cm', style: TextStyle(fontSize: 9, color: textSecondary)),
              Text('150 Watch', style: const TextStyle(fontSize: 9, color: Color(0xFFeab308))),
              Text('300 Warn', style: const TextStyle(fontSize: 9, color: Color(0xFFf59e0b))),
              Text('380 Emerg', style: const TextStyle(fontSize: 9, color: Color(0xFFef4444))),
              Text('500 cm', style: TextStyle(fontSize: 9, color: textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _statChip(Icons.cell_tower, '$nodeCount Nodes', const Color(0xFF06b6d4)),
        const SizedBox(width: 8),
        _statChip(Icons.warning_amber, '$activeAlerts Alerts', activeAlerts > 0 ? const Color(0xFFf59e0b) : const Color(0xFF10b981)),
        const SizedBox(width: 8),
        _statChip(Icons.access_time, lastUpdate, const Color(0xFF8b5cf6)),
        const SizedBox(width: 8),
        _statChip(Icons.battery_charging_full, '87%', const Color(0xFF10b981)),
      ],
    );
  }

  Widget _statChip(IconData icon, String text, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: widget.isDark ? 0.08 : 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 4),
            Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _sensorCard(String title, double value, String unit, IconData icon, Color color, double maxVal) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: widget.isDark ? [] : [BoxShadow(color: color.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: color, size: 16),
              ),
              Text(value.toStringAsFixed(1),
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: textPrimary, fontSize: 12, fontWeight: FontWeight.w600)),
              Text(unit, style: TextStyle(color: textSecondary, fontSize: 10)),
            ],
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: (value / maxVal).clamp(0, 1),
              backgroundColor: widget.isDark ? Colors.white10 : Colors.black12,
              valueColor: AlwaysStoppedAnimation(color.withValues(alpha: 0.7)),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction() {
    return GestureDetector(
      onTap: simulateData,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF06b6d4), Color(0xFF3b82f6)],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.refresh, color: Colors.white, size: 28),
            SizedBox(height: 8),
            Text('Simulate', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
            Text('New Data', style: TextStyle(color: Colors.white70, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniPrediction() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_graph, color: Color(0xFF8b5cf6), size: 18),
              const SizedBox(width: 8),
              Text('72-Hour Forecast', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: textPrimary)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _miniPredChip('24h', '${(waterLevel * 1.05).toStringAsFixed(0)}cm', const Color(0xFF10b981)),
              const SizedBox(width: 8),
              _miniPredChip('48h', '${(waterLevel * 1.12).toStringAsFixed(0)}cm', const Color(0xFFf59e0b)),
              const SizedBox(width: 8),
              _miniPredChip('72h', '${(waterLevel * 1.2).toStringAsFixed(0)}cm', const Color(0xFFef4444)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniPredChip(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: widget.isDark ? 0.1 : 0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            Text(label, style: TextStyle(color: textSecondary, fontSize: 11)),
            const SizedBox(height: 2),
            Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }

  Widget _buildAlerts() {
    final alerts = [
      {'time': '10:30 AM', 'level': 'WARNING', 'msg': 'Water level crossed 200cm at Node 1', 'color': const Color(0xFFf59e0b), 'icon': Icons.water},
      {'time': '09:15 AM', 'level': 'WATCH', 'msg': 'Heavy rainfall detected - 25mm/hr', 'color': const Color(0xFFeab308), 'icon': Icons.umbrella},
      {'time': '08:00 AM', 'level': 'SAFE', 'msg': 'All 4 sensors operating normally', 'color': const Color(0xFF10b981), 'icon': Icons.check_circle},
      {'time': 'Yesterday', 'level': 'EMERGENCY', 'msg': 'Water level reached 350cm at Node 2', 'color': const Color(0xFFef4444), 'icon': Icons.dangerous},
      {'time': 'Yesterday', 'level': 'WARNING', 'msg': 'Soil moisture above 90% - flood risk high', 'color': const Color(0xFFf59e0b), 'icon': Icons.grass},
      {'time': '2 days ago', 'level': 'WATCH', 'msg': 'Pressure dropping rapidly - storm approaching', 'color': const Color(0xFFeab308), 'icon': Icons.speed},
      {'time': '3 days ago', 'level': 'SAFE', 'msg': 'System restarted after maintenance', 'color': const Color(0xFF10b981), 'icon': Icons.restart_alt},
    ];

    return ListView(
      key: const ValueKey('alerts'),
      padding: const EdgeInsets.all(14),
      children: [
        Text('Alert History', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textPrimary)),
        const SizedBox(height: 12),
        ...alerts.map((a) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: (a['color'] as Color).withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (a['color'] as Color).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(a['icon'] as IconData, color: a['color'] as Color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: (a['color'] as Color).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(a['level'] as String,
                              style: TextStyle(color: a['color'] as Color, fontWeight: FontWeight.w800, fontSize: 10)),
                        ),
                        Text(a['time'] as String, style: TextStyle(color: textSecondary, fontSize: 10)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(a['msg'] as String, style: TextStyle(color: textPrimary, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildPrediction() {
    final preds = [
      {'hours': '24-Hour', 'level': (waterLevel * 1.05).toStringAsFixed(1), 'trend': 'Rising', 'color': const Color(0xFF10b981), 'conf': '95%', 'icon': Icons.trending_up},
      {'hours': '48-Hour', 'level': (waterLevel * 1.12).toStringAsFixed(1), 'trend': 'Rising Fast', 'color': const Color(0xFFf59e0b), 'conf': '88%', 'icon': Icons.trending_up},
      {'hours': '72-Hour', 'level': (waterLevel * 1.2).toStringAsFixed(1), 'trend': 'Critical', 'color': const Color(0xFFef4444), 'conf': '79%', 'icon': Icons.warning},
    ];

    return SingleChildScrollView(
      key: const ValueKey('prediction'),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF8b5cf6), Color(0xFFec4899)]),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.psychology, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('AI Flood Prediction', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textPrimary)),
                  Text('LSTM + Attention Model | RMSE: 8.34cm', style: TextStyle(fontSize: 11, color: textSecondary)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          ...preds.map((p) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: (p['color'] as Color).withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (p['color'] as Color).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(p['icon'] as IconData, color: p['color'] as Color, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p['hours'] as String, style: TextStyle(color: textSecondary, fontSize: 12)),
                      const SizedBox(height: 2),
                      Text('${p['level']} cm',
                          style: TextStyle(color: p['color'] as Color, fontSize: 28, fontWeight: FontWeight.w900)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: (p['color'] as Color).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(p['trend'] as String,
                          style: TextStyle(color: p['color'] as Color, fontSize: 10, fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(height: 6),
                    Text('Confidence: ${p['conf']}', style: TextStyle(color: textSecondary, fontSize: 10)),
                  ],
                ),
              ],
            ),
          )),

          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFef4444).withValues(alpha: widget.isDark ? 0.15 : 0.08),
                  const Color(0xFFef4444).withValues(alpha: widget.isDark ? 0.05 : 0.02),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFef4444).withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFef4444).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.warning_amber, color: Color(0xFFef4444), size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('AI Advisory', style: TextStyle(color: const Color(0xFFef4444), fontWeight: FontWeight.w700, fontSize: 13)),
                      const SizedBox(height: 2),
                      Text('Water level predicted to cross danger mark within 48 hours. Prepare for possible evacuation.',
                          style: TextStyle(color: textPrimary, fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettings() {
    return ListView(
      key: const ValueKey('settings'),
      padding: const EdgeInsets.all(14),
      children: [
        Text('Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: textPrimary)),
        const SizedBox(height: 14),
        _settingsGroup('Station Configuration', [
          _settingsTile('Station Name', 'Kosi River - Node 1', Icons.location_on, const Color(0xFF06b6d4)),
          _settingsTile('Node Count', '4 Active Nodes', Icons.cell_tower, const Color(0xFF10b981)),
          _settingsTile('GPS Location', '26.1196 N, 86.0046 E', Icons.map, const Color(0xFF8b5cf6)),
        ]),
        const SizedBox(height: 14),
        _settingsGroup('Alerts & Notifications', [
          _settingsTile('Alert Level', 'All alerts enabled', Icons.notifications, const Color(0xFFf59e0b)),
          _settingsTile('Emergency Contact', 'NDRF: 9711077372', Icons.phone, const Color(0xFFef4444)),
          _settingsTile('SMS Alerts', 'Enabled via SIM800L', Icons.sms, const Color(0xFF10b981)),
        ]),
        const SizedBox(height: 14),
        _settingsGroup('App Preferences', [
          _settingsTile('Theme', widget.isDark ? 'Dark Mode' : 'Light Mode', Icons.palette, const Color(0xFF8b5cf6)),
          _settingsTile('Language', 'English / Hindi', Icons.language, const Color(0xFF06b6d4)),
          _settingsTile('Data Refresh', 'Every 30 seconds', Icons.refresh, const Color(0xFF14b8a6)),
        ]),
        const SizedBox(height: 14),
        _settingsGroup('AI Model Info', [
          _settingsTile('Model', 'LSTM + Attention', Icons.psychology, const Color(0xFFec4899)),
          _settingsTile('Accuracy', 'RMSE 8.34cm (24h)', Icons.analytics, const Color(0xFF10b981)),
          _settingsTile('Training Data', 'CWC 5 Years (43,800 pts)', Icons.storage, const Color(0xFFf97316)),
        ]),
        const SizedBox(height: 20),
        Center(
          child: Column(
            children: [
              Text('Flood Prediction System v3.0', style: TextStyle(color: textSecondary, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text('Ayush Deep | GEC Vaishali', style: TextStyle(color: textSecondary, fontSize: 12)),
              Text('B.Tech CSE (IoT) | Batch 2022-2026', style: TextStyle(color: textSecondary, fontSize: 11)),
              const SizedBox(height: 4),
              Text('Guide: Asst. Prof. Aparna Kamal', style: TextStyle(color: textSecondary, fontSize: 11)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _settingsGroup(String title, List<Widget> tiles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textSecondary)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor),
          ),
          child: Column(children: tiles),
        ),
      ],
    );
  }

  Widget _settingsTile(String title, String subtitle, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
                Text(subtitle, style: TextStyle(color: textSecondary, fontSize: 11)),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: textSecondary, size: 18),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        border: Border(top: BorderSide(color: borderColor, width: 0.5)),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: const Color(0xFF06b6d4),
        unselectedItemColor: textSecondary,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.warning_amber_rounded), label: 'Alerts'),
          BottomNavigationBarItem(icon: Icon(Icons.auto_graph_rounded), label: 'Predict'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: 'Settings'),
        ],
      ),
    );
  }

  Widget _buildSOSButton() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: const Color(0xFFef4444).withValues(alpha: 0.4), blurRadius: 12, spreadRadius: 2)],
      ),
      child: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: cardBg,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  const Icon(Icons.emergency, color: Color(0xFFef4444), size: 28),
                  const SizedBox(width: 10),
                  Text('Emergency SOS', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w800)),
                ],
              ),
              content: Text('This will alert NDRF, district authorities, and your emergency contacts with your location.',
                  style: TextStyle(color: textSecondary)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text('Cancel', style: TextStyle(color: textSecondary)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFef4444)),
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('SOS Alert Sent! Authorities notified.'),
                        backgroundColor: Color(0xFFef4444),
                      ),
                    );
                  },
                  child: const Text('SEND SOS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                ),
              ],
            ),
          );
        },
        backgroundColor: const Color(0xFFef4444),
        child: const Icon(Icons.emergency, color: Colors.white, size: 26),
      ),
    );
  }
}