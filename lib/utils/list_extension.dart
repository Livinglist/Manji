import 'dart:math';

extension ListExtension<E> on List<E> {
  bool containsWhere(bool test(E e)) {
    for (var i in this) {
      if (test(i)) return true;
    }
    return false;
  }

  List<E> getThenRemoveWhere(bool test(E e)) {
    final tempList = <E>[];

    for (var i in this) {
      if (test(i)) {
        tempList.add(i);
        remove(i);
      }
    }

    return tempList;
  }

  List<E> takeRandomly(int amount) {
    var index = -1;
    final list = <E>[];

    final visited = <int>[];

    for (var i = 0; i < amount; i++) {
      index =
          Random(DateTime.now().millisecondsSinceEpoch).nextInt(length - 1) + 1;

      while (visited.contains(index)) {
        index =
            Random(DateTime.now().millisecondsSinceEpoch).nextInt(length - 1) +
                1;
      }

      visited.add(index);
      list.add(this[index]);
    }

    return list;
  }
}
