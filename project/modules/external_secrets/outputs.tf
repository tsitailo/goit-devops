# -----------------------------------------------
# Виводи модуля External Secrets Operator
# -----------------------------------------------

output "eso_irsa_role_arn" {
  description = "ARN IAM ролі ESO (IRSA)"
  value       = aws_iam_role.eso.arn
}
