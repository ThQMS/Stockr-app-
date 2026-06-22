import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/product.dart';
import '../providers/products_provider.dart';
import '../widgets/product_card.dart';

enum _ProductFilter { all, lowStock, inactive }

final _productSearchProvider = StateProvider.autoDispose<String>((ref) => '');
final _productFilterProvider = StateProvider.autoDispose<_ProductFilter>(
  (ref) => _ProductFilter.all,
);

class ProductsScreen extends ConsumerWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(
      productsNotifierProvider(workspaceId: defaultWorkspaceId),
    );
    final query = ref.watch(_productSearchProvider);
    final filter = ref.watch(_productFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Produtos'),
        actions: [
          IconButton(
            tooltip: 'Scanner',
            onPressed: () => context.go('/scanner'),
            icon: const Icon(Icons.qr_code_scanner),
          ),
          IconButton(
            tooltip: 'Relatorios',
            onPressed: () => context.go('/reports'),
            icon: const Icon(Icons.bar_chart),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref
            .read(
              productsNotifierProvider(workspaceId: defaultWorkspaceId)
                  .notifier,
            )
            .refresh(),
        child: products.when(
          data: (items) {
            final filtered = _filterProducts(items, query, filter);

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const _SyncStatusBanner(),
                SearchBar(
                  hintText: 'Buscar produto ou SKU',
                  leading: const Icon(Icons.search),
                  onChanged: (value) {
                    ref.read(_productSearchProvider.notifier).state = value;
                  },
                ),
                const SizedBox(height: 12),
                _FilterChips(
                  selected: filter,
                  onSelected: (value) {
                    ref.read(_productFilterProvider.notifier).state = value;
                  },
                ),
                const SizedBox(height: 12),
                if (filtered.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 96),
                    child: Center(child: Text('Nenhum produto encontrado.')),
                  )
                else
                  for (final product in filtered) ...[
                    ProductCard(
                      product: product,
                      onTap: () => context.go('/products/${product.id}'),
                    ),
                    const SizedBox(height: 8),
                  ],
              ],
            );
          },
          error: (error, stackTrace) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _ErrorPanel(message: error.toString()),
            ],
          ),
          loading: () => const _ProductsSkeleton(),
        ),
      ),
    );
  }

  List<Product> _filterProducts(
    List<Product> products,
    String query,
    _ProductFilter filter,
  ) {
    final normalized = query.trim().toLowerCase();
    return products.where((product) {
      final matchesQuery = normalized.isEmpty ||
          product.name.toLowerCase().contains(normalized) ||
          product.sku.value.toLowerCase().contains(normalized);
      final matchesFilter = switch (filter) {
        _ProductFilter.all => true,
        _ProductFilter.lowStock => product.isLowStock,
        _ProductFilter.inactive => !product.isActive,
      };

      return matchesQuery && matchesFilter;
    }).toList();
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({
    required this.selected,
    required this.onSelected,
  });

  final _ProductFilter selected;
  final ValueChanged<_ProductFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        FilterChip(
          label: const Text('Todos'),
          selected: selected == _ProductFilter.all,
          onSelected: (_) => onSelected(_ProductFilter.all),
        ),
        FilterChip(
          label: const Text('Estoque baixo'),
          selected: selected == _ProductFilter.lowStock,
          onSelected: (_) => onSelected(_ProductFilter.lowStock),
        ),
        FilterChip(
          label: const Text('Inativos'),
          selected: selected == _ProductFilter.inactive,
          onSelected: (_) => onSelected(_ProductFilter.inactive),
        ),
      ],
    );
  }
}

class _SyncStatusBanner extends ConsumerWidget {
  const _SyncStatusBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = ref.watch(pendingSyncCountProvider);
    return pending.maybeWhen(
      data: (count) => count > 0
          ? Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: MaterialBanner(
                leading: const Icon(Icons.sync_problem),
                content: Text('$count movimentacao(oes) aguardando sync.'),
                actions: const [SizedBox.shrink()],
              ),
            )
          : const SizedBox.shrink(),
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _ProductsSkeleton extends StatelessWidget {
  const _ProductsSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) => const _SkeletonCard(),
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemCount: 6,
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ShimmerBox(width: 180, height: 18),
            SizedBox(height: 10),
            _ShimmerBox(width: 96, height: 14),
            SizedBox(height: 16),
            _ShimmerBox(width: double.infinity, height: 12),
          ],
        ),
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox({
    required this.width,
    required this.height,
  });

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.35, end: 0.75),
      duration: const Duration(milliseconds: 900),
      builder: (context, value, child) {
        return DecoratedBox(
          decoration: BoxDecoration(
            color: Color.lerp(
              Theme.of(context).colorScheme.surfaceContainerHighest,
              Theme.of(context).colorScheme.surface,
              value,
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: SizedBox(width: width, height: height),
        );
      },
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(message),
      ),
    );
  }
}
