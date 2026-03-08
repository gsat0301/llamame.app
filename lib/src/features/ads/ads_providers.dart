import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'ad_models.dart';
import 'ads_repository.dart';

final bannerAdProvider =
    FutureProvider.family<Ad?, int?>((ref, categoryId) async {
  final repo = ref.watch(adsRepositoryProvider);
  if (repo == null) throw StateError('Supabase not configured');
  return repo.fetchActiveAd(type: AdType.banner, categoryId: categoryId);
});

final interstitialAdProvider =
    FutureProvider.family<Ad?, int?>((ref, categoryId) async {
  final repo = ref.watch(adsRepositoryProvider);
  if (repo == null) throw StateError('Supabase not configured');
  return repo.fetchActiveAd(type: AdType.interstitial, categoryId: categoryId);
});

final heroAdProvider = FutureProvider<Ad?>((ref) async {
  final repo = ref.watch(adsRepositoryProvider);
  if (repo == null) throw StateError('Supabase not configured');
  return repo.fetchActiveAd(type: AdType.hero);
});

final popupAdProvider = FutureProvider<Ad?>((ref) async {
  final repo = ref.watch(adsRepositoryProvider);
  if (repo == null) throw StateError('Supabase not configured');
  return repo.fetchActiveAd(type: AdType.popup);
});

final _interstitialShownProvider = StateProvider<bool>((ref) => false);

final canShowInterstitialProvider = Provider<bool>((ref) {
  return !ref.watch(_interstitialShownProvider);
});

void markInterstitialShown(WidgetRef ref) {
  ref.read(_interstitialShownProvider.notifier).state = true;
}

final _popupShownProvider = StateProvider<bool>((ref) => false);

final canShowPopupProvider = Provider<bool>((ref) {
  return !ref.watch(_popupShownProvider);
});

void markPopupShown(WidgetRef ref) {
  ref.read(_popupShownProvider.notifier).state = true;
}
