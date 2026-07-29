fmt:
	terraform -chdir=terraform/aws fmt -recursive

validate:
	terraform -chdir=terraform/aws validate
