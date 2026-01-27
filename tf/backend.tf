terraform {
  backend "s3" {
    bucket       = "a4life-fortune-terraform-state"
    key          = "github/FortunexFortune/python-cat"
    region       = "eu-west-1"
    use_lockfile = true
  }
}
