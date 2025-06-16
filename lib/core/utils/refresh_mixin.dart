import 'package:flutter/material.dart';
import 'package:get/get.dart';

mixin RefreshMixin<T> on GetxController {
  // Loading və refresh statusları
  final isLoading = false.obs;
  final isRefreshing = false.obs;

  // Data
  final Rx<T?> data = Rx<T?>(null);

  // Error
  final error = Rx<String?>(null);

  // Data yükləmə metodu (override edilməlidir)
  Future<T?> loadData();

  // İlk yükləmə
  Future<void> onInit() async {
    super.onInit();
    await fetchData();
  }

  // Data yükləmə
  Future<void> fetchData() async {
    if (isLoading.value) return;

    isLoading.value = true;
    error.value = null;

    try {
      final result = await loadData();
      data.value = result;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // Refresh
  Future<void> onRefresh() async {
    if (isRefreshing.value) return;

    isRefreshing.value = true;
    error.value = null;

    try {
      final result = await loadData();
      data.value = result;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isRefreshing.value = false;
    }
  }

  // Widget builder
  Widget buildRefreshableList({
    required Widget Function(T data) builder,
    Widget Function(String error)? errorBuilder,
    Widget Function()? emptyBuilder,
  }) {
    return Obx(() {
      if (isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (error.value != null) {
        return errorBuilder?.call(error.value!) ??
            Center(child: Text(error.value!));
      }

      if (data.value == null) {
        return emptyBuilder?.call() ??
            const Center(child: Text('Məlumat tapılmadı'));
      }

      return RefreshIndicator(
        onRefresh: onRefresh,
        child: builder(data.value as T),
      );
    });
  }
}
