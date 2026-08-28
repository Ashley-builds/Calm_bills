// ============================================================
// CALM BILLS
// Add what you pay once. It remembers the dates, warns you
// early, and keeps an honest running total.
//
// Everything lives on the phone. Nothing is sent anywhere.
// ============================================================

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

// ------------------------------------------------------------
// COLOURS
// ------------------------------------------------------------

const ink = Color(0xFF16202B);
const amber = Color(0xFFE8A33D);
const paidGreen = Color(0xFF4A7C59);
const urgentAmber = Color(0xFFB45309);
const muted = Color(0xFF64748B);
const dim = Color(0xFF7C8899);
const hairline = Color(0xFFF1F5F9);

// ------------------------------------------------------------
// CURRENCIES
// ------------------------------------------------------------

class Currency {
  final String code;
  final String symbol;
  final String name;
  const Currency(this.code, this.symbol, this.name);
}

const currencies = <Currency>[
  Currency('UGX', 'USh', 'Ugandan shilling'),
  Currency('KES', 'KSh', 'Kenyan shilling'),
  Currency('TZS', 'TSh', 'Tanzanian shilling'),
  Currency('RWF', 'FRw', 'Rwandan franc'),
  Currency('BIF', 'FBu', 'Burundian franc'),
  Currency('ETB', 'Br', 'Ethiopian birr'),
  Currency('SOS', 'Sh', 'Somali shilling'),
  Currency('SSP', 'SS', 'South Sudanese pound'),
  Currency('SDG', 'SDG', 'Sudanese pound'),
  Currency('ERN', 'Nfk', 'Eritrean nakfa'),
  Currency('DJF', 'Fdj', 'Djiboutian franc'),
  Currency('NGN', 'N', 'Nigerian naira'),
  Currency('GHS', 'GHS', 'Ghanaian cedi'),
  Currency('ZAR', 'R', 'South African rand'),
  Currency('ZMW', 'ZK', 'Zambian kwacha'),
  Currency('MWK', 'MK', 'Malawian kwacha'),
  Currency('ZWL', 'Z\$', 'Zimbabwean dollar'),
  Currency('BWP', 'P', 'Botswana pula'),
  Currency('NAD', 'N\$', 'Namibian dollar'),
  Currency('MZN', 'MT', 'Mozambican metical'),
  Currency('AOA', 'Kz', 'Angolan kwanza'),
  Currency('LSL', 'L', 'Lesotho loti'),
  Currency('SZL', 'E', 'Eswatini lilangeni'),
  Currency('MGA', 'Ar', 'Malagasy ariary'),
  Currency('MUR', 'Rs', 'Mauritian rupee'),
  Currency('SCR', 'SR', 'Seychellois rupee'),
  Currency('KMF', 'CF', 'Comorian franc'),
  Currency('XOF', 'CFA', 'West African CFA franc'),
  Currency('XAF', 'FCFA', 'Central African CFA franc'),
  Currency('CDF', 'FC', 'Congolese franc'),
  Currency('GMD', 'D', 'Gambian dalasi'),
  Currency('GNF', 'FG', 'Guinean franc'),
  Currency('SLE', 'Le', 'Sierra Leonean leone'),
  Currency('LRD', 'L\$', 'Liberian dollar'),
  Currency('CVE', 'CVE', 'Cape Verdean escudo'),
  Currency('STN', 'Db', 'Sao Tome dobra'),
  Currency('MRU', 'UM', 'Mauritanian ouguiya'),
  Currency('EGP', 'EGP', 'Egyptian pound'),
  Currency('MAD', 'DH', 'Moroccan dirham'),
  Currency('DZD', 'DA', 'Algerian dinar'),
  Currency('TND', 'DT', 'Tunisian dinar'),
  Currency('LYD', 'LD', 'Libyan dinar'),
  Currency('GBP', '\u00A3', 'British pound'),
  Currency('USD', '\$', 'US dollar'),
  Currency('EUR', '\u20AC', 'Euro'),
  Currency('CHF', 'CHF', 'Swiss franc'),
  Currency('SEK', 'kr', 'Swedish krona'),
  Currency('NOK', 'kr', 'Norwegian krone'),
  Currency('DKK', 'kr', 'Danish krone'),
  Currency('PLN', 'zl', 'Polish zloty'),
  Currency('CZK', 'Kc', 'Czech koruna'),
  Currency('HUF', 'Ft', 'Hungarian forint'),
  Currency('RON', 'lei', 'Romanian leu'),
  Currency('TRY', 'TL', 'Turkish lira'),
  Currency('RUB', 'RUB', 'Russian ruble'),
  Currency('UAH', 'UAH', 'Ukrainian hryvnia'),
  Currency('CAD', 'C\$', 'Canadian dollar'),
  Currency('AUD', 'A\$', 'Australian dollar'),
  Currency('NZD', 'NZ\$', 'New Zealand dollar'),
  Currency('INR', 'Rs', 'Indian rupee'),
  Currency('PKR', 'Rs', 'Pakistani rupee'),
  Currency('BDT', 'Tk', 'Bangladeshi taka'),
  Currency('LKR', 'Rs', 'Sri Lankan rupee'),
  Currency('NPR', 'Rs', 'Nepalese rupee'),
  Currency('CNY', 'CNY', 'Chinese yuan'),
  Currency('JPY', 'JPY', 'Japanese yen'),
  Currency('KRW', 'KRW', 'South Korean won'),
  Currency('HKD', 'HK\$', 'Hong Kong dollar'),
  Currency('SGD', 'S\$', 'Singapore dollar'),
  Currency('MYR', 'RM', 'Malaysian ringgit'),
  Currency('IDR', 'Rp', 'Indonesian rupiah'),
  Currency('THB', 'THB', 'Thai baht'),
  Currency('VND', 'VND', 'Vietnamese dong'),
  Currency('PHP', 'PHP', 'Philippine peso'),
  Currency('AED', 'AED', 'UAE dirham'),
  Currency('SAR', 'SAR', 'Saudi riyal'),
  Currency('QAR', 'QAR', 'Qatari riyal'),
  Currency('KWD', 'KD', 'Kuwaiti dinar'),
  Currency('BHD', 'BD', 'Bahraini dinar'),
  Currency('OMR', 'OMR', 'Omani rial'),
  Currency('JOD', 'JD', 'Jordanian dinar'),
  Currency('LBP', 'LBP', 'Lebanese pound'),
  Currency('ILS', 'ILS', 'Israeli shekel'),
  Currency('IQD', 'ID', 'Iraqi dinar'),
  Currency('AFN', 'AFN', 'Afghan afghani'),
  Currency('KZT', 'KZT', 'Kazakhstani tenge'),
  Currency('UZS', 'som', 'Uzbekistani som'),
  Currency('BRL', 'R\$', 'Brazilian real'),
  Currency('MXN', 'MX\$', 'Mexican peso'),
  Currency('ARS', 'AR\$', 'Argentine peso'),
  Currency('CLP', 'CL\$', 'Chilean peso'),
  Currency('COP', 'CO\$', 'Colombian peso'),
  Currency('PEN', 'S/', 'Peruvian sol'),
  Currency('UYU', '\$U', 'Uruguayan peso'),
  Currency('BOB', 'Bs', 'Bolivian boliviano'),
  Currency('PYG', 'Gs', 'Paraguayan guarani'),
  Currency('JMD', 'J\$', 'Jamaican dollar'),
  Currency('TTD', 'TT\$', 'Trinidad dollar'),
  Currency('DOP', 'RD\$', 'Dominican peso'),
  Currency('GTQ', 'Q', 'Guatemalan quetzal'),
];

