#!/bin/bash
set -euo pipefail

# Usage: ./install-verified.sh <chart-name> <version> [helm-args...]
# Example: ./install-verified.sh wik-webservice 0.4.0 my-release -n production

CHART_NAME="${1:?Chart name required}"
VERSION="${2:?Version required}"
RELEASE_NAME="${3:-$CHART_NAME}"
REGISTRY="ghcr.io/wikodit/charts"
IDENTITY_REGEXP="https://github.com/wikodit/charts"
OIDC_ISSUER="https://token.actions.githubusercontent.com"

echo "Verifying signature for ${CHART_NAME}:${VERSION}..."

if ! cosign verify "${REGISTRY}/${CHART_NAME}:${VERSION}" \
  --certificate-identity-regexp="${IDENTITY_REGEXP}" \
  --certificate-oidc-issuer="${OIDC_ISSUER}" >/dev/null 2>&1; then
  echo "Signature verification failed!"
  exit 1
fi

echo "Signature verified successfully"
echo "Installing ${CHART_NAME}:${VERSION}..."

shift 3 || shift $#
helm install "${RELEASE_NAME}" "oci://${REGISTRY}/${CHART_NAME}" --version "${VERSION}" "$@"
