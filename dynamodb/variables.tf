variable "table_name" {
	description = "Name of the DynamoDB table."
	type        = string
}

variable "billing_mode" {
	description = "Billing mode for the DynamoDB table."
	type        = string
}

variable "hash_key" {
	description = "Name of the partition key."
	type        = string
}

variable "range_key" {
	description = "Name of the sort key, if applicable."
	type        = string
	default     = null
}

variable "read_capacity" {
	description = "Read capacity units for the table."
	type        = number
	default     = null
}

variable "write_capacity" {
	description = "Write capacity units for the table."
	type        = number
	default     = null
}

variable "hash_key_type" {
	description = "Attribute type of the partition key: S, N, or B."
	type        = string
}

variable "range_key_type" {
	description = "Attribute type of the sort key: S, N, or B."
	type        = string
	default     = null
}

variable "tags" {
	description = "Tags to apply to the DynamoDB table."
	type        = map(string)
	default     = {}
}
