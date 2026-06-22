import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection.dart';
import '../../../inventory/presentation/providers/products_provider.dart';
import '../../domain/usecases/get_inventory_report_usecase.dart';
import '../widgets/metric_card.dart';
import '../widgets/movement_chart.dart';

final inventoryReportProvider = FutureProvider.autoDispose((ref) async {
  final useCase = getIt<GetInventoryReportUseCase>();
  final result = await useCase(
    const GetInventoryReportParams(workspaceId: defaultWorkspaceId),
  );
  return result.match(
    (failure) => throw _ReportException(failure.message),
    (report) => report,
  );
});

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final report = ref.watch(inventoryReportProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Relatórios')),
      body: report.when(
        data: (data) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            MetricCard(
              label: 'Produtos',
              value: data.totalProducts.toString(),
              icon: Icons.inventory_2,
            ),
            MetricCard(
              label: 'Estoque baixo',
              value: data.lowStockProducts.toString(),
              icon: Icons.warning_amber,
            ),
            MetricCard(
              label: 'Sem estoque',
              value: data.outOfStockProducts.toString(),
              icon: Icons.remove_shopping_cart,
            ),
            MetricCard(
              label: 'Valor total',
              value: data.totalInventoryValue.formatted,
              icon: Icons.payments,
            ),
            const SizedBox(height: 16),
            const MovementChart(values: [8, 12, 6, 16, 10, 14, 9]),
          ],
        ),
        error: (error, stackTrace) => Center(child: Text(error.toString())),
        loading: () => const _ReportsSkeleton(),
      ),
    );
  }
}

final class _ReportException implements Exception {
  const _ReportException(this.message);

  final String message;

  @override
  String toString() => message;
}

class _ReportsSkeleton extends StatelessWidget {
  const _ReportsSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.35, end: 0.78),
            duration: const Duration(milliseconds: 850),
            builder: (context, value, child) {
              final color = Color.lerp(
                Theme.of(context).colorScheme.surfaceContainerHighest,
                Theme.of(context).colorScheme.surface,
                value,
              );
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SkeletonLine(width: 120, color: color),
                  const SizedBox(height: 10),
                  _SkeletonLine(width: 180, color: color),
                ],
              );
            },
          ),
        ),
      ),
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemCount: 4,
    );
  }
}

class _SkeletonLine extends StatelessWidget {
  const _SkeletonLine({
    required this.width,
    required this.color,
  });

  final double width;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: SizedBox(width: width, height: 14),
    );
  }
}
