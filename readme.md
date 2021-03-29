# Terraform PreCommit Hooks

These Hooks work out with pre-commit framework 🚀 — These hooks found inspiration in some other nice projects available in the community, however, I've added my own additions, like adding a hook to cleaning up the `.terraform` (metadata) folder which is usually generated whenever we run a local `terraform` command, or the addition of the `terraform plan` hook as well.

## Configuration
### 1. Install dependencies

* [`pre-commit`](https://pre-commit.com/#install)
* [`terraform-docs`](https://github.com/terraform-docs/terraform-docs) required for `terraform_docs` hooks.
* [`TFLint`](https://github.com/terraform-linters/tflint)
* [`TFSec`](https://github.com/liamg/tfsec)

##### MacOS

```bash
brew install pre-commit gawk terraform-docs tflint tfsec coreutils
```
Or run this script
```bash
 npm run lib:install
```


### 2. Hook consumer configuration

After pre-commit hook has been installed you can run it manually on all files in the repository

```bash
pre-commit run -a
```

At the repository level, add the following file called `.pre-commit-config.yaml` with the following contents (This is just an example. You can add whatever available hook you might need. In addition, depending in your folder structure, you can use the same hook that acts in different `submodules` within your `terraform` project ;)):

```yaml
repos:
    -   repo: https://github.com/Excoriate/terraform-precommit-hooks.git
        rev: v0.0.1
        hooks:
            -  id: terraform-clean
              files: ^module/
              args:
                - "--dir=module"
            -  id: terraform-sec
              files: ^module/
              args:
                - "--dir=module"

```

### 3. Use notes
Every time you commit a code change (`.tf` file), the hooks in the `.pre-commit-config.yaml` will be executed.