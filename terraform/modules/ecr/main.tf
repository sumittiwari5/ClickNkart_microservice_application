# One repository per service, not one shared repo - this mirrors "every
# microservice is independently deployable": each service's images,
# tags, and vulnerability scan results stay separate, so a scan finding
# in catalog-service's image doesn't get mixed up with order-service's.
resource "aws_ecr_repository" "services" {
  for_each             = toset(var.services)
  name                 = "${var.project_name}/${each.value}"
  image_tag_mutability = "IMMUTABLE" # once a tag like "1.2.0-build45" is pushed, it can NEVER be overwritten - this is what makes a version tag actually trustworthy for rollback

  image_scanning_configuration {
    scan_on_push = true # every image is scanned for known CVEs the moment it's pushed, not on some later schedule
  }
}

# Lifecycle policy: without this, every single build (including ones from
# your very first day of testing) sits in ECR forever, costing storage.
# This keeps the last 15 images per service and expires the rest - plenty
# of history for rollback, without unbounded growth.
resource "aws_ecr_lifecycle_policy" "services" {
  for_each   = aws_ecr_repository.services
  repository = each.value.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last 15 images, expire the rest"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 15
      }
      action = { type = "expire" }
    }]
  })
}