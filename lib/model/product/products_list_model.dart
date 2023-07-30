import 'dart:convert';

import 'product_model.dart';

class ProductListModel {
  List<ProductModel> products;
  int total;
  int skip;
  int limit;

  ProductListModel({
    required this.products,
    required this.total,
    required this.skip,
    required this.limit,
  });

  factory ProductListModel.fromRawJson(String str) =>
      ProductListModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ProductListModel.fromJson(Map<String, dynamic> json) =>
      ProductListModel(
        products: List<ProductModel>.from(
            json["products"].map((x) => ProductModel.fromJson(x))),
        total: json["total"],
        skip: json["skip"],
        limit: json["limit"],
      );

  Map<String, dynamic> toJson() => {
        "products": List<dynamic>.from(products.map((x) => x.toJson())),
        "total": total,
        "skip": skip,
        "limit": limit,
      };
}
