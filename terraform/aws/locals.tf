# ============================================================
# COMMON PROJECT LOCALS
# ============================================================

locals {

  project_prefix = "${var.project_name}-${var.environment_name}"

  common_tags = {

    Project     = var.project_name
    Environment = var.environment_name
    ManagedBy   = "Terraform"

  }

}


# ============================================================
# PUBLIC SUBNET DEFINITIONS
# ============================================================

locals {

  public_subnets = {

    public_a = {

      cidr = "10.0.1.0/24"

      az = "us-east-1a"

    }

    public_b = {

      cidr = "10.0.2.0/24"

      az = "us-east-1b"

    }

  }

}


# ============================================================
# PRIVATE SUBNET DEFINITIONS
# ============================================================

locals {

  private_subnets = {

    private_a = {

      cidr = "10.0.11.0/24"

      az = "us-east-1a"

    }

    private_b = {

      cidr = "10.0.12.0/24"

      az = "us-east-1b"

    }

  }

}