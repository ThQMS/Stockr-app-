import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../inventory/domain/entities/movement.dart';
import '../../../inventory/domain/entities/movement_params.dart';
import '../../../inventory/domain/entities/product.dart';
import '../../../inventory/presentation/providers/products_provider.dart';
import '../providers/scanner_provider.dart';
import '../widgets/product_found_card.dart';
import '../widgets/scanner_overlay.dart';

class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen> {
  late final MobileScannerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      formats: const [
        BarcodeFormat.qrCode,
        BarcodeFormat.ean13,
        BarcodeFormat.ean8,
        BarcodeFormat.code128,
        BarcodeFormat.code39,
        BarcodeFormat.upcA,
        BarcodeFormat.upcE,
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scannerState = ref.watch(scannerNotifierProvider);

    ref.listen<ScannerState>(scannerNotifierProvider, (previous, next) {
      if (next is ScannerProductFound) {
        _showMovementSheet(context, next.product);
      }
      if (next is ScannerOfflineFound) {
        _showMovementSheet(context, next.product);
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Scanner')),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              String? value;
              for (final barcode in capture.barcodes) {
                final raw = barcode.rawValue;
                if (raw != null && raw.isNotEmpty) {
                  value = raw;
                  break;
                }
              }

              if (value != null) {
                ref.read(scannerNotifierProvider.notifier).scan(
                      code: value,
                      workspaceId: defaultWorkspaceId,
                    );
              }
            },
          ),
          const ScannerOverlay(),
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: _ScannerResultPanel(state: scannerState),
          ),
        ],
      ),
    );
  }

  Future<void> _showMovementSheet(BuildContext context, Product product) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _MovementBottomSheet(product: product),
    );
  }
}

class _ScannerResultPanel extends StatelessWidget {
  const _ScannerResultPanel({required this.state});

  final ScannerState state;

  @override
  Widget build(BuildContext context) {
    final child = switch (state) {
      ScannerIdle() => const SizedBox.shrink(),
      ScannerScanning() => const _ScannerSkeleton(),
      ScannerProductFound(:final product) => ProductFoundCard(product: product),
      ScannerOfflineFound(:final product) => ProductFoundCard(product: product),
      ScannerProductNotFound(:final code) => Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Produto nao encontrado: $code'),
          ),
        ),
    };

    return AnimatedSlide(
      offset: state is ScannerIdle ? const Offset(0, 1.2) : Offset.zero,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      child: child,
    );
  }
}

class _MovementBottomSheet extends ConsumerStatefulWidget {
  const _MovementBottomSheet({required this.product});

  final Product product;

  @override
  ConsumerState<_MovementBottomSheet> createState() =>
      _MovementBottomSheetState();
}

class _MovementBottomSheetState extends ConsumerState<_MovementBottomSheet> {
  final _quantityController = TextEditingController(text: '1');
  final _notesController = TextEditingController();
  MovementType _type = MovementType.inbound;

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quantity = int.tryParse(_quantityController.text) ?? 0;
    final current = widget.product.currentStock.value;
    final next = switch (_type) {
      MovementType.inbound => current + quantity,
      MovementType.out || MovementType.transfer => current - quantity,
      MovementType.adjustment => quantity,
    };
    final movementState = ref.watch(movementNotifierProvider);

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.product.name,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _quantityController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Quantidade',
              prefixIcon: Icon(Icons.numbers),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          SegmentedButton<MovementType>(
            segments: const [
              ButtonSegment(
                value: MovementType.inbound,
                icon: Icon(Icons.south_west),
                label: Text('Entrada'),
              ),
              ButtonSegment(
                value: MovementType.out,
                icon: Icon(Icons.north_east),
                label: Text('Saida'),
              ),
              ButtonSegment(
                value: MovementType.adjustment,
                icon: Icon(Icons.tune),
                label: Text('Ajuste'),
              ),
            ],
            selected: {_type},
            onSelectionChanged: (value) {
              setState(() => _type = value.first);
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesController,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Notas',
              prefixIcon: Icon(Icons.notes),
            ),
          ),
          const SizedBox(height: 12),
          Text('Estoque atual: $current -> $next'),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: movementState.isLoading
                  ? null
                  : () async {
                      await ref
                          .read(movementNotifierProvider.notifier)
                          .register(
                            RegisterMovementParams(
                              productId: widget.product.id,
                              workspaceId: widget.product.workspaceId,
                              type: _type,
                              quantity: quantity,
                              notes: _notesController.text.trim().isEmpty
                                  ? null
                                  : _notesController.text.trim(),
                            ),
                          );
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
              icon: const Icon(Icons.check),
              label: const Text('Confirmar'),
            ),
          ),
          movementState.maybeWhen(
            error: (error, stackTrace) => Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(error.toString()),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _ScannerSkeleton extends StatelessWidget {
  const _ScannerSkeleton();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.35, end: 0.8),
          duration: const Duration(milliseconds: 800),
          builder: (context, value, child) {
            final color = Color.lerp(
              Theme.of(context).colorScheme.surfaceContainerHighest,
              Theme.of(context).colorScheme.surface,
              value,
            );
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SkeletonLine(width: 160, color: color),
                const SizedBox(height: 10),
                _SkeletonLine(width: 96, color: color),
              ],
            );
          },
        ),
      ),
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
