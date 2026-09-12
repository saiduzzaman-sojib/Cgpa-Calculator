import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/database_helper.dart';
import 'calculate_cgpa_screen.dart';
import 'semester_report_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = 'User';
  String _userInitials = 'U';
  String? _profileImagePath;
  double _currentCgpa = 0.00;
  double _totalCredits = 0.0;
  
  List<Map<String, dynamic>> _chartData = [];
  bool _animateChart = false;
  
  int _selectedChartType = 1; 

  final List<Color> _chartColors = [
    const Color(0xFF3B82F6), 
    const Color(0xFF10B981), 
    const Color(0xFFF59E0B), 
    const Color(0xFFEC4899), 
    const Color(0xFF8B5CF6), 
    const Color(0xFF14B8A6), 
    const Color(0xFFF43F5E), 
  ];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final prefs = await SharedPreferences.getInstance();
    
    String name = prefs.getString('user_name') ?? 'User';
    String? imagePath = prefs.getString('profile_image_path');
    String initials = 'U';
    
    if (name.isNotEmpty) {
      List<String> nameParts = name.trim().split(' ');
      if (nameParts.length > 1) {
        initials = '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
      } else {
        initials = nameParts[0][0].toUpperCase();
      }
    }

    int? userId = prefs.getInt('user_id');
    
    double totalEarnedCredits = 0.0;
    double totalCgpaPoints = 0.0;
    double simpleCgpaSum = 0.0;
    int validSemesters = 0;
    
    List<Map<String, dynamic>> tempData = [];

    if (userId != null) {
      final dbHelper = DatabaseHelper();
      final semesters = await dbHelper.getSemesters(userId);
      
      final chartSemesters = semesters.reversed.toList();

      for (var item in chartSemesters) {
        double cgpa = item['sgpa'] != null ? (item['sgpa'] as num).toDouble() : 0.0;
        double credit = item['total_credits'] != null ? (item['total_credits'] as num).toDouble() : 0.0;
        
        if (cgpa > 0) {
          totalEarnedCredits += credit;
          totalCgpaPoints += (cgpa * credit); 
          simpleCgpaSum += cgpa;
          validSemesters++;
          
          tempData.add({
            'name': item['semester_name'] ?? '',
            'cgpa': cgpa,
            'credit': credit,
          });
        }
      }
    }

    double finalCgpa = 0.00;
    if (totalEarnedCredits > 0) {
      finalCgpa = totalCgpaPoints / totalEarnedCredits; 
    } else if (validSemesters > 0) {
      finalCgpa = simpleCgpaSum / validSemesters; 
    }

    setState(() {
      _userName = name;
      _userInitials = initials;
      _profileImagePath = imagePath;
      _currentCgpa = finalCgpa;
      _totalCredits = totalEarnedCredits;
      _chartData = tempData;
      _animateChart = false; 
    });

    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) {
        setState(() {
          _animateChart = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    String displayCredits = _totalCredits == _totalCredits.toInt() 
        ? _totalCredits.toInt().toString() 
        : _totalCredits.toStringAsFixed(1);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                'Hello, $_userName',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text('👋', style: TextStyle(fontSize: 24)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Keep going! You\'re doing great',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.blue.shade50,
                    backgroundImage: _profileImagePath != null ? FileImage(File(_profileImagePath!)) : null,
                    child: _profileImagePath == null
                        ? Text(
                            _userInitials,
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          )
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C4380),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2C4380).withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Overall CGPA',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _currentCgpa.toStringAsFixed(2),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark ? Colors.transparent : Colors.grey.shade200,
                        ),
                        boxShadow: isDark
                            ? []
                            : [
                                BoxShadow(
                                  color: Colors.grey.shade100,
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Credits',
                            style: TextStyle(
                              color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            displayCredits,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CalculateCgpaScreen()),
                        );
                        _loadDashboardData(); 
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : theme.colorScheme.primary.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? Colors.transparent : theme.colorScheme.primary.withOpacity(0.1),
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.calculate_rounded,
                              color: theme.colorScheme.primary,
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Calculate CGPA',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SemesterReportScreen()),
                        );
                        _loadDashboardData(); 
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? Colors.transparent : Colors.grey.shade200,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.assessment_rounded,
                              color: Colors.grey.shade600,
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Semester Report',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              if (_chartData.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Performance Analytics',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          _buildChartToggleBtn(Icons.bar_chart_rounded, 0, isDark, theme),
                          _buildChartToggleBtn(Icons.show_chart_rounded, 1, isDark, theme),
                          _buildChartToggleBtn(Icons.pie_chart_rounded, 2, isDark, theme),
                        ],
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  height: 320, 
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(12, 20, 12, 12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark ? Colors.white10 : Colors.grey.shade200,
                    ),
                    boxShadow: isDark
                        ? []
                        : [
                            BoxShadow(
                              color: Colors.grey.shade100,
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _buildSelectedChart(theme, isDark),
                  ),
                ),
                const SizedBox(height: 20),
              ] else ...[
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      'No semester records yet.\nCalculate and save to see your analytics!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  ),
                )
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartToggleBtn(IconData icon, int index, bool isDark, ThemeData theme) {
    bool isSelected = _selectedChartType == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedChartType = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? (isDark ? theme.colorScheme.primary.withOpacity(0.3) : Colors.white) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected && !isDark ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] : [],
        ),
        child: Icon(
          icon,
          size: 20,
          color: isSelected ? theme.colorScheme.primary : (isDark ? Colors.grey.shade400 : Colors.grey.shade500),
        ),
      ),
    );
  }

  Widget _buildSelectedChart(ThemeData theme, bool isDark) {
    switch (_selectedChartType) {
      case 0: return _buildBarChart(theme, isDark);
      case 1: return _buildCleanLineChart(theme, isDark);
      case 2: return _buildPieChart(theme, isDark);
      default: return _buildCleanLineChart(theme, isDark);
    }
  }

  Widget _buildBarChart(ThemeData theme, bool isDark) {
    return SingleChildScrollView(
      key: const ValueKey('bar'),
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: SizedBox(
        width: math.max(MediaQuery.of(context).size.width - 72, _chartData.length * 60.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_chartData.length, (index) {
            final data = _chartData[index];
            double cgpa = data['cgpa'];
            String rawName = data['name'].toString();
            String shortName = rawName.toLowerCase().contains('semester') 
                ? rawName.replaceFirst(RegExp('semester', caseSensitive: false), 'Sem')
                : rawName;
            
            double barHeight = _animateChart ? (cgpa / 4.0) * 180 : 0.0;
            Color barColor = _chartColors[index % _chartColors.length];

            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 800),
                  opacity: _animateChart ? 1.0 : 0.0,
                  child: Text(
                    cgpa.toStringAsFixed(2),
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: barColor),
                  ),
                ),
                const SizedBox(height: 6),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutCubic,
                  height: barHeight,
                  width: 28,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [barColor, barColor.withOpacity(0.5)],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 8),
                Text(shortName, style: TextStyle(fontSize: 11, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontWeight: FontWeight.w600)),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildCleanLineChart(ThemeData theme, bool isDark) {
    List<double> cgpas = _chartData.map((e) => (e['cgpa'] as num).toDouble()).toList();
    List<String> labels = _chartData.map((e) {
      String r = e['name'].toString();
      return r.toLowerCase().contains('semester') ? r.replaceFirst(RegExp('semester', caseSensitive: false), 'Sem') : r;
    }).toList();
    
    return LayoutBuilder(
      builder: (context, constraints) {
        double computedWidth = math.max(constraints.maxWidth, _chartData.length * 65.0);
        return SingleChildScrollView(
          key: const ValueKey('clean_line'),
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: SizedBox(
            width: computedWidth,
            height: 280,
            child: CustomPaint(
              painter: CleanVerticalAxisLineChartPainter(
                cgpas: cgpas,
                labels: labels,
                primaryColor: theme.colorScheme.primary,
                isAnimated: _animateChart,
                isDark: isDark,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPieChart(ThemeData theme, bool isDark) {
    List<double> cgpas = _chartData.map((e) => (e['cgpa'] as num).toDouble()).toList();
    
    return Container(
      key: const ValueKey('pie'),
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(200, 200),
            painter: PieChartPainter(
              values: cgpas,
              colors: _chartColors,
              isAnimated: _animateChart,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Avg CGPA',
                style: TextStyle(fontSize: 11, color: isDark ? Colors.grey.shade400 : Colors.grey.shade500, fontWeight: FontWeight.w600),
              ),
              Text(
                _currentCgpa.toStringAsFixed(2),
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class CleanVerticalAxisLineChartPainter extends CustomPainter {
  final List<double> cgpas;
  final List<String> labels;
  final Color primaryColor;
  final bool isAnimated;
  final bool isDark;

  CleanVerticalAxisLineChartPainter({
    required this.cgpas,
    required this.labels,
    required this.primaryColor,
    required this.isAnimated,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (cgpas.isEmpty) return;

    final paintGridHoriz = Paint()
      ..color = isDark ? Colors.white10 : Colors.grey.shade200
      ..strokeWidth = 1.0;

    final paintGridVert = Paint()
      ..color = primaryColor.withOpacity(0.2)
      ..strokeWidth = 1.0;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right,
    );

    double leftPadding = 32.0; 
    double bottomPadding = 25.0; 
    double chartWidth = size.width - leftPadding;
    double chartHeight = size.height - bottomPadding;

    for (int i = 1; i <= 4; i++) {
      double y = chartHeight - ((i / 4.0) * (chartHeight - 20));
      
      canvas.drawLine(Offset(leftPadding, y), Offset(size.width, y), paintGridHoriz);

      textPainter.text = TextSpan(
        text: '$i.0',
        style: TextStyle(fontSize: 10, color: isDark ? Colors.grey.shade500 : Colors.grey.shade400, fontWeight: FontWeight.bold),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(2, y - textPainter.height / 2));
    }

    double stepX = chartWidth / cgpas.length;
    List<Offset> points = [];

    for (int i = 0; i < cgpas.length; i++) {
      double x = leftPadding + (i * stepX) + (stepX / 2);
      
      canvas.drawLine(Offset(x, chartHeight), Offset(x, 15), paintGridVert);

      double targetY = chartHeight - ((cgpas[i] / 4.0) * (chartHeight - 20));
      double y = isAnimated ? targetY : chartHeight;
      points.add(Offset(x, y));
    }

    final paintLine = Paint()
      ..color = primaryColor
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final paintDotOuter = Paint()..color = primaryColor.withOpacity(0.3)..style = PaintingStyle.fill;
    final paintDotInner = Paint()..color = isDark ? const Color(0xFF0F172A) : Colors.white..style = PaintingStyle.fill;
    final paintDotCenter = Paint()..color = primaryColor..style = PaintingStyle.fill;

    final path = Path();
    if (points.isNotEmpty) {
      path.moveTo(points.first.dx, points.first.dy);
      for (int i = 0; i < points.length - 1; i++) {
        var p0 = points[i];
        var p1 = points[i + 1];
        var controlPoint1 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p0.dy);
        var controlPoint2 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p1.dy);
        path.cubicTo(controlPoint1.dx, controlPoint1.dy, controlPoint2.dx, controlPoint2.dy, p1.dx, p1.dy);
      }

      canvas.drawPath(path, paintLine);

      for (int i = 0; i < points.length; i++) {
        canvas.drawCircle(points[i], 8.0, paintDotOuter);
        canvas.drawCircle(points[i], 5.0, paintDotInner);
        canvas.drawCircle(points[i], 3.0, paintDotCenter);

        textPainter.text = TextSpan(
          text: labels[i],
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
        );
        textPainter.layout();
        textPainter.paint(
          canvas, 
          Offset(points[i].dx - textPainter.width / 2, chartHeight + 6)
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class PieChartPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;
  final bool isAnimated;

  PieChartPainter({required this.values, required this.colors, required this.isAnimated});

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    double total = values.fold(0, (sum, item) => sum + item);
    double startAngle = -math.pi / 2;
    
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 32.0
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2) - (paint.strokeWidth / 2);

    for (int i = 0; i < values.length; i++) {
      double sweepAngle = (values[i] / total) * 2 * math.pi;
      if (!isAnimated) sweepAngle = 0; 
      
      paint.color = colors[i % colors.length];
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle - 0.04, 
        false,
        paint,
      );
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}