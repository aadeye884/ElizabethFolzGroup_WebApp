# Cloudwatch Dashboard
resource "aws_cloudwatch_dashboard" "ElizabethFolzGroup_web_dashboard" {
  dashboard_name = "ElizabethFolzGroup_Web_dashboard"
  dashboard_body = <<EOF
{
  "widgets": [
    {
      "type": "metric",
      "x": 0,
      "y": 0,
      "width": 12,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "AWS/EC2",
            "CPUUtilization",
            "InstanceId",
            "${aws_instance.ElizabethFolzGroup_WebApp.id}"
          ]
        ],
        "period": 300,
        "stat": "Average",
        "region": "us-east-1",
        "title": "EC2 Instance CPU"
      }
    },
    {
      "type": "metric",
      "x": 0,
      "y": 0,
      "width": 12,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "AWS/EC2",
            "NetworkIn",
            "InstanceId",
            "${aws_instance.ElizabethFolzGroup_WebApp.id}"
          ]
        ],
        "period": 300,
        "stat": "Average",
        "region": "us-east-1",
        "title": "EC2 Network In"
      }
    }
  ]
 }
EOF
}

#SNS Alarms Topic
resource "aws_sns_topic" "ElizabethFolzGroup_alarms_topic" {
  name            = "ElizabethFolzGroup_alarms_topic"
  delivery_policy = <<EOF
{
  "http": {
    "defaultHealthyRetryPolicy": {
      "minDelayTarget": 20,
      "maxDelayTarget": 20,
      "numRetries": 3,
      "numMaxDelayRetries": 0,
      "numNoDelayRetries": 0,
      "numMinDelayRetries": 0,
      "backoffFunction": "linear"
    },
    "disableSubscriptionOverrides": false,
    "defaultThrottlePolicy": {
      "maxReceivesPerSecond": 1
    }
  }
}
EOF
  provisioner "local-exec" {
    command = "aws sns subscribe --topic-arn arn:aws:sns:us-east-1:670390228985:ElizabethFolzGroup_alarms_topic --protocol email --notification-endpoint abiola.adeyemi86@gmail.com"
  }
}

# Cloudwatch metric alarm for CPU utilisation 
resource "aws_cloudwatch_metric_alarm" "ElizabethFolzGroup_Metric_Alarm" {
  alarm_name          = "ElizabethFolzGroup_Metric_Alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"
  dimensions = {
    AutoScalingGroupName = "${aws_autoscaling_group.ElizabethFolzGroup_asg.name}"
  }
  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.ElizabethFolzGroup_asg_pol.arn]
}

# Cloudwatch metric alarm for health
resource "aws_cloudwatch_metric_alarm" "ElizabethFolzGroup_metric_health_alarm" {
  alarm_name          = "ElizabethFolzGroup_health_metric"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "1"
  dimensions = {
    "AutoScalingGroupName" = "${aws_autoscaling_group.ElizabethFolzGroup_asg.name}"
  }
  alarm_description = "This metric monitors ec2 health status"
  alarm_actions     = ["${aws_autoscaling_policy.ElizabethFolzGroup_asg_pol.arn}"]
}