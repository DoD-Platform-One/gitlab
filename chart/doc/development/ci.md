---
stage: Systems
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: CI setup and use
---

## CI Variables

| Variable   | Default Value | Description                                                                                                              |
|------------|---------------|--------------------------------------------------------------------------------------------------------------------------|
| `LIMIT_TO` | `""`          | Limit pipeline execution to a specific logical block. Available blocks: `eks`, `eks130`, `gke130`, `gke130a`, `vcluster`. Empty value implies absence of limits - i.e. all components shall be considered for execution. |

### LIMIT_TO

`LIMIT_TO` allows to isolate singular logical block of pipeline and *only* execute that block skipping all other blocks. This allows for faster iteration as developer may choose to test only a singular platform before code is ready for more thorough testing. It also allows for external pipeline invocations for very specific scenarios.

`LIMIT_TO` accepts only a single value.

Empty value implies that there are no limits and that pipeline shall be executed in full.
