import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:washgo/core/constants/app_colors.dart';
import 'package:washgo/core/constants/app_text_styles.dart';

class ListScreenHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const ListScreenHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.headline.copyWith(fontSize: 24)),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTextStyles.subtitle.copyWith(
              fontSize: 13,
              color: AppColors.textLight.withValues(alpha: 0.75),
            ),
          ),
        ],
      ),
    );
  }
}

class ListSearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;

  const ListSearchField({
    super.key,
    required this.controller,
    required this.hintText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: AppTextStyles.body,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTextStyles.subtitle.copyWith(fontSize: 14),
          prefixIcon: const Icon(Icons.search, color: AppColors.cyan, size: 22),
          filled: true,
          fillColor: AppColors.cardDark,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.cyan, width: 1.5),
          ),
        ),
      ),
    );
  }
}

class ListFilterChips extends StatefulWidget {
  final List<String> filters;
  final String selected;
  final ValueChanged<String> onSelected;

  const ListFilterChips({
    super.key,
    required this.filters,
    required this.selected,
    required this.onSelected,
  });

  @override
  State<ListFilterChips> createState() => _ListFilterChipsState();
}

class _ListFilterChipsState extends State<ListFilterChips> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onPointerScroll(PointerSignalEvent event) {
    if (event is! PointerScrollEvent || !_scrollController.hasClients) return;

    final delta = event.scrollDelta.dy != 0 ? event.scrollDelta.dy : event.scrollDelta.dx;
    if (delta == 0) return;

    final position = _scrollController.position;
    final target = (_scrollController.offset + delta).clamp(0.0, position.maxScrollExtent);
    _scrollController.jumpTo(target);
  }

  @override
  Widget build(BuildContext context) {
    final scrollbarTheme = ScrollbarTheme.of(context).copyWith(
      thumbVisibility: WidgetStateProperty.all(true),
      trackVisibility: WidgetStateProperty.all(true),
      thickness: WidgetStateProperty.all(8),
      radius: const Radius.circular(4),
      thumbColor: WidgetStateProperty.all(AppColors.cyan.withValues(alpha: 0.9)),
      trackColor: WidgetStateProperty.all(Colors.white.withValues(alpha: 0.12)),
      crossAxisMargin: 0,
      mainAxisMargin: 2,
      minThumbLength: 36,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Theme(
        data: Theme.of(context).copyWith(scrollbarTheme: scrollbarTheme),
        child: SizedBox(
          height: 54,
          child: Listener(
            onPointerSignal: _onPointerScroll,
            child: Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              trackVisibility: true,
              interactive: true,
              child: SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    for (var i = 0; i < widget.filters.length; i++) ...[
                      if (i > 0) const SizedBox(width: 8),
                      _FilterChipItem(
                        label: widget.filters[i],
                        isSelected: widget.selected == widget.filters[i],
                        onSelected: () => widget.onSelected(widget.filters[i]),
                      ),
                    ],
                    const SizedBox(width: 4),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterChipItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const _FilterChipItem({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          color: isSelected ? AppColors.textLight : AppColors.textSecondary,
        ),
      ),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      showCheckmark: isSelected,
      checkmarkColor: AppColors.limeAccent,
      selectedColor: AppColors.aquaBlue.withValues(alpha: 0.35),
      backgroundColor: AppColors.cardDark,
      side: BorderSide(
        color: isSelected
            ? AppColors.cyan.withValues(alpha: 0.6)
            : Colors.white.withValues(alpha: 0.1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

class ListResultCount extends StatelessWidget {
  final int count;
  final String singularLabel;
  final String pluralLabel;

  const ListResultCount({
    super.key,
    required this.count,
    required this.singularLabel,
    required this.pluralLabel,
  });

  @override
  Widget build(BuildContext context) {
    final label = count == 1 ? singularLabel : pluralLabel;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Text(
        '$count $label',
        style: AppTextStyles.caption.copyWith(
          color: AppColors.cyan,
          fontWeight: FontWeight.w600,
          fontSize: 12,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
