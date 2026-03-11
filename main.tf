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

# Only look up default SQS KMS key when explicitly requested (use_aws_managed_sqs_kms_key = true).
# Count uses a bool so it is known at plan time even when kms_master_key_id is a resource reference.
data "aws_kms_alias" "sqs" {
  count  = var.use_aws_managed_sqs_kms_key ? 1 : 0
  name   = "alias/aws/sqs"
}

resource "aws_sqs_queue" "queue" {
  name                              = var.name
  name_prefix                       = var.name_prefix
  visibility_timeout_seconds        = var.visibility_timeout_seconds
  message_retention_seconds         = var.message_retention_seconds
  max_message_size                  = var.max_message_size
  delay_seconds                     = var.delay_seconds
  receive_wait_time_seconds         = var.receive_wait_time_seconds
  policy                            = var.policy
  redrive_policy                    = var.redrive_policy
  redrive_allow_policy              = var.redrive_allow_policy
  fifo_queue                        = var.fifo_queue
  content_based_deduplication       = var.content_based_deduplication
  sqs_managed_sse_enabled           = local.use_sqs_managed_sse ? true : null
  kms_master_key_id                 = local.use_kms_encryption ? (var.use_aws_managed_sqs_kms_key ? data.aws_kms_alias.sqs[0].target_key_id : var.kms_master_key_id) : null
  kms_data_key_reuse_period_seconds = var.kms_data_key_reuse_period_seconds
  deduplication_scope               = var.deduplication_scope
  fifo_throughput_limit             = var.fifo_throughput_limit

  tags = local.tags
}
