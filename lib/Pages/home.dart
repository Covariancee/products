import 'package:flutter/material.dart';
import 'package:products/services/auth/auth_service.dart';
import 'package:products/services/connection_service.dart';
import 'package:products/services/product/product_list_service.dart';
import 'package:products/widgets/status_message.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late ConnectionService connectionService;
  AuthServiceResponse authServiceResponse = AuthServiceResponse();

  //// bunu neden böyle tanımladık sor ?

  // late ProductService productService;
  final ProductListService productListService = ProductListService();
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    connectionService = ConnectionService(productListService);
    connectionService.watchConnectivity(productListService);
    getAuth();
    // check if scrool has reached the bottom ,Then show next 10
    scrollController.addListener(() {
      if (scrollController.offset ==
              scrollController.position.maxScrollExtent &&
          !productListService.isProductLoading) {
        //TODO get products ...      }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<bool> checkInternetConnection() async {
    productListService.internetConnectionAvailability =
        await connectionService.isInternetConnectionAvailable();
    if (!productListService.internetConnectionAvailability) {
      productListService.internetConnectionAvailability = false;
      productListService.isProductLoading = false;
      productListService
          .addProductError('Internet Connection is not available');
    }
    return productListService.internetConnectionAvailability;
  }

  Future<void> getAuth() async {
    productListService.internetConnectionAvailability =
        await checkInternetConnection();
    if (!productListService.internetConnectionAvailability) {
      return;
    }

    // Authenticate User and look for credantel error
    authServiceResponse = await AuthService.login();
    if (authServiceResponse.statusCode == 200 &&
        authServiceResponse.error != 'Error Response') {
      productListService.isProductLoading = false;
      //TODO get product
    } else {
      productListService.isProductLoading = false;
      final String error = authServiceResponse.error;
      productListService.addProductError(error);
    }
  }

  Future<void> getProducts() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product'),
      ),
      body: SafeArea(
        child: StreamBuilder(
          initialData: const [],
          stream: productListService.getProductList,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (!productListService.internetConnectionAvailability) {
              return const StatusMessage(
                message: 'Internet connection is not available',
                bannerMessage: 'none',
                bannerColor: Colors.yellow,
                textColor: Colors.black,
              );
            }
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return const Center(child: CircularProgressIndicator());
              case ConnectionState.active:
                if (snapshot.hasError) {
                  return StatusMessage(
                      message: '${snapshot.error}',
                      bannerMessage:
                          !productListService.internetConnectionAvailability
                              ? 'none'
                              : 'error',
                      bannerColor:
                          !productListService.internetConnectionAvailability
                              ? Colors.yellow
                              : Colors.red,
                      textColor:
                          !productListService.internetConnectionAvailability
                              ? Colors.black
                              : Colors.white);
                } else if (snapshot.hasData) {
                  //TODO: Return products
                }
              default:
            }
            return const Text('Hello');
          },

          // TODO Check SnapShot connection State
        ),
      ),
    );
  }
}
