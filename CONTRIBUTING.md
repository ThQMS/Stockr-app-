# Contributing to Stockr App

Thanks for your interest in improving Stockr! This guide keeps contributions
consistent and easy to review.

## Getting set up

```sh
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter test
```

See [docs/01-getting-started.md](docs/01-getting-started.md) for the full setup,
including pointing the app at the API.

## Workflow

1. **Fork & branch** off `main`. Use a descriptive branch name:
   `feat/scanner-torch`, `fix/sync-retry`, `docs/architecture`.
2. **Keep changes focused.** One logical change per pull request.
3. **Match the architecture.** New code goes in the right layer of the right
   feature (`domain` / `data` / `presentation`). Domain stays framework-free.
4. **Run the checks below** before pushing.

## Before you push

```sh
dart format .
flutter analyze
flutter test
```

CI runs the same checks on a pinned Flutter version and must pass before merge.

## Commit messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
feat(scanner): add torch toggle
fix(sync): cap retry attempts on poison writes
docs(readme): add offline-flow GIF
test(inventory): cover register movement use case
```

## Code style

- `prefer_single_quotes`, trailing commas, `const` where possible (enforced by
  [`analysis_options.yaml`](analysis_options.yaml)).
- Use `Either<Failure, T>` for fallible operations; don't throw across layers.
- Don't commit generated files (`*.g.dart`, `*.config.dart`, `*.freezed.dart`).

## Pull requests

Fill in the PR template, link any related issue, and include screenshots/GIFs
for UI changes. Be kind in review — see the
[Code of Conduct](CODE_OF_CONDUCT.md).
