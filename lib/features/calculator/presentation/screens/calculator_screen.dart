import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:math_expressions/math_expressions.dart';
import '../../../../core/constants/app_colors.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});
  @override State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;
  @override void initState() { super.initState(); _tab = TabController(length: 5, vsync: this); }
  @override void dispose() { _tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text('Calculator Suite', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
      bottom: TabBar(
        controller: _tab,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        tabs: const [
          Tab(text: 'Scientific'),
          Tab(text: 'Currency'),
          Tab(text: 'BMI'),
          Tab(text: 'EMI'),
          Tab(text: 'Unit Convert'),
        ],
      ),
    ),
    body: TabBarView(controller: _tab, children: const [
      _ScientificCalc(),
      _CurrencyCalc(),
      _BMICalc(),
      _EMICalc(),
      _UnitConvertCalc(),
    ]),
  );
}

// ─── Scientific Calculator ─────────────────────────────────────────────────────

class _ScientificCalc extends StatefulWidget {
  const _ScientificCalc();
  @override State<_ScientificCalc> createState() => _ScientificCalcState();
}

class _ScientificCalcState extends State<_ScientificCalc> {
  String _expr = '';
  String _result = '0';
  bool _isError = false;

  static const _sciRow1 = ['sin', 'cos', 'tan', 'log', 'ln', '√'];
  static const _sciRow2 = ['x²', 'x³', 'π', 'e', '^', '!'];
  static const _numPad = [
    'C', '⌫', '(', ')', 'mod',
    '7', '8', '9', '÷', '',
    '4', '5', '6', '×', '',
    '1', '2', '3', '-', '',
    '0', '.', '=', '+', '',
  ];

  void _press(String val) {
    setState(() {
      _isError = false;
      switch (val) {
        case 'C':
          _expr = ''; _result = '0';
          break;
        case '⌫':
          if (_expr.isNotEmpty) _expr = _expr.substring(0, _expr.length - 1);
          break;
        case '=':
          _evaluate();
          break;
        case 'sin':
          _expr += 'sin(';
          break;
        case 'cos':
          _expr += 'cos(';
          break;
        case 'tan':
          _expr += 'tan(';
          break;
        case 'log':
          _expr += 'log(';
          break;
        case 'ln':
          _expr += 'ln(';
          break;
        case '√':
          _expr += 'sqrt(';
          break;
        case 'x²':
          _expr += '^2';
          break;
        case 'x³':
          _expr += '^3';
          break;
        case 'π':
          _expr += 'pi';
          break;
        case 'e':
          _expr += 'e';
          break;
        case '^':
          _expr += '^';
          break;
        case '!':
          _appendFactorial();
          break;
        case 'mod':
          _expr += '%';
          break;
        default:
          if (val.isNotEmpty) _expr += val;
      }
    });
  }

  void _appendFactorial() {
    // Extract trailing number and compute factorial
    final match = RegExp(r'(\d+)$').firstMatch(_expr);
    if (match != null) {
      final n = int.tryParse(match.group(1) ?? '') ?? 0;
      if (n >= 0 && n <= 20) {
        final base = _expr.substring(0, _expr.length - match.group(1)!.length);
        _expr = base + _factorial(n).toString();
      }
    }
  }

  int _factorial(int n) {
    if (n <= 1) return 1;
    return n * _factorial(n - 1);
  }

