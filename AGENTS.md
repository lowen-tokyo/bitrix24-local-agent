# Bitrix24 local agent development

This repository contains a general-purpose Bitrix24 work agent for the ChatGPT/Codex desktop app. It uses the browser UI so it can work across portals and projects without a public server or separate runtime.

- Use the `bitrix24-ui` skill for portal work. Verify the live portal and current object before changing it. Do not hard-code a portal, project, workflow, or data model. Respect the browser tool's confirmation policy and the user's current authorization.
- Do not activate a Bitrix24 trial or subscription as a routine setup step.
- Keep the agent generic. Do not create portal-specific smart processes, fields, or numbering rules without the user's actual data model and a concrete portal configuration request.
- Treat any Bitrix24 webhook URL as a secret. Never include it in source, prompts, test fixtures, screenshots, logs, tool descriptions, or Git.
- If an API path is later chosen, expose only named purpose-specific tools; never accept arbitrary REST method names or raw bodies from the model. Check official Bitrix24 documentation for scope and permissions.
- Keep read operations separate from writes. For every write, identify validated inputs, show the exact proposed change to the user when necessary, and record an outcome without secrets.
- Do not invent a correspondence number by reading the last number in the chat. A production numbering rule needs one authoritative allocator that handles concurrent writers.
- Do not claim live Bitrix24 acceptance from syntax checks or installation. Record clearly whether a feature was written, locally checked, or verified against the actual portal.
- Update `README.md` when adding user-facing tools or changing setup steps. Increase the plugin version before redistributing a changed plugin package.
