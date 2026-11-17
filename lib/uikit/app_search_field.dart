// ignore_for_file: type=lint
// uikit: единственное место, где разрешены сырые Material-виджеты
// (см. AGENTS.md «Сырые Material-виджеты», CI-гейты).
import 'package:material_ui/material_ui.dart';
import 'package:finanseapp/app/theme/app_spacing.dart';
import 'package:finanseapp/uikit/app_text.dart';

/// Поле поиска с иконкой поиска и кнопкой очистки (target ≥48dp).
/// Видимость clear-кнопки синхронизируется с controller; дефолтный clear
/// дополнительно сообщает feature пустое значение через [onChanged].
///
/// Экраны: фильтры журналов и справочников — Операции (query), Активы
/// (query), Аудит (query), длинные списки в bottom sheets.
class AppSearchField extends StatefulWidget {
  const AppSearchField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.onChanged,
    this.onClear,
    this.enabled = true,
    this.clearTooltip = 'Очистить',
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final bool enabled;

  /// Tooltip кнопки очистки — переопределяется feature (l10n).
  final String clearTooltip;

  @override
  State<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends State<AppSearchField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(AppSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        AppText(widget.label, style: textTheme.bodyMedium),
        const SizedBox(height: AppSpacing.xxs),
        TextField(
          controller: widget.controller,
          onChanged: widget.onChanged,
          enabled: widget.enabled,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: widget.controller.text.isEmpty
                ? null
                : IconButton(
                    tooltip: widget.clearTooltip,
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      widget.controller.clear();
                      widget.onChanged?.call('');
                      widget.onClear?.call();
                    },
                  ),
          ),
        ),
      ],
    );
  }
}
