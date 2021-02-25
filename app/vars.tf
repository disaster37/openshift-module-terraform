variable "namespace" {
    description = "Namespace where to deploy"
    type        = string
}

variable "repository" {
    description = "Helm repository to use"
    default     = ""
    type        = string
}

variable "template_name" {
    description = "Template name used to deploy"
    type        = string
}

variable "template_version" {
    description = "Template version used to deploy"
    type        = string
}

variable "name" {
    description = "Application name"
    type        = string
}


variable "values_path" {
    description = "Values path used when invoke helm"
    type        = string
}

variable "vault_path" {
    description = "Vault path to use."
    type        = string
    default     = ""
}

variable "vault_global_path" {
    description = "Vault path to use."
    type        = string
    default     = ""
}


variable "certificates" {
    description = "List of certificates to retrive from vault"
    type        = map(object({
        cert_key = string
        key_key  = string
    }))
    default     = {}
}

variable "global_certificates" {
    description = "List of certificates to retrive from vault"
    type        = list(string)
    default     = []
}

variable "credentials" {
    description = "List of credentials to retrive from vault"
    type        = list(string)
    default     = []
}

variable "secret_files" {
    description = "List of secret files to retrive from vault"
    type        = list(string)
    default     = []
}

variable "is_substitute_values" {
    description = "Subsitute variable on values.yaml from credentials secrets"
    type        = bool
    default     = false
}

variable "force_upgrade" {
    description = "Force helm upgrade"
    type        = bool
    default     = false
}

variable "pvcs" {
    description = "Additionnals PVC"
    type        = map(object({
        storage_class = string
        access_mode   = string
        size          = string
    }))
    default     = {}
}