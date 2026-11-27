import 'package:flutter/material.dart';

import '../data/finance_data.dart';
import '../theme/app_colors.dart';

Route<T> fadeRoute<T>(Widget page) => PageRouteBuilder<T>(
  transitionDuration: const Duration(milliseconds: 350),
  pageBuilder: (_, _, _) => page,
  transitionsBuilder: (_, anim, _, child) =>
      FadeTransition(opacity: anim, child: child),
);

/* ───────────────────────────── Logo ───────────────────────────── */

class FinixLogoMark extends StatelessWidget {
  final double size;
  const FinixLogoMark({super.key, this.size = 48});

  /// Logo oficial (Logos/Logo2.png → assets/images/logo.png, ya con esquinas redondeadas).
  static const asset = 'assets/images/logo.png';

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: Image.asset(
      asset,
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
    ),
  );
}

class FinixLogo extends StatelessWidget {
  final double size;
  final Color textColor;
  const FinixLogo({super.key, this.size = 28, this.textColor = AppColors.text});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      FinixLogoMark(size: size),
      SizedBox(width: size * 0.25),
      Flexible(
        child: Text(
          'Finix',
          overflow: TextOverflow.fade,
          softWrap: false,
          style: TextStyle(
            fontSize: size * 0.85,
            fontWeight: FontWeight.w800,
            color: textColor,
            letterSpacing: -0.5,
          ),
        ),
      ),
    ],
  );
}

/* ───────────────────────────── Botones ───────────────────────────── */

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool arrow;
  final double height;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.arrow = true,
    this.height = 56,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(18);
    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: AppColors.buttonGradient,
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.30),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: radius,
          onTap: onPressed,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (arrow) ...[
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class WhitePillButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  const WhitePillButton({super.key, required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(30),
    child: InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.text,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.arrow_forward_rounded,
              size: 18,
              color: AppColors.text,
            ),
          ],
        ),
      ),
    ),
  );
}

/* ───────────────────────────── Campos ───────────────────────────── */

class FinixField extends StatefulWidget {
  final String hint;
  final IconData? icon;
  final bool obscure;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final Color fillColor;

  const FinixField({
    super.key,
    required this.hint,
    this.icon,
    this.obscure = false,
    this.controller,
    this.keyboardType,
    this.onChanged,
    this.fillColor = AppColors.field,
  });

  @override
  State<FinixField> createState() => _FinixFieldState();
}

class _FinixFieldState extends State<FinixField> {
  late bool _hidden = widget.obscure;

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color c) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: c),
    );
    return TextField(
      controller: widget.controller,
      obscureText: _hidden,
      keyboardType: widget.keyboardType,
      onChanged: widget.onChanged,
      style: const TextStyle(fontSize: 15, color: AppColors.text),
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: const TextStyle(color: AppColors.muted, fontSize: 15),
        prefixIcon: widget.icon == null
            ? null
            : Icon(widget.icon, color: AppColors.muted, size: 21),
        suffixIcon: widget.obscure
            ? IconButton(
                icon: Icon(
                  _hidden
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.muted,
                  size: 21,
                ),
                onPressed: () => setState(() => _hidden = !_hidden),
              )
            : null,
        filled: true,
        fillColor: widget.fillColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        border: border(AppColors.border),
        enabledBorder: border(AppColors.border),
        focusedBorder: border(AppColors.green),
      ),
    );
  }
}

/* ───────────────────────────── Tarjetas ───────────────────────────── */

class SoftCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final Gradient? gradient;
  final double radius;
  final VoidCallback? onTap;

  const SoftCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color = Colors.white,
    this.gradient,
    this.radius = 22,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(radius);
    return Container(
      decoration: BoxDecoration(
        color: gradient == null ? color : null,
        gradient: gradient,
        borderRadius: r,
        border: Border.all(color: const Color(0x0D0B5A3A)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120B5A3A),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: r,
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

class CategoryBubble extends StatelessWidget {
  final Category category;
  final double size;
  final double? radius; // null = círculo

  const CategoryBubble({
    super.key,
    required this.category,
    this.size = 48,
    this.radius,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: category.color.withValues(alpha: 0.14),
      shape: radius == null ? BoxShape.circle : BoxShape.rectangle,
      borderRadius: radius == null ? null : BorderRadius.circular(radius!),
    ),
    child: Icon(category.icon, color: category.color, size: size * 0.5),
  );
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  final IconData? icon;
  final double fontSize;

  const SectionHeader({
    super.key,
    required this.title,
    this.action,
    this.onAction,
    this.icon,
    this.fontSize = 16,
  });

  @override
  Widget build(BuildContext context) => Row(
    children: [
      if (icon != null) ...[
        Icon(icon, size: 22, color: AppColors.text),
        const SizedBox(width: 8),
      ],
      Expanded(
        child: Text(
          title,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
        ),
      ),
      if (action != null)
        InkWell(
          onTap: onAction,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  action!,
                  style: const TextStyle(
                    color: AppColors.green,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_forward_rounded,
                  size: 15,
                  color: AppColors.green,
                ),
              ],
            ),
          ),
        ),
    ],
  );
}

class TransactionTile extends StatelessWidget {
  final Txn txn;
  final bool dense;
  const TransactionTile({super.key, required this.txn, this.dense = false});

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(vertical: dense ? 6 : 10),
    child: Row(
      children: [
        CategoryBubble(
          category: txn.category,
          size: dense ? 42 : 48,
          radius: 14,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                txn.note?.isNotEmpty == true
                    ? '${txn.title} - ${txn.note}'
                    : txn.title,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                dateLabel(txn.date),
                style: const TextStyle(color: AppColors.muted, fontSize: 12),
              ),
            ],
          ),
        ),
        Text(
          formatMoney(txn.amount, withSign: true),
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            color: txn.isIncome ? AppColors.green : AppColors.text,
          ),
        ),
      ],
    ),
  );
}

class UserAvatar extends StatelessWidget {
  final double size;
  final bool online;
  const UserAvatar({super.key, this.size = 44, this.online = false});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: size,
    height: size,
    child: Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFFDDF7EA), Color(0xFF9FE5C1)],
            ),
            border: Border.all(color: Colors.white, width: size > 60 ? 4 : 2),
            boxShadow: const [
              BoxShadow(color: Color(0x220B5A3A), blurRadius: 10),
            ],
          ),
          alignment: Alignment.center,
          clipBehavior: Clip.antiAlias,
          child: ValueListenableBuilder<AppUser?>(
            valueListenable: AppState.user,
            builder: (_, u, _) {
              final initials = Text(
                u?.initials.isNotEmpty == true ? u!.initials : '👤',
                style: TextStyle(
                  fontSize: size * 0.36,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              );
              if (u?.avatarUrl == null) return initials;
              return Image.network(
                u!.avatarUrl!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => initials,
              );
            },
          ),
        ),
        if (online)
          Positioned(
            right: 1,
            bottom: 1,
            child: Container(
              width: size * 0.26,
              height: size * 0.26,
              decoration: BoxDecoration(
                color: AppColors.green,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    ),
  );
}

class IconCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool badge;
  final double size;
  const IconCircleButton({
    super.key,
    required this.icon,
    this.onTap,
    this.badge = false,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    shape: const CircleBorder(),
    elevation: 0,
    child: InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, color: AppColors.text, size: size * 0.52),
            if (badge)
              Positioned(
                top: size * 0.2,
                right: size * 0.24,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: AppColors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

/// Selector de pestañas tipo píldora (Gasto/Ingreso, Mes/Trimestre/Año…).
class PillTabs extends StatelessWidget {
  final List<String> labels;
  final int index;
  final ValueChanged<int> onChanged;
  final bool boxed;
  final double height;

  const PillTabs({
    super.key,
    required this.labels,
    required this.index,
    required this.onChanged,
    this.boxed = false,
    this.height = 40,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(boxed ? 4 : 0),
    decoration: boxed
        ? BoxDecoration(
            color: AppColors.field,
            borderRadius: BorderRadius.circular(18),
          )
        : null,
    child: Row(
      children: [
        for (var i = 0; i < labels.length; i++)
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: boxed ? 0 : 4),
              child: GestureDetector(
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: height,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: i == index ? AppColors.buttonGradient : null,
                    color: i == index
                        ? null
                        : (boxed ? Colors.transparent : AppColors.field),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    labels[i],
                    style: TextStyle(
                      color: i == index ? Colors.white : AppColors.text,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

class FinixSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const FinixSwitch({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) => Switch(
    value: value,
    onChanged: onChanged,
    activeTrackColor: AppColors.green,
    inactiveTrackColor: const Color(0xFFD9E2DD),
    thumbColor: const WidgetStatePropertyAll(Colors.white),
    trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
  );
}

/// Switch enlazado a un ValueNotifier global (se sincroniza en toda la app).
class NotifierSwitch extends StatelessWidget {
  final ValueNotifier<bool> notifier;
  const NotifierSwitch(this.notifier, {super.key});

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<bool>(
    valueListenable: notifier,
    builder: (_, v, _) =>
        FinixSwitch(value: v, onChanged: (x) => notifier.value = x),
  );
}

class MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? color;

  const MenuTile({
    super.key,
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      child: Row(
        children: [
          Icon(icon, color: color ?? AppColors.text, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: color ?? AppColors.text,
              ),
            ),
          ),
          trailing ??
              (onTap != null
                  ? const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.muted,
                    )
                  : const SizedBox.shrink()),
        ],
      ),
    ),
  );
}

class ProgressBar extends StatelessWidget {
  final double value;
  final Color color;
  final double height;
  const ProgressBar({
    super.key,
    required this.value,
    this.color = AppColors.green,
    this.height = 7,
  });

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(99),
    child: Container(
      height: height,
      color: color.withValues(alpha: 0.15),
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: value.clamp(0, 1).toDouble(),
        heightFactor: 1,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withValues(alpha: 0.75), color],
            ),
            borderRadius: BorderRadius.circular(99),
          ),
        ),
      ),
    ),
  );
}

class LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const LegendDot({super.key, required this.color, required this.label});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 6),
      Text(label, style: const TextStyle(fontSize: 13, color: AppColors.text)),
    ],
  );
}

/// Envuelve una pantalla que se abre como ruta independiente.
class StandalonePage extends StatelessWidget {
  final Widget child;
  final Color background;
  const StandalonePage({
    super.key,
    required this.child,
    this.background = AppColors.bg,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: background,
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: child,
        ),
      ),
    ),
  );
}

void showSoon(BuildContext context, String what) =>
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$what estará disponible pronto'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.primaryDark,
        ),
      );

/// "↑ +12%" en verde o "↓ -8%" en rojo.
class ChangeLabel extends StatelessWidget {
  final double percent;
  final bool onDark;
  final String suffix;
  const ChangeLabel(
    this.percent, {
    super.key,
    this.onDark = false,
    this.suffix = '',
  });

  @override
  Widget build(BuildContext context) {
    final up = percent >= 0;
    final color = up ? AppColors.green : AppColors.red;
    final text =
        '${up ? '+' : ''}${percent.toStringAsFixed(percent.abs() >= 10 ? 0 : 1)}%';
    if (onDark) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(
              up ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
              size: 11,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              '$text$suffix',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 12,
              ),
            ),
          ),
        ],
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          up ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
          size: 15,
          color: color,
        ),
        Flexible(
          child: Text(
            '$text$suffix',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: color, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

/// Mensaje para cuando todavía no hay datos.
class EmptyHint extends StatelessWidget {
  final IconData icon;
  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;
  const EmptyHint({
    super.key,
    required this.icon,
    required this.text,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) => SoftCard(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 40, color: AppColors.green.withValues(alpha: 0.7)),
        const SizedBox(height: 10),
        Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.muted, height: 1.4),
        ),
        if (actionLabel != null) ...[
          const SizedBox(height: 14),
          PrimaryButton(
            label: actionLabel!,
            onPressed: onAction,
            height: 46,
            arrow: false,
          ),
        ],
      ],
    ),
  );
}
