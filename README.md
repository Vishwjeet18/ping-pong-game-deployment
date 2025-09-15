# ping-pong-game-deployment

 **Load Balancer + Auto Scaling Group (ASG)** step by step in AWS.

---

# 🔹 Step 1: Launch Template (with your script)

1. Go to **EC2 Console** → **Launch Templates** → **Create launch template**.
2. Name: `pong-game-template`.
3. Choose Amazon Linux 2 AMI.
4. Instance type: `t2.micro` (free tier).
5. Key pair: (optional, if you want SSH access).
6. Security group: allow **HTTP (80)** and **SSH (22)**.
7. **Advanced details → User data** → paste your script:

```bash
#!/bin/bash
yum update -y
yum install httpd git -y

systemctl start httpd
systemctl enable httpd

usermod -a -G apache ec2-user
chmod 775 /var/www/html
chown -R ec2-user:apache /var/www/html

cd /var/www/html
git clone https://github.com/atulkamble/pong-game.git
mv pong-game/* .
rm -rf pong-game
```

8. Save the template.

---

# 🔹 Step 2: Create Target Group

1. Go to **EC2 → Load Balancing → Target Groups**.
2. Create target group:

   * Choose **Instances**.
   * Protocol: `HTTP` Port: `80`.
   * VPC: default.
   * Health check path: `/index.html`.
3. Create.

---

# 🔹 Step 3: Create Application Load Balancer (ALB)

1. Go to **Load Balancers → Create load balancer** → **Application Load Balancer**.
2. Name: `pong-game-alb`.
3. Scheme: Internet-facing.
4. IP type: IPv4.
5. Listeners: HTTP 80.
6. VPC: default.
7. Availability Zones: select at least **2 subnets**.
8. Security group: allow **HTTP (80)** inbound.
9. Register target group: select the one created earlier.
10. Create ALB.

---

# 🔹 Step 4: Create Auto Scaling Group

1. Go to **EC2 → Auto Scaling Groups → Create Auto Scaling group**.
2. Name: `pong-game-asg`.
3. Choose the **launch template** created earlier.
4. Choose the VPC + **2 subnets**.
5. Attach to load balancer: select **Attach to an existing load balancer target group** and choose your target group.
6. Group size:

   * Desired capacity: `2`
   * Minimum: `1`
   * Maximum: `3`
7. Scaling policies:

   * Choose **Target tracking scaling policy**.
   * Example: scale out if **CPU > 70%**.
8. Create ASG.

---

# 🔹 Step 5: Test the Setup

1. Open your **Load Balancer DNS name** (found in Load Balancers → Description).
   Example:

   ```
   http://pong-game-alb-1234567890.us-east-1.elb.amazonaws.com
   ```
2. You should see your **Ping Pong game** served by any instance.
3. Stop/terminate one instance → Auto Scaling will launch a new one automatically.
4. The Load Balancer will route traffic to healthy instances only.

---


**## 🔗 Pong Game Source
The game code is cloned automatically from:  
[atulkamble/pong-game](https://github.com/atulkamble/pong-game)**
