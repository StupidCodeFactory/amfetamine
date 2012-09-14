## 0.3.3

* fix for double Array error messages bug for remote (server) validations [Issue #6]

## 0.3.2

* fix for Object#save return value with disabled caching

## 0.3.1

* `memcached_instance` Dalli::Client configuration setting changes (it should now start with "memcached://")

## 0.3.0

* Caching is now turned off by default in Rails development/test modes
* Add `class_name` and `foreign_key` options to relationships, which allows mapping resources to local Amfetamine classes with different names

## 0.2.12

* Add abillity to deactivate caching, using `disable_caching=` on either the config or an object
* Starting builds against other ruby versions

## 0.2.11

* Rewrote specs to be idempotent when randomized
* Fixed a lot of specs for travis in general

## 0.2.10

* Removed verbosity from tests
* Dropped support for Ruby 1.8.7
* Sourcecode is now available on github

## 0.2.9

* Cleaning up

## 0.2.8

* Attributes are now set dynamically. This **overrides** anything you set on `amfetamine_attributes`. This should reduce a lot of bloat.