const suggestedBills = [
  'Rent', 'Electricity', 'Water', 'Internet', 'Phone',
  'Childcare', 'Insurance', 'Transport', 'School fees',
];

const suggestedSubs = [
  'Netflix', 'Spotify', 'Gym', 'Cloud storage', 'Games', 'News',
];

// ------------------------------------------------------------
// THE DATA MODEL
// Bills and subscriptions are the same thing underneath.
// ------------------------------------------------------------

enum Cycle { weekly, monthly, yearly }

class Payment {
  final String id;
  String name;
  double amount;
  Cycle cycle;
  DateTime dueDate;
  int reminderDays;
  bool isSub;
  DateTime? lastPaid;
  int covers;
  DateTime? paidFrom;

  Payment({
    required this.id,
    required this.name,
    required this.amount,
    required this.cycle,
    required this.dueDate,
    required this.reminderDays,
    required this.isSub,
    this.lastPaid,
    this.covers = 1,
    this.paidFrom,
  });

  static DateTime dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  // Ticked today? Then the tick locks until tomorrow, which is
  // what stops a double tap pushing the due date out a month.
  bool get paidToday {
    final last = lastPaid;
    if (last == null) return false;
    return dayOnly(last) == dayOnly(DateTime.now());
  }

  DateTime get reminderDate => dueDate.subtract(Duration(days: reminderDays));

