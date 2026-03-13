apiVersion: audit.k8s.io/v1
kind: Policy
rules:
  # Log secret access at metadata level (no body)
  - level: Metadata
    resources:
      - group: ""
        resources: ["secrets"]
  # Log pod and service changes at request level
  - level: RequestResponse
    resources:
      - group: ""
        resources: ["pods", "services"]
    verbs: ["create", "update", "patch", "delete"]
  # Log everything else at metadata level, skip noisy read-only
  - level: Metadata
    omitStages:
      - RequestReceived
