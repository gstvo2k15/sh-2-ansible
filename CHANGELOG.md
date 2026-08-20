# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### 20/08/2026: Added

- Initial Ansible role replacing the legacy Bash workflow:
  - `generate_product_patchfiles.sh`
  - `generate_product_hosts.sh`
  - `generate_product_varfiles.sh`
  - `generate_varfile.sh`
- Support for the following products:
  - `java`
  - `apache`
  - `apache_sso`
  - `tomcat`
  - `jbossews`
  - `jbosseap`
  - `weblogic`
- Validation of the `product` and `change` runtime variables.
- Validation of change references using the `CHG<number>` format.
- Read-only checkout of the Elastic Inventory Git repository.
- Inventory discovery from the `inventories/` directory.
- Special handling for `product=java`, reading:
  - `tomcat.ini`
  - `jbossews.ini`
  - `jbosseap.ini`
  - `weblogic.ini`
- Parsing of host inventory attributes:
  - region
  - environment
  - location
- Validation of supported regions, environments, and locations.
- Grouping of hosts by product, region, environment, and location.
- Generation of intermediate patch host files.
- Generation of final YAML varfiles using an Ansible Jinja2 template.
- Conversion of `MZR` location to `CORE` for generated varfiles.
- `apache_sso` compatibility, writing `patch_product: apache` in the generated YAML.
- Separate Git repository for persistent generated output.
- Automatic `git add`, commit, and push of generated files.
- Change reference included in Git commit messages.
- Protection against empty Git commits when generated content has not changed.
- Tower / Ansible Automation Platform Job Template documentation.
- Recommended Tower Survey containing only:
  - `product`
  - `change`
- Separation between:
  - runtime Survey variables;
  - fixed Job Template variables;
  - Git credentials.
- Documentation of required Git permissions:
  - read access to the Elastic Inventory repository;
  - read/write access to the generated-output repository.

### Changed

- Replaced temporary filesystem output from the legacy Bash workflow with Git-backed persistence.
- Replaced shell-based YAML construction with `ansible.builtin.template`.
- Replaced Bash associative-array grouping with deterministic inventory processing inside the Ansible role.
- Removed the dependency on `/apps/patching/.token-plat` from the generation logic.
- Removed the requirement to execute the legacy Bash scripts from Tower.
- Normalized the product handling so `weblogic` is consistently supported.
- Centralized inventory parsing so host files and YAML files are generated from the same parsed data.

### Fixed

- Fixed inconsistent `weblogic` validation between the original Bash scripts.
- Fixed the mismatch between generated filenames using `-` separators and the legacy varfile script parsing them with `_`.
- Fixed the legacy hand-off where `generate_product_varfiles.sh` did not provide all values required by `generate_varfile.sh`, including:
  - region;
  - patch environment;
  - patch wave.
- Fixed Java processing so the four Java-related inventory files are treated as part of a single `product=java` execution.
- Avoided reporting a successful workflow when the underlying varfile generation had not actually produced the expected YAML files.

## Migration Notes

The Ansible implementation preserves the intended functional behavior of the Bash scripts rather than reproducing known defects in the original implementation.

The Tower/AAP operator supplies only:

```yaml
product: java
change: CHG1400222
```

The inventory repository is used only as an input source. Generated host files and YAML varfiles are committed to a separate output repository so they remain available after the Tower/AAP execution environment is destroyed.
