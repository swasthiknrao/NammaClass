# NammaClass — JSON Schemas (tenant & entitlements)

Canonical contract documents for multi-tenant configuration. **Version** fields MUST increment when breaking changes are introduced; clients must reject or safely ignore unknown `schema_version` values per [API_STYLE_GUIDE.md](../API_STYLE_GUIDE.md).

| File | Purpose |
|------|---------|
| [tenant_profile.schema.json](./tenant_profile.schema.json) | Branding, locale, baseline features, optional nested entitlement snapshot / theme / nav |
| [entitlement_snapshot.schema.json](./entitlement_snapshot.schema.json) | Billing-backed module toggles, quotas, limits (server source of truth) |
| [role_pack.schema.json](./role_pack.schema.json) | Reusable role + permission templates for tenant onboarding |
| [role_module_requirements.json](./role_module_requirements.json) | Module → role dependency matrix (which roles require which `NcFeature` keys) |
