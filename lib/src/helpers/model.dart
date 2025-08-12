class IModel {
  int? id = 0;

  IModel({this.id = 0});

  bool hasRecord() {
    return id != null && id! > 0;
  }
}
