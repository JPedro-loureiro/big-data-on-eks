package trino.authz

default allow = false

# Main rule for impersonation
allow {
  input.context.action == "impersonate-user"
  input.identity.user == "dbt_user"
}