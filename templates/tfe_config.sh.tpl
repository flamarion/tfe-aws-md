#!/bin/bash

cat > /etc/replicated.conf <<EOF
{
  "DaemonAuthenticationType": "password",
  "DaemonAuthenticationPassword": "${admin_password}",
  "TlsBootstrapType": "self-signed",
  "BypassPreflightChecks": true,
  "ImportSettingsFrom": "/etc/settings.json",
  "LicenseFileLocation": "/etc/license.rli",
  "ReleaseSequence": ${rel_seq}
}
EOF

cat > /etc/settings.json <<EOF
{
  "aws_access_key_id": {},
  "aws_instance_profile": {
    "value": "0"
  },
  "aws_secret_access_key": {},
  "azure_account_key": {},
  "azure_account_name": {},
  "azure_container": {},
  "azure_endpoint": {},
  "backup_token": {
    "value": "XHFJPTv7pnsq6EomEtONDWRcO0aweqws"
  },
  "ca_certs": {},
  "capacity_concurrency": {
    "value": "10"
  },
  "capacity_memory": {
    "value": "512"
  },
  "custom_image_tag": {
    "value": "hashicorp/build-worker:now"
  },
  "disk_path": {
    "value": "${tfe_mount_point}"
  },
  "enable_metrics_collection": {
    "value": "1"
  },
  "enc_password": {
    "value": "${admin_password}"
  },
  "extern_vault_addr": {},
  "extern_vault_enable": {
    "value": "0"
  },
  "extern_vault_path": {},
  "extern_vault_propagate": {},
  "extern_vault_role_id": {},
  "extern_vault_secret_id": {},
  "extern_vault_token_renew": {},
  "extra_no_proxy": {},
  "gcs_bucket": {},
  "gcs_credentials": {
    "value": "{}"
  },
  "gcs_project": {},
  "hostname": {
    "value": "${lb_fqdn}"
  },
  "iact_subnet_list": {},
  "iact_subnet_time_limit": {
    "value": "60"
  },
  "installation_type": {
    "value": "production"
  },
  "pg_dbname": {},
  "pg_extra_params": {},
  "pg_netloc": {},
  "pg_password": {},
  "pg_user": {},
  "placement": {
    "value": "placement_s3"
  },
  "production_type": {
    "value": "disk"
  },
  "s3_bucket": {},
  "s3_endpoint": {},
  "s3_region": {},
  "s3_sse": {},
  "s3_sse_kms_key_id": {},
  "tbw_image": {
    "value": "default_image"
  },
  "tls_vers": {
    "value": "tls_1_2_tls_1_3"
  }
}
EOF

chmod 644 /etc/replicated.conf /etc/settings.json
curl -o /tmp/install.sh https://install.terraform.io/ptfe/stable
chmod +x /tmp/install.sh
/tmp/install.sh no-proxy private-address=$(curl http://169.254.169.254/latest/meta-data/local-ipv4) public-address=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)
