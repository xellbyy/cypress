# 1. Дефект: публичный доступ к S3 bucket
resource "aws_s3_bucket" "test_bucket" {
  bucket = "iac-test-public-bucket-12345"
}

resource "aws_s3_bucket_public_access_block" "test_bucket_access" {
  bucket                  = aws_s3_bucket.test_bucket.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# 2. Дефект: нешифрованный S3 bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "test_encryption" {
  bucket = aws_s3_bucket.test_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# 3. Дефект: SSH открыт для всего интернета
resource "aws_security_group" "test_sg" {
  name        = "test-open-ssh"
  description = "Test security group"
  vpc_id      = "vpc-12345678"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 4. Дефект: открытый доступ к RDP
resource "aws_security_group" "test_rdp" {
  name        = "test-open-rdp"
  description = "Test RDP security group"
  vpc_id      = "vpc-12345678"

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 5. Дефект: публичный доступ к EC2 через публичный IP
resource "aws_instance" "test_instance" {
  ami                         = "ami-12345678"
  instance_type               = "t2.micro"
  associate_public_ip_address = true

  root_block_device {
    encrypted = false
  }
}
