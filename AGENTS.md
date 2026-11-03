# Repository Guidelines

## Project Structure & Module Organization

This repository packages the Transmission torrent client as a Home Assistant add-on. The add-on definition, Docker build metadata, and user-facing documentation are in `transmission/`:

- `transmission/config.json` defines the add-on metadata, ports, options, schemas, and supported architectures.
- `transmission/Dockerfile` and `transmission/build.json` define the image build.
- `transmission/rootfs/` contains files copied into the image, including OpenRC service scripts, initialization hooks, nginx configuration, and OpenVPN setup.
- `transmission/DOCS.md` documents add-on usage; `logo.png` and `icon.png` are its assets.
- Repository-level Markdown files describe contribution, licensing, and release history.

## Build, Test, and Development Commands

There is no package manager, application test suite, or Makefile. Before submitting changes:

```sh
yamllint .                 # Validate YAML files using .yamllint
mdl .                      # Check Markdown style using .mdlrc
docker build -t transmission-addon transmission/
```

The Docker build is the closest full integration check; it catches invalid image instructions and missing files. If Docker is unavailable, still validate changed JSON with a JSON parser and inspect shell scripts with `shellcheck` when installed.

## Coding Style & Naming Conventions

Use UTF-8, LF line endings, and no trailing whitespace. Follow `.editorconfig`: four-space indentation by default, two spaces for Markdown and JSON, and two-space YAML indentation. Keep shell scripts POSIX-compatible unless the target base image explicitly requires Bash. Use lowercase, descriptive filenames and preserve the existing Home Assistant add-on keys and directory layout.

## Testing Guidelines

No automated unit or coverage requirements are currently defined. For behavior changes, build the image and verify the affected service or initialization path in a local Home Assistant/add-on environment. Check both normal startup and relevant option combinations, especially OpenVPN, download paths, ports, and authentication.

## Commit & Pull Request Guidelines

Existing history uses short, imperative-style messages such as `update`; keep commits focused and describe the user-visible change when possible. Discuss substantial work in an issue first. PRs should explain the change, list validation performed, and call out configuration, security, or migration impacts. Search existing issues and PRs before opening a duplicate. Obtain two developer approvals before merging, as required by `CONTRIBUTING.md`.

Every version change, commit, and push must be represented in `CHANGELOG.md`. Add the changelog entry in the same commit as the implementation or release metadata, and update it before pushing. Use the current version heading for release changes; for non-release commits, add a concise entry under an `Unreleased` heading (or create one). Never push a repository change with an undocumented user-visible effect.

## Security & Configuration Tips

Never commit VPN credentials, private certificates, or generated secrets. Treat changes to `privileged`, `/dev/net/tun`, port mappings, and writable volume mappings as security-sensitive and explain their necessity in the PR.

## Weekly maintenance workflow

```sh
gh issue list --state open --json number,title,url --limit 50 > issues.json
```

When selecting tasks for Plans.md, start with the issues file.
