provider "google" {
  project = "orbital-outpost-416405"
   credentials = "${file("C:/cca-terraform/gcp-tf/gcp.keys/keys.json")}"
 # credentials = "${file("/home/tadala1999/gcp-tf/gcp.keys/keys.json")}"
  region  = "us-central1"
  zone    = "us-central1-c"
}