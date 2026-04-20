# RICLPM-to-drawio

An R-based utility for exporting Random Intercept Cross-lagged Panel Model (RICLPM) results to draw.io / diagrams.net-compatible XML.

## Overview

This repository provides a single R function, `RICLPM_export_drawio.R`, for generating `.drawio`-compatible output from RICLPM-related objects and metadata.

At the current stage, this repository is intentionally minimal:
- it shares only the R function `RICLPM_export_drawio.R`;
- it does **not** redistribute example datasets;
- it does **not** redistribute the annotated lavaan or Mplus code published on the RI-CLPM supplementary website;
- it does **not** bundle draw.io / diagrams.net source code, icons, stencil libraries, or templates.

The present repository should therefore be understood as an **original implementation inspired by published methodological work**, not as a mirror of upstream code or assets.

## Scope

Current scope:
- export of model-related information to draw.io / diagrams.net-compatible XML
- R-based workflow support
- repository-level distribution of a single function file: `RICLPM_export_drawio.R`

Planned future scope:
- extension to Python-based workflows
- support for Mplus-oriented pipelines
- broader SEM diagram export infrastructure

## Repository structure

```text
.
├─ R/
│  └─ export_drawio.R
├─ README.md
├─ ATTRIBUTION.md
├─ LICENSE
└─ .gitignore