  // Weekly and yearly converted to a monthly figure so they can
  // all be added into one honest total.
  double get monthlyEquivalent {
    switch (cycle) {
      case Cycle.weekly:
        return amount * 52 / 12;
      case Cycle.monthly:
        return amount;
      case Cycle.yearly:
        return amount / 12;
    }
  }

  String get cycleLabel {
    switch (cycle) {
      case Cycle.weekly:
        return 'Weekly';
      case Cycle.monthly:
        return 'Monthly';
      case Cycle.yearly:
        return 'Yearly';
    }
  }

  String get periodWord {
    switch (cycle) {
      case Cycle.weekly:
        return 'week';
      case Cycle.monthly:
        return 'month';
      case Cycle.yearly:
        return 'year';
    }
  }

  String get dueLabel {
    final days = dayOnly(dueDate).difference(dayOnly(DateTime.now())).inDays;
    if (days < 0) return 'Overdue';
    if (days == 0) return 'Due today';
    if (days == 1) return 'Due tomorrow';
    return 'Due in $days days';
  }

  DateTime stepForward(DateTime from, int times) {
    var d = from;
    for (var i = 0; i < times; i++) {
      switch (cycle) {
        case Cycle.weekly:
          d = d.add(const Duration(days: 7));
          break;
        case Cycle.monthly:
          d = DateTime(d.year, d.month + 1, d.day);
          break;
        case Cycle.yearly:
          d = DateTime(d.year + 1, d.month, d.day);
          break;
      }
    }
    return d;
  }

  // Counts forward from the DUE date, never from today. Paying
  // on the 26th for a bill due the 30th still lands the next
  // one on the 30th.
  void markPaid({int cycles = 1}) {
    final anchor = paidFrom ?? dueDate;
    paidFrom = anchor;
    dueDate = stepForward(anchor, cycles);
    covers = cycles;
    lastPaid = DateTime.now();
  }

  void undo() {
    final anchor = paidFrom;
    if (anchor == null) return;
    dueDate = anchor;
    paidFrom = null;
    lastPaid = null;
    covers = 1;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'amount': amount,
        'cycle': cycle.name,
        'dueDate': dueDate.toIso8601String(),
        'reminderDays': reminderDays,
        'isSub': isSub,
        'lastPaid': lastPaid?.toIso8601String(),
        'covers': covers,
        'paidFrom': paidFrom?.toIso8601String(),
      };

  factory Payment.fromJson(Map<String, dynamic> j) {
    DateTime? maybe(dynamic v) => v == null ? null : DateTime.parse(v as String);
    return Payment(
      id: j['id'] as String,
      name: j['name'] as String,
      amount: (j['amount'] as num).toDouble(),
      cycle: Cycle.values.firstWhere((c) => c.name == j['cycle'],
          orElse: () => Cycle.monthly),
      dueDate: DateTime.parse(j['dueDate'] as String),
      reminderDays: j['reminderDays'] as int,
      isSub: j['isSub'] as bool,
      lastPaid: maybe(j['lastPaid']),
      covers: j['covers'] as int? ?? 1,
      paidFrom: maybe(j['paidFrom']),
    );
  }
}

// A record of money actually leaving the account. Separate,
// because "what I owe monthly" and "what I spent this month"
// are two different numbers.
class Spend {
  final String paymentId;
  final DateTime anchor;
  final DateTime date;
  final double amount;
  final bool isSub;

  Spend({
    required this.paymentId,
    required this.anchor,
    required this.date,
    required this.amount,
    required this.isSub,
  });

  Map<String, dynamic> toJson() => {
        'paymentId': paymentId,
        'anchor': anchor.toIso8601String(),
        'date': date.toIso8601String(),
        'amount': amount,
        'isSub': isSub,
      };

