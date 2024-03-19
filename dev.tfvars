#generic vars
location  =   "us-central1"
#project_id = "terraform-415114" 
project_id = "orbital-outpost-416405"
region 	   = "us-central1"

#svc account
sa 		= "cca-svc-account"
sa_dispname	= "CCA Svc account"


#pubsub inputs
#sub_names     = ["cca-dev-pubsub1-2702","cca-dev-pubsub2-2702"]
#topic_name    = "cca-dev-topic-2702" 
#push_endpoint = "https://console.cloud.google.com/storage/browser/cca-bucket2"


#cloudrun inputs
service   =   "cca-run-2702"
port      =   "8080"
image     =   "us-docker.pkg.dev/cloudrun/container/hello"


#cloudfunction inputs
#function_name    ="cca-function"
runtime          ="python310"


