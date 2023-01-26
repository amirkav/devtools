

# You can manage and work with multiple Terraform Cloud accounts from your machine.
# To do so, first generate user API tokens on Terraform Cloud for each of the user accounts you have.
# Then, create two separate ~/.terraformrc files:

```
{
  "credentials": {
    "app.terraform.io": {
      "token": "{insert_user_api_token_here}"
    }
  }
}
```


### Add the following to ~/.zprofile to make working with Terraform easier
# Then, to switch between Terraform Cloud backends, use the aliases you define below.
alias tf="terraform"
alias tf-personal='export TF_CLI_CONFIG_FILE=~/.terraformrc.personal'
alias tf-work='export TF_CLI_CONFIG_FILE=~/.terraformrc.work'
