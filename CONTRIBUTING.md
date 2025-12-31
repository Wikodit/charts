# Contributing to Wikodit Helm Charts

Thank you for your interest in contributing to Wikodit Helm Charts!

## Prerequisites

Just two tools needed:
- [Docker](https://docs.docker.com/get-docker/) - For consistent testing
- [Helm](https://helm.sh/docs/intro/install/) (v3.14+) - For chart operations

## Development Setup

1. Clone the repository:
   ```bash
   git clone git@github.com:wikodit/charts.git
   cd charts
   ```

2. Test your changes:
   ```bash
   # Lint all charts (includes yamllint, schema validation)
   docker run --rm -v $(pwd):/charts -w /charts quay.io/helmpack/chart-testing:latest ct lint --config ct.yaml

   # Test chart rendering
   helm template charts/<chart-name> --dry-run

   # Optional: Run unit tests (if you want to test deeper)
   docker run --rm -v $(pwd):/charts -w /charts helmunittest/helm-unittest:latest charts/<chart-name>
   ```

## Adding a New Chart

1. Create a new directory under `charts/`:
   ```bash
   mkdir -p charts/<chart-name>/templates
   ```

2. Create the required files:
   - `Chart.yaml` - Chart metadata
   - `values.yaml` - Default configuration values
   - `README.md.gotmpl` - Chart documentation template (NOT README.md!)
   - `templates/` - Kubernetes manifest templates

3. Follow the [chart structure requirements](#chart-structure-requirements)

## Documentation (IMPORTANT)

**DO NOT EDIT `README.md` FILES DIRECTLY!**

All chart README.md files are automatically generated from `README.md.gotmpl` templates:

- Edit `charts/<chart>/README.md.gotmpl` instead of `README.md`
- The `docs.yaml` workflow automatically generates README.md from the template
- Any manual edits to README.md will be overwritten on the next push

To update documentation:
1. Modify the appropriate `.gotmpl` file
2. Run `helm-docs` locally to preview: `helm-docs --chart-search-root=charts`
3. Commit both the template changes and generated README.md

### Adding Documentation to Templates

When editing `README.md.gotmpl`:
- Use Helm template functions: `{{ template "chart.version" . }}`
- Include installation examples with OCI registry
- Add configuration tables with default values
- The template will be processed with chart metadata automatically

## Chart Structure Requirements

Each chart must include:

```
charts/<chart-name>/
├── Chart.yaml          # Required: Chart metadata
├── values.yaml         # Required: Default values
├── README.md           # Generated: Documentation (DO NOT EDIT)
├── README.md.gotmpl    # Required: Documentation template
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
home: https://github.com/wikodit/charts
sources:
  - https://github.com/wikodit/charts
maintainers:
  - name: Wikodit
    url: https://github.com/wikodit
  - name: Anthony Domingue
    email: anthony@wikodit.fr
  - name: Jeremy Trufier
    email: jeremy@wikodit.fr
keywords:
  - wikodit
  - <chart-specific-keywords>
annotations:
  artifacthub.io/license: MIT
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

### Documentation Enforcement

**Important**: The repository has automated safeguards for documentation:

1. **Pre-commit hooks**: Run `helm-docs` automatically to ensure README.md matches templates
2. **CI/CD workflow**: The `docs.yaml` workflow will overwrite any manual README.md changes
3. **PR comments**: If documentation is out of date, the CI will add a warning comment to the PR

**Rule**: Always edit `README.md.gotmpl`, never `README.md` directly!

### Running Tests Locally

```bash
# Lint all charts
docker run --rm -v $(pwd):/charts -w /charts quay.io/helmpack/chart-testing:latest ct lint --config ct.yaml

# Test chart rendering
helm template charts/<chart-name> --dry-run
```

## Code Style

- Use 2-space indentation in YAML files
- Follow Helm best practices
- Document all values in `values.yaml` with comments
- Keep templates readable and well-organized

## Questions?

Open an issue for any questions or concerns.
