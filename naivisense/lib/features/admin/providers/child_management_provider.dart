import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/child_repository.dart';
import '../../../shared/models/child.dart';
import '../../../shared/models/api/child_requests.dart';

class ChildrenNotifier extends AsyncNotifier<List<Child>> {
  @override
  Future<List<Child>> build() =>
      ref.read(childRepositoryProvider).getChildren();

  Future<bool> create(ChildCreateRequest request) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.read(childRepositoryProvider).createChild(request),
    );
    return result.when(
      data: (child) {
        state = AsyncData([...state.valueOrNull ?? [], child]);
        return true;
      },
      error: (e, _) {
        state = AsyncError(e, StackTrace.current);
        return false;
      },
      loading: () => false,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(childRepositoryProvider).getChildren(),
    );
  }

  Future<bool> assignTherapist(String childId, String therapistId) async {
    final result = await AsyncValue.guard(
      () => ref
          .read(childRepositoryProvider)
          .assignTherapist(childId, therapistId),
    );
    return result.when(
      data: (updated) {
        state = AsyncData(
          (state.valueOrNull ?? [])
              .map((c) => c.id == childId ? updated : c)
              .toList(),
        );
        return true;
      },
      error: (_, __) => false,
      loading: () => false,
    );
  }
}

final childrenProvider =
    AsyncNotifierProvider<ChildrenNotifier, List<Child>>(ChildrenNotifier.new);

final childProvider = FutureProvider.family<Child, String>(
  (ref, id) => ref.read(childRepositoryProvider).getChild(id),
);
