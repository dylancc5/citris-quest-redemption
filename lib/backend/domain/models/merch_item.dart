enum MerchItemType {
  shirt,
  magnet,
  sticker,
  keychain,
}

class MerchItem {
  final String id;
  final String name;
  final String description;
  final int coinPrice;
  final String imageUrl; // Placeholder icon or actual image path
  final MerchItemType type;
  final List<String>? sizes; // Only for shirts
  final String printifyProductId; // Printify API product ID

  const MerchItem({
    required this.id,
    required this.name,
    required this.description,
    required this.coinPrice,
    required this.imageUrl,
    required this.type,
    this.sizes,
    required this.printifyProductId,
  });

  bool get requiresSize => type == MerchItemType.shirt && sizes != null;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'coin_price': coinPrice,
        'image_url': imageUrl,
        'type': type.name,
        'sizes': sizes,
        'printify_product_id': printifyProductId,
      };

  factory MerchItem.fromJson(Map<String, dynamic> json) => MerchItem(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        coinPrice: json['coin_price'] as int,
        imageUrl: json['image_url'] as String,
        type: MerchItemType.values.firstWhere(
          (e) => e.name == json['type'],
        ),
        sizes: (json['sizes'] as List<dynamic>?)?.cast<String>(),
        printifyProductId: json['printify_product_id'] as String,
      );
}
