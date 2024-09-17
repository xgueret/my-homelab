#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

source /tmp/common.sh

# Check if the TERRAFORM_PASSWORD environment variable is set
if [ -z "$TERRAFORM_PASSWORD" ]; then
  echo "Error: TERRAFORM_PASSWORD environment variable is not set."
  exit 1
fi

# Join the array into a single string separated by spaces
PRIVILEGES_STR=$(IFS=" "; echo "${PRIVILEGES[*]}")


# Check if the role already exists
if pveum role list -o json | jq -e --arg role "$TERRAFORM_ROLE" '.[] | select (.roleid == $role)' > /dev/null ; then
  echo "Role $TERRAFORM_ROLE already exists, skipping creation."
else
  # Add TerraformProv role with specified privileges
  echo "Adding role $TERRAFORM_ROLE..."
  run_command "pveum role add $TERRAFORM_ROLE -privs \"$PRIVILEGES_STR\""
fi

# Check if the user already exists
if pveum user list -o json | jq -e --arg user "$TERRAFORM_UGID" '.[] | select(.userid == $user)'  > /dev/null; then
  echo "User $TERRAFORM_UGID already exists, skipping creation."
else
  # Add user terraform-prov@pve with the specified password
  echo "Adding user $TERRAFORM_UGID..."
  run_command "pveum user add $TERRAFORM_UGID --password \"$TERRAFORM_PASSWORD\""
fi

# Check if the user already has the role assigned
if pveum acl list -o json | jq -e --arg role "$TERRAFORM_ROLE" --arg ugid "$TERRAFORM_UGID"   '.[] | select (.roleid == $role and .ugid == $ugid)' > /dev/null; then
  echo "User $TERRAFORM_UGID already has the $TERRAFORM_ROLE role assigned, skipping association."
else
  # Assign TerraformProv role to the user
  echo "Assigning $TERRAFORM_ROLE role to user $TERRAFORM_UGID..."
  run_command "pveum aclmod / -user $TERRAFORM_UGID -role $TERRAFORM_ROLE"
fi

echo "Role $TERRAFORM_ROLE assigned to user $TERRAFORM_UGID successfully."
