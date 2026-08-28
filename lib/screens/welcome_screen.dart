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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxHeight < 700;
            final horizontalPadding = constraints.maxWidth < 360 ? 18.0 : 22.0;
            final content = Column(
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
                        _MoonMark(size: compact ? 38 : 42),
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
                      compact: compact,
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
                SizedBox(height: compact ? 16 : 24),
                PrimaryButton(
                  label: _index == _slides.length - 1 ? 'ابدئي الآن' : 'التالي',
                  onPressed: _next,
                ),
                SizedBox(height: compact ? 2 : 5),
                TextButton(
                  onPressed: widget.onSignIn,
                  child: Text.rich(
                    TextSpan(
                      style: TextStyle(
                        color: numuwSecondaryTextColor(),
                        fontSize: compact ? 14 : 15,
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
            );

            return Padding(
              padding: EdgeInsetsDirectional.fromSTEB(
                horizontalPadding,
                compact ? 6 : 12,
                horizontalPadding,
                compact ? 10 : 20,
              ),
              child: content,
            );
          },
        ),
      ),
    );
  }
}

class _SlideView extends StatelessWidget {
  const _SlideView({
    required this.slide,
    required this.index,
    required this.compact,
  });

  final _Slide slide;
  final int index;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final accent = numuwAccentColor();
    final illustrationHeight = compact ? 178.0 : 245.0;
    final outerCircle = compact ? 164.0 : 220.0;
    final innerCircle = compact ? 116.0 : 150.0;
    final floatingCircle = compact ? 48.0 : 62.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          flex: compact ? 5 : 6,
          child: Center(
            child: SizedBox(
              height: illustrationHeight,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: outerCircle,
                    height: outerCircle,
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
                    width: innerCircle,
                    height: innerCircle,
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
                          blurRadius: compact ? 24 : 34,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Icon(
                      slide.icon,
                      color: accent,
                      size: compact ? 52 : 68,
                    ),
                  ),
                  if (index == 0)
                    PositionedDirectional(
                      bottom: compact ? 12 : 24,
                      start: compact ? 34 : 40,
                      child: Container(
                        width: floatingCircle,
                        height: floatingCircle,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.peachLight,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.peach.withValues(alpha: .22),
                          ),
                        ),
                        child: Text(
                          '🤱',
                          style: TextStyle(fontSize: compact ? 24 : 30),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: compact ? 8 : 14),
        Text(
          slide.title,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: numuwTextColor(),
            fontSize: compact ? 22 : 26,
            height: 1.35,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: compact ? 8 : 13),
        Flexible(
          flex: compact ? 2 : 1,
          child: Text(
            slide.description,
            textAlign: TextAlign.center,
            maxLines: compact ? 3 : 4,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: numuwSecondaryTextColor(),
              fontSize: compact ? 14 : 16,
              height: compact ? 1.55 : 1.75,
            ),
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
