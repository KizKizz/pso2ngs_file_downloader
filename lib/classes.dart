class Item {
  Item(this.infos);

  Map<String, String> infos = {};
  List<String> defaultHeaders = ['Game', 'Type', 'Subtype', 'JP Name', 'EN Name', 'Icon'];

  Item.fromMap(Map<String, String> infos) : this(infos);

  Map<String, String> setInfos(List<String> headers, List<String> itemInfos) {
    if (headers.isEmpty || itemInfos.isEmpty) return {};

    Map<String, String> item = {};
    if (itemInfos.length > headers.length) {
      for (var i = 0; i < itemInfos.length; i++) {
        if (i > headers.length) {
          item.addAll({itemInfos[i]: 'Unknown($i)'});
        } else {
          item.addAll({itemInfos[i]: headers[i]});
        }
      }
    } else if (itemInfos.length < headers.length) {
      for (var i = 0; i < headers.length; i++) {
        if (i > itemInfos.length) {
          item.addAll({'': headers[i]});
        } else {
          item.addAll({itemInfos[i]: headers[i]});
        }
      }
    } else {
      for (var i = 0; i < headers.length; i++) {
        item.addAll({itemInfos[i]: headers[i]});
      }
    }

    return item;
  }
}
