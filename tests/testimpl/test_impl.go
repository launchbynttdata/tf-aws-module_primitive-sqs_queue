package testimpl

import (
	"testing"
	"time"
	"context"
	"fmt"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/sqs"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/launchbynttdata/lcaf-component-terratest/types"
	"github.com/stretchr/testify/assert"
)

func TestComposableComplete(t *testing.T, ctx types.TestContext) {
	sqsClient := GetSqsClient(t)

	t.Run("QueueExists", func(t *testing.T) {
		queueUrl := terraform.Output(t, ctx.TerratestTerraformOptions(), "queue_url")
		queueName := terraform.Output(t, ctx.TerratestTerraformOptions(), "queue_name")

		output, err := sqsClient.ListQueues(context.TODO(), &sqs.ListQueuesInput{
			QueueNamePrefix: &queueName,
		})
		assert.NoErrorf(t, err, "Unable to get queue list, %v", err)
		queueFound := false
		fmt.Printf("Queues: %v \n", output.QueueUrls)
		for _, url := range output.QueueUrls {
			if url == queueUrl {
				queueFound = true
				break
			}
		}
		assert.True(t, queueFound, "Expected queue URL not found in the list")
	})

	t.Run("DlqExists", func(t *testing.T) {
		ctx.EnabledOnlyForTests(t, "dlq")

		dlqUrl := terraform.Output(t, ctx.TerratestTerraformOptions(), "dlq_url")
		dlqName := terraform.Output(t, ctx.TerratestTerraformOptions(), "dlq_name")

		output, err := sqsClient.ListQueues(context.TODO(), &sqs.ListQueuesInput{
			QueueNamePrefix: &dlqName,
		})
		assert.NoErrorf(t, err, "Unable to get queue list, %v", err)
		fmt.Printf("Queues: %v \n", output.QueueUrls)

		queueFound := false
		for _, url := range output.QueueUrls {
			if url == dlqUrl {
				queueFound = true
				break
			}
		}
		assert.True(t, queueFound, "Expected DLQ URL not found in the list")
	})

	t.Run("SendAndReceiveMessage", func(t *testing.T) {
		queueUrl := terraform.Output(t, ctx.TerratestTerraformOptions(), "queue_url")

		messageBody := "Hello, World!"

		_, err := sqsClient.SendMessage(context.TODO(), &sqs.SendMessageInput{
			MessageBody: &messageBody,
			QueueUrl:    &queueUrl,
		})
		assert.NoErrorf(t, err, "Unable to send message, %v", err)

		time.Sleep(5 * time.Second)

		// Receive the message from the SQS queue
		received, err := sqsClient.ReceiveMessage(context.TODO(), &sqs.ReceiveMessageInput{
			QueueUrl: &queueUrl,
		})
		assert.NoErrorf(t, err, "Unable to receive message, %v", err)
		assert.Equal(t, messageBody, *received.Messages[0].Body)

		// Now that we have the receipt handle, we can delete the message
		_, err = sqsClient.DeleteMessage(context.TODO(), &sqs.DeleteMessageInput{
			QueueUrl:      &queueUrl,
			ReceiptHandle: received.Messages[0].ReceiptHandle,
		})
		assert.NoErrorf(t, err, "Unable to delete message, %v", err)
	})

	t.Run("SendAndFailToReceiveMessage", func(t *testing.T) {
		ctx.EnabledOnlyForTests(t, "dlq")

		queueUrl := terraform.Output(t, ctx.TerratestTerraformOptions(), "queue_url")
		dlqUrl := terraform.Output(t, ctx.TerratestTerraformOptions(), "dlq_url")

		messageBody := "Hello, DLQ!"

		_, err := sqsClient.SendMessage(context.TODO(), &sqs.SendMessageInput{
			MessageBody: &messageBody,
			QueueUrl:    &queueUrl,
		})
		assert.NoErrorf(t, err, "Unable to send message, %v", err)

		// Receive the message from the SQS queue
		received, err := sqsClient.ReceiveMessage(context.TODO(), &sqs.ReceiveMessageInput{
			QueueUrl: &queueUrl,
		})
		assert.NoErrorf(t, err, "Unable to receive message, %v", err)
		assert.Equal(t, messageBody, *received.Messages[0].Body)

		time.Sleep(5 * time.Second)
		// Try to receive the message from the SQS queue again, which causes it to be sent to the DLQ
		_, err = sqsClient.ReceiveMessage(context.TODO(), &sqs.ReceiveMessageInput{
			QueueUrl: &queueUrl,
		})
		assert.NoErrorf(t, err, "Should not have received an error!, %v", err)

		time.Sleep(1 * time.Second)
		// Receive the message from the DLQ
		received, err = sqsClient.ReceiveMessage(context.TODO(), &sqs.ReceiveMessageInput{
			QueueUrl: &dlqUrl,
		})
		assert.NoErrorf(t, err, "Unable to receive message, %v", err)
		assert.Equal(t, messageBody, *received.Messages[0].Body)
	})
}


func GetAWSConfig(t *testing.T) (cfg aws.Config) {
	cfg, err := config.LoadDefaultConfig(context.TODO())
	assert.NoErrorf(t, err, "unable to load SDK config, %v", err)
	return cfg
}

func GetSqsClient(t *testing.T) *sqs.Client {
	sqsClient := sqs.NewFromConfig(GetAWSConfig(t))
	return sqsClient
}
