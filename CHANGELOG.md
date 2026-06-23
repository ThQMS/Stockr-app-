# Changelog

All notable changes to this project are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-06-22

### Added

- Clean Architecture (by feature) scaffold: `auth`, `inventory`, `scanner`, `reports`.
- Offline-first persistence with Drift: `Products`, `Movements`, `Categories`,
  and a `PendingSyncTable` write queue.
- QR / barcode scanning via `mobile_scanner`.
- Background synchronization with the [Stockr API](https://github.com/ThQMS/Stockr-api)
  (`SyncPendingMovementsUseCase`), with client-generated ids for idempotency.
- Typed failures with `fpdart` `Either`; Riverpod state management; `go_router`
  navigation; `get_it` service locator for dependency injection.
- Domain value objects: `ProductSku`, `StockQuantity`, `Money`.
- Inventory reports with `fl_chart`.
- Project documentation under `docs/`, CI pipeline, and community files.

[1.0.0]: https://github.com/ThQMS/Stockr-app-/releases/tag/v1.0.0
