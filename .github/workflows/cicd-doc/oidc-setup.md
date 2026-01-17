# ============================================================
#  GITHUB OIDC + AWS SETUP — SHORT GUIDE
# ============================================================

# ------------------------------------------------------------
#  1. CREATE OIDC PROVIDER IN AWS
# ------------------------------------------------------------
1. Go to IAM → Identity Providers → Add provider
2. Provider type: OpenID Connect (OIDC)
3. Provider URL: https://token.actions.githubusercontent.com
4. Audience: sts.amazonaws.com
5. Save the provider

# ------------------------------------------------------------
#  2. CREATE IAM ROLE FOR GITHUB ACTIONS
# ------------------------------------------------------------
1. Go to IAM → Roles → Create role → Web identity
2. Choose provider: the OIDC provider you just created
3. Audience: sts.amazonaws.com
4. Trusted GitHub repo: 
   e.g "repo:<github-username>/<repo-name>:ref:refs/heads/main"

5. Attach policy: AdministratorAccess 
   (or custom policy limited to project resources e.g ec2, alb only ) 
6. Role name: e.g., MyGithubRole-dev / YourAwsRole-prod
7. Copy the Role ARN

# ------------------------------------------------------------
#  3. ADD GITHUB SECRETS
# ------------------------------------------------------------
1. Go to GitHub → Settings → Secrets → Actions
2. Add the following secrets:  e.gs

   - PYFLEET_ARN = arn:aws:iam::<account_id>:role/MyGithubAwsRole
   - INFRACOST_API_KEY = <my Infracost API key>

# ------------------------------------------------------------
#  4. USE IN GITHUB ACTIONS WORKFLOW
# ------------------------------------------------------------
Configure AWS credentials dynamically in your workflow:

- uses: aws-actions/configure-aws-credentials@v4
  with:
    role-to-assume: ${{ secrets.PYFLEET_ARN }}-dev
    aws-region: us-east-1

Note: id-token write permission is required in workflow for OIDC.

# ------------------------------------------------------------
#  5. TRIGGER & TEST
# ------------------------------------------------------------
1. Workflow can now assume AWS role securely without storing long-term keys
2. Test access using commands like:

   aws s3 ls
   aws sts get-caller-identity

