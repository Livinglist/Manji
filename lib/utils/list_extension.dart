extension ListHelpers<E> on List<E> {
  bool containsWhere(bool test(E e)) {
    for (var i in this) {
      if (test(i)) return true;
    }
    return false;
  }

  List<E> getThenRemoveWhere(bool test(E e)){
    var tempList = <E>[];

    for(var i in this){
      if(test(i)) {
        tempList.add(i);
        this.remove(i);
      }
    }

    return tempList;
  }
}