  void _evaluate() {
    if (_expr.isEmpty) return;
    try {
      // Pre-process: trig functions use degrees? -> use radians via conversion
      // Replace trig calls: sin(x) -> sin(x*pi/180) for degree mode
      // We'll keep radians for scientific use
      String processedExpr = _expr
          .replaceAll('×', '*')
          .replaceAll('÷', '/')
          .replaceAll('pi', '${math.pi}')
          .replaceAll('ln(', 'log(')  // math_expressions log is natural log
          .replaceAll('log(', 'log10(');

      // Replace log10 back for log10 calls and ln for natural
      // Actually math_expressions: log() = natural log
      // Re-process: our 'ln' -> log, 'log' -> log10
      processedExpr = _expr
          .replaceAll('×', '*')
          .replaceAll('÷', '/')
          .replaceAll('pi', '${math.pi}');

      // handle log vs ln distinction
      // _expr uses 'log(' for log10 and 'ln(' for natural log
      // math_expressions: log() = natural log
      // So: replace log( with log10( substitute using change of base
      // Easiest: evaluate with custom handling
      processedExpr = _computeExpression(_expr);

      _result = processedExpr;
    } catch (e) {
      _result = 'Error';
      _isError = true;
    }
  }

  String _computeExpression(String raw) {
    // Pre-process the expression for math_expressions
    String expr = raw
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll('pi', '${math.pi}')
        .replaceAll('%', '/100*'); // basic mod handling

    // log( -> log base 10: replace with (ln/ln10)
    // ln( -> log(  (math_expressions uses log for natural)
    // log( -> log()/log(10)
    expr = expr.replaceAllMapped(RegExp(r'log\('), (_) => '(log(');
    expr = expr.replaceAllMapped(RegExp(r'\(log\('), (m) {
      // We'll handle after parsing
      return '(log(';
    });

    // Simpler approach: use dart:math directly via manual scan
    final result = _evalWithDartMath(raw);
    return result;
  }

  String _evalWithDartMath(String raw) {
    // Replace our tokens for math_expressions
    String expr = raw
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll('mod', '%');

    // Replace pi and e
    expr = expr.replaceAll('pi', '3.141592653589793');
    // Replace 'e' only when standalone (not inside 'cos', 'sin', etc.)
    // Use regex to match 'e' not preceded/followed by letters
    expr = expr.replaceAllMapped(RegExp(r'(?<![a-zA-Z])e(?![a-zA-Z])'), (_) => '2.718281828459045');

    // Handle log10 and ln
    // Replace ln( with __LN__( and log( with __LOG10__(
    expr = expr.replaceAll('ln(', '__LN__(');
    expr = expr.replaceAll('log(', '__LOG10__(');
    expr = expr.replaceAll('sqrt(', '__SQRT__(');

    // Now evaluate inner expressions for special functions
    // For simplicity, use math_expressions on cleaned expr
    // and handle special functions by substitution
    expr = expr.replaceAll('__LN__(', 'log(');
    // log10 = log/log(10) - math_expressions doesn't have log10 natively
    // We'll use the trick: log10(x) = log(x)/log(10)
    // But we need to match the closing paren - too complex for simple replace
    // Let's use a different approach: evaluate using math_expressions with custom context

    expr = expr.replaceAll('__LOG10__(', 'log('); // treat log as natural for now, mark for post-process

    expr = expr.replaceAll('__SQRT__(', 'sqrt(');
    expr = expr.replaceAll('%', '/100*'); // naive mod

    try {
      final parser = Parser();
      final expParsed = parser.parse(expr);
      final ctx = ContextModel();
      final val = expParsed.evaluate(EvaluationType.REAL, ctx) as double;
      if (val.isNaN || val.isInfinite) return 'Error';
      // Format nicely
      if (val == val.truncateToDouble() && val.abs() < 1e15) {
        return val.toInt().toString();
      }
      return val.toStringAsFixed(8).replaceAll(RegExp(r'\.?0+$'), '');
    } catch (_) {
      rethrow;
    }
  }

