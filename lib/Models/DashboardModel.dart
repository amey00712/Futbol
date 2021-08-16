class SideMenuModel {
  String files_id;
  String files_type;
  String files_title;
  String files_name;
  String files_status;
  String files_date;

  SideMenuModel(this.files_id, this.files_type, this.files_title, this.files_name, this.files_status, this.files_date);

  SideMenuModel.fromJSON(Map<String, dynamic> json) {
    files_id = json["files_id"];
    files_type = json["files_type"];
    files_title = json["files_title"];
    files_name = json["files_name"];
    files_status = json["files_status"];
    files_date = json["files_date"];
  }

}

class SliderModel {
  String files_title;
  String files_name;
  String files_content;
  String files_thumb;
  String files_type;
  String post_appurl;
  String files_id;

  SliderModel(
      this.files_title,
      this.files_name,
      this.files_content,
      this.files_thumb,
      this.files_type,
      this.post_appurl,
      this.files_id

  );

  SliderModel.fromJSON(Map<String, dynamic> json) {
    files_title = json["files_title"];
    files_name = json["files_name"];
    files_content = json["files_content"];
    files_thumb = json["files_thumb"];
    files_type = json["files_type"];
    post_appurl = json["post_appurl"];
    files_id = json["files_id"];

  }
}