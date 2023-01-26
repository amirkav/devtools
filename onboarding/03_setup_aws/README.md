# AWS Configure
Set up local environment to manage and interact with the AWS accounts.

## Configure IAM profiles
First, set up the local profiles for the IAM users of your AWS account.
1. Create initial aws configuration: `source ./03_setup_aws/01_setup_aws_profiles.sh`
2. There are two types of IAM profiles: non-MFA and MFA. 
2.a. **Non-MFA IAM Users**: For acccess via an IAM use without MFA setup, you just need to add the (aws_access_key_id, aws_secret_access_key) for that IAM profile.
- `[dev]`
2.b. **MFA IAM Users**: If you need CLI access to an IAM account with MFA enabled, you will need to create the following profiles:
- `[prod-mfagen]` : this profile has your base AWS credentials (aws_access_key_id, aws_secret_access_key) for the IAM use with MFA.
- `[prod]` and [`staging]` : these profiles will be populated by temporary credentials that you receive from STS MFA call.
The applications and scripts that you run locally use these profiles to access AWS resource on behalf of the account with MFA.
- Consider using the scripts in `bash-lib/aws.sh` to automate the process of creating temporary credentials.
Add `aws-refresh-session-mfa` bash method to your `~/.bash_profile` or `~/.zprofile` and call it from Terminal. 
When prompted for `MFA code`, use your MFA device to get a valid MFA code.
3. Consider option Bash Profile aliases below

*Example: contents of ~/.aws/credentials*
```bash
[dev]
aws_access_key_id = <your iam key id for dev account> 
aws_secret_access_key = <your iam secret access key for dev account>

[prod-mfagen]
aws_access_key_id = <your iam key id for prod account> 
aws_secret_access_key = <your iam secret access key for prod account>

[staging]
aws_access_key_id = <temp credentials you get from sts get-session-token command> 
aws_secret_access_key = <temp credentials you get from sts get-session-token command>
aws_session_token = <temp credentials you get from sts get-session-token command>

[prod]
aws_access_key_id = <temp credentials you get from sts get-session-token command> 
aws_secret_access_key = <temp credentials you get from sts get-session-token command>
aws_session_token = <temp credentials you get from sts get-session-token command>
```

*Example: contents of ~/.aws/config*
```bash
[default]
source_profile = dev
output = json
region = us-west-2

[profile dev]
source_profile = dev
output = json
region = us-west-2

[profile staging]
source_profile = staging
output = json
region = us-west-2

[profile prod]
source_profile = prod
output = json
region = us-west-2

[profile prod-mfagen]
source_profile = prod-mfagen
output = json
region = us-west-2
```

## ~/.bashprofile and ~/.zprofile

```bash
### AWS TOOLS
# Refresh ECR tokens
alias ecr='$(aws ecr get-login --no-include-email)'

# AWS DEV
alias dev='echo "Setting AWS_PROFILE to DEV"; export AWS_PROFILE=dev; export ENV=dev;'

# AWS STAGING
alias staging='echo "Setting AWS_PROFILE to STAGING"; export AWS_PROFILE=staging; export ENV=staging;'

# AWS PROD
alias prod='echo "Setting AWS_PROFILE to PROD"; export AWS_PROFILE=prod; export ENV=prod;'
```
