/*output "sa_email" {
  description 	= "svc account email"
  value 	= module.svc-account.sa_email
}
*/
output "topic_name" {
  description = "topic"
  value = module.app-topic[*].id
}
/*
output "subscriptions" {
  description = "topic"
  value = module.app-pubsub-ccatopic.subscription_name
}

output "sub_binding" {
  description = "topic"
  value = module.app-pubsub-ccatopic.sub_binding
}

output "pysrc-bucket" {
  description 	= "storage buckets"
  value 	= module.app_src_bucket.buckets
}
*/
