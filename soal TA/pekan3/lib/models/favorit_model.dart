import 'package:flutter/foundation.dart';

class FavoritModel extends ChangeNotifier {
  final Set<String> _favorit = {};

  Set<String> get favorit => Set.unmodifiable(_favorit);

  bool isFavorit(String namaLayanan) {
    return _favorit.contains(namaLayanan);
  }

  void tandai(String namaLayanan) {
    if (_favorit.add(namaLayanan)) {
      notifyListeners();
    }
  }

  void batalTandai(String namaLayanan) {
    if (_favorit.remove(namaLayanan)) {
      notifyListeners();
    }
  }
}