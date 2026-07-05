import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../widgets/app_widgets.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({
    super.key,
    required this.onSignIn,
    required this.onSignUp,
  });

  final VoidCallback onSignIn;
  final VoidCallback onSignUp;

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  static const _slides = [
    _Slide(
      title: 'كل تفاصيل يوم طفلك في مكان واحد',
      description:
          'سجّلي الرضاعة والنوم والحفاضات بسهولة، حتى في منتصف الليل.',
      icon: Icons.child_friendly_rounded,
    ),
    _Slide(
      title: 'مساعد ذكي يفهم يومك',
      description:
          'اسألي نُمُوّ، راجعي تسجيلات طفلك، وجهّزي أسئلتك قبل زيارة الطبيب.',
      icon: Icons.auto_awesome_rounded,
    ),
    _Slide(
      title: 'لستِ وحدك',
      description:
          'شاركي الأب أو أحد أفراد الأسرة واجعلي رعاية طفلك أسهل.',
      icon: Icons.family_restroom_rounded,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_index == _slides.length - 1) {
      widget.onSignUp();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 340),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = numuwAccentColor();
    return Scaffold(
      backgroundColor: numuwPageColor(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(22, 12, 22, 20),
          child: Column(
            children: [
              Row(
                children: [
                  TextButton(
                    onPressed: widget.onSignUp,
                    child: Text(
                      'تخطي',
                      style: TextStyle(color: numuwSecondaryTextColor()),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Text(
                        'نُمُوّ',
                        style: TextStyle(
                          color: numuwTextColor(),
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _MoonMark(size: 42),
                    ],
                  ),
                ],
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _slides.length,
                  onPageChanged: (value) => setState(() => _index = value),
                  itemBuilder: (context, index) => _SlideView(
                    slide: _slides[index],
                    index: index,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _slides.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 240),
                    width: index == _index ? 26 : 8,
                    height: 8,
                    margin: const EdgeInsetsDirectional.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: index == _index ? accent : numuwBorderColor(),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: _index == _slides.length - 1 ? 'ابدئي الآن' : 'التالي',
                onPressed: _next,
              ),
              const SizedBox(height: 5),
              TextButton(
                onPressed: widget.onSignIn,
                child: Text.rich(
                  TextSpan(
                    style: TextStyle(
                      color: numuwSecondaryTextColor(),
                      fontSize: 15,
                    ),
                    children: [
                      const TextSpan(text: 'لديكِ حساب بالفعل؟ '),
                      TextSpan(
                        text: 'تسجيل الدخول',
                        style: TextStyle(
                          color: accent,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SlideView extends StatelessWidget {
  const _SlideView({required this.slide, required this.index});

  final _Slide slide;
  final int index;

  @override
  Widget build(BuildContext context) {
    final accent = numuwAccentColor();
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 245,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      accent.withValues(alpha: .18),
                      accent.withValues(alpha: .03),
                    ],
                  ),
                ),
              ),
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: numuwSurfaceColor(),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: accent.withValues(alpha: .26),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: .16),
                      blurRadius: 34,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Icon(slide.icon, color: accent, size: 68),
              ),
              if (index == 0)
                PositionedDirectional(
                  bottom: 24,
                  start: 40,
                  child: Container(
                    width: 62,
                    height: 62,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.peachLight,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.peach.withValues(alpha: .22),
                      ),
                    ),
                    child: const Text('🤱', style: TextStyle(fontSize: 30)),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          slide.title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: numuwTextColor(),
            fontSize: 26,
            height: 1.4,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 13),
        Text(
          slide.description,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: numuwSecondaryTextColor(),
            fontSize: 16,
            height: 1.75,
          ),
        ),
      ],
    );
  }
}

class _MoonMark extends StatelessWidget {
  const _MoonMark({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: numuwAccentColor().withValues(alpha: .14),
          shape: BoxShape.circle,
          border: Border.all(
            color: numuwAccentColor().withValues(alpha: .28),
          ),
        ),
        child: Icon(
          Icons.nightlight_round,
          color: numuwAccentColor(),
          size: size * .56,
        ),
      );
}

class _Slide {
  const _Slide({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;
}
