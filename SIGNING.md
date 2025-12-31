# Chart Signing & Verification

All charts released from this repository are cryptographically signed using [Sigstore Cosign](https://github.com/sigstore/cosign) keyless signatures.

## Why Signing Matters

- **Authenticity**: Verify charts originate from this repository
- **Integrity**: Detect tampering or corruption
- **Non-repudiation**: Cryptographic proof of origin

## Signature Method

We use **Sigstore keyless signing** with GitHub Actions OIDC:
- No private key management required
- Signatures include identity of the GitHub Actions workflow
- Recorded in Rekor transparency log

## Verification

### Prerequisites

```bash
# Install cosign
# macOS
brew install cosign

# Linux
curl -L https://github.com/sigstore/cosign/releases/latest/download/cosign-linux-amd64 -o /usr/local/bin/cosign
chmod +x /usr/local/bin/cosign
```

### Verify Chart from GHCR

```bash
cosign verify ghcr.io/wikodit/charts/wik-webservice:0.4.0 \
  --certificate-identity-regexp='https://github.com/wikodit/charts' \
  --certificate-oidc-issuer='https://token.actions.githubusercontent.com'
```

### Verify Chart from Harbor

```bash
cosign verify registry.cluster.wik.cloud/library/wik-webservice:0.4.0 \
  --certificate-identity-regexp='https://github.com/wikodit/charts' \
  --certificate-oidc-issuer='https://token.actions.githubusercontent.com'
```

### Install with Verification (Recommended)

```bash
# Pull the chart
helm pull oci://ghcr.io/wikodit/charts/wik-webservice --version 0.4.0

# Verify signature
cosign verify ghcr.io/wikodit/charts/wik-webservice:0.4.0 \
  --certificate-identity-regexp='https://github.com/wikodit/charts' \
  --certificate-oidc-issuer='https://token.actions.githubusercontent.com'

# Install if verification succeeds
helm install my-release oci://ghcr.io/wikodit/charts/wik-webservice --version 0.4.0
```

## Transparency Log

All signatures are recorded in the [Rekor transparency log](https://rekor.sigstore.dev/). You can search for entries:

```bash
rekor-cli search --email github-actions[bot]@users.noreply.github.com
```

## Troubleshooting

### "no matching signatures found"

1. Verify the image tag is correct
2. Ensure you're using the correct certificate identity regexp
3. Check if the image was signed (older releases may not be signed)

### "certificate has expired"

Sigstore certificates are short-lived (10 minutes). The signature remains valid because it's recorded in Rekor before expiry. Use `--insecure-ignore-sct` if you encounter SCT validation issues.

## More Information

- [Sigstore Documentation](https://docs.sigstore.dev/)
- [Cosign GitHub](https://github.com/sigstore/cosign)
- [Rekor Transparency Log](https://rekor.sigstore.dev/)
