import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(
    MaterialApp(
      home: CombinedTankApp(),
      theme: ThemeData.light(),
      debugShowCheckedModeBanner: false,
    ),
  );
}

class CombinedTankApp extends StatefulWidget {
  @override
  State<CombinedTankApp> createState() => _CombinedTankAppState();
}

class _CombinedTankAppState extends State<CombinedTankApp> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Расчёты по ёмкостям'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.opacity), text: '323 и 321'),
            Tab(icon: Icon(Icons.local_drink), text: '315 и 324'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          TankForm323321(),
          TankForm315324(),
        ],
      ),
    );
  }
}

class TankForm323321 extends StatefulWidget {
  @override
  _TankForm323321State createState() => _TankForm323321State();
}

class _TankForm323321State extends State<TankForm323321> {
  final level323 = TextEditingController();
  final level321 = TextEditingController();
  final flowRate = TextEditingController();
  String result = '';

  final minLevel323 = 30.0;
  final maxLevel321 = 634.0;
  final proportionIncrease323 = 35.0;
  final proportionVolume321 = 340.0;

  double _target321 = 160;
  final TextEditingController _customTarget321 = TextEditingController();
  String _targetOption = '160';

  void calculate() {
    final l323 = double.tryParse(level323.text) ?? 0;
    final l321 = double.tryParse(level321.text) ?? 0;
    final rate = double.tryParse(flowRate.text) ?? 1;

    final timeToMin = (l323 - minLevel323) / rate;
    final pumpVolume = l321 - _target321;
    final increase = (proportionIncrease323 / proportionVolume321) * pumpVolume;
    final newLevel = l323 + increase;
    final totalTime = (newLevel - minLevel323) / rate;
    final nextPumping =
        DateTime.now().add(Duration(minutes: (totalTime * 60).round()));

    final fullPump = maxLevel321 - _target321;
    final fullLevel = l323 + (proportionIncrease323 / proportionVolume321) * fullPump;
    final fullTime = (fullLevel - minLevel323) / rate;
    final endTime = nextPumping.add(Duration(minutes: (fullTime * 60).round()));

    setState(() {
      result =
          'Целевой уровень в 321: ${_target321.toStringAsFixed(0)} мм\n'
          'Объём перекачки: ${pumpVolume.toStringAsFixed(0)} мм\n'
          'Без перекачки: ${timeToMin.toStringAsFixed(2)} ч\n'
          'После текущей перекачки: ${totalTime.toStringAsFixed(2)} ч\n'
          'Новый уровень: ${newLevel.toStringAsFixed(2)}%\n'
          'Раствора хватит после перекачки до: ${DateFormat('yyyy-MM-dd HH:mm').format(nextPumping)}\n\n'
          'После полной дозаправки: ${fullLevel.toStringAsFixed(2)}%\n'
          'Время работы после неё: ${fullTime.toStringAsFixed(2)} ч\n'
          'Раствора хватит до: ${DateFormat('yyyy-MM-dd HH:mm').format(endTime)}';
    });
  }

  @override
  Widget build(BuildContext context) => buildForm(
        'Уровень в 323 (%)',
        level323,
        'Уровень в 321 (мм)',
        level321,
        'Расход 323 (%/ч)',
        flowRate,
        calculate,
        result,
        Colors.teal[100]!,
        extra: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButton<String>(
              value: _targetOption,
              items: const [
                DropdownMenuItem(value: '160', child: Text('160')),
                DropdownMenuItem(value: '0', child: Text('0')),
                DropdownMenuItem(value: 'custom', child: Text('custom')),
              ],
              onChanged: (value) {
                setState(() {
                  _targetOption = value!;
                  if (_targetOption == '160') {
                    _target321 = 160;
                  } else if (_targetOption == '0') {
                    _target321 = 0;
                  } else {
                    _target321 =
                        double.tryParse(_customTarget321.text) ?? _target321;
                  }
                });
              },
            ),
            if (_targetOption == 'custom')
              TextField(
                controller: _customTarget321,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: 'Целевой уровень 321 (мм)'),
                onChanged: (value) {
                  setState(() {
                    _target321 = double.tryParse(value) ?? _target321;
                  });
                },
              ),
          ],
        ),
      );
}

