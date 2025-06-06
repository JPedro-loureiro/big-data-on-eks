package trino.authz

default allow = false

blocked_impersonation_targets = {
  "root",
  "admin",
  "trino",
  "superuser"
}

# Main rule for impersonation
allow {
  input.context.action == "impersonate-user"
  input.identity.user == "dbt_user"
  not blocked_impersonation_targets[input.context.targetUser]
}