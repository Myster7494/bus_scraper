// lib/pages/cars_page.dart

import 'package:bus_scraper/widgets/favorite_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // 導入 provider

import '../data/car.dart';
import '../static.dart';
import '../widgets/favorite_button.dart';
import '../widgets/searchable_list.dart';
import 'history_page.dart';

class CarsPage extends StatelessWidget {
  const CarsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // *** 修改點 1: 使用 Consumer 包裹，以便在收藏狀態改變時自動重繪圖示 ***
    return Consumer<FavoritesNotifier>(
      builder: (context, notifier, child) {
        return SearchableList<Car>(
          allItems: Static.carData,
          searchHintText: "搜尋車牌",
          filterCondition: (car, text) {
            final cleanPlate =
                car.plate.replaceAll(Static.letterNumber, "").toUpperCase();
            final cleanText =
                text.replaceAll(Static.letterNumber, "").toUpperCase();
            return cleanPlate.contains(cleanText);
          },
          sortCallback: (a, b) => a.plate.compareTo(b.plate),
          itemBuilder: (context, car) {
            // 從 notifier 檢查當前車輛是否已被收藏
            final bool isFavorite = notifier.isFavorite(car.plate);

            return ListTile(
              // *** 修改點 2: 在標題前加入收藏按鈕 ***
              leading: FavoriteButton(
                plate: car.plate,
                notifier: notifier,
              ),
              title: Text(
                car.plate,
                style: const TextStyle(fontSize: 18),
              ),
              subtitle: Text(
                car.type.chinese,
                style: const TextStyle(fontSize: 16),
              ),
              trailing: FilledButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HistoryPage(plate: car.plate),
                    ),
                  );
                },
                style:
                    FilledButton.styleFrom(padding: const EdgeInsets.all(10)),
                child: const Text('歷史位置', style: TextStyle(fontSize: 16)),
              ),
            );
          },
          // emptyStateWidget 保持不變，但這裡的 ThemeProvider 其實可以移除
          // 因為主題已經由 main.dart 的全局 ThemeProvider 提供了
          emptyStateWidget: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off,
                    size: 100, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 10),
                const Text(
                  "找不到符合的車牌\n或車牌尚未被記錄",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
