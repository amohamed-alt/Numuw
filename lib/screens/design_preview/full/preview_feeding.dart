import 'package:flutter/material.dart';

import '../../../widgets/classy/reference_feeding_pane.dart';
import 'preview_shared.dart';

class PreviewFeedingScreen extends StatefulWidget {
  const PreviewFeedingScreen({super.key, required this.black});

  final bool black;

  @override
  State<PreviewFeedingScreen> createState() => _PreviewFeedingScreenState();
}

class _PreviewFeedingScreenState extends State<PreviewFeedingScreen> {
  final _amount = TextEditingController(text: '60');
  final _notes = TextEditingController();
  final Set<String> _methods = {'breast'};
  String _side = 'right';
  int _amountMl = 60;
  bool _burped = false;
  bool _vomited = false;
  bool _active = false;

  @override
  void dispose() {
    _amount.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PreviewScreenScaffold(
        black: widget.black,
        showBack: false,
        padding: const EdgeInsetsDirectional.fromSTEB(20, 8, 20, 28),
        child: NumuwReferenceFeedingPane(
          active: _active,
          timerText: _active ? '00:18' : '00:00',
          side: _side,
          feedingMethods: _methods,
          amountController: _amount,
          notesController: _notes,
          amountMl: _amountMl,
          burped: _burped,
          vomited: _vomited,
          loading: false,
          onBack: previewNoop,
          onTimerPressed: () => setState(() => _active = !_active),
          onSideChanged: (value) => setState(() => _side = value),
          onPrimaryMethodChanged: (value) => setState(() {
            _methods
              ..clear()
              ..add(value);
          }),
          onMethodToggled: (value) => setState(() {
            if (_methods.contains(value)) {
              if (_methods.length > 1) _methods.remove(value);
            } else {
              _methods.add(value);
            }
          }),
          onAmountChanged: (value) => setState(() {
            _amountMl = int.tryParse(value) ?? 0;
          }),
          onAmountDelta: (delta) => setState(() {
            _amountMl = (_amountMl + delta).clamp(0, 990).toInt();
            _amount.text = _amountMl.toString();
          }),
          onBurpedChanged: (value) => setState(() => _burped = value),
          onVomitedChanged: (value) => setState(() => _vomited = value),
        ),
      );
}
