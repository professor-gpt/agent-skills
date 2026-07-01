---
name: silentuser/shadcn-admin-dashboard-design-reference
description: Use this skill when designing websites, admin panels, or dashboards that reference the visual language, layout patterns, component structure, and theming of the next-shadcn-admin-dashboard repository.
category: design
tags: [admin-dashboard, shadcn-ui, nextjs, tailwind, ui-design, dashboard]
---

# Skill: Shadcn Admin Dashboard Design Reference

## Description
This skill enables an AI agent to design UIs and websites inspired by the next-shadcn-admin-dashboard GitHub repository. It provides structured access to the exact layout architecture, component patterns, color tokens, typography, and responsive behaviors used in that codebase.

## Instructions
1. When activated by a design request, first identify the target page type (dashboard overview, settings, data table page, form page, or marketing landing) and confirm with the user if ambiguous.
2. Retrieve the exact color tokens, spacing scale, and typography from `./design.md` § Color System and § Typography.
3. Load the layout primitives (sidebar width, header height, grid gaps, card padding) from `./design.md` § Layout Architecture.
4. Select and adapt the appropriate component patterns (stat cards, data tables, charts, navigation) from `./design.md` § Component Patterns, using only the documented Tailwind class combinations and shadcn/ui variants.
5. Generate complete, production-ready JSX/TSX or HTML output that matches the repository's visual density, border radius values, shadow usage, and dark mode support.
6. Validate the generated design: confirm all colors reference CSS custom properties (no hardcoded hex), all interactive elements include focus-visible states, responsive breakpoints match the documented mobile-first approach, and accessibility attributes (aria-labels, roles) are present.
7. If the request involves multiple pages, produce a consistent navigation structure matching `./design.md` § Navigation Structure.
8. Return the design with a short rationale referencing the specific sections of design.md that were applied.

## Constraints
- Never invent new color values, spacing units, or component styles not present in design.md.
- Do not generate marketing or e-commerce layouts unless the user explicitly requests adaptation of the admin aesthetic to those contexts.
- Always include dark mode token overrides when the primary design uses light mode.
- Escalate to the user if the request requires real backend data integration, authentication flows, or third-party chart libraries beyond Recharts patterns shown in the reference.
- Scope is limited to visual and structural design; do not provide Next.js routing code, API route implementations, or state management logic.