# Primitives: сигнатуры и поведение

Все классы immutable `StatelessWidget`, кроме wrappers, которым действительно нужен State.
`Key? key` доступен у каждого public widget; ниже не повторяется в описании полей.

## 1. Scaffold, text, icon, layout

```dart
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key, required this.body, this.title, this.appBar,
    this.floatingActionButton, this.bottomNavigationBar, this.drawer,
    this.resizeToAvoidBottomInset,
  });
  final Widget body;
  final String? title;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Widget? drawer;
  final bool? resizeToAvoidBottomInset;
}

class AppTopAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopAppBar({
    super.key, required this.title, this.leading,
    this.actions = const [], this.large = false,
  });
  final String title;
  final Widget? leading;
  final List<Widget> actions;
  final bool large;
}

class AppText extends StatelessWidget {
  const AppText(this.data, {
    super.key, this.style, this.textAlign, this.maxLines,
    this.overflow, this.softWrap, this.semanticsLabel,
  });
  final String data;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool? softWrap;
  final String? semanticsLabel;
}

class AppIcon extends StatelessWidget {
  const AppIcon(this.icon, {super.key, this.size, this.color, this.semanticLabel});
  final IconData icon;
  final double? size;
  final Color? color;
  final String? semanticLabel;
}

class AppBox extends StatelessWidget {
  const AppBox({
    super.key, this.child, this.padding, this.margin, this.width, this.height,
    this.color, this.border, this.borderRadius, this.clipBehavior = Clip.none,
  });
  final Widget? child;
  final EdgeInsetsGeometry? padding, margin;
  final double? width, height;
  final Color? color;
  final BoxBorder? border;
  final BorderRadiusGeometry? borderRadius;
  final Clip clipBehavior;
}

class AppCard extends StatelessWidget {
  const AppCard({
    super.key, required this.child, this.padding = const EdgeInsets.all(16),
    this.onTap, this.semanticLabel, this.outlined = true,
  });
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final bool outlined;
}

class AppListTile extends StatelessWidget {
  const AppListTile({
    super.key, required this.title, this.subtitle, this.leading, this.trailing,
    this.onTap, this.enabled = true, this.semanticLabel,
  });
  final String title;
  final String? subtitle;
  final Widget? leading, trailing;
  final VoidCallback? onTap;
  final bool enabled;
  final String? semanticLabel;
}

class AppListView extends StatelessWidget {
  const AppListView({
    super.key, required this.children, this.padding, this.shrinkWrap = false,
    this.physics, this.controller,
  }) : itemCount = null, itemBuilder = null;
  const AppListView.builder({
    super.key, required this.itemCount, required this.itemBuilder,
    this.padding, this.controller, this.physics,
  }) : children = null, shrinkWrap = false;
  final List<Widget>? children;
  final int? itemCount;
  final NullableIndexedWidgetBuilder? itemBuilder;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final ScrollController? controller;
}

class AppGridView extends StatelessWidget {
  const AppGridView.builder({
    super.key, required this.itemCount, required this.itemBuilder,
    required this.gridDelegate, this.padding, this.controller,
  });
  final int itemCount;
  final NullableIndexedWidgetBuilder itemBuilder;
  final SliverGridDelegate gridDelegate;
  final EdgeInsetsGeometry? padding;
  final ScrollController? controller;
}

class AppInkWell extends StatelessWidget {
  const AppInkWell({
    super.key, required this.child, this.onTap, this.borderRadius,
    this.semanticLabel, this.enabled = true,
  });
  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final String? semanticLabel;
  final bool enabled;
}

class AppTapRegion extends StatelessWidget {
  const AppTapRegion({
    super.key, required this.child, this.onTap, this.semanticLabel,
    this.enabled = true,
  });
  final Widget child;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final bool enabled;
}

class AppImage extends StatelessWidget {
  const AppImage.asset(this.name, {
    super.key, this.width, this.height, this.fit, this.semanticLabel,
  }) : bytes = null;
  const AppImage.memory(this.bytes, {
    super.key, this.width, this.height, this.fit, this.semanticLabel,
  }) : name = null;
  final String? name;
  final Uint8List? bytes;
  final double? width, height;
  final BoxFit? fit;
  final String? semanticLabel;
}
```