  factory Spend.fromJson(Map<String, dynamic> j) => Spend(
        paymentId: j['paymentId'] as String,
        anchor: DateTime.parse(j['anchor'] as String),
        date: DateTime.parse(j['date'] as String),
        amount: (j['amount'] as num).toDouble(),
        isSub: j['isSub'] as bool,
      );
}

// ------------------------------------------------------------
// STORAGE
// ------------------------------------------------------------

class Store {
  static Future<void> savePayments(List<Payment> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'payments', jsonEncode(items.map((p) => p.toJson()).toList()));
  }

  static Future<List<Payment>> loadPayments() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('payments');
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => Payment.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveSpends(List<Spend> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'spends', jsonEncode(items.map((s) => s.toJson()).toList()));
  }

  static Future<List<Spend>> loadSpends() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('spends');
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => Spend.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveProfile(String name, String code, String symbol) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', name);
    await prefs.setString('code', code);
    await prefs.setString('symbol', symbol);
  }

  static Future<Map<String, String>?> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('name');
    if (name == null) return null;
    return {
      'name': name,
      'code': prefs.getString('code') ?? 'GBP',
      'symbol': prefs.getString('symbol') ?? '',
    };
  }
}

// ------------------------------------------------------------
// NOTIFICATIONS
// The phone's own alarm system fires these. No server, no
// internet, and they work with the app closed.
// ------------------------------------------------------------

class Notifier {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz_data.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _plugin.initialize(settings);

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      // Android 13+ asks before it lets an app notify.
      await androidPlugin.requestNotificationsPermission();
      // Android 12+ needs this separately for timed reminders.
      await androidPlugin.requestExactAlarmsPermission();
    }
  }

  // Fires straight away. Proves permission, channel and delivery
  // all work, without waiting until 9am.
  static Future<void> testNow() async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'calm_bills',
        'Bill reminders',
        channelDescription: 'Warnings before a payment is due',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );

    await _plugin.show(
      99999,
      'Reminders are on',
      'This is how a bill warning will look.',
      details,
    );
  }

  static Future<void> rescheduleAll(
      List<Payment> payments, String symbol) async {
    await _plugin.cancelAll();
    for (final p in payments) {
      await _scheduleFor(p, symbol);
    }
  }

  static Future<void> _scheduleFor(Payment p, String symbol) async {
    final when = p.reminderDate;
    final now = tz.TZDateTime.now(tz.local);

    var at = tz.TZDateTime(tz.local, when.year, when.month, when.day, 9);

    // If 9am on the reminder day has already gone but the bill
    // is still coming, warn in a minute rather than staying silent.
    if (at.isBefore(now)) {
      final due = tz.TZDateTime(
          tz.local, p.dueDate.year, p.dueDate.month, p.dueDate.day, 9);
      if (due.isBefore(now)) return;
      at = now.add(const Duration(minutes: 1));
    }

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'calm_bills',
        'Bill reminders',
        channelDescription: 'Warnings before a payment is due',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );

    final word = p.reminderDays == 1 ? 'day' : 'days';

    await _plugin.zonedSchedule(
      p.id.hashCode.abs() % 100000,
      '${p.name} due soon',
      '$symbol${p.amount.toStringAsFixed(2)} due in ${p.reminderDays} $word',
      at,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}// ------------------------------------------------------------
// APP
// ------------------------------------------------------------

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Notifier.init();
  await Notifier.testNow();
  runApp(const CalmBills());
}

class CalmBills extends StatelessWidget {
  const CalmBills({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calm Bills',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(seedColor: ink, primary: ink),
      ),
      home: const Root(),
    );
  }
}

class Root extends StatefulWidget {
  const Root({super.key});

  @override
  State<Root> createState() => _RootState();
}

class _RootState extends State<Root> {
  bool _loading = true;
  Map<String, String>? _profile;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final profile = await Store.loadProfile();
    setState(() {
      _profile = profile;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_profile == null) {
      return WelcomeScreen(onDone: _load);
    }
    return HomeScreen(profile: _profile!);
  }
}

// ------------------------------------------------------------
// WELCOME
// ------------------------------------------------------------

class WelcomeScreen extends StatelessWidget {
  final VoidCallback onDone;

