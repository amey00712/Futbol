class SideMenuModel {
  String web_id;
  String web_title;
  String web_img;
  String web_link;
  String web_status;

  SideMenuModel(this.web_id, this.web_title, this.web_img, this.web_link, this.web_status);

  SideMenuModel.fromJSON(Map<String, dynamic> json) {
    web_id = json["web_id"];
    web_title = json["web_title"];
    web_img = json["web_img"];
    web_link = json["web_link"];
    web_status = json["web_status"];
  }
}