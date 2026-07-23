// lib/core/widgets/pp_text_field.dart
// PESAPOP AI — Reusable TextField Component

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

class PPTextField extends StatelessWidget {
  const PPTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.focusNode,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.validator,
    this.inputFormatters,
    this.autofillHints,
    this.helper,
  });

  final String label;
  final String? hint;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final FormFieldValidator<String>? validator;
  final List<TextInputFormatter>? inputFormatters;
  final Iterable<String>? autofillHints;
  final String? helper;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: PPTypography.labelMD.copyWith(
            color: isDark ? PPColors.darkTextSecondary : PPColors.lightTextSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          obscureText: obscureText,
          enabled: enabled,
          readOnly: readOnly,
          maxLines: maxLines,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          onTap: onTap,
          validator: validator,
          inputFormatters: inputFormatters,
          autofillHints: autofillHints,
          style: PPTypography.bodyMD.copyWith(
            color: isDark ? PPColors.darkText : PPColors.lightText,
          ),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            helperText: helper,
            helperStyle: PPTypography.bodyXS.copyWith(
              color: isDark ? PPColors.darkTextSecondary : PPColors.lightTextSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
