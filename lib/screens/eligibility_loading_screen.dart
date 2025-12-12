import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/user.dart';
import '../models/eligibility.dart';
import 'eligibility_result_screen.dart';

class EligibilityLoadingScreen extends StatefulWidget {
  final String language;
  final EligibilityResult result;
  final User user;

  const EligibilityLoadingScreen({
    Key? key,
    required this.language,
    required this.result,
    required this.user,
  }) : super(key: key);

  @override
  State<EligibilityLoadingScreen> createState() => _EligibilityLoadingScreenState();
}

class _EligibilityLoadingScreenState extends State<EligibilityLoadingScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _checkController;

  late final List<String> _checkingSteps;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();

    // Define checking steps
    _checkingSteps = widget.language == 'ms'
        ? [
            'Menyemak kewarganegaraan...',
            'Menyemak umur...',
            'Menyemak pendapatan isi rumah...',
            'Menyemak bantuan sedia ada...',
            'Mengira kelayakan...',
          ]
        : [
            'Checking citizenship...',
            'Checking age...',
            'Checking household income...',
            'Checking existing aids...',
            'Calculating eligibility...',
          ];

    // Initialize animation controllers
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Start checking steps animation
    _animateSteps();
  }

  void _animateSteps() async {
    for (int i = 0; i < _checkingSteps.length; i++) {
      await Future.delayed(Duration(milliseconds: i == 0 ? 500 : 800));
      if (mounted) {
        setState(() {
          _currentStep = i;
        });
        _checkController.forward(from: 0);
      }
    }

    // After all steps complete, wait a bit then navigate to result screen
    await Future.delayed(const Duration(milliseconds: 800));

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => EligibilityResultScreen(
            user: widget.user,
            result: widget.result,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    _checkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = widget.language;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated circular progress with rotating rings
                SizedBox(
                  height: 200,
                  width: 200,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer rotating ring
                      AnimatedBuilder(
                        animation: _rotationController,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _rotationController.value * 2 * math.pi,
                            child: Container(
                              height: 180,
                              width: 180,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: theme.colorScheme.primary.withOpacity(0.3),
                                  width: 3,
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      // Middle pulsing circle
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return Container(
                            height: 140 + (_pulseController.value * 20),
                            width: 140 + (_pulseController.value * 20),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: theme.colorScheme.primary
                                  .withOpacity(0.1 + (_pulseController.value * 0.1)),
                            ),
                          );
                        },
                      ),

                      // Inner icon
                      Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.colorScheme.primary,
                        ),
                        child: Icon(
                          Icons.verified_user,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),

                      // Progress dots around the circle
                      ...List.generate(8, (index) {
                        return AnimatedBuilder(
                          animation: _rotationController,
                          builder: (context, child) {
                            final angle = (index / 8) * 2 * math.pi +
                                (_rotationController.value * 2 * math.pi);
                            final x = math.cos(angle) * 90;
                            final y = math.sin(angle) * 90;

                            return Transform.translate(
                              offset: Offset(x, y),
                              child: Container(
                                height: 8,
                                width: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: theme.colorScheme.primary
                                      .withOpacity(0.5 + (_rotationController.value * 0.5)),
                                ),
                              ),
                            );
                          },
                        );
                      }),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Main title
                Text(
                  lang == 'ms'
                      ? 'Menyemak Kelayakan Peka B40'
                      : 'Checking Peka B40 Eligibility',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                Text(
                  lang == 'ms'
                      ? 'Sila tunggu sebentar...'
                      : 'Please wait a moment...',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),

                const SizedBox(height: 40),

                // Checking steps
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(_checkingSteps.length, (index) {
                      final isCompleted = index < _currentStep;
                      final isCurrent = index == _currentStep;
                      final isPending = index > _currentStep;

                      return AnimatedOpacity(
                        opacity: isPending ? 0.3 : 1.0,
                        duration: const Duration(milliseconds: 300),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              // Step indicator
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                height: 24,
                                width: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isCompleted
                                      ? Colors.green
                                      : isCurrent
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme.outline.withOpacity(0.2),
                                ),
                                child: isCompleted
                                    ? const Icon(
                                        Icons.check,
                                        size: 16,
                                        color: Colors.white,
                                      )
                                    : isCurrent
                                        ? SizedBox(
                                            height: 16,
                                            width: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                            ),
                                          )
                                        : null,
                              ),

                              const SizedBox(width: 12),

                              // Step text
                              Expanded(
                                child: Text(
                                  _checkingSteps[index],
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: isCurrent || isCompleted
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                    color: isCompleted
                                        ? Colors.green
                                        : isCurrent
                                            ? theme.colorScheme.primary
                                            : theme.colorScheme.onSurface.withOpacity(0.4),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
