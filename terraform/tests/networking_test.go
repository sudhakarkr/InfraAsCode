package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestNetworkingModuleAWS(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../modules/networking",
		Vars: map[string]interface{}{
			"cloud_provider":     "aws",
			"project_name":       "test",
			"environment":        "test",
			"region":             "us-east-1",
			"vpc_cidr":           "10.0.0.0/16",
			"availability_zones": []string{"us-east-1a", "us-east-1b"},
			"cluster_name":       "test-cluster",
			"enable_nat_gateway": false,
		},
		NoColor: true,
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	vpcId := terraform.Output(t, terraformOptions, "vpc_id")
	assert.NotEmpty(t, vpcId, "VPC ID should not be empty")

	publicSubnetIds := terraform.OutputList(t, terraformOptions, "public_subnet_ids")
	assert.Equal(t, 2, len(publicSubnetIds), "Should have 2 public subnets")
}

func TestNetworkingModuleValidation(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../modules/networking",
		Vars: map[string]interface{}{
			"cloud_provider": "invalid",
			"project_name":   "test",
			"environment":    "test",
			"region":         "us-east-1",
		},
		NoColor: true,
	})

	_, err := terraform.InitAndPlanE(t, terraformOptions)
	assert.Error(t, err, "Should fail with invalid cloud provider")
}
