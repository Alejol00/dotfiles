---
name: dev-workflow
description: Guía de flujos de desarrollo. Usa este skill para tareas de git, gestión de proyectos de desarrollo, y flujos de trabajo con código.
---

# Development Workflow

## Git workflow
- Usa `git status` y `git diff` antes de commits
- Prefiere commits atómicos y mensajes descriptivos
- Usa `gh` para issues y PRs

## Commits
- Mensajes en inglés para proyectos públicos, español para proyectos personales
- Formato: tipo(scope): descripción corta
- Tipos: feat, fix, refactor, docs, chore, style, test

## Antes de commitear
1. `git status` - ver qué cambió
2. `git diff` - revisar cambios
3. Ejecutar linter/tests si existen
4. Commit atómico (un cambio por commit)
