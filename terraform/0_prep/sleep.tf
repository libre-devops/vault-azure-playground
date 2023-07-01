# Add delay to allow key vault permissions time to propagate on IAM
resource "time_sleep" "wait_120_seconds" {
  depends_on = [
    module.roles
  ]

  create_duration = "120s"
}
