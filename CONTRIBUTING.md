# Contributing to Wikodit Helm Charts

Thank you for your interest in contributing to Wikodit Helm Charts!

## Prerequisites

Ensure you have the following tools installed:

- [Helm](https://helm.sh/docs/intro/install/) (v3.x)
- [helm-unittest](https://github.com/helm-unittest/helm-unittest)
- [chart-testing (ct)](https://github.com/helm/chart-testing)
- [yamllint](https://yamllint.readthedocs.io/)

## Adding a New Chart

1. Create a new directory under `charts/`:
   ```bash
   mkdir -p charts/<chart-name>/templates
   ```

2. Create the required files:
   - `Chart.yaml` - Chart metadata
   - `values.yaml` - Default configuration values
   - `README.md` - Chart documentation
   - `templates/` - Kubernetes manifest templates

3. Follow the [chart structure requirements](#chart-structure-requirements)

## Chart Structure Requirements

Each chart must include:

```
charts/<chart-name>/
├── Chart.yaml          # Required: Chart metadata
├── values.yaml         # Required: Default values
├── README.md           # Required: Documentation
├── templates/          # Required: Template files
│   ├── _helpers.tpl    # Template helpers
│   ├── NOTES.txt       # Post-install notes
│   └── ...
├── tests/              # Recommended: Unit tests
│   └── *_test.yaml
└── ci/                 # Optional: CI test values
    └── *-values.yaml
```

### Chart.yaml Requirements

```yaml
apiVersion: v2
name: <chart-name>
description: Brief description
type: application
version: 0.1.0        # Chart version (SemVer)
appVersion: "1.0.0"   # Application version
maintainers:
  - name: Wikodit
    url: https://wikodit.fr
```

## Version Bump Policy

We follow [Semantic Versioning](https://semver.org/):

- **MAJOR** (`x.0.0`): Breaking changes (incompatible value changes, removed features)
- **MINOR** (`0.x.0`): New features (backward-compatible additions)
- **PATCH** (`0.0.x`): Bug fixes (backward-compatible fixes)

When making changes:
1. Update `version` in `Chart.yaml`
2. Update `CHANGELOG.md` if present
3. Document breaking changes clearly

## Pull Request Process

1. **Fork** the repository and create a feature branch
2. **Make changes** following the guidelines above
3. **Test locally**:
   ```bash
   # Lint the chart
   helm lint charts/<chart-name>
   
   # Run unit tests
   helm unittest charts/<chart-name>
   
   # Template validation
   helm template charts/<chart-name>
   ```
4. **Commit** with clear, descriptive messages
5. **Open a PR** with:
   - Description of changes
   - Testing performed
   - Breaking changes (if any)

## Testing Requirements

### Required Tests

- Chart must pass `helm lint`
- Chart must render without errors via `helm template`

### Recommended Tests

- Unit tests using helm-unittest
- Integration tests with chart-testing

### Running Tests Locally

```bash
# Lint all charts
ct lint --all

# Run unit tests for a specific chart
helm unittest charts/<chart-name>

# Full validation
helm template test charts/<chart-name> | kubectl apply --dry-run=client -f -
```

## Code Style

- Use 2-space indentation in YAML files
- Follow Helm best practices
- Document all values in `values.yaml` with comments
- Keep templates readable and well-organized

## Questions?

Open an issue for any questions or concerns.
