variable "lambdas" {
  description = "Name and tag for lambdas to download."
  type = list(object({
    name = string
    tag  = string
  }))
  default = [ {
    name = "webhook"
    tag  = "v5.7.0"
  }, {
    name = "runners"
    tag  = "v5.7.0"
  }, {
    name = "runner-binaries-syncer"
    tag  = "v5.7.0"
  } ]
}
