plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

# Disabled for child modules — the root module enforces these
rule "terraform_required_version" {
  enabled = false
}

rule "terraform_required_providers" {
  enabled = false
}
