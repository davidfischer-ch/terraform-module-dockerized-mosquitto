# Changelog

## Release v1.3.0 (2026-04-28)

### Minor compatibility breaks

* Bump minimum `NikolaLohinski/jinja` provider version from `1.17.0` to `2.0.0`. Consumers must run `terraform init -upgrade` to refresh the provider.

### Fix and enhancements

* Migrate `jinja_template` data source from deprecated `template` attribute to `source` block

## Release v1.2.0 (2026-03-14)

### Minor compatibility breaks

* Remove the `CAP_` prefix from `cap_add` and `cap_drop` values — the module now adds it automatically when calling the Docker provider

### Fix and enhancements

* Add validation of `cap_add` and `cap_drop` against the exhaustive list of Linux capabilities
* Reorder variables to be consistent

## Release v1.1.1 (2026-03-13)

### Fix and enhancements

* Set `enabled` default to `true`
* Refine variable descriptions, validators, and attribute ordering
* Remove redundant default values from examples and README

## Release v1.1.0 (2026-03-13)

### Fix and enhancements

* Add `# Process` section: `app_uid`, `app_gid`, `privileged`, `cap_add`, `cap_drop`
  variables wired into the container via `user`, `privileged`, and a dynamic `capabilities` block
* Add `examples/default/` Terraform example

## Release v1.0.1 (2026-01-03)

### Fix and enhancements

* Module: Declare network_mode bridge to prevent infinite recreate

## Release v1.0.0 (2025-01-20)

Initial release
