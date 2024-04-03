
#svc account creation
module "svc-account" {
  source 	= "git::https://github.com/Swamy-Pepakayala/cca-modules.git//svcacc?ref=main"
  project_id	= var.project_id
  name 		= var.sa
  display_name  = "cca-svc-account"
}

#topic creation iam binding
module "app-topic" {
  source 	= "git::https://github.com/Swamy-Pepakayala/cca-modules.git//topic?ref=main"
  project_id	= var.project_id
  name		= ["cca-topic","cca-eventsharing"]
}

#create subscriptions for cca-topic
module "app-pubsub-ccatopic" {
  source 	= "git::https://github.com/Swamy-Pepakayala/cca-modules.git//pubsub?ref=main"
  project_id	= var.project_id
  topic_name 	= "cca-topic"
  subscriptions	= {
  	trg-cldfunc = null
	trg-storage-bucket = null
	}
  push_configs = {
  trg-storage-bucket = {
      endpoint   = "https://console.cloud.google.com/storage/browser/cca-error"
      attributes = null
      oidc_token = null
    } 
  trg-cldfunc = { 
      endpoint   = "https://console.cloud.google.com/storage/browser/cca-error" #to be changed to cld func
      attributes = null
      oidc_token = null
   }
  }
  subscription_iam_roles = {
    trg-cldfunc = ["roles/pubsub.subscriber","roles/pubsub.admin"],
    trg-storage-bucket = ["roles/pubsub.subscriber","roles/pubsub.admin"]
    
  }
  subscription_iam_members = {
    trg-cldfunc = {
      "roles/pubsub.subscriber" = ["serviceAccount:${module.svc-account.sa_email}"]
    }
  }
  depends_on = [module.app-topic]
}

#create subscriptions for cca-eventsharing
module "app-pubsub-eventshare" {
  source 	= "git::https://github.com/Swamy-Pepakayala/cca-modules.git//pubsub?ref=main"
  project_id	= var.project_id
  topic_name 	= "cca-eventsharing"
  subscriptions	= {
  	cca-event = null
	push-rdstorage = null
	pull-ingka = null
	}
  push_configs = {
  cca-event = {
      endpoint   = "https://console.cloud.google.com/storage/browser/cca-error" #to cldfunc
      attributes = null
      oidc_token = null
    } 
  push-rdstorage = { 
      endpoint   = "https://console.cloud.google.com/storage/browser/cca-rd"
      attributes = null
      oidc_token = null
   }
  }
  subscription_iam_roles = {
    cca-event = ["roles/pubsub.subscriber","roles/pubsub.admin"]
  }
  subscription_iam_members = {
    cca-event = {
      "roles/pubsub.subscriber" = ["serviceAccount:${module.svc-account.sa_email}"]
    }
  }
  depends_on = [module.app-topic]
}

module "app_buckets" {
  source        = "git::https://github.com/Swamy-Pepakayala/cca-modules.git//storage"
  project_id    = var.project_id
  location      = var.location
  storage_class = "REGIONAL"
  names         = ["cca-error", "cca-source"]
  folders = {
    "cca-error" = ["staging"]
    "cca-source" = ["staging"]
  }
  storage_iam_roles = {
    cca-error = ["roles/storage.admin"],
    cca-source = ["roles/storage.admin"]
  }
  storage_iam_members = {
    cca-error = {
      "roles/storage.admin" = ["serviceAccount:${module.svc-account.sa_email}"]
    },
    cca-source = {
      "roles/storage.admin" = ["serviceAccount:${module.svc-account.sa_email}"]
    }
  }
  lifecycle_age = {
    delete_age = 5
  }
}

module "app_bucket-retention" {
  source        = "git::https://github.com/Swamy-Pepakayala/cca-modules.git//storage?ref=main"
  project_id    = var.project_id
  location      = var.location
  storage_class = "REGIONAL"
  names         = ["cca-rd"]
  folders = {
    "cca-rd" = ["data"]
  }
  storage_iam_roles = {
    cca-rd = ["roles/storage.admin"],
  }
  storage_iam_members = {
    cca-rd = {
      "roles/storage.admin" = ["serviceAccount:${module.svc-account.sa_email}"]
    }
  }
  lifecycle_age = {
    delete_age = 21
  }
}
/*
module "app-cloudrun" {
  source  	= "git::https://github.com/Swamy-Pepakayala/cca-modules.git//cloudrun?ref=main"
  service 	= "cca-cldrun"
  project_id	= var.project_id
  location 	= var.location
  port 		= var.port
  image 	= var.image
  service_account_email = module.svc-account.sa_email
  depends_on = [module.svc-account]
}
*/


