locals {
  app_name             = data.terraform_remote_state.eb_env_state.outputs.app_name
  eb_env_id            = data.terraform_remote_state.eb_env_state.outputs.eb_env_id
  account_id           = data.aws_caller_identity.current.account_id
  eb_role_name         = data.terraform_remote_state.eb_env_state.outputs.eb_role_name
  policy_to_detach_arn = data.terraform_remote_state.eb_env_state.outputs.policy_to_detach_arn
}