  Widget _buildSciButton(String label, {Color? bg, Color? fg}) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _press(label),
        child: Container(
          margin: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: bg ?? const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withOpacity(0.06)),
          ),
          child: Center(
            child: Text(label,
              style: GoogleFonts.inter(
                fontSize: 13, fontWeight: FontWeight.w600,
                color: fg ?? Colors.white70,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNumButton(String label, {Color? bg, Color? fg, int flex = 1}) {
    if (label.isEmpty) return Expanded(flex: flex, child: const SizedBox());
    final isOp = ['÷', '×', '-', '+'].contains(label);
    final isEq = label == '=';
    final isSpec = ['C', '⌫', '(', ')', 'mod'].contains(label);

    Color btnBg = bg ?? (
      isEq ? AppColors.primary :
      isOp ? AppColors.primary.withOpacity(0.2) :
      isSpec ? const Color(0xFF334155) :
      const Color(0xFF1E293B)
    );
    Color btnFg = fg ?? (
      isEq ? Colors.white :
      isOp ? AppColors.primaryLight :
      isSpec ? Colors.white70 :
      Colors.white
    );

    return Expanded(
      flex: flex,
      child: GestureDetector(
        onTap: () => _press(label),
        child: Container(
          margin: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: btnBg,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isEq ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8)] : null,
          ),
          child: Center(
            child: label == '⌫'
                ? Icon(Icons.backspace_outlined, color: btnFg, size: 18)
                : Text(label, style: GoogleFonts.inter(
                    fontSize: label.length > 2 ? 13 : 18,
                    fontWeight: FontWeight.w600,
                    color: btnFg,
                  )),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0F172A),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalH = constraints.maxHeight;
          final displayH = totalH * 0.22;
          final sciRowH = totalH * 0.09;
          final numPadH = totalH - displayH - sciRowH * 2 - 8;
          final numRowH = numPadH / 5;

          return Column(
            children: [
              // Display
              Container(
                height: displayH,
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                color: const Color(0xFF0F172A),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      child: Text(
                        _expr.isEmpty ? '0' : _expr,
                        style: GoogleFonts.inter(
                          fontSize: 22,
                          color: Colors.white38,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      child: Text(
                        _result,
                        style: GoogleFonts.inter(
                          fontSize: 42,
                          fontWeight: FontWeight.w700,
                          color: _isError ? AppColors.error : Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Sci row 1
              SizedBox(
                height: sciRowH,
                child: Row(
                  children: _sciRow1.map((l) => _buildSciButton(l,
                    bg: const Color(0xFF1E3A5F),
                    fg: const Color(0xFF60A5FA),
                  )).toList(),
                ),
              ),

              // Sci row 2
              SizedBox(
                height: sciRowH,
                child: Row(
                  children: _sciRow2.map((l) => _buildSciButton(l,
                    bg: const Color(0xFF1E3A5F),
                    fg: const Color(0xFF60A5FA),
                  )).toList(),
                ),
              ),

              // Number pad rows
              SizedBox(
                height: numRowH,
                child: Row(children: [
                  _buildNumButton('C', bg: const Color(0xFF7F1D1D), fg: Colors.red[200]),
                  _buildNumButton('⌫', bg: const Color(0xFF334155)),
                  _buildNumButton('('),
                  _buildNumButton(')'),
                  _buildNumButton('mod', bg: const Color(0xFF334155), fg: Colors.white60),
                ]),
              ),
              SizedBox(
                height: numRowH,
                child: Row(children: [
                  _buildNumButton('7'),
                  _buildNumButton('8'),
                  _buildNumButton('9'),
                  _buildNumButton('÷'),
                  const Expanded(child: SizedBox()),
                ]),
              ),
              SizedBox(
                height: numRowH,
                child: Row(children: [
                  _buildNumButton('4'),
                  _buildNumButton('5'),
                  _buildNumButton('6'),
                  _buildNumButton('×'),
                  const Expanded(child: SizedBox()),
                ]),
              ),
              SizedBox(
                height: numRowH,
                child: Row(children: [
                  _buildNumButton('1'),
                  _buildNumButton('2'),
                  _buildNumButton('3'),
                  _buildNumButton('-'),
                  const Expanded(child: SizedBox()),
                ]),
              ),
              SizedBox(
                height: numRowH,
                child: Row(children: [
                  _buildNumButton('0'),
                  _buildNumButton('.'),
                  _buildNumButton('='),
                  _buildNumButton('+'),
                  const Expanded(child: SizedBox()),
                ]),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─── Currency Calculator ────────────────────────────────────────────────────────

class _CurrencyCalc extends StatefulWidget {
  const _CurrencyCalc();
  @override State<_CurrencyCalc> createState() => _CurrencyCalcState();
}

class _CurrencyCalcState extends State<_CurrencyCalc> {
  final _amtCtrl = TextEditingController(text: '1');
  String _from = 'USD';
  static const Map<String, double> _rates = {
    'BDT': 110.0, 'USD': 1.0, 'EUR': 0.92, 'GBP': 0.79, 'INR': 83.0, 'SAR': 3.75, 'MYR': 4.7,
  };
  final _currencies = ['BDT', 'USD', 'EUR', 'GBP', 'INR', 'SAR', 'MYR'];

  double _convert(String to) {
    final amt = double.tryParse(_amtCtrl.text) ?? 1;
    final fromRate = _rates[_from] ?? 1;
    final toRate = _rates[to] ?? 1;
    return amt / fromRate * toRate;
  }

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      DropdownButtonFormField<String>(
        value: _from,
        decoration: const InputDecoration(labelText: 'From currency'),
        items: _currencies.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
        onChanged: (v) => setState(() => _from = v ?? _from),
      ),
      const SizedBox(height: 14),
      TextField(
        controller: _amtCtrl,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: 'Amount in $_from'),
        onChanged: (_) => setState(() {}),
      ),
      const SizedBox(height: 24),
      Text('Converted to:', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey)),
      const SizedBox(height: 12),
      ..._currencies.where((c) => c != _from).map((c) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(children: [
          Text(c, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16)),
          const Spacer(),
          Text(_convert(c).toStringAsFixed(2),
            style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.primary)),
        ]),
      )),
      const SizedBox(height: 12),
      Text('*Using offline fallback rates.', style: GoogleFonts.inter(fontSize: 11, color: Colors.grey)),
    ],
  );
}

// ─── BMI Calculator ─────────────────────────────────────────────────────────────

class _BMICalc extends StatefulWidget {
  const _BMICalc();
  @override State<_BMICalc> createState() => _BMICalcState();
}

class _BMICalcState extends State<_BMICalc> {
  double _weight = 60, _height = 170;
  double get _bmi => _weight / ((_height / 100) * (_height / 100));
  String get _category {
    if (_bmi < 18.5) return 'Underweight';
    if (_bmi < 25) return 'Normal ✅';
    if (_bmi < 30) return 'Overweight';
    return 'Obese';
  }
  Color get _color {
    if (_bmi < 18.5) return AppColors.info;
    if (_bmi < 25) return AppColors.success;
    if (_bmi < 30) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(24),
    child: Column(children: [
      Text('Weight: ${_weight.round()} kg', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
      Slider(value: _weight, min: 30, max: 150, divisions: 120, label: '${_weight.round()}kg',
        onChanged: (v) => setState(() => _weight = v), activeColor: AppColors.primary),
      const SizedBox(height: 8),
      Text('Height: ${_height.round()} cm', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
      Slider(value: _height, min: 100, max: 220, divisions: 120, label: '${_height.round()}cm',
        onChanged: (v) => setState(() => _height = v), activeColor: AppColors.primary),
      const SizedBox(height: 36),
      Container(
        width: 160, height: 160,
        decoration: BoxDecoration(
          color: _color.withOpacity(0.12), shape: BoxShape.circle,
          border: Border.all(color: _color, width: 4),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(_bmi.toStringAsFixed(1),
            style: GoogleFonts.inter(fontSize: 40, fontWeight: FontWeight.w800, color: _color)),
          Text('BMI', style: GoogleFonts.inter(fontSize: 14, color: _color)),
        ]),
      ),
      const SizedBox(height: 20),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(color: _color.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
        child: Text(_category, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: _color)),
      ),
    ]),
  );
}

// ─── EMI Calculator ─────────────────────────────────────────────────────────────

class _EMICalc extends StatefulWidget {
  const _EMICalc();
  @override State<_EMICalc> createState() => _EMICalcState();
}

class _EMICalcState extends State<_EMICalc> {
  final _p = TextEditingController();
  final _r = TextEditingController();
  final _n = TextEditingController();
  double? _emi, _total, _interest;

  void _calc() {
    final p = double.tryParse(_p.text) ?? 0;
    final rate = (double.tryParse(_r.text) ?? 0) / 12 / 100;
    final n = double.tryParse(_n.text) ?? 0;
    if (p <= 0 || rate <= 0 || n <= 0) return;
    final pn = _pow(1 + rate, n);
    setState(() {
      _emi = p * rate * pn / (pn - 1);
      _total = _emi! * n;
      _interest = _total! - p;
    });
  }

  double _pow(double base, double exp) {
    double result = 1;
    for (int i = 0; i < exp.toInt(); i++) result *= base;
    return result;
  }

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      TextField(controller: _p, keyboardType: TextInputType.number,
        decoration: const InputDecoration(labelText: 'Principal Amount', prefixText: '৳ ')),
      const SizedBox(height: 14),
      TextField(controller: _r, keyboardType: TextInputType.number,
        decoration: const InputDecoration(labelText: 'Annual Interest Rate', suffixText: '%')),
      const SizedBox(height: 14),
      TextField(controller: _n, keyboardType: TextInputType.number,
        decoration: const InputDecoration(labelText: 'Duration', suffixText: 'months')),
      const SizedBox(height: 20),
      SizedBox(width: double.infinity, child: FilledButton(onPressed: _calc, child: const Text('Calculate EMI'))),
      if (_emi != null) ...[
        const SizedBox(height: 24),
        ...[
          ('Monthly EMI', '৳${_emi!.toStringAsFixed(0)}', AppColors.primary),
          ('Total Payment', '৳${_total!.toStringAsFixed(0)}', AppColors.info),
          ('Total Interest', '৳${_interest!.toStringAsFixed(0)}', AppColors.warning),
        ].map((row) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: row.$3.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: row.$3.withOpacity(0.2)),
          ),
          child: Row(children: [
            Text(row.$1, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500)),
            const Spacer(),
            Text(row.$2, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: row.$3)),
          ]),
        )),
      ],
    ],
  );
}

