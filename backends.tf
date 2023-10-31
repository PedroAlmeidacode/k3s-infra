terraform {
  cloud {
    organization = "pa-org"

    workspaces {
      name = "pa-dev"
    }
  }
}