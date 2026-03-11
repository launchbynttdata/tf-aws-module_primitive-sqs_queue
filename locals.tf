// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

locals {
  default_tags = {
    provisioner = "Terraform"
  }

  tags = merge(local.default_tags, var.tags)

  # SQS-managed SSE and KMS encryption are mutually exclusive on aws_sqs_queue.
  # Only one of these may be set on the resource at a time.
  use_kms_encryption = var.use_aws_managed_sqs_kms_key || (var.kms_master_key_id != null && var.kms_master_key_id != "")
  use_sqs_managed_sse = var.sqs_managed_sse_enabled == true && !local.use_kms_encryption
}