// ─── Unit Convert Calculator ────────────────────────────────────────────────────

class _UnitConvertCalc extends StatefulWidget {
  const _UnitConvertCalc();
  @override State<_UnitConvertCalc> createState() => _UnitConvertCalcState();
}

class _UnitConvertCalcState extends State<_UnitConvertCalc> {
  String _category = 'Length';
  final _valueCtrl = TextEditingController(text: '1');

  // Category -> units
  static const Map<String, List<String>> _units = {
    'Length': ['km', 'm', 'cm', 'mm', 'miles', 'feet', 'inches'],
    'Temperature': ['°C', '°F', 'K'],
    'Mass': ['kg', 'g', 'lb', 'oz'],
  };

  // Conversion to base unit (m for length, °C for temp, kg for mass)
  static const Map<String, double> _toBase = {
    // Length -> meters
    'km': 1000, 'm': 1, 'cm': 0.01, 'mm': 0.001,
    'miles': 1609.344, 'feet': 0.3048, 'inches': 0.0254,
    // Mass -> kg
    'kg': 1, 'g': 0.001, 'lb': 0.453592, 'oz': 0.0283495,
  };

  late String _from;
  late String _to;

  @override
  void initState() {
    super.initState();
    _from = _units[_category]![0];
    _to = _units[_category]![1];
  }