  const WelcomeScreen({super.key, required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ink,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 56),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2C3B),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.circle_outlined,
                    color: Colors.white, size: 34),
              ),
              const SizedBox(height: 32),
              const Text(
                'Never be surprised\nby a bill again.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  height: 1.2,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Add what you pay once. After that it remembers the '
                'dates, warns you early, and keeps a running total.',
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 15, height: 1.6),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SetupScreen()),
                    );
                    onDone();
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: amber,
                    foregroundColor: ink,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Get started', style: TextStyle(fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------
// SETUP
// ------------------------------------------------------------

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final _name = TextEditingController();
  final _search = TextEditingController();
  Currency? _picked;
  String _error = '';

  @override
  void dispose() {
    _name.dispose();
    _search.dispose();
    super.dispose();
  }

  List<Currency> get _matches {
    final q = _search.text.trim().toLowerCase();
    if (q.isEmpty) return currencies;
    return currencies
        .where((c) =>
            c.name.toLowerCase().contains(q) ||
            c.code.toLowerCase().contains(q) ||
            c.symbol.toLowerCase().contains(q))
        .toList();
  }

  Future<void> _finish() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Enter a name so the app can greet you.');
      return;
    }
    if (_picked == null) {
      setState(() => _error = 'Pick your currency.');
      return;
    }
    await Store.saveProfile(name, _picked!.code, _picked!.symbol);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final list = _matches;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: ink,
        foregroundColor: Colors.white,
        title: const Text('Set up'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Stays on this phone. No account needed.',
                    style: TextStyle(color: muted, fontSize: 13)),
                const SizedBox(height: 16),
                TextField(
                  controller: _name,
                  decoration: const InputDecoration(
                    labelText: 'What should we call you?',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _search,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    labelText: 'Currency',
                    hintText: 'Search country or currency',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: list.isEmpty
                ? const Center(
                    child: Text('Nothing matches. Try the code, like UGX.',
                        style: TextStyle(color: muted)))
                : ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, i) {
                      final c = list[i];
                      final on = _picked?.code == c.code;
                      return ListTile(
                        dense: true,
                        selected: on,
                        selectedTileColor: hairline,
                        leading: SizedBox(
                          width: 46,
                          child: Text(c.code,
                              style: const TextStyle(fontSize: 13, color: muted)),
                        ),
                        title: Text(c.name, style: const TextStyle(fontSize: 14)),
                        trailing: Text(c.symbol,
                            style: const TextStyle(color: muted)),
                        onTap: () => setState(() {
                          _picked = c;
                          _error = '';
                        }),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: hairline)),
            ),
            child: Column(
              children: [
                if (_error.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(_error,
                        style: const TextStyle(color: Colors.red, fontSize: 14)),
                  ),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _finish,
                    style: FilledButton.styleFrom(
                      backgroundColor: ink,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(_picked == null
                        ? 'Continue'
                        : 'Continue with ${_picked!.code}'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}// ------------------------------------------------------------
// HOME
// ------------------------------------------------------------

class HomeScreen extends StatefulWidget {
  final Map<String, String> profile;

  const HomeScreen({super.key, required this.profile});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Payment> _payments = [];
  List<Spend> _spends = [];
  bool _loading = true;
  bool _showSubs = false;
  String? _justPaidId;
  late DateTime _viewMonth;

  String get _symbol => widget.profile['symbol'] ?? '';

  String _money(double n) => '$_symbol${n.toStringAsFixed(2)}';

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _viewMonth = DateTime(now.year, now.month);
    _load();
  }

  Future<void> _load() async {
    final payments = await Store.loadPayments();
    final spends = await Store.loadSpends();
    setState(() {
      _payments = payments;
      _spends = spends;
      _loading = false;
    });
    await Notifier.rescheduleAll(_payments, _symbol);
  }

  Future<void> _persist() async {
    await Store.savePayments(_payments);
    await Store.saveSpends(_spends);
    await Notifier.rescheduleAll(_payments, _symbol);
  }

  List<Payment> get _visible {
    final list = _payments.where((p) => p.isSub == _showSubs).toList();
    list.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return list;
  }

  double get _commitment => _payments
      .where((p) => p.isSub == _showSubs)
      .fold(0.0, (sum, p) => sum + p.monthlyEquivalent);

  double get _paidInMonth => _spends
      .where((s) =>
          s.isSub == _showSubs &&
          s.date.year == _viewMonth.year &&
          s.date.month == _viewMonth.month)
      .fold(0.0, (sum, s) => sum + s.amount);

  bool get _isCurrentMonth {
    final now = DateTime.now();
    return _viewMonth.year == now.year && _viewMonth.month == now.month;
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Future<void> _markPaid(Payment p, {int cycles = 1, bool adjust = false}) async {
    if (p.paidToday && !adjust) return;

    final anchor = p.paidFrom ?? p.dueDate;

    setState(() {
      p.markPaid(cycles: cycles);
      _spends.removeWhere((s) =>
          s.paymentId == p.id && _sameDay(s.date, DateTime.now()));
      _spends.add(Spend(
        paymentId: p.id,
        anchor: anchor,
        date: DateTime.now(),
        amount: p.amount * cycles,
        isSub: p.isSub,
      ));
      _justPaidId = p.id;
    });

    await _persist();
  }

  Future<void> _undo() async {
    final id = _justPaidId;
    if (id == null) return;

    setState(() {
      for (final p in _payments) {
        if (p.id == id) p.undo();
      }
      _spends.removeWhere(
          (s) => s.paymentId == id && _sameDay(s.date, DateTime.now()));
      _justPaidId = null;
    });

    await _persist();
  }

  Future<void> _openAdjust(Payment p) async {
    final cycles = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => AdjustSheet(payment: p, symbol: _symbol),
    );
    if (cycles != null) {
      await _markPaid(p, cycles: cycles, adjust: true);
    }
  }

  Future<void> _openEditor({Payment? existing, String? presetName}) async {
    final result = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(
        builder: (_) => EditScreen(
          existing: existing,
          presetName: presetName,
          defaultSub: _showSubs,
          symbol: _symbol,
        ),
      ),
    );

    if (result == 'delete' && existing != null) {
      setState(() {
        _payments.removeWhere((p) => p.id == existing.id);
        _spends.removeWhere((s) => s.paymentId == existing.id);
      });
      await _persist();
    } else if (result is Payment) {
      setState(() {
        final i = _payments.indexWhere((p) => p.id == result.id);
        if (i == -1) {
          _payments.add(result);
        } else {
          _payments[i] = result;
        }
      });
      await _persist();
    }
  }

  void _shiftMonth(int delta) {
    setState(() {
      _viewMonth = DateTime(_viewMonth.year, _viewMonth.month + delta);
      _justPaidId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    Payment? justPaid;
    if (_justPaidId != null) {
      final found = _payments.where((p) => p.id == _justPaidId);
      if (found.isNotEmpty) justPaid = found.first;
    }

    final visible = _visible;

    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Stack(
              children: [
                visible.isEmpty
                    ? _buildEmpty()
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 120),
                        itemCount: visible.length,
                        itemBuilder: (context, i) =>
                            _buildRow(visible[i]),
                      ),
                if (justPaid != null)
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 12,
                    child: _buildPaidBar(justPaid),
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEditor(),
        backgroundColor: amber,
        foregroundColor: ink,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHeader() {
    const monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];

    final paidLabel = _isCurrentMonth
        ? 'Paid this month'
        : 'Paid ${monthNames[_viewMonth.month - 1]}';

    return Container(
      width: double.infinity,
      color: ink,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        left: 20,
        right: 20,
        bottom: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Hello, ${widget.profile['name']}',
              style: const TextStyle(color: dim, fontSize: 13)),
          const SizedBox(height: 16),
          Row(
            children: [
              _tab('Bills', !_showSubs, () => setState(() {
                    _showSubs = false;
                    _justPaidId = null;
                  })),
              const SizedBox(width: 24),
              _tab('Subscriptions', _showSubs, () => setState(() {
                    _showSubs = true;
                    _justPaidId = null;
                  })),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('PER MONTH',
                        style: TextStyle(
                            color: dim, fontSize: 11, letterSpacing: 0.8)),
                    Text(_money(_commitment),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => _shiftMonth(-1),
                        child: const Icon(Icons.chevron_left,
                            color: dim, size: 18),
                      ),
                      Text(paidLabel.toUpperCase(),
                          style: const TextStyle(
                              color: dim, fontSize: 11, letterSpacing: 0.8)),
                      GestureDetector(
                        onTap: () => _shiftMonth(1),
                        child: const Icon(Icons.chevron_right,
                            color: dim, size: 18),
                      ),
                    ],
                  ),
                  Text(_money(_paidInMonth),
                      style: TextStyle(
                          color: _paidInMonth > 0 ? amber : dim, fontSize: 20)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tab(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
                color: selected ? amber : Colors.transparent, width: 2),
          ),
        ),
        child: Text(label,
            style: TextStyle(
                color: selected ? Colors.white : dim, fontSize: 15)),
      ),
    );
  }

  Widget _buildEmpty() {
    final names = _showSubs ? suggestedSubs : suggestedBills;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text('Add your ${_showSubs ? "subscriptions" : "bills"}',
              style: const TextStyle(fontSize: 17)),
          const SizedBox(height: 8),
          const Text(
            'Enter each one once - the name, what you pay, and when '
            'it is next due. After that the app tracks it for you.',
            style: TextStyle(color: muted, fontSize: 14, height: 1.6),
          ),
          const SizedBox(height: 28),
          const Text('COMMON ONES',
              style: TextStyle(color: dim, fontSize: 11, letterSpacing: 0.8)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: names
                .map((n) => ActionChip(
                      label: Text(n, style: const TextStyle(fontSize: 13)),
                      onPressed: () => _openEditor(presetName: n),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }Widget _buildRow(Payment p) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    String short(DateTime d) => '${d.day} ${months[d.month - 1]}';

    final done = p.paidToday;
    final label = p.dueLabel;
    final urgent = label == 'Overdue' || label == 'Due today';
    final n = p.covers;
    final plural = n > 1 ? 's' : '';

    final subtitle = done
        ? 'Paid ${short(p.lastPaid!)} - covers $n ${p.periodWord}$plural '
            '- next ${short(p.dueDate)}'
        : '${p.cycleLabel} - $label - remind ${p.reminderDays}d early';

    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: hairline)),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => _openEditor(existing: p),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 8, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(p.name,
                              style: const TextStyle(fontSize: 15),
                              overflow: TextOverflow.ellipsis),
                        ),
                        Text(_money(p.amount),
                            style: const TextStyle(fontSize: 15)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: done
                            ? paidGreen
                            : urgent
                                ? urgentAmber
                                : muted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16, left: 4),
            child: GestureDetector(
              onTap: done ? null : () => _markPaid(p),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done ? paidGreen : Colors.transparent,
                  border: Border.all(
                      color: done ? paidGreen : const Color(0xFFCBD5E1)),
                ),
                child: Icon(Icons.check,
                    size: 18,
                    color: done ? Colors.white : const Color(0xFF94A3B8)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaidBar(Payment p) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final next = '${p.dueDate.day} ${months[p.dueDate.month - 1]}';
    final n = p.covers;
    final plural = n > 1 ? 's' : '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: ink,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${p.name} paid - covers $n ${p.periodWord}$plural '
                  '- next due $next',
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: _undo,
                icon: const Icon(Icons.undo, size: 15),
                label: const Text('Undo'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFF64748B)),
                  visualDensity: VisualDensity.compact,
                  textStyle: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () => _openAdjust(p),
            child: Text('Paid more than one ${p.periodWord}?',
                style: const TextStyle(color: amber, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------
// ADJUST SHEET
// Only reachable on purpose, never by accident.
// ------------------------------------------------------------

class AdjustSheet extends StatefulWidget {
  final Payment payment;
  final String symbol;

  const AdjustSheet({super.key, required this.payment, required this.symbol});

  @override
  State<AdjustSheet> createState() => _AdjustSheetState();
}

class _AdjustSheetState extends State<AdjustSheet> {
  late int _count = widget.payment.covers;

  @override
  Widget build(BuildContext context) {
    const monthsLong = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    const monthsShort = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];

    final p = widget.payment;
    final anchor = p.paidFrom ?? p.dueDate;

    final covered = <String>[];
    for (var i = 0; i < _count; i++) {
      final d = p.stepForward(anchor, i);
      covered.add(p.cycle == Cycle.monthly
          ? monthsLong[d.month - 1]
          : '${d.day} ${monthsShort[d.month - 1]}');
    }

    final next = p.stepForward(anchor, _count);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('How many ${p.periodWord}s did you pay for?',
              style: const TextStyle(fontSize: 17)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _stepButton(Icons.remove,
                  _count > 1 ? () => setState(() => _count--) : null),
              SizedBox(
                width: 72,
                child: Text('$_count',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 34)),
              ),
              _stepButton(Icons.add,
                  _count < 12 ? () => setState(() => _count++) : null),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Covers ${covered.join(", ")}',
                    style: const TextStyle(fontSize: 13, color: muted)),
                const SizedBox(height: 4),
                Text(
                  'Next due ${next.day} ${monthsShort[next.month - 1]} - '
                  '${widget.symbol}${(p.amount * _count).toStringAsFixed(2)} paid',
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.pop(context, _count),
              style: FilledButton.styleFrom(
                backgroundColor: ink,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Confirm'),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepButton(IconData icon, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
              color: onTap == null
                  ? const Color(0xFFE2E8F0)
                  : const Color(0xFFCBD5E1)),
        ),
        child: Icon(icon,
            color: onTap == null ? const Color(0xFFCBD5E1) : ink),
      ),
    );
  }
}// ------------------------------------------------------------
// ADD / EDIT
// ------------------------------------------------------------

