import 'dart:math';

import 'package:flutter/material.dart';
import 'package:number_paginator/src/button.dart';

class NumberPaginator extends StatefulWidget {
  /// Total number of pages that should be shown.
  final int numberPages;

  /// Index of initially selected page.
  final int initialPage;

  /// This function is called when the user switches between pages. The received
  /// parameter indicates the selected index, starting from 0.
  final Function(int)? onPageChange;

  /// The height of the number paginator.
  final double height;

  /// The shape of the [PaginatorButton]s.
  final OutlinedBorder? buttonShape;

  /// The [PaginatorButton]'s foreground color (text/icon color) when selected.
  ///
  /// Defaults to [Colors.white].
  final Color? buttonSelectedForegroundColor;

  /// The [PaginatorButton]'s foreground color (text/icon color) when unselected.
  ///
  /// Defaults to `null`.
  final Color? buttonUnselectedForegroundColor;

  /// The [PaginatorButton]'s background color when selected.
  ///
  /// Defaults to the [Theme]'s accent color.
  final Color? buttonSelectedBackgroundColor;

  /// The [PaginatorButton]'s background color when unselected.
  ///
  /// Defaults to `null`.
  final Color? buttonUnselectedBackgroundColor;

  /// The button's padding when selected.
  ///
  /// Default to `EdgeInsets.all(4.0)`
  final EdgeInsetsGeometry selectedPadding;

  /// The button's padding when not selected.
  ///
  /// Default to `EdgeInsets.all(4.0)`
  final EdgeInsetsGeometry unSelectedPadding;

  /// The content button's padding when selected.
  ///
  /// Default to `EdgeInsets.all(4.0)`
  final EdgeInsetsGeometry selectedContentPadding;

  /// The content button's padding when not selected.
  ///
  /// Default to `EdgeInsets.all(4.0)`
  final EdgeInsetsGeometry unSelectedContentPadding;

  /// The [PaginatorButton]'s text style
  ///
  /// Default to `null`
  final TextStyle? buttonTextStyle;

  /// Creates an instance of [NumberPaginator].
  const NumberPaginator({
    Key? key,
    required this.numberPages,
    this.initialPage = 0,
    this.onPageChange,
    this.height = 48.0,
    this.buttonShape,
    this.buttonSelectedForegroundColor,
    this.buttonUnselectedForegroundColor,
    this.buttonSelectedBackgroundColor,
    this.buttonUnselectedBackgroundColor,
    this.selectedPadding = const EdgeInsets.all(4),
    this.unSelectedPadding = const EdgeInsets.all(4),
    this.selectedContentPadding = const EdgeInsets.all(4),
    this.unSelectedContentPadding = const EdgeInsets.all(4),
    this.buttonTextStyle,
  }) : super(key: key);

  @override
  _NumberPaginatorState createState() => _NumberPaginatorState();
}

class _NumberPaginatorState extends State<NumberPaginator> {
  late int _currentPage;
  int _availableSpots = 0;

