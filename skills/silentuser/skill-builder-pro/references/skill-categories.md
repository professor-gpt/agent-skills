# Reference: Skill Categories & Wizard Prompts

## §1 — Full Category Taxonomy

### Developer Categories
| Category ID | Display Name | Typical Skills |
|---|---|---|
| web-app-dev | Website / App Developer | React, Next.js, Vue, Svelte, full-stack web, UI component generation |
| mobile-dev | Mobile Developer | React Native, Flutter, SwiftUI, Kotlin, cross-platform mobile |
| backend-api | Backend / API Engineer | Node.js, Python/FastAPI, Go, REST, GraphQL, microservices |
| devops-platform | DevOps / Platform Engineer | Docker, Kubernetes, CI/CD, Terraform, AWS/Azure/GCP, monitoring |
| data-ml | Data & ML Engineer | Python, Spark, ML pipelines, model deployment, feature engineering |
| software-eng | Software Engineering Assistant | Code review, refactoring, architecture, testing, general SE |
| desktop-dev | Desktop App Developer | Electron, Tauri, WPF, macOS native, cross-platform desktop |

### Business Categories
| Category ID | Display Name | Typical Skills |
|---|---|---|
| sales | Sales Assistant | Call scripts, deal analysis, CRM workflows, prospecting, follow-ups |
| marketing | Marketing Assistant | Content calendars, campaign analysis, SEO briefs, ad copy, social media |
| customer-support | Customer Support Assistant | Ticket triage, response templates, escalation workflows, FAQ generation |
| operations | Operations & Logistics Assistant | Process documentation, inventory tracking, vendor management, SOP creation |
| finance | Finance & Accounting Assistant | Report generation, reconciliation, budget analysis, expense categorization |
| hr | HR & People Ops Assistant | Job descriptions, onboarding checklists, policy drafts, interview guides |
| legal-compliance | Legal & Compliance Assistant | Contract review, compliance checklists, regulatory summaries, clause analysis |
| ecommerce | E-commerce Assistant | Product descriptions, listing optimization, order management, category planning |
| research | Research Assistant | Literature review, source evaluation, data extraction, citation management |
| education | Education & Training Assistant | Lesson plans, quiz generation, curriculum mapping, learning path design |

### Creative & Other Categories
| Category ID | Display Name | Typical Skills |
|---|---|---|
| corporate | Corporate Assistant | Meeting summaries, memo drafting, presentation outlines, internal comms |
| product | Product Developer | PRDs, user stories, roadmap planning, stakeholder updates, feature specs |
| ai-workflow | AI Workflow Builder | Multi-step AI pipelines, chained prompts, agent orchestration, tool-use flows |
| data-analytics | Data & Analytics Assistant | Dashboard design, SQL query generation, insight reports, data storytelling |

## §2 — Category-Specific Wizard Prompts

When the user selects a category, use these specialized question sets instead of generic questions.

### Website / App Developer
Ask: target framework (React/Next.js/Vue/Svelte/etc.), design system or CSS framework (Tailwind/shadcn/MUI/etc.), component types needed (pages, forms, dashboards, landing pages, modals), TypeScript or JavaScript, state management preference, testing framework, and whether the skill should generate full components or guide architecture decisions.

### Backend / API Engineer
Ask: language and framework (Python/FastAPI, Node.js/Express, Go, etc.), API style (REST/GraphQL/gRPC), database (PostgreSQL/MongoDB/Redis/etc.), authentication method, deployment target, and whether the skill should generate endpoint code, database schemas, middleware, or full service scaffolding.

### DevOps / Platform Engineer
Ask: primary cloud provider (AWS/Azure/GCP), infrastructure-as-code tool (Terraform/Pulumi/CDK), container orchestration (Kubernetes/Docker Swarm/ECS), CI/CD platform (GitHub Actions/GitLab CI/Jenkins), monitoring stack, and whether the skill should generate config files, pipeline definitions, or architecture docs.

### Data & ML Engineer
Ask: primary language (Python/R), frameworks (PyTorch/TensorFlow/scikit-learn), data sources (SQL warehouses, data lakes, streaming), pipeline tools (Airflow/Dagster/Prefect), model serving approach, and whether the skill should generate pipeline code, model training scripts, or feature engineering workflows.

### Sales Assistant
Ask: sales methodology (SPIN/MEDDIC/Challenger/etc.), CRM (Salesforce/HubSpot/Pipedrive), deal stage focus (prospecting/qualification/closing), output types (call scripts, email sequences, deal analysis reports), and target industry/vertical.

### Marketing Assistant
Ask: content channels (blog/social/email/paid), tone of voice, target audience persona, tools (HubSpot/Mailchimp/Google Analytics), output types (content calendars, ad copy, SEO briefs, campaign reports), and whether brand guidelines should be embedded.

### Legal & Compliance Assistant
Ask: jurisdiction (US/EU/UK/specific country), regulation focus (GDPR/CCPA/SOC2/HIPAA/industry-specific), document types (contracts, policies, compliance checklists, regulatory summaries), risk classification needs, and whether escalation-to-counsel rules should be embedded.

### Research Assistant
Ask: academic or business research, citation style (APA/MLA/Chicago/IEEE), source quality criteria, output types (literature reviews, annotated bibliographies, evidence extraction tables), and domain/subject area focus.

### Corporate Assistant
Ask: communication types (memos, presentations, meeting summaries, internal announcements), company size/culture context, tone (formal/semi-formal/casual), document templates to embed, and any corporate style guide requirements.

### Product Developer
Ask: product methodology (agile/scrum/Shape Up), artifact types (PRDs, user stories, roadmaps, feature specs, retros), stakeholder audience, tools (Jira/Linear/Notion), and whether the skill should facilitate ceremonies or generate artifacts.

### AI Workflow Builder
Ask: target agent platform (Claude Code/Cursor/custom), step count (simple 3–5 step chain vs complex branching pipeline), tool integrations (APIs, MCP servers, databases), output schema requirements, error handling strategy, and whether human-in-the-loop checkpoints are needed.

## §3 — Orientation Decision Guide

Use these heuristics to infer orientation when the user doesn't explicitly choose:

- **Problem-first** if: the user describes a business outcome, workflow, or process (e.g., "I need to compare suppliers", "I want to review contracts faster", "Help me plan sprints")
- **Tool-first** if: the user names a specific API, SDK, framework, or platform and wants the agent to work effectively with it (e.g., "I need my agent to use the Stripe API", "Make my agent good at Terraform")
- **Hybrid** if: the user describes both a workflow outcome and a specific tool that is central to achieving it