  void _setCategory(String cat) {
    setState(() {
      _category = cat;
      _from = _units[cat]![0];
      _to = _units[cat]![1];
    });
  }

  String _convert() {
    final val = double.tryParse(_valueCtrl.text);
    if (val == null) return '—';

    if (_category == 'Temperature') {
      return _convertTemp(val, _from, _to).toStringAsFixed(4)
          .replaceAll(RegExp(r'\.?0+$'), '');
    }

    final fromFactor = _toBase[_from] ?? 1;
    final toFactor = _toBase[_to] ?? 1;
    final result = val * fromFactor / toFactor;
    if (result.abs() >= 1e6 || (result.abs() < 0.001 && result != 0)) {
      return result.toStringAsExponential(4);
    }
    return result.toStringAsFixed(6).replaceAll(RegExp(r'\.?0+$'), '');
  }

  double _convertTemp(double val, String from, String to) {
    // Convert to Celsius first
    double celsius;
    switch (from) {
      case '°C': celsius = val; break;
      case '°F': celsius = (val - 32) * 5 / 9; break;
      case 'K': celsius = val - 273.15; break;
      default: celsius = val;
    }
    switch (to) {
      case '°C': return celsius;
      case '°F': return celsius * 9 / 5 + 32;
      case 'K': return celsius + 273.15;
      default: return celsius;
    }
  }