  @override
  void initState() {
    _currentPage = widget.initialPage;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: Row(
        children: [
          PaginatorButton(
            onPressed: _currentPage > 0 ? _prev : null,
            child: const Icon(Icons.chevron_left),
            shape: widget.buttonShape,
            selectedForegroundColor: widget.buttonSelectedForegroundColor,
            unSelectedforegroundColor: widget.buttonUnselectedForegroundColor,
            selectedBackgroundColor: widget.buttonSelectedBackgroundColor,
            unSelectedBackgroundColor: widget.buttonUnselectedBackgroundColor,
            selectedPadding: widget.selectedPadding,
            unSelectedPadding: widget.unSelectedPadding,
            selectedContentPadding: widget.selectedContentPadding,
            unSelectedContentPadding: widget.unSelectedContentPadding,
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                _availableSpots = (constraints.maxWidth / _buttonWidth).floor();

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildPageButton(0),
                    if (_firstDotsShouldShow) _buildDots(),
                    ..._generateButtonList(),
                    if (_lastDotsShouldShow) _buildDots(),
                    _buildPageButton(widget.numberPages - 1),
                  ],
                );
              },
            ),
          ),
          PaginatorButton(
            onPressed: _currentPage < widget.numberPages - 1 ? _next : null,
            child: const Icon(Icons.chevron_right),
            shape: widget.buttonShape,
            selectedForegroundColor: widget.buttonSelectedForegroundColor,
            unSelectedforegroundColor: widget.buttonUnselectedForegroundColor,
            selectedBackgroundColor: widget.buttonSelectedBackgroundColor,
            unSelectedBackgroundColor: widget.buttonUnselectedBackgroundColor,
            selectedPadding: widget.selectedPadding,
            unSelectedPadding: widget.unSelectedPadding,
            selectedContentPadding: widget.selectedContentPadding,
            unSelectedContentPadding: widget.unSelectedContentPadding,
          ),
        ],
      ),
    );
  }

  /// Buttons have an aspect ratio of 1:1. Therefore use paginator height as
  /// button width.
  double get _buttonWidth => widget.height;

  _prev() {
    setState(() {
      _currentPage--;
    });
    widget.onPageChange?.call(_currentPage);
  }

  _next() {
    setState(() {
      _currentPage++;
    });
    widget.onPageChange?.call(_currentPage);
  }

  _navigateToPage(int index) {
    setState(() {
      _currentPage = index;
    });
    widget.onPageChange?.call(index);
  }

  /// Checks if pages don't fit in available spots and dots have to be shown.
  bool get _lastDotsShouldShow =>
      _availableSpots < widget.numberPages &&
      _currentPage < widget.numberPages - _availableSpots ~/ 2;

  bool get _firstDotsShouldShow =>
      _availableSpots < widget.numberPages &&
      _currentPage > _availableSpots ~/ 2 - 1;

  /// Generates the variable button list which is on the left of the (optional)
  /// dots. The very last page is shown independently of this list.
  List<Widget> _generateButtonList() {
    // if dots shown: available minus one for last page + one for dots
    var shownPages = _availableSpots;
    shownPages -= _lastDotsShouldShow ? 2 : 1;
    shownPages -= _firstDotsShouldShow ? 2 : 1;

    int minValue, maxValue;
    minValue = max(1, _currentPage - shownPages ~/ 2);
    maxValue = min(minValue + shownPages, widget.numberPages - 1);
    if (maxValue - minValue < shownPages) {
      minValue = (maxValue - shownPages).clamp(1, widget.numberPages - 1);
    }

    return List.generate(
        maxValue - minValue, (index) => _buildPageButton(minValue + index));
  }

  /// Builds a button for the given index.
  Widget _buildPageButton(int index) => PaginatorButton(
        onPressed: () => _navigateToPage(index),
        selected: _selected(index),
        child: Text((index + 1).toString(), style: widget.buttonTextStyle),
        shape: widget.buttonShape,
        selectedForegroundColor: widget.buttonSelectedForegroundColor,
        unSelectedforegroundColor: widget.buttonUnselectedForegroundColor,
        selectedBackgroundColor: widget.buttonSelectedBackgroundColor,
        unSelectedBackgroundColor: widget.buttonUnselectedBackgroundColor,
        selectedPadding: widget.selectedPadding,
        unSelectedPadding: widget.unSelectedPadding,
        selectedContentPadding: widget.selectedContentPadding,
        unSelectedContentPadding: widget.unSelectedContentPadding,
      );

  Widget _buildDots() => AspectRatio(
        aspectRatio: 1,
        child: Container(
          // padding: const EdgeInsets.all(4.0),
          margin: const EdgeInsets.all(4.0),
          alignment: Alignment.center,
          decoration: ShapeDecoration(
            shape: widget.buttonShape ?? const CircleBorder(),
            color: widget.buttonUnselectedBackgroundColor,
          ),
          child: Icon(
            Icons.more_horiz,
            color: widget.buttonUnselectedForegroundColor ??
                Theme.of(context).colorScheme.secondary,
            size: 20,
          ),
        ),
      );

  /// Checks if the given index is currently selected.
  bool _selected(index) => index == _currentPage;
}
