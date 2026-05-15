import 'package:flutter/material.dart';

import '../components/app_ui_tokens.dart';

class SearchField extends StatefulWidget {
  const SearchField({
    super.key,
    required this.controller,
    this.hintText = 'Поиск...',
    this.onChanged,
    this.onClear,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {});
  }

  void _onClearPressed() {
    _controller.clear();
    widget.onClear?.call();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: TextStyle(
          color: AppUiTokens.secondaryText,
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: AppUiTokens.surfaceMuted,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppUiTokens.radiusLg),
          borderSide: const BorderSide(color: AppUiTokens.borderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppUiTokens.radiusLg),
          borderSide: const BorderSide(color: AppUiTokens.borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppUiTokens.radiusLg),
          borderSide: const BorderSide(color: Color(0xFFFFCC00), width: 1.5),
        ),
        prefixIcon: Icon(
          Icons.search,
          color: AppUiTokens.tertiaryText,
          size: 20,
        ),
        suffixIcon: _controller.text.isNotEmpty
            ? IconButton(
                icon: Icon(
                  Icons.clear,
                  color: AppUiTokens.tertiaryText,
                  size: 20,
                ),
                onPressed: _onClearPressed,
              )
            : null,
      ),
    );
  }
}
