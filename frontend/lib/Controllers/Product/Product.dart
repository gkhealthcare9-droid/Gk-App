import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sales_grow/Models/product/customer_product.dart';
import 'package:sales_grow/Models/product/getproduct_model.dart';
import 'package:sales_grow/Models/product/product_category_model.dart';
import 'package:sales_grow/Services/Product/Get_product_services.dart';
import 'package:flutter/foundation.dart';
import 'package:sales_grow/Views/Widgets/CustomAlert.dart';
import 'package:sales_grow/Views/Widgets/CustomBottomNav.dart';

class ProductController extends GetxController {
  var isLoading = false.obs;
  var products = <GetProductModel>[].obs;
  var customerProducts = <CustomerProduct>[].obs;
  var categories = <ProductCategoryModel>[].obs;
  var manufacturers = <Manufacturer>[].obs;
  final Productservices _productservices = Productservices();
  var customerLoading = false.obs;
  var productsLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
    fetchManufacturers();
  }

  Future<void> fetchCategories() async {
    if (isLoading.value) return;
    isLoading.value = true;
    try {
      final fetched = await _productservices.fetchCategories();
      if (fetched != null) {
        categories.assignAll(fetched);
      }
    } catch (e) {
      // Intentionally silent or logged during onInit to prevent "No Overlay" crash
      debugPrint("Failed to fetch categories: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchManufacturers() async {
    if (isLoading.value) return;
    isLoading.value = true;
    try {
      final fetched = await _productservices.fetchManufacturers();
      if (fetched != null && fetched.isNotEmpty) {
        manufacturers.assignAll(fetched);
      }
    } catch (e) {
      debugPrint("Failed to fetch manufacturers: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<GetProductModel?> fetchProductById(int productId) async {
    if (productsLoading.value) return null;
    try {
      if (products.isEmpty) {
        await fetchProducts();
      }
      final product = products.firstWhereOrNull(
        (p) => p.productId == productId,
      );
      return product;
    } catch (e) {
      CustomAlert.error("Failed to fetch product: $e");
      return null;
    }
  }

  Future<void> addProduct({
    required String hsn,
    required String category,
    required String productName,
    required double rate,
    required int tax,
    List<Uint8List>? imageBytesList,
    List<String>? fileNames,
  }) async {
    isLoading.value = true;
    try {
      final success = await _productservices.addProduct(
        category: category,
        hsn: hsn,
        imageBytesList: imageBytesList,
        fileNames: fileNames,
        productName: productName,
        rate: rate,
        tax: tax,
      );
      if (success) {
        CustomAlert.success('Product added successfully');
        await fetchProducts();
        await Future.delayed(const Duration(seconds: 2));
        Get.offAll(() => const CustomBottomNavBar());
      } else {
        CustomAlert.error('Failed to add product');
      }
    } catch (e) {
      CustomAlert.error('Something went wrong: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateProduct({
    required String id,
    required String productName,
    required double rate,
    required int tax,
    required String hsn,
    required String categoryId,
  }) async {
    try {
      final success = await _productservices.updateProduct(
        productId: id,
        name: productName,
        rate: rate,
        tax: tax,
        hsn: hsn,
        categoryId: categoryId,
      );
      if (success) {
        CustomAlert.success("Product updated successfully");
        await fetchProducts();
        await Future.delayed(const Duration(seconds: 2));
        Get.offAll(() => const CustomBottomNavBar());
      }
      return success;
    } catch (e) {
      CustomAlert.error("Error updating product: $e");
      return false;
    }
  }

  Future<bool> deleteProduct(String productId) async {
    try {
      final success = await _productservices.deleteProduct(productId);
      if (success) {
        products.removeWhere((p) => p.productId.toString() == productId);
        CustomAlert.success("Product deleted successfully");
        update();
      }
      return success;
    } catch (e) {
      CustomAlert.error("Error deleting product: $e");
      return false;
    }
  }

  Future<void> fetchProducts() async {
    if (productsLoading.value) return;
    productsLoading.value = true;
    try {
      final fetched = await _productservices.fetchProducts();
      if (fetched != null) {
        products.assignAll(fetched);
      }
    } on DioException catch (e) {
      CustomAlert.error("Network error: ${e.message}");
    } catch (e) {
      CustomAlert.error("Failed to fetch products: $e");
    } finally {
      productsLoading.value = false;
    }
  }

  Future<void> addCustomerProduct({
    required String customerId,
    required String productCategoryId,
    required String slNumber,
    required String manufacturer,
    required String soldDate,
    required String warrantyDate,
    String? amcStart,
    String? amcEnd,
  }) async {
    if (isLoading.value) return;
    isLoading.value = true;
    try {
      final success = await _productservices.addCustomerProduct(
        customerId: customerId,
        productCategoryId: productCategoryId,
        slNumber: slNumber,
        manufacturer: manufacturer,
        soldDate: soldDate,
        warrantyDate: warrantyDate,
        amcStart: amcStart,
        amcEnd: amcEnd,
      );
      if (success) {
        CustomAlert.success('Customer product added successfully');
        await fetchCustomerProducts(customerId);
        await Future.delayed(const Duration(seconds: 2));
        Get.offAll(() => const CustomBottomNavBar());
      } else {
        CustomAlert.error('Failed to add customer product');
      }
    } catch (e) {
      CustomAlert.error('Something went wrong: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchCustomerProducts(String id) async {
    if (customerLoading.value) return;
    customerLoading.value = true;
    try {
      final fetched = await _productservices.fetchCustomerProducts(id);
      if (fetched != null && fetched.isNotEmpty) {
        customerProducts.assignAll(fetched);
      }
    } catch (e) {
      CustomAlert.error("Failed to fetch customer products: $e");
    } finally {
      customerLoading.value = false;
    }
  }

  Future<bool> deleteCustomerProduct(String customerProductId) async {
    try {
      final success = await _productservices.deleteCustomerProduct(
        customerProductId,
      );
      if (success) {
        customerProducts.removeWhere((p) => p.id == customerProductId);
        CustomAlert.success("Customer product deleted");
        update();
      }
      return success;
    } catch (e) {
      CustomAlert.error("Error deleting product: $e");
      return false;
    }
  }

  Future<bool> updateCustomerProduct(
    String productId,
    PostCustomerProductModel updatedProduct,
  ) async {
    try {
      final success = await _productservices.updateCustomerProduct(
        id: productId,
        customerId: updatedProduct.customer,
        productCategoryId: updatedProduct.productCategory,
        manufacturerId: updatedProduct.manufacturer,
        serialNumber: updatedProduct.slNumber,
        soldDate: updatedProduct.soldDate,
        warrantyDate: updatedProduct.warranty,
        amcStart: updatedProduct.amcStart,
        amcEnd: updatedProduct.amcEnd,
      );
      if (success) {
        CustomAlert.success("Customer product updated");
        await fetchCustomerProducts(updatedProduct.customer);
        await Future.delayed(const Duration(seconds: 2));
        Get.offAll(() => const CustomBottomNavBar());
      }
      return success;
    } catch (e) {
      CustomAlert.error('Error updating customer product: $e');
      return false;
    }
  }
}
