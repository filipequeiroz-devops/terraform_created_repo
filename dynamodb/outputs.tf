output "dynamodb_table_name" {
  value = aws_dynamodb_table.my_table.name
}

output "dynamodb_partition_key" {
  value = aws_dynamodb_table.my_table.hash_key
}

output "dynamodb_sort_key" {
  value = aws_dynamodb_table.my_table.range_key
}