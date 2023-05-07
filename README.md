# github_pages

Publish files to a `gh-pages` branch on GitHub (or any other branch anywhere else). Dart port of the NodeJS [gh-pages](https://www.npmjs.com/package/gh-pages) package.

[![pub package](https://img.shields.io/pub/v/github_pages.svg)](https://pub.dev/packages/github_pages)

## Getting Started

Install it globally from the command line.

```console
$ dart pub global activate github_pages
```

Or add it to your `pubspec.yaml` file as a dev dependency.

```yaml
dev_dependencies:
  github_pages: ^2.0.0
```

## Usage

For example, to publish your web application, you must generate a release build and then run the package with the required directory.

```console
$ flutter build web
$ flutter pub run github_pages -d build/web
```

Calling this script will create a temporary clone of the current repository, create a `gh-pages` branch if one doesn't already exist, copy over all files from the base path, or only those that match patterns from the optional `src` configuration, commit all changes, and push to the `origin` remote.

If a `gh-pages` branch already exists, it will be updated with all commits from the remote before adding any commits from the provided `src` files.

**Note** that any files in the `gh-pages` branch that are *not* in the `src` files **will be removed**.  See the `add` option if you don't want any of the existing files removed.

## Options

The default options work for simple cases. The options described below let you push to alternate branches, customize your commit messages and more.

```console
$ flutter pub run github_pages --help
Usage: github_pages [options]
Options:
-d, --dist          Base directory for all source files
-s, --src           Pattern used to select which files to publish
                    (defaults to "**")
-b, --branch        Name of the branch you are pushing to
                    (defaults to "gh-pages")
-e, --dest          Target directory within the destination branch (relative to the root)
                    (defaults to ".")
-a, --add           Only add, and never remove existing files
-x, --silent        Do not output the repository url
-m, --message       Commit message
                    (defaults to "Updates")
-g, --tag           Add tag to commit
-t, --dotfiles      Include dotfiles
-r, --repo          URL of the repository you are pushing to
-p, --depth         Depth for clone
                    (defaults to "1")
-o, --remote        The name of the remote
                    (defaults to "origin")
-u, --user          The name and email of the user. Format is "Your Name <email@example.com>".
                    (defaults to the git config)
-v, --remove        Remove files that match the given pattern (ignored if used together with --add).
                    (defaults to ".")
-n, --no-push       Commit only (with no push)
-f, --no-history    Push force new commit without parent history
-h, --help          Print usage information
```