class TankForm315324 extends StatefulWidget {
  @override
  _TankForm315324State createState() => _TankForm315324State();
}

class _TankForm315324State extends State<TankForm315324> {
  final TextEditingController _level315 = TextEditingController();
  final TextEditingController _level324 = TextEditingController();
  final TextEditingController _consumptionRate = TextEditingController();
  String _result = '';

  void _calculate() {
    double level315 = double.tryParse(_level315.text) ?? 0;
    double level324 = double.tryParse(_level324.text) ?? 0;
    double rate = double.tryParse(_consumptionRate.text) ?? 1;

    double transferredHeight = 20.0;
    double conversionFactor = 26.0;
    double controlLevel324 = 350.0;
    double fullSolutionHeight = 380.0;

    double volumeToTransfer =
        (level315 - 260) / transferredHeight * conversionFactor;
    double excess = level324 - controlLevel324;
    double totalVolume = volumeToTransfer + excess;
    double timeToConsume = totalVolume / rate;
    DateTime now = DateTime.now();
    DateTime endTime =
        now.add(Duration(minutes: (timeToConsume * 60).round()));

    double fullTransfer =
        (fullSolutionHeight / transferredHeight) * conversionFactor;
    double totalWithFull = fullTransfer + excess;
    double fullTimeToConsume = totalWithFull / rate;
    DateTime fullEndTime =
        endTime.add(Duration(minutes: (fullTimeToConsume * 60).round()));

    setState(() {
      _result =
          'Перекачка из 315: ${volumeToTransfer.toStringAsFixed(1)} мм\n'
          'Избыток в 324: ${excess.toStringAsFixed(1)} мм\n'
          'Общий объём: ${totalVolume.toStringAsFixed(1)} мм\n'
          'Хватит на: ${timeToConsume.toStringAsFixed(2)} ч\n'
          'Раствора хватит до: ${DateFormat('yyyy-MM-dd HH:mm').format(endTime)}\n\n'
          'Полная дозаправка (380 мм в 315): ${fullTransfer.toStringAsFixed(1)} мм\n'
          'Общий объём: ${totalWithFull.toStringAsFixed(1)} мм\n'
          'Хватит на: ${fullTimeToConsume.toStringAsFixed(2)} ч\n'
          'Раствора хватит до: ${DateFormat('yyyy-MM-dd HH:mm').format(fullEndTime)}';
    });
  }

  @override
  Widget build(BuildContext context) => buildForm(
        'Уровень в 315 (мм)',
        _level315,
        'Уровень в 324 (мм)',
        _level324,
        'Скорость потребления (мм/ч)',
        _consumptionRate,
        _calculate,
        _result,
        Colors.orange[100]!,
      );
}

Widget buildForm(
  String label1,
  TextEditingController ctrl1,
  String label2,
  TextEditingController ctrl2,
  String label3,
  TextEditingController ctrl3,
  VoidCallback onCalc,
  String result,
  Color bg,
  {Widget? extra,}
) {
  return Container(
    color: bg,
    child: SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            decoration: InputDecoration(labelText: label1),
            controller: ctrl1,
            keyboardType: TextInputType.number,
          ),
          TextFormField(
            decoration: InputDecoration(labelText: label2),
            controller: ctrl2,
            keyboardType: TextInputType.number,
          ),
          TextFormField(
            decoration: InputDecoration(labelText: label3),
            controller: ctrl3,
            keyboardType: TextInputType.number,
          ),
          if (extra != null) extra!,
          SizedBox(height: 20),
          Center(
            child: ElevatedButton.icon(
              onPressed: onCalc,
              icon: Icon(Icons.calculate),
              label: Text('Рассчитать'),
            ),
          ),
          SizedBox(height: 20),
          Text(result, style: TextStyle(fontSize: 16)),
        ],
      ),
    ),
  );
}