class EditScreen extends StatefulWidget {
  final Payment? existing;
  final String? presetName;
  final bool defaultSub;
  final String symbol;

  const EditScreen({
    super.key,
    this.existing,
    this.presetName,
    required this.defaultSub,
    required this.symbol,
  });

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  final _name = TextEditingController();
  final _amount = TextEditingController();
  final _remind = TextEditingController(text: '3');

  Cycle _cycle = Cycle.monthly;
  late bool _isSub = widget.defaultSub;
  DateTime _dueDate = DateTime.now().add(const Duration(days: 7));

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _name.text = e.name;
      _amount.text = e.amount.toStringAsFixed(2);
      _remind.text = e.reminderDays.toString();
      _cycle = e.cycle;
      _isSub = e.isSub;
      _dueDate = e.dueDate;
    } else if (widget.presetName != null) {
      _name.text = widget.presetName!;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    _remind.dispose();
    super.dispose();
  }

  void _error(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  void _save() {
    final name = _name.text.trim();
    final amount = double.tryParse(_amount.text);
    final remind = int.tryParse(_remind.text);

    if (name.isEmpty) return _error('Give it a name.');
    if (amount == null || amount <= 0) {
      return _error('Enter an amount above zero.');
    }
    if (remind == null || remind < 0) {
      return _error('Reminder days cannot be blank.');
    }

    final e = widget.existing;

    Navigator.pop(
      context,
      Payment(
        id: e?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        amount: amount,
        cycle: _cycle,
        dueDate: _dueDate,
        reminderDays: remind,
        isSub: _isSub,
        lastPaid: e?.lastPaid,
        covers: e?.covers ?? 1,
        paidFrom: e?.paidFrom,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.existing == null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: ink,
        foregroundColor: Colors.white,
        title: Text(isNew
            ? (_isSub ? 'Add a subscription' : 'Add a bill')
            : 'Edit'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: _name,
            decoration: InputDecoration(
              labelText: 'Name',
              hintText: _isSub ? 'Netflix, gym' : 'Rent, electricity, childcare',
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _amount,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Amount (${widget.symbol})',
                    hintText: '0.00',
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<Cycle>(
                  value: _cycle,
                  decoration: const InputDecoration(
                    labelText: 'Repeats',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: Cycle.weekly, child: Text('Weekly')),
                    DropdownMenuItem(
                        value: Cycle.monthly, child: Text('Monthly')),
                    DropdownMenuItem(value: Cycle.yearly, child: Text('Yearly')),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _cycle = v);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: _pickDate,
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Next due date',
                border: OutlineInputBorder(),
              ),
              child: Text('${_dueDate.day}/${_dueDate.month}/${_dueDate.year}'),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _remind,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Remind me this many days early',
              helperText: 'Big bills deserve longer warnings',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Filed under subscriptions'),
            value: _isSub,
            onChanged: (v) => setState(() => _isSub = v),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(
                backgroundColor: ink,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(isNew ? 'Add' : 'Save changes'),
            ),
          ),
          if (!isNew)
            TextButton.icon(
              onPressed: () => Navigator.pop(context, 'delete'),
              icon: const Icon(Icons.delete_outline, size: 18),
              label: const Text('Delete'),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
            ),
        ],
      ),
    );
  }
}
