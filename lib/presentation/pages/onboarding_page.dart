import 'package:flutter/material.dart';
import 'tasks_page.dart';
import '../theme/app_theme.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final PageController pageController = PageController();
    final ValueNotifier<int> currentPageNotifier = ValueNotifier<int>(0);

    final List<Map<String, dynamic>> pages = [
      {
        'title': 'Welcome to SyncStrive',
        'description':
            'Your personal task manager designed to keep you focused and organized.',
        'image': 'assets/images/onboarding1.png',
        'color': const Color(0xFF1E293B),
      },
      {
        'title': 'Create and Organize',
        'description':
            'Create tasks, add details, set due dates, and organize them in custom lists.',
        'image': 'assets/images/onboarding2.png',
        'color': const Color(0xFF0EA5E9),
      },
      {
        'title': 'Stay Productive',
        'description':
            'With only the features you need, SyncStrive is customized for a stress-free productivity experience.',
        'image': 'assets/images/onboarding3.png',
        'color': AppTheme.primaryDarkColor,
      },
    ];

    void onPageChanged(int page) {
      currentPageNotifier.value = page;
    }

    void navigateToNextPage() {
      if (currentPageNotifier.value < pages.length - 1) {
        pageController.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const TasksPage(),
          ),
        );
      }
    }

    Widget buildOnboardingPage(int index) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.4,
              margin: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: pages[index]['color'],
                borderRadius: BorderRadius.circular(24),
                boxShadow: [AppTheme.smallShadow],
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 24,
                    left: 24,
                    child: Text(
                      'Sync\nStrive',
                      style: AppTheme.headingMedium.copyWith(
                        color: Colors.white,
                        fontSize: 28,
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: StaticShapes(colorIndex: index),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              pages[index]['title'],
              style: AppTheme.headingLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              pages[index]['description'],
              style: AppTheme.bodyLarge.copyWith(
                color: AppTheme.textMediumColor,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    Widget buildDot(int index, int currentPage) {
      final isActive = index == currentPage;

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        height: 8,
        width: isActive ? 24 : 8,
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primaryColor : AppTheme.borderColor,
          borderRadius: BorderRadius.circular(4),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            ValueListenableBuilder<int>(
              valueListenable: currentPageNotifier,
              builder: (context, currentPage, _) {
                return Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: currentPage < pages.length - 1
                        ? TextButton(
                            onPressed: () {
                              pageController.animateToPage(
                                pages.length - 1,
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: Text(
                              'Skip',
                              style: AppTheme.bodyMedium.copyWith(
                                color: AppTheme.textMediumColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                );
              },
            ),
            Expanded(
              child: PageView.builder(
                controller: pageController,
                onPageChanged: onPageChanged,
                itemCount: pages.length,
                itemBuilder: (context, index) {
                  return buildOnboardingPage(index);
                },
              ),
            ),
            ValueListenableBuilder<int>(
              valueListenable: currentPageNotifier,
              builder: (context, currentPage, _) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      pages.length,
                      (index) => buildDot(index, currentPage),
                    ),
                  ),
                );
              },
            ),
            ValueListenableBuilder<int>(
              valueListenable: currentPageNotifier,
              builder: (context, currentPage, _) {
                return Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: navigateToNextPage,
                      style: AppTheme.primaryButtonStyle,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          currentPage < pages.length - 1
                              ? 'Continue'
                              : 'Get Started',
                          style: AppTheme.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class StaticShapes extends StatelessWidget {
  final int colorIndex;

  const StaticShapes({Key? key, required this.colorIndex}) : super(key: key);

  Color getShapeColor(int baseValue) {
    final colors = [
      AppTheme.primaryColor,
      AppTheme.infoColor,
      AppTheme.warningColor,
      AppTheme.accentColor,
    ];

    return colors[(colorIndex + baseValue) % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 50,
          right: 50,
          child: Container(
            width: 70,
            height: 80,
            decoration: BoxDecoration(
              color: getShapeColor(0),
              borderRadius: BorderRadius.circular(40),
            ),
          ),
        ),
        Positioned(
          top: 120,
          left: 40,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: getShapeColor(1),
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
        Positioned(
          bottom: 40,
          right: 60,
          child: Container(
            width: 50,
            height: 80,
            decoration: BoxDecoration(
              color: getShapeColor(2),
              borderRadius: BorderRadius.circular(40),
            ),
          ),
        ),
        Positioned(
          top: 70,
          left: 100,
          child: Container(
            width: 15,
            height: 15,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          bottom: 80,
          right: 30,
          child: Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}