`AppListView`/`.builder` — разные constructors, неиспользуемые fields имеют private/default
initialization без `late` crash. AppCard/AppInkWell disabled не дают splash/callback.
Decorative AppImage имеет `semanticLabel = null` и `excludeFromSemantics`; content image
обязана получить label. Вместо raw Container/InkWell/GestureDetector/Image используются эти wrappers.

## 2. Buttons и навигация

```dart
enum AppButtonVariant { filled, tonal, outlined, text, destructive }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key, required this.label, this.onPressed, this.icon,
    this.variant = AppButtonVariant.filled, this.pending = false,
    this.expanded = false, this.semanticLabel,
  });
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final AppButtonVariant variant;
  final bool pending, expanded;
  final String? semanticLabel;
}

class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key, required this.icon, required this.tooltip, this.onPressed,
    this.variant = AppButtonVariant.text, this.pending = false,
  });
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool pending;
}

class AppFloatingActionButton extends StatelessWidget {
  const AppFloatingActionButton({
    super.key, required this.icon, required this.tooltip,
    this.label, this.onPressed, this.pending = false,
  });
  final IconData icon;
  final String tooltip;
  final String? label;
  final VoidCallback? onPressed;
  final bool pending;
}

class AppNavigationDestination {
  const AppNavigationDestination({
    required this.label, required this.icon, this.selectedIcon,
  });
  final String label;
  final IconData icon;
  final IconData? selectedIcon;
}

class AppNavigationBar extends StatelessWidget {
  const AppNavigationBar({
    super.key, required this.destinations, required this.selectedIndex,
    required this.onDestinationSelected,
  });
  final List<AppNavigationDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
}

class AppNavigationRail extends StatelessWidget {
  const AppNavigationRail({
    super.key, required this.destinations, required this.selectedIndex,
    required this.onDestinationSelected, this.extended = false,
  });
  final List<AppNavigationDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final bool extended;
}
```

Pending сохраняет ширину, показывает spinner и semantics «Выполняется», блокирует callback.
`destructive` использует error roles; expense/negative money не destructive. FAB extended
при label != null. Navigation indices валидируются assert, labels не ellipsis при 1.3 —
используется scroll/extended layout по доступным constraints.

## 3. Dialogs, sheets, feedback

```dart
class AppDialog extends StatelessWidget {
  const AppDialog({
    super.key, this.title, this.content, this.actions = const [],
    this.scrollable = false,
  });
  final Widget? title, content;
  final List<Widget> actions;
  final bool scrollable;
}

Future<T?> showAppDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
});

class AppBottomSheet extends StatelessWidget {
  const AppBottomSheet({
    super.key, required this.child, this.title, this.padding,
  });
  final Widget child;
  final String? title;
  final EdgeInsetsGeometry? padding;
}

Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = true,
});

Future<void> showAppSnackBar(
  BuildContext context, {
  required String message,
  String? actionLabel,
  VoidCallback? onAction,
  bool isError = false,
});

class AppSpinner extends StatelessWidget {
  const AppSpinner({super.key, this.size = 24, this.semanticLabel});
  final double size;
  final String? semanticLabel;
}

class AppSkeleton extends StatelessWidget {
  const AppSkeleton({
    super.key, required this.width, required this.height, this.borderRadius = 8,
  });
  final double width, height;
  final double borderRadius;
}

class AppProgress extends StatelessWidget {
  const AppProgress({
    super.key, required this.value, this.label, this.semanticLabel,
  });
  final double? value; // null = indeterminate, иначе clamp 0..1
  final String? label;
  final String? semanticLabel;
}

class AppDivider extends StatelessWidget {
  const AppDivider({super.key, this.indent = 0, this.endIndent = 0});
  final double indent, endIndent;
}

class AppChip extends StatelessWidget {
  const AppChip({
    super.key, required this.label, this.icon, this.selected = false,
    this.onSelected, this.onDeleted, this.deleteTooltip,
  }) : assert(onDeleted == null || deleteTooltip != null);
  final String label;
  final IconData? icon;
  final bool selected;
  final ValueChanged<bool>? onSelected;
  final VoidCallback? onDeleted;
  final String? deleteTooltip;
}

class AppTooltip extends StatelessWidget {
  const AppTooltip({super.key, required this.message, required this.child});
  final String message;
  final Widget child;
}
```

