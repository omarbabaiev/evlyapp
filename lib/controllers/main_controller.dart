import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MainController extends GetxController {
  static MainController get to => Get.find();

  var currentIndex = 0.obs;
  var isBottomBarVisible = true.obs;
  DateTime? lastBackPressTime;
  bool _isScrollingUp = false;

  // Scroll threshold - minimum scroll distance to trigger hide/show
  static const double _scrollThreshold = 10.0;
  double _accumulatedScrollDelta = 0.0;

  void changePage(int index) {
    currentIndex.value = index;
    // Show bottom bar when changing to non-hidable screens
    if (index != 0 && index != 1) {
      showBottomBar();
    }
  }

  void hideBottomBar() {
    if (isBottomBarVisible.value) {
      isBottomBarVisible.value = false;
      update();
    }
  }

  void showBottomBar() {
    if (!isBottomBarVisible.value) {
      isBottomBarVisible.value = true;
      update();
    }
  }

  void handleScroll(double scrollDelta) {
    // Only handle scroll for home (0) and favorite (1) screens
    if (currentIndex.value != 0 && currentIndex.value != 1) {
      return;
    }

    // Ignore very small scroll movements (elastic bounce, etc.)
    if (scrollDelta.abs() < 10.0) {
      return;
    }

    // Accumulate scroll delta
    _accumulatedScrollDelta += scrollDelta;

    // Only trigger hide/show if accumulated scroll exceeds threshold
    if (_accumulatedScrollDelta.abs() >= _scrollThreshold) {
      if (_accumulatedScrollDelta > 0) {
        // Scrolling down - hide bottom bar
        _isScrollingUp = false;
        hideBottomBar();
      } else {
        // Scrolling up - show bottom bar
        _isScrollingUp = true;
        showBottomBar();
      }

      // Reset accumulated delta after triggering action
      _accumulatedScrollDelta = 0.0;
    }
  }

  void resetAccumulatedDelta() {
    _accumulatedScrollDelta = 0.0;
  }

  Future<bool> onWillPop() async {
    if (currentIndex.value != 0) {
      currentIndex.value = 0;
      return false;
    }

    if (lastBackPressTime == null ||
        DateTime.now().difference(lastBackPressTime!) > Duration(seconds: 2)) {
      lastBackPressTime = DateTime.now();
      Fluttertoast.showToast(
        msg: "Çıxmaq üçün təkrar basın",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
      );
      return false;
    }
    return true;
  }
}
