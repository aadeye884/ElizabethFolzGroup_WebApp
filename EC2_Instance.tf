# EC2 Instance
resource "aws_instance" "ElizabethFolzGroup_WebApp" {
  ami                         = var.ami
  instance_type               = var.instance_type
  vpc_security_group_ids      = [aws_security_group.ElizabethFolzGroup_Frontend_SG.id]
  subnet_id                   = aws_subnet.ElizabethFolzGroup_Public_SN1.id
  key_name                    = "EFG_Key"
  iam_instance_profile        = aws_iam_instance_profile.EliabethFolzGroup_IAM_Profile.id
  associate_public_ip_address = true
  user_data                   = <<-EOF
#!/bin/bash
sudo yum update -y
sudo yum upgrade -y
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo yum install unzip -y
unzip awscliv2.zip
sudo ./aws/install
sudo yum install httpd php php-mysqlnd -y
cd /var/www/html
echo "This is a test file" > indextest.html
sudo yum install wget -y
wget https://wordpress.org/wordpress-5.1.1.tar.gz
tar -xzf wordpress-5.1.1.tar.gz
cp -r wordpress/* /var/www/html/
rm -rf wordpress
rm -rf wordpress-5.1.1.tar.gz
chmod -R 755 wp-content
chown -R apache:apache wp-content
wget https://s3.amazonaws.com/bucketforwordpresslab-donotdelete/htaccess.txt
mv htaccess.txt .htaccess
cd /var/www/html && mv wp-config-sample.php wp-config.php
sed -i "s@define( 'DB_NAME', 'database_name_here' )@define( 'DB_NAME', 'elizabethfolzgroupdb' )@g" /var/www/html/wp-config.php
sed -i "s@define( 'DB_USER', 'username_here' )@define( 'DB_USER', 'admin' )@g" /var/www/html/wp-config.php
sed -i "s@define( 'DB_PASSWORD', 'password_here' )@define( 'DB_PASSWORD', 'Admin123' )@g" /var/www/html/wp-config.php
sed -i "s@define( 'DB_HOST', 'localhost' )@define( 'DB_HOST', '{aws_db_instance.elizabethfolzgroupdb.endpoint}')@g" /var/www/html/wp-config.php
cat <<EOT> /etc/httpd/conf/httpd.conf
ServerRoot "/etc/httpd"
Listen 80
Include conf.modules.d/*.conf
User apache
Group apache
ServerAdmin root@localhost
<Directory />
    AllowOverride none
    Require all denied
</Directory>
DocumentRoot "/var/www/html"
<Directory "/var/www">
    AllowOverride None
    # Allow open access:
    Require all granted
</Directory>
<Directory "/var/www/html">
    Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
</Directory>
<IfModule dir_module>
    DirectoryIndex index.html
</IfModule>
<Files ".ht*">
    Require all denied
</Files>
ErrorLog "logs/error_log"
LogLevel warn
<IfModule log_config_module>
    LogFormat "%h %l %u %t \"%r\" %>s %b \"%%{Referer}i\" \"%%{User-Agent}i\"" combined
    LogFormat "%h %l %u %t \"%r\" %>s %b" common
    <IfModule logio_module>
      LogFormat "%h %l %u %t \"%r\" %>s %b \"%%{Referer}i\" \"%%{User-Agent}i\" %I %O" combinedio
    </IfModule>
    CustomLog "logs/access_log" combined
</IfModule>
<IfModule alias_module>
    ScriptAlias /cgi-bin/ "/var/www/cgi-bin/"
</IfModule>
<Directory "/var/www/cgi-bin">
    AllowOverride None
    Options None
    Require all granted
</Directory>
<IfModule mime_module>
    TypesConfig /etc/mime.types
    AddType application/x-compress .Z
    AddType application/x-gzip .gz .tgz
    AddType text/html .shtml
    AddOutputFilter INCLUDES .shtml
</IfModule>
AddDefaultCharset UTF-8
<IfModule mime_magic_module>
        MIMEMagicFile conf/magic
</IfModule>
EnableSendfile on
IncludeOptional conf.d/*.conf
EOT
cat <<EOT> /var/www/html/.htaccess
Options +FollowSymlinks
RewriteEngine on
rewriterule ^wp-content/uploads/(.*)$ http://${data.aws_cloudfront_distribution.elizabethfolzgroup_cloudfront.domain_name}/\$1 [r=301,nc]
# BEGIN WordPress
# END WordPress
EOT
aws s3 cp --recursive /var/www/html/ s3://elizabethfolzgroup-code
aws s3 sync /var/www/html/ s3://elizabethfolzgroup-code
echo "* * * * * ec2-user /usr/local/bin/aws s3 sync --delete s3://elizabethfolzgroup-code /var/www/html/" > /etc/crontab
echo "* * * * * ec2-user /usr/local/bin/aws s3 sync /var/www/html/wp-content/uploads/ s3://elizabethfolzgroupmedia" >> /etc/crontab
sudo chkconfig httpd on
sudo service httpd start
sudo setenforce 0
  EOF
  tags = {
    Name = "ElizabethFolzGroup_WebApp"
  }
}

# Route 53 Hosted Zone
resource "aws_route53_zone" "elizabethfolzgroup_zone" {
  name          = "www.elizabethfolzgroup.com"
  force_destroy = true
}

# Route 53 A Record
resource "aws_route53_record" "ElizabethFolzGroup_Website" {
  zone_id = aws_route53_zone.elizabethfolzgroup_zone.zone_id
  name    = "www.elizabethfolzgroup.com"
  type    = "A"
  alias {
name = aws_lb.elizabethfolzgroup-elb.dns_name
zone_id = aws_lb.elizabethfolzgroup-elb.zone_id
evaluate_target_health = false
}
}

# Cloudfront Distribution Data
data "aws_cloudfront_distribution" "elizabethfolzgroup_cloudfront" {
 id= "${aws_cloudfront_distribution.elizabethfolzgroup_distribution.id}" 
}

#Cloudfront Distribution
locals {
  s3_origin_id = "aws_s3_bucket.elizabethfolzgroupmedia.id"
}

resource "aws_cloudfront_distribution" "elizabethfolzgroup_distribution" {
  origin {
    domain_name = aws_s3_bucket.elizabethfolzgroupmedia.bucket_regional_domain_name
    origin_id   = local.s3_origin_id
  }
  
  enabled            = true

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 600
  }

  price_class = "PriceClass_All"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

# Target Group
resource "aws_lb_target_group" "elizabethfolzgroup-tg" {
  name     = "elizabethfolzgroup-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.ElizabethFolzGroup_VPC.id
  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 10
    interval            = 90
    timeout             = 60
    path                = "/indextest.html"
  }
}

# Target Group Attachment
resource "aws_lb_target_group_attachment" "elizabethfolzgroup-tg-att" {
  target_group_arn = aws_lb_target_group.elizabethfolzgroup-tg.arn
  target_id        = aws_instance.ElizabethFolzGroup_WebApp.id
  port             = 80
}

# Elastic Load Balancer
resource "aws_lb" "elizabethfolzgroup-elb" {
  name                       = "elizabethfolzgroup-elb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.ElizabethFolzGroup_Frontend_SG.id]
  subnets                    = [aws_subnet.ElizabethFolzGroup_Public_SN1.id, aws_subnet.ElizabethFolzGroup_Public_SN2.id]
  enable_deletion_protection = false
  access_logs {
    bucket = "aws_s3_bucket.elizabethfolzgroup-elblogs"
    prefix = "elizabethfolzgroup"
  }
}

# Load Balancer Listerner
resource "aws_lb_listener" "elizabethfolzgroup-elb-listener" {
  load_balancer_arn = aws_lb.elizabethfolzgroup-elb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.elizabethfolzgroup-tg.arn
  }
}