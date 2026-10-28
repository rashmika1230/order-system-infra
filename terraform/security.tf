# Remove all rules from the VPC's default security group so nothing can use it by accident
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project}-default-locked"
  }
}

# ---------- k3s node ----------

resource "aws_security_group" "node" {
  name        = "${var.project}-node"
  description = "k3s node: public web traffic and admin Kubernetes API access"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.project}-node-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "node_http" {
  security_group_id = aws_security_group.node.id
  description       = "HTTP to Traefik ingress"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "node_https" {
  security_group_id = aws_security_group.node.id
  description       = "HTTPS to Traefik ingress"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "node_kube_api" {
  security_group_id = aws_security_group.node.id
  description       = "Kubernetes API from the admin IP only"
  cidr_ipv4         = var.admin_cidr
  ip_protocol       = "tcp"
  from_port         = 6443
  to_port           = 6443
}

resource "aws_vpc_security_group_egress_rule" "node_all" {
  security_group_id = aws_security_group.node.id
  description       = "Outbound: install packages, pull images from ECR, reach RDS and SSM"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # all protocols and ports
}

# ---------- RDS ----------

resource "aws_security_group" "rds" {
  name        = "${var.project}-rds"
  description = "MySQL, reachable only from the k3s node"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.project}-rds-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "rds_from_node" {
  security_group_id            = aws_security_group.rds.id
  description                  = "MySQL from the k3s node only"
  referenced_security_group_id = aws_security_group.node.id
  ip_protocol                  = "tcp"
  from_port                    = 3306
  to_port                      = 3306
}
