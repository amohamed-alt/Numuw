import 'package:flutter/material.dart';

import '../widgets/app_widgets.dart';

class DoctorReportScreen extends StatelessWidget {
  const DoctorReportScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: numuwPageColor(),
        appBar: AppBar(title: const Text('تقرير زيارة الطبيب')),
        body: const AppPage(
          child: Center(child: CircularProgressIndicator()),
        ),
      );
}
