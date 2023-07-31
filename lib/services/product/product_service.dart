import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:products/model/product/products_list_model.dart';
import 'package:products/services/auth/api_value_service.dart';
import 'package:products/services/product/product_list_service.dart';

class ProductService {
  late ProductListService productListService;

  ProductService(ProductListService service) {
    productListService = service;
  }

  getProducts(String autToken) async {
    if (autToken.isNotEmpty) {
      Uri url = Uri.http(
          ApiServiceValues.productBaseUrl, ApiServiceValues.productBaseUrl, {
        'limit': '10',
        'skip': productListService.skip.toString(),
        //'select': 'title,price',
      });
      await http.get(
        url,
        headers: {
          'Connection': 'keep-alive',
          'Authorization': 'Bearer $autToken',
          'Content-Type': 'application/json'
        },
      ).then((response) {
        if (response.statusCode == 200) {
          //Tree ways to parse info. Default ,via compute ,Isolate.spawn-Message
          //1 default
          productListService.isProductLoading = true;
          final productListModel = ProductsListModel.fromRawJson(response.body);
          productListService.addProducts(productListModel.products);
          productListService.skip += 10;
          productListService.isProductLoading = false;

          //2 via compute
          // productListService.isProductLoading = true;
          // ProductsServiceBackgroundParser()
          //     .parseViaCompute(response.body)
          //     .then((productsList) {
          //   productListService.addProducts(productsList.products);
          //   productListService.skip += 10;
          //   productListService.isProductLoading = false;
          // });
          //3 via Isolate.spawn
          // productListService.isProductLoading = true;
          // ProductsServiceBackgroundParser()
          //     .parseViaIsolate(response.body)
          //     .then((productsList) {
          //   productListService.addProducts(productsList.products);
          //   productListService.skip += 10;
          //   productListService.isProductLoading = false;
          // });
        } else if (response.statusCode == 404) {
          productListService.isProductLoading = false;
          productListService
              .addProductError('Failed to load products:\n404 not found');
        } else {
          productListService.isProductLoading = false;
          productListService
              .addProductError('Failed to load product \nUnknown error');
        }
      }).onError((error, stackTrace) {
        productListService.isProductLoading = false;
        productListService.addProductError('Failed to load product \n$error');
      });
    } else {
      productListService.isProductLoading = false;
      productListService.addProductError('Failed to load prodcuts');
    }
  }
}

@immutable
class ProductServiceBackgroundMessage {
  final SendPort sendPort;
  final String encodeJson;

  const ProductServiceBackgroundMessage({
    required this.sendPort,
    required this.encodeJson,
  });
}

class ProductsServiceBackgroundParser {
  //Background parser via compute
  Future<ProductsListModel> parseViaCompute(String encodedJson) async {
    return await compute(_fromRawJsonViaCompute, encodedJson);
  }

  ProductsListModel _fromRawJsonViaCompute(String body) {
    return ProductsListModel.fromRawJson(body);
  }

  // parser via Isolate spawn
  Future<ProductsListModel> parseViaIsolate(String encodedJson) async {
    final ReceivePort receivePort = ReceivePort();
    ProductServiceBackgroundMessage productServiceBackgroundMessage =
        ProductServiceBackgroundMessage(
      sendPort: receivePort.sendPort,
      encodeJson: encodedJson,
    );
    // await Isolate.spawn(
    //     _fromRawJsonViaIsolate, ProductServiceBackgroundMessage);

    // Note:Arguments can be as (a list<dynamic> parameters)
    // await Isolate.spawn(_fromRawJsonDynamic,[recivePort.sendPort, encodedJson ]);
    return await receivePort.first;
  }

  void _fromRawJsonViaIsolate(
      ProductServiceBackgroundMessage productServiceBackgroundMessage) async {
    SendPort sendPort = productServiceBackgroundMessage.sendPort;
    String encodedJson = productServiceBackgroundMessage.encodeJson;
    final result = ProductsListModel.fromRawJson(encodedJson);
    Isolate.exit(sendPort, result);
  }
/*
  // Parameters could also receive Arguments as (List<dynamic>)
  // Future<void> _fromRawJsonViaIsolateDynamic(List<dynamic> parameters) {
  //   SendPort sendPort = parameters[0];
  //   String encodedJson = parameters[1];
  //   final resuld = ProductsListModel.fromRawJson(encodedJson);
  //
//   Isolate.exit(sendPort, resuld);}
*/
}
