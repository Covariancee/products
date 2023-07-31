import 'dart:convert';

import 'product_model.dart';

class ProductsListModel {
  List<ProductModel> products;
  int total;
  int skip;
  int limit;

  ProductsListModel({
    required this.products,
    required this.total,
    required this.skip,
    required this.limit,
  });

  factory ProductsListModel.fromRawJson(String str) =>
      ProductsListModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ProductsListModel.fromJson(Map<String, dynamic> json) =>
      ProductsListModel(
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
