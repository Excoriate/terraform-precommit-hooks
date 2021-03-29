# Terraform PreCommit Hooks

These Hooks work out with pre-commit framework 🚀 — These hooks found inspiration in some other nice projects available in the community, however, I've added my own additions, like adding a hook to cleaning up the `.terraform` (metadata) folder which is usually generated whenever we run a local `terraform` command, or the addition of the `terraform plan` hook as well.

## Hooks

These hooks works with  [pre-commit](https://pre-commit.com/) and act onto (`*.tf` and `*.tfvars`) depending on the `file` configuration placed in the main `.pre-commit.hooks.yaml` file. Whether in the future I (or anyone who wanna contribute here) found that's needed a new hook, please, feel free to raise a `feature request or, even better! just push your PR!

| Hook                                              | Description                                                                                                                |
| ------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------- |
| `terraform-validate`                             | Validates all Terraform configuration files.                                                                               |
| `terraform-fmt`                                  | Format (check and fix) Terraform configuration following the canonical format.                                                          |
| `terraform-docs`                                 | Generate and keep up to date the documentation of terraform components. Re-write the `readme.md` file dynamically                                                      |
| `terraform-lint`                               | Use [TFLint](https://github.com/terraform-linters/tflint) to prevent bugs!                           |
| `terraform-clean`                                 | Get rid of the `.terraform` folder on local executions, after you've done all your local terraform commands. |
| `terragrunt-sec`                            | Validates all Terraform configuration from the security point of view. It uses [TFSec](https://github.com/liamg/tfsec)                       |
| `terraform-plan`                                | Execute terraform plan command onto specific terraform modules |

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