class Player {
  String imageUrl, name, position;
  String? id;
  DateTime? createdAt;

  Player(
      {this.position = "unemployed",
      this.id,
      this.imageUrl = "https://api.multiavatar.com/1.png",
      this.name = "unknown",
      this.createdAt});
}
