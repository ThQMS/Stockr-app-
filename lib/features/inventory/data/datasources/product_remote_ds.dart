import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/product_filters.dart';
import '../../domain/entities/product_params.dart';
import '../models/product_model.dart';

abstract interface class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts({
    required String workspaceId,
    ProductFilters? filters,
  });
  Future<ProductModel> getById(String id);
  Future<ProductModel> scanByCode({
    required String code,
    required String workspaceId,
  });
  Future<ProductModel> create(CreateProductParams params);
  Future<ProductModel> update(UpdateProductParams params);
  Future<Unit> delete(String id);
}

final class DioProductRemoteDataSource implements ProductRemoteDataSource {
  const DioProductRemoteDataSource(this._client);

  final DioClient _client;

  @override
  Future<List<ProductModel>> getProducts({
    required String workspaceId,
    ProductFilters? filters,
  }) async {
    final response = await _client.get<List<dynamic>>(
      '/products',
      queryParameters: {
        'workspaceId': workspaceId,
        if (filters?.query != null) 'query': filters!.query,
        if (filters?.categoryId != null) 'categoryId': filters!.categoryId,
        if (filters?.onlyActive != null) 'onlyActive': filters!.onlyActive,
        if (filters?.onlyLowStock != null)
          'onlyLowStock': filters!.onlyLowStock,
      },
    );
    final data = response.data;
    if (data == null) {
      throw const ServerException('Empty products response');
    }

    return data
        .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ProductModel> getById(String id) async {
    final response = await _client.get<Map<String, dynamic>>('/products/$id');
    return _readProduct(response);
  }

  @override
  Future<ProductModel> scanByCode({
    required String code,
    required String workspaceId,
  }) async {
    try {
      final response = await _client.get<Map<String, dynamic>>(
        '/products/scan/$code',
        queryParameters: {'workspaceId': workspaceId},
      );
      return _readProduct(response);
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw const NotFoundException('Product not found');
      }
      rethrow;
    }
  }

  @override
  Future<ProductModel> create(CreateProductParams params) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/products',
      data: {
        'workspaceId': params.workspaceId,
        'name': params.name,
        'sku': params.sku.value,
        'barcode': params.barcode,
        'currentStock': params.currentStock.value,
        'minimumStock': params.minimumStock.value,
        'costPriceCents': params.costPrice.cents,
        'salePriceCents': params.salePrice.cents,
        'categoryId': params.categoryId,
        'status': params.isActive ? 'active' : 'inactive',
        'unit': 'un',
      },
    );
    return _readProduct(response);
  }

  @override
  Future<ProductModel> update(UpdateProductParams params) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/products/${params.id}',
      data: {
        if (params.name != null) 'name': params.name,
        if (params.sku != null) 'sku': params.sku!.value,
        if (params.barcode != null) 'barcode': params.barcode,
        if (params.currentStock != null)
          'currentStock': params.currentStock!.value,
        if (params.minimumStock != null)
          'minimumStock': params.minimumStock!.value,
        if (params.costPrice != null) 'costPriceCents': params.costPrice!.cents,
        if (params.salePrice != null) 'salePriceCents': params.salePrice!.cents,
        if (params.categoryId != null) 'categoryId': params.categoryId,
        if (params.isActive != null)
          'status': params.isActive! ? 'active' : 'inactive',
      },
    );
    return _readProduct(response);
  }

  @override
  Future<Unit> delete(String id) async {
    await _client.post<void>('/products/$id/delete');
    return unit;
  }

  ProductModel _readProduct(Response<Map<String, dynamic>> response) {
    final data = response.data;
    if (data == null) {
      throw const ServerException('Empty product response');
    }

    return ProductModel.fromJson(data);
  }
}
