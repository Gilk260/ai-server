variable "node_name" {
  type = string
}

variable "bridges" {
  type = list(object({
    name    = string
    address = string
    comment = optional(string, "")
  }))
}