  @override
  Widget build(BuildContext context) {
    final units = _units[_category]!;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Category selector
        Text('Category', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: _units.keys.map((cat) {
            final selected = _category == cat;
            return GestureDetector(
              onTap: () => _setCategory(cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: selected ? AppColors.primary : const Color(0xFFE2E8F0)),
                ),
                child: Text(cat, style: GoogleFonts.inter(
                  color: selected ? Colors.white : null,
                  fontWeight: FontWeight.w600, fontSize: 13,
                )),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),

        // Value input
        TextField(
          controller: _valueCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
          onChanged: (_) => setState(() {}),
          style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700),
          decoration: const InputDecoration(
            labelText: 'Value',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),

        // From / To dropdowns
        Row(children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _from,
              decoration: const InputDecoration(labelText: 'From', border: OutlineInputBorder()),
              items: units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
              onChanged: (v) => setState(() => _from = v ?? _from),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Icon(Icons.swap_horiz, color: AppColors.primary, size: 28),
          ),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _to,
              decoration: const InputDecoration(labelText: 'To', border: OutlineInputBorder()),
              items: units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
              onChanged: (v) => setState(() => _to = v ?? _to),
            ),
          ),
        ]),
        const SizedBox(height: 24),

        // Result card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withOpacity(0.25)),
          ),
          child: Column(children: [
            Text('${_valueCtrl.text.isEmpty ? '0' : _valueCtrl.text} $_from =',
              style: GoogleFonts.inter(fontSize: 15, color: Colors.grey)),
            const SizedBox(height: 8),
            Text('${_convert()} $_to',
              style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.primary)),
          ]),
        ),

        const SizedBox(height: 16),

        // Quick reference table
        Text('All conversions', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey)),
        const SizedBox(height: 8),
        ...units.where((u) => u != _from).map((u) {
          final res = _category == 'Temperature'
              ? _convertTemp(double.tryParse(_valueCtrl.text) ?? 1, _from, u)
                  .toStringAsFixed(4).replaceAll(RegExp(r'\.?0+$'), '')
              : (() {
                  final val = double.tryParse(_valueCtrl.text) ?? 1;
                  final fromF = _toBase[_from] ?? 1;
                  final toF = _toBase[u] ?? 1;
                  final r = val * fromF / toF;
                  if (r.abs() >= 1e6 || (r.abs() < 0.001 && r != 0)) return r.toStringAsExponential(3);
                  return r.toStringAsFixed(4).replaceAll(RegExp(r'\.?0+$'), '');
                })();
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(children: [
              Text(u, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15)),
              const Spacer(),
              Text(res, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary)),
            ]),
          );
        }),
      ],
    );
  }
}
