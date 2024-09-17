# shellcheck disable=SC2148
# shellcheck disable=SC2034
PRIVILEGES=(
  "Datastore.AllocateSpace"
  "Datastore.Audit"
  "Pool.Allocate"
  "Sys.Audit"
  "Sys.Console"
  "Sys.Modify"
  "VM.Allocate"
  "VM.Audit"
  "VM.Clone"
  "VM.Config.CDROM"
  "VM.Config.Cloudinit"
  "VM.Config.CPU"
  "VM.Config.Disk"
  "VM.Config.HWType"
  "VM.Config.Memory"
  "VM.Config.Network"
  "VM.Config.Options"
  "VM.Migrate"
  "VM.Monitor"
  "VM.PowerMgmt"
)

TERRAFORM_UGID="terraform-prov@pve"
TERRAFORM_ROLE="TerraformProv"
TOKEN_NAME="terraform"
TOKEN_COMMENT="Terraform token"
TOKEN_EXPIRE="0"
TOKEN_PRIVSEP="0"

# Function to run commands and handle errors
run_command() {
  local command="$1"
  echo "Running command: $command"
  if eval "$command"; then
    echo "Command succeeded: $command"
  else
    echo "Error: Command failed: $command" >&2
    exit 1
  fi
}