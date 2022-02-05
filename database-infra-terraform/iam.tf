################################# IAM Role for DB Agent with Required Permissions #######################
#############################################################################################################

resource "aws_iam_role" "db_agent_role" {
  name               = "db-agent-ec2-iam-role"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "get_ssm" {
  name_prefix = "db_agent_get_ssm"
  role        = aws_iam_role.db_agent_role.name
  policy      = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ssm:GetParameter",
                "ssm:GetParameters",
                "ssm:GetParametersHistory",
                "ssm:GetParametersByPath"
            ],
            "Resource": "arn:aws:ssm:*:${data.aws_caller_identity.current.account_id}:*"
        }
    ]
  }
  EOF
}

resource "aws_iam_role_policy" "get_s3_object" {
  name_prefix = "db_agent_get_s3_object"
  role        = aws_iam_role.db_agent_role.name
  policy      = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject"
            ],
            "Resource": "arn:aws:s3:::${aws_s3_bucket.db.id}/rates.sql"
        }
    ]
  }
  EOF
}

resource "aws_iam_role_policy_attachment" "db_agent_policy" {
  role       = aws_iam_role.db_agent_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "db_agent_iam_profile" {
  name = "db-agent-ec2-iam-profile"
  role = aws_iam_role.db_agent_role.name
}