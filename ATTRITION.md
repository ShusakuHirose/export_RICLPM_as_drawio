
---

## `ATTRIBUTION.md`

```md
# ATTRIBUTION

## Purpose of this file

This document records the academic, legal, and software-attribution context of this repository.

It is intended to clarify:
- which works informed the implementation;
- what is and is not redistributed here;
- which third-party rights remain with their original owners;
- how this repository should be interpreted in relation to upstream publications, supplementary materials, and software.

---

## 1. Methodological basis

This repository is informed by the methodological literature on the Random Intercept Cross-Lagged Panel Model (RI-CLPM), including:

- Mulder, J. D., & Hamaker, E. L. (2021). *Three Extensions of the Random Intercept Cross-Lagged Panel Model*. *Structural Equation Modeling: A Multidisciplinary Journal, 28*(4), 638–648. https://doi.org/10.1080/10705511.2020.1784738

Related supplementary website:
- The RI-CLPM & Extensions: https://jeroendmulder.github.io/RI-CLPM/

These sources are acknowledged as the principal conceptual and methodological basis for the present work.

---

## 2. Nature of the implementation in this repository

Unless explicitly stated otherwise, the code distributed in this repository is an **original implementation** by the repository maintainer.

More specifically:

- this repository does **not** claim authorship of the RI-CLPM framework itself;
- this repository does **not** claim authorship of the statistical modelling ideas introduced by prior literature;
- this repository does **not** redistribute third-party supplementary code unless explicitly identified and licensed for such redistribution.

Accordingly, this repository should be interpreted as:

> an original software implementation informed by published methodological work,

and **not** as:

> an official distribution, mirror, or republication of upstream supplementary materials.

---

## 3. What is not redistributed here

At the current stage, this repository intentionally does **not** redistribute:

- the annotated lavaan code published on the RI-CLPM supplementary website;
- the Mplus syntax published on the RI-CLPM supplementary website;
- simulated example datasets associated with the supplementary materials;
- article figures reproduced verbatim from the publication;
- draw.io / diagrams.net source code;
- draw.io icon sets;
- draw.io stencil libraries;
- draw.io diagram templates.

This minimal-distribution policy is intentional and is adopted to reduce ambiguity regarding copyright, licensing, and provenance.

---

## 4. Article attribution and reuse note

The article below is a key scholarly source for this repository:

- Mulder, J. D., & Hamaker, E. L. (2021). *Three Extensions of the Random Intercept Cross-Lagged Panel Model*. *Structural Equation Modeling: A Multidisciplinary Journal, 28*(4), 638–648. https://doi.org/10.1080/10705511.2020.1784738

If any future version of this repository includes:
- adapted figures,
- adapted explanatory text,
- quoted passages,
- derivative visualisations clearly based on article material,

then those materials should carry explicit attribution and licence notices as appropriate.

Recommended attribution wording for adapted article material:

> Adapted from Mulder & Hamaker (2021), licensed under CC BY 4.0. Changes were made.

If the repository does **not** include such adapted material, this wording need not be used.

---

## 5. Supplementary website attribution note

The RI-CLPM supplementary website is:

- https://jeroendmulder.github.io/RI-CLPM/

This website is acknowledged as a supplementary methodological resource associated with the article above.

Important distinction:
- consulting a supplementary website for methodological understanding is **not the same** as obtaining permission to republish its code;
- unless an explicit software licence is provided for reusable code, redistribution rights should not be presumed.

For this reason, this repository does not redistribute the supplementary lavaan or Mplus code.

---

## 6. draw.io / diagrams.net compatibility note

This repository aims to generate `.drawio`-compatible XML that can be opened in draw.io / diagrams.net-compatible software.

However:

- draw.io / diagrams.net remains separate third-party software;
- compatibility with a file format does **not** imply affiliation, endorsement, sponsorship, or trademark permission;
- the maintainers of this repository do not claim ownership of draw.io / diagrams.net software, branding, or related assets.

Suggested wording when describing compatibility elsewhere:

> Generates `.drawio`-compatible XML for use with draw.io / diagrams.net-compatible editors.

Avoid wording such as:
- “official draw.io exporter”
- “draw.io certified”
- “approved by diagrams.net”
- any phrasing suggesting endorsement or partnership, unless such status has actually been granted.

---

## 7. draw.io / diagrams.net software and asset boundaries

This repository does **not** bundle the draw.io / diagrams.net application itself.

This repository also does **not** bundle:
- icon sets,
- stencil libraries,
- templates,
- other graphical assets from draw.io / diagrams.net.

This distinction matters because software code, diagram output, and bundled visual assets may be governed by different legal terms.

The practical policy of this repository is therefore:

- generate user-owned diagram content only;
- avoid redistributing software assets not authored within this repository;
- keep third-party assets out of the repository unless their licence terms are checked and documented.

---

## 8. Ownership of exported diagrams

As a general project policy, the repository maintainer does not claim ownership over diagrams created by users from their own inputs through this repository, except to the extent that copyright may subsist in original code written for the export function itself.

Users remain responsible for ensuring that:
- their input data,
- model outputs,
- labels,
- embedded text,
- imported assets,
- and downstream uses

do not infringe third-party rights.

---

## 9. No legal advice

This file is provided for transparency and good-faith documentation purposes only.

It is not legal advice.  
If you plan to redistribute:
- third-party code,
- article figures,
- software assets,
- proprietary syntax,
- or trademarked material,

you should independently confirm the relevant rights and obligations.

---

## 10. Project-specific statement for the current repository state

As of the current version of this repository:

- the only shared R-side code intended for public distribution is `export_drawio.R`;
- no sample analysis scripts are included;
- no upstream supplementary code is redistributed;
- no example datasets are included;
- no draw.io / diagrams.net software assets are included.

This repository therefore aims to remain:
- academically transparent,
- technically useful,
- legally cautious,
- and straightforward to maintain.

---

## 11. Suggested acknowledgement text

If you wish to acknowledge the background of this repository in a paper, presentation, or documentation, the following wording may be used:

> This software implementation was developed with reference to Mulder and Hamaker’s RI-CLPM extension framework and related supplementary materials, but the code distributed here is an original implementation by the present repository author.

For a shorter acknowledgement:

> Methodological background informed by Mulder & Hamaker (2021); implementation in this repository is original unless otherwise noted.

---

## 12. Maintainer

Repository maintainer: Shusaku HIROSE