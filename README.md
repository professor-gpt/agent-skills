# agent-skills

Official skill registry for the [ProfessorGPT](https://professorgpt.ai) platform.

Skills are automatically submitted, validated, and published via the ProfessorGPT platform. Manual PRs are not accepted.

## Install a skill

```bash
npx -y skills add professor-gpt/agent-skills --skill professor-gpt/code-reviewer --global --agent claude-code
```

## Structure

```
skills/
  professor-gpt/
    <skill-slug>/
      SKILL.md          # Main skill definition
      metadata.json     # Skill metadata
      ...               # Supporting files (templates, checklists, examples)
registry.json           # Auto-generated skill index
```
