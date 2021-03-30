import 'dart:math';

extension ListExtension<E> on List<E> {
  bool containsWhere(bool test(E e)) {
    for (var i in this) {
      if (test(i)) return true;
    }
    return false;
  }

  List<E> getThenRemoveWhere(bool test(E e)) {
    var tempList = <E>[];

    for (var i in this) {
      if (test(i)) {
        tempList.add(i);
        this.remove(i);
      }
    }

    return tempList;
  }

  List<E> takeRandomly(int amount) {
    int index = -1;
    var list = <E>[];

    var visited = <int>[];

    for (int i = 0; i < amount; i++) {
      index = Random(DateTime.now().millisecondsSinceEpoch)
              .nextInt(this.length - 1) +
          1;

      while (visited.contains(index)) {
        index = Random(DateTime.now().millisecondsSinceEpoch)
                .nextInt(this.length - 1) +
            1;
      }

      visited.add(index);
      list.add(this[index]);
    }

    return list;
  }
}
