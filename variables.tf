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

variable "name" {
  description = "The name of the queue. Conflicts with name_prefix."
  type        = string
  nullable    = true
  default     = null
}

variable "name_prefix" {
  description = "Creates a unique name beginning with the specified prefix. Conflicts with name."
  type        = string
  nullable    = true
  default     = null
}

variable "visibility_timeout_seconds" {
  description = "The visibility timeout for the queue, in seconds. Valid values: an integer from 0 to 43200 (maximum 12 hours). Default: 30."
  type        = number
  default     = 30
  nullable    = false
}

variable "message_retention_seconds" {
  description = "The number of seconds Amazon SQS retains a message. Integer representing seconds, from 60 (1 minute) to 1209600 (14 days). Default: 345600 (4 days)."
  type        = number
  default     = 345600
  nullable    = false
}

variable "max_message_size" {
  description = "The limit of how many bytes a message can contain before Amazon SQS rejects it. An integer from 1024 bytes (1 KiB) up to 262144 bytes (256 KiB). Default: 262144 (256 KiB)."
  type        = number
  default     = 262144
  nullable    = false
}

variable "delay_seconds" {
  description = "The time in seconds that the delivery of all messages in the queue is delayed. An integer from 0 to 900 (15 minutes). Default: 0."
  type        = number
  default     = 0
  nullable    = false
}

variable "receive_wait_time_seconds" {
  description = "The time for which a ReceiveMessage call will wait for a message to arrive. An integer from 0 to 20 (seconds). Default: 0, which will return immediately."
  type        = number
  default     = 0
  nullable    = false
}

variable "policy" {
  description = "The JSON policy for the SQS queue"
  type        = string
  nullable    = true
  default     = null
}

variable "redrive_policy" {
  description = "The JSON policy to set up the Dead Letter Queue. See: https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/sqs-dead-letter-queues.html"
  type        = string
  nullable    = true
  default     = null
}

variable "redrive_allow_policy" {
  description = "The JSON policy to set up the Dead Letter Queue redrive permission. See: https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/sqs-dead-letter-queues.html"
  type        = string
  nullable    = true
  default     = null
}

variable "fifo_queue" {
  description = "Boolean designating a FIFO queue. If not set, it defaults to false making it standard."
  type        = bool
  default     = false
  nullable    = false
}

variable "content_based_deduplication" {
  description = "Enables content-based deduplication for FIFO queues. See: https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/FIFO-queues-exactly-once-processing.html"
  type        = bool
  default     = false
  nullable    = false
}

variable "sqs_managed_sse_enabled" {
  description = "Boolean designating if Server-Side Encryption is enabled with SQS-owned encryption keys."
  type        = bool
  default     = null
  nullable    = true
}

variable "kms_master_key_id" {
  description = "The ID of an AWS-managed customer master key (CMK) for Amazon SQS or a custom CMK. See: https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/sqs-server-side-encryption.html. Defaults to an empty string, which will use the default KMS key for this account. To disable encryption at rest entirely, set this value to `null` and set sqs_managed_sse_enabled to `false`."
  type        = string
  default     = ""
  nullable    = true
}

variable "kms_data_key_reuse_period_seconds" {
  description = "The length of time, in seconds, for which Amazon SQS can reuse a data key to encrypt or decrypt messages before calling AWS KMS again. An integer representing seconds, between 60 seconds (1 minute) and 86,400 seconds (24 hours). Default: 300 (5 minutes)."
  type        = number
  default     = 300
  nullable    = false
}

variable "deduplication_scope" {
  description = "Specifies whether message deduplication occurs at the message group or queue level. Valid values are `messageGroup` and `queue`. Defaults to `queue`."
  type        = string
  default     = null

  validation {
    condition     = var.deduplication_scope == null ? true : (var.deduplication_scope == "messageGroup" || var.deduplication_scope == "queue")
    error_message = "deduplication_scope must be either `messageGroup` or `queue`"
  }
}

variable "fifo_throughput_limit" {
  description = "Specifies whether the FIFO queue throughput quota applies to the entire queue or per message group. Valid values are `perQueue` and `perMessageGroupId`. Defaults to `perQueue`."
  type        = string
  default     = null

  validation {
    condition     = var.fifo_throughput_limit == null ? true : (var.fifo_throughput_limit == "perQueue" || var.fifo_throughput_limit == "perMessageGroupId")
    error_message = "fifo_throughput_limit must be either `perQueue` or `perMessageGroupId`"
  }
}

variable "tags" {
  type        = map(string)
  nullable    = false
  default     = {}
  description = "A mapping of tags to assign to the resource."
}