Dialogs имеют accessible title, actions при узком экране располагаются без overflow,
barrierDismissible=false используется только для blocking import/restart. SnackBar error
использует errorContainer/onErrorContainer и дополнительный icon/текст. Skeleton исключён
из semantics и не анимируется при disableAnimations.

## 4. Selection controls и system gestures

```dart
class AppSwitch extends StatelessWidget {
  const AppSwitch({
    super.key, required this.value, required this.label, this.onChanged,
  });
  final bool value;
  final String label;
  final ValueChanged<bool>? onChanged;
}

class AppCheckbox extends StatelessWidget {
  const AppCheckbox({
    super.key, required this.value, required this.label, this.onChanged,
    this.tristate = false,
  });
  final bool? value;
  final String label;
  final ValueChanged<bool?>? onChanged;
  final bool tristate;
}

class AppRadioListTile<T> extends StatelessWidget {
  const AppRadioListTile({
    super.key, required this.label, required this.value,
    required this.groupValue, required this.onChanged,
    this.subtitle, this.enabled = true,
  });
  final String label;
  final T value;
  final T groupValue;
  final ValueChanged<T>? onChanged;
  final String? subtitle;
  final bool enabled;
}

class AppPopupMenuItem<T> {
  const AppPopupMenuItem({required this.value, required this.label, this.icon});
  final T value;
  final String label;
  final IconData? icon;
}

class AppPopupMenu<T> extends StatelessWidget {
  const AppPopupMenu({
    super.key, required this.items, required this.onSelected,
    required this.tooltip, this.icon = Icons.more_vert, this.enabled = true,
  });
  final List<AppPopupMenuItem<T>> items;
  final ValueChanged<T> onSelected;
  final String tooltip;
  final IconData icon;
  final bool enabled;
}

class AppRefreshIndicator extends StatelessWidget {
  const AppRefreshIndicator({
    super.key, required this.child, required this.onRefresh,
  });
  final Widget child;
  final RefreshCallback onRefresh;
}
```

Switch/Checkbox/Radio label кликабелен как одна target ≥48dp, disabled сохраняет readable
label. Radio group сообщает Semantics selected value и не требует цвета для выбора.
Popup не содержит destructive default без AppConfirmDialog. Refresh доступен поверх
lazy list и не используется как замена первичному skeleton.

## 5. Обязательные primitive tests

- Каждый wrapper рендерится без raw Material в feature fixture, tap/focus/disabled/pending
  callbacks проходят ровно один раз.
- Dialog/sheet/snackbar открываются/закрываются, title/action Semantics доступны.
- NavigationBar/Rail отражают selection, long five labels при 320dp и 1.3 не overflow.
- AppListTile и Card onTap имеют 48dp, keyboard activation и label.
- Light/dark screenshots для filled/tonal/destructive, Card, Dialog, Switch/Checkbox/Radio;
  расходный AppButton destructive в тестах специально запрещён по semantics variant.
- Radio selection по label и клавиатуре, disabled state, target ≥48dp и Semantics selected value
  проверяются отдельно. `AppChip(onDeleted != null, deleteTooltip == null)` падает assert;
  доступный deleteTooltip проходит в Semantics.
