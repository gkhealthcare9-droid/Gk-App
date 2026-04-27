import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:sales_grow/Models/product/customer_product.dart';
import 'package:sales_grow/Models/product/getproduct_model.dart';
import 'package:sales_grow/Models/product/product_category_model.dart';
import '../ApiService.dart';
import '../../Utils/Appconstants.dart';

class Productservices {
  final Dio _dio = ApiService().dio;

  Future<List<GetProductModel>?> fetchProducts() async {
    try {
      final response = await _dio.get(AppConstants.GETPRODUCT);

      if (response.statusCode == 200) {
        if (response.data is List) {
          return (response.data as List)
              .map((item) => GetProductModel.fromJson(item))
              .toList();
        }
      }
      return null;
    } catch (e) {
      print('Error fetching products: $e');
      return null;
    }
  }

  Future<List<ProductCategoryModel>?> fetchCategories() async {
    try {
      final response = await _dio.get(AppConstants.CATEGORYPRODUCT);

      if (response.statusCode == 200) {
        if (response.data is List) {
          return (response.data as List)
              .map((item) => ProductCategoryModel.fromJson(item))
              .toList();
        }
      }
      return null;
    } catch (e) {
      print('Error fetching categories: $e');
      return null;
    }
  }

  Future<List<CustomerProduct>?> fetchCustomerProducts(String id) async {
    try {
      final response = await _dio.get('${AppConstants.GETPRODUCTBYCUSTOMER}/$id');

      if (response.statusCode == 200) {
        if (response.data is List) {
          return (response.data as List)
              .map((item) => CustomerProduct.fromJson(item))
              .toList();
        }
      }
      return null;
    } catch (e) {
      print('Error fetching customer products: $e');
      return null;
    }
  }

  Future<List<Manufacturer>?> fetchManufacturers() async {
    try {
      final response = await _dio.get(AppConstants.GETMANUFACTURER);

      if (response.statusCode == 200) {
        if (response.data is List) {
          return (response.data as List)
              .map((item) => Manufacturer.fromJson(item))
              .toList();
        }
      }
      return null;
    } catch (e) {
      print('Error fetching manufacturers: $e');
      return null;
    }
  }

  Future<bool> addProduct({
    required String hsn,
    required String category,
    required String productName,
    required double rate,
    required int tax,
    required List<Uint8List>? imageBytesList,
    required List<String>? fileNames,
  }) async {
    try {
      List<MultipartFile> multipartImages = [];

      if (imageBytesList != null && fileNames != null) {
        for (int i = 0; i < imageBytesList.length; i++) {
          multipartImages.add(
            MultipartFile.fromBytes(imageBytesList[i], filename: fileNames[i]),
          );
        }
      }

      FormData formData = FormData.fromMap({
        'productCategory': category,
        'productName': productName,
        'tax': tax,
        'rate': rate,
        'HSN': hsn,
        'images': multipartImages,
      });

      final response = await _dio.post(
        AppConstants.GETPRODUCT,
        data: formData,
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error adding product: $e');
      return false;
    }
  }

  Future<bool> deleteProduct(String productId) async {
    try {
      final response = await _dio.delete('${AppConstants.DELETEPRODUCT}/$productId');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Error while deleting product: $e');
      return false;
    }
  }

  Future<bool> updateProduct({
    required String productId,
    required String name,
    required double rate,
    required int tax,
    required String hsn,
    required String categoryId,
  }) async {
    try {
      final url = '/api/v1/product/product/$productId';

      final data = {
        "productName": name,
        "rate": rate,
        "tax": tax,
        "HSN": hsn,
        "productCategory": categoryId,
      };

      final response = await _dio.put(url, data: data);
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print("Error updating product: $e");
      return false;
    }
  }

  Future<bool> addCustomerProduct({
    required String customerId,
    required String productCategoryId,
    required String slNumber,
    required String manufacturer,
    required String soldDate,
    required String warrantyDate,
    String? amcStart,
    String? amcEnd,
  }) async {
    try {
      Map<String, dynamic> requestBody = {
        'customer': customerId,
        'productCategory': productCategoryId,
        'manufacturer': manufacturer,
        'slNumber': slNumber,
        'soldDate': soldDate,
        'warranty': warrantyDate,
        'amcStart': amcStart?.isEmpty ?? true ? null : amcStart,
        'amcEnd': amcEnd?.isEmpty ?? true ? null : amcEnd,
      };

      final response = await _dio.post(
        AppConstants.ADDPRODUCT,
        data: requestBody,
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error adding customer product: $e');
      return false;
    }
  }

  Future<bool> deleteCustomerProduct(String customerProductId) async {
    try {
      final url = '/customer-product/$customerProductId';
      final response = await _dio.delete(url);
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print("Error deleting customer product: $e");
      return false;
    }
  }

  Future<bool> updateCustomerProduct({
    required String id,
    required String customerId,
    required String productCategoryId,
    required String manufacturerId,
    required String serialNumber,
    required DateTime soldDate,
    required DateTime warrantyDate,
    DateTime? amcStart,
    DateTime? amcEnd,
  }) async {
    try {
      final url = '/api/v1/customer/product/$id';

      final data = {
        "customer": customerId,
        "productCategory": productCategoryId,
        "manufacturer": manufacturerId,
        "slNumber": serialNumber,
        "soldDate": soldDate.toIso8601String(),
        "warranty": warrantyDate.toIso8601String(),
        "amcStart": amcStart?.toIso8601String(),
        "amcEnd": amcEnd?.toIso8601String(),
      };

      final response = await _dio.put(url, data: data);
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print("Error updating customer product: $e");
      return false;
    }
  }
}
