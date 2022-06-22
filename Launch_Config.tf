# Create AMI for Web Serer
resource "aws_ami_from_instance" "ElizabethFolzGroup_ami" {
  name                    = "ElizabethFolzGroup_ami"
  source_instance_id      = aws_instance.ElizabethFolzGroup_WebApp.id
  snapshot_without_reboot = true
}

# Launch Configuration
resource "aws_launch_configuration" "ElizabethFolzGroup_lc" {
  name_prefix                 = "ElizabethFolzGrouplc"
  image_id                    = aws_ami_from_instance.ElizabethFolzGroup_ami.id
  instance_type               = var.instance_type
  iam_instance_profile        = aws_iam_instance_profile.EliabethFolzGroup_IAM_Profile.id
  security_groups             = [aws_security_group.ElizabethFolzGroup_Frontend_SG.id]
  associate_public_ip_address = true
  key_name                    = "EFG_Key"
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
touch indextest.html
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
  lifecycle {
    create_before_destroy = false
  }
}

# Autoscaling Group
resource "aws_autoscaling_group" "ElizabethFolzGroup_asg" {
  name                      = "ElizabethFolzGroup_asg"
  desired_capacity          = 3
  max_size                  = 3
  min_size                  = 2
  health_check_grace_period = 1800
  default_cooldown          = 60
  health_check_type         = "ELB"
  force_delete              = true
  launch_configuration      = aws_launch_configuration.ElizabethFolzGroup_lc.name
  vpc_zone_identifier       = [aws_subnet.ElizabethFolzGroup_Public_SN1.id, aws_subnet.ElizabethFolzGroup_Public_SN2.id]
  target_group_arns         = ["${aws_lb_target_group.elizabethfolzgroup-tg.arn}"]
  tag {
    key                 = "Name"
    value               = "ElizabethFolzGroup_asg"
    propagate_at_launch = true
  }
}
# Autoscaling Group Policy
resource "aws_autoscaling_policy" "ElizabethFolzGroup_asg_pol" {
  name                   = "ElizabethFolzGroup_asg_pol"
  policy_type            = "TargetTrackingScaling"
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = aws_autoscaling_group.ElizabethFolzGroup_asg.name
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 60.0
  }
}