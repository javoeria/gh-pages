# github_pages

Publish web files to a `gh-pages` branch on GitHub (or any other branch anywhere else).

[![pub package](https://img.shields.io/pub/v/github_pages.svg)](https://pub.dartlang.org/packages/github_pages)

## Installation

Add to your pubspec as a dev dependency because it's a command line tool.

```yaml
dev_dependencies:
  github_pages:
```

## Usage

To use this package, you need to build a web application bundle.

```
$ flutter build web
$ flutter pub run github_pages
```

Calling this function will create a temporary clone of the current repository, create a `gh-pages` branch if one doesn't already exist, copy over all files from the directory path, commit all changes, and push to the `origin` remote.

## Options

The default options work for simple cases. The options described below let you push to alternate branches, customize your commit messages, and more.

```console
$ flutter pub run github_pages --help
-d, --dist          Base directory for all source files
                    (defaults to "build")
-b, --branch        Name of the branch you are pushing to
                    (defaults to "gh-pages")
-m, --message       Commit message
                    (defaults to "Updates")
-o, --remote        The name of the remote
                    (defaults to "origin")
-n, --no-push       Commit only (with no push)
-f, --no-history    Push force new commit without parent history
-h, --help          Usage help
```