module "app_src_bucket" {
  source        = "git::https://github.com/Swamy-Pepakayala/cca-modules.git//storage?ref=main"
  project_id    = var.project_id
  location      = var.location
  storage_class = "REGIONAL"
  names         = ["cca-pysrc"]
  folders = {
    "cca-pysrc" = ["test"]
  }
  storage_iam_roles = {
    cca-pysrc = ["roles/storage.admin"],
  }
  storage_iam_members = {
    cca-pysrc = {
      "roles/storage.admin" = ["serviceAccount:${module.svc-account.sa_email}"]
    }
  }
  lifecycle_age = {
    delete_age = 21
  }
}

#it will have pubsub trigger
module "app-cloudfuncv2-valsvc" {
  source 	= "git::https://github.com/Swamy-Pepakayala/cca-modules.git//cloudfunctionsv2?ref=main"
  project_id	= var.project_id
  location	= var.location
  names		= ["cca-valsvc"]
  runtime	= var.runtime
  entry_point	= "hello_http"
  srccde 	= "valsvc"
  bucket_name	= "cca-pysrc"
  bucket_location = var.location
  sa_email 	= module.svc-account.sa_email
  event_trigger = true
  pubsub_topic  = module.app-topic.id[0]
  depends_on = [module.svc-account,module.app-topic]
}

module "app-cloudfuncv2-handshake" {
  source 	= "git::https://github.com/Swamy-Pepakayala/cca-modules.git//cloudfunctionsv2?ref=main"
  project_id	= var.project_id
  location	= var.location
  names		= ["cca-handshake"]
  runtime	= var.runtime
  entry_point	= "hello_http"
  srccde 	= "handshake"
  #bucket_name 	= module.app_src_bucket["pysrc-bucket"].name
  bucket_name 	= "cca-pysrc"
  bucket_location = var.location
  sa_email 	= module.svc-account.sa_email
  event_trigger = true
  pubsub_topic  = module.app-topic.id[1]
  depends_on = [module.svc-account,module.app-topic] 
}


module "app-cloudfuncv2-failsvc" {
  source 	= "git::https://github.com/Swamy-Pepakayala/cca-modules.git//cloudfunctionsv2?ref=main"
  project_id	= var.project_id
  location	= var.location
  names		= ["cca-failsvc"]
  runtime	= var.runtime
  entry_point	= "hello_http"
  srccde 	= "failsvc"
  bucket_name	= "cca-pysrc"
  bucket_location = var.location
  sa_email 	= module.svc-account.sa_email
  event_trigger = false
  pubsub_topic  = module.app-topic.id[1]
  depends_on = [module.svc-account,module.app-topic] 
}

module "app-cloudfuncv2-rdsvc" {
  source 	= "git::https://github.com/Swamy-Pepakayala/cca-modules.git//cloudfunctionsv2?ref=main"
  project_id	= var.project_id
  location	= var.location
  names		= ["cca-rdsvc"]
  runtime	= var.runtime
  entry_point	= "hello_http"
  srccde 	= "rdsvc"
  bucket_name	= "cca-pysrc"
  bucket_location = var.location
  sa_email 	= module.svc-account.sa_email
  event_trigger = false
  pubsub_topic  = module.app-topic.id[1]
  depends_on = [module.svc-account,module.app-topic] 
}
/*
# to schedule cloud functions
module "app-cloudsch" {
  source 	= "git::https://github.com/Swamy-Pepakayala/cca-modules.git//scheduler?ref=main"
  project_id	= var.project_id
  names		= ["cca-failsvc-sch","cca-rdsvc-sch"]
  schedule	= "59 23 * * *"
  https_trigger_url	= [module.app-cloudfuncv2-failsvc.url[0], module.app-cloudfuncv2-rdsvc.url[0]]
  #module.app-cloudfuncv2.url[3]]
  sa_email 	= module.svc-account.sa_email
}
*/
