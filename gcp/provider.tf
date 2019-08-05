provider "google" {
  credentials = "${file("account.json")}"
  project     = "${jsondecode(file("account.json"))["project_id"]}"
  region      = "${var.region}"
}
