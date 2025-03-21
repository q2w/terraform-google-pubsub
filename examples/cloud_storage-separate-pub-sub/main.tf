/**
 * Copyright 2018-2023 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

provider "google" {
  region = "europe-west1"
}

module "pub" {
  source  = "terraform-google-modules/pubsub/google//modules/pub"
  version = "~> 7.0"

  project_id = var.project_id
  topic      = "cft-tf-pub-topic-cloud-storage"

  topic_labels = {
    foo_label = "foo_value"
  }
}

module "sub" {
  source  = "terraform-google-modules/pubsub/google//modules/sub"
  version = "~> 7.0"

  project_id = var.project_id
  topic      = "cft-tf-pub-topic-cloud-storage"

  cloud_storage_subscriptions = [
    {
      name   = "sub_example_bucket_subscription"
      bucket = google_storage_bucket.test.name

      filename_prefix          = "example_prefix_"
      filename_suffix          = "_example_suffix"
      filename_datetime_format = "YYYY-MM-DD/hh_mm_ssZ"
      ack_deadline_seconds     = 300
    },
  ]
}

resource "google_storage_bucket" "test" {
  project                     = var.project_id
  name                        = join("-", ["sub_test_bucket", random_id.bucket_suffix.hex])
  location                    = "europe-west1"
  uniform_bucket_level_access = true
}
