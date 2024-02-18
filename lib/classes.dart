class Item {
  Item(this.infos);

  Map<String, String> infos = {};
  //List<String> defaultHeaders = ['Game', 'Type', 'Subtype', 'JP Name', 'EN Name', 'Icon'];

  Item.fromMap(Map<String, String> infos) : this(infos);

}
