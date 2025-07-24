---
status: Experimental / Internal Use Only
group: Tenant Scale
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: TLS Configuration for Cells Components (Development Only)
---

## Context

As part of the ongoing development of [Cells architecture](https://docs.gitlab.com/ee/development/cells/), TLS configuration has been introduced to support secure communication between the monolith and cell services (e.g., the Topology Service).

At present, TLS-related settings for Cells are placed under:

```yaml
global:
  appConfig:
    cell:
      topologyServiceClient:
        tls:
          enabled: true
          secret: topology-service-tls
```

This aligns with how other sensitive settings (e.g., `client_secret`, `suggested_reviewers`) are stored under `appConfig`.

---

## Design Discussion & Known Deviation

While placing TLS config under `appConfig.cell` is functional, it's worth noting that:

- Most GitLab components follow the pattern: `global.{component}.tls`
  - Examples: `global.gitaly.tls`, `global.praefect.tls`, `global.kas.tls`, `global.ingress.tls`
- The current approach mixes TLS configuration (an operational concern) with `appConfig` (intended primarily for application runtime settings).

This decision was made for speed and simplicity during the experimental phase but may warrant refactoring in the future.

---

## Naming Note

Another known inconsistency is that the top-level key uses `cell` (singular), while the feature itself is referred to as **Cells** across documentation and architecture discussions. Future cleanup may involve renaming to `global.cells`.

---

## Future Considerations

- Refactor the config structure:
  - Move `tls` to `global.cell.topologyServiceClient.tls` or
  - Rename `appConfig.cell` to `cells` entirely
- Add tests to prevent regressions when restructuring
- Create a user-facing doc once Cells become an officially supported feature
- Review all settings implemented under the experimental `appConfig.cell` structure

---

## Summary

For now, TLS secrets used by Cells-related components (like the Topology Service) live under `global.appConfig.cell`. This is subject to change, and any future consumer-facing exposure will be preceded by a cleanup and proper documentation pass.

> ✅ **Developers:** When adding new Cells-related configuration, consider documenting your additions under `doc/development/cells/` to avoid future gaps.
