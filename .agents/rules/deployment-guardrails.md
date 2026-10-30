# Strict Deployment Guardrails

- **NEVER deploy code to any Salesforce org** (including via `sf project deploy`, `sfdx force:source:deploy`, or any metadata API deployment) unless the user explicitly requests and authorizes it in writing.
- Any changes to Apex, Lightning Web Components, metadata, or configuration must remain strictly local in the workspace.
- Verification must be performed locally (unit tests via local runners or dry-runs) and never pushed to an org without permission.
