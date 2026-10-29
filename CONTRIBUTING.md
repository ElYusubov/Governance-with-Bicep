# Contributing

Thanks for helping make this repo easier to learn from.

1. Fork the repo and create a branch.
2. Make your change. Keep policies **audit-first** and keep the naming conventions in `infra/modules/README.md`.
3. Check it builds: `az bicep build --file infra/main.bicep --stdout > /dev/null`
4. Open a pull request. The **PR Validate** workflow lints, scans, and runs a what-if.

Docs and lab fixes are very welcome. If a step confused you, please open an issue or fix it.

Use a sandbox subscription when testing. Never commit secrets or subscription IDs.
