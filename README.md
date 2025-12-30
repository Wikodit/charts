# Wikodit Helm Charts

[![CI](https://github.com/wikodit/wik-ops/actions/workflows/charts-ci.yml/badge.svg)](https://github.com/wikodit/wik-ops/actions/workflows/charts-ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

A collection of Helm charts maintained by Wikodit for Kubernetes deployments.

## Installation

Charts are available via OCI registries:

```bash
# From GitHub Container Registry
helm pull oci://ghcr.io/wikodit/charts/<chart-name> --version <version>
```

### Example

```bash
helm install my-webservice oci://ghcr.io/wikodit/charts/wik-webservice --version 1.0.0
```

## Available Charts

| Chart | Description | Documentation |
|-------|-------------|---------------|
| [wik-webservice](charts/wik-webservice/) | Quick start for all-in-one webservice | [README](charts/wik-webservice/README.md) |
| [wik-backup](charts/wik-backup/) | Backup solution based on restic | [README](charts/wik-backup/README.md) |
| [wik-cronjob](charts/wik-cronjob/) | Quick start for all-in-one cronjob | [README](charts/wik-cronjob/README.md) |
| [wik-rbac](charts/wik-rbac/) | RBAC management with rbac-manager | [README](charts/wik-rbac/README.md) |
| [wik-node-local-dns](charts/wik-node-local-dns/) | Node-local DNS configuration | [README](charts/wik-node-local-dns/README.md) |

## Repository Structure

```
charts/
├── charts/
│   ├── wik-webservice/
│   ├── wik-backup/
│   ├── wik-cronjob/
│   ├── wik-rbac/
│   └── wik-node-local-dns/
└── releases/
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on how to contribute to this repository.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
