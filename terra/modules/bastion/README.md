# Bastion Host Module — PyFleet

## Overview

The Bastion module provisions secure bastion hosts in the VPC to enable SSH access to private resources.  
It includes a security group restricted to a specified IP and supports multi-AZ deployment for high availability.

---

## What This Module Creates

### Security Group

- Allows SSH (port 22) only from the specified public IP (my_ip_cidr).  
- Allows all outbound traffic.  
- Tagged as `pyfleet-bastion-sg`.

### Bastion EC2 Instances

- Multi-AZ deployment across provided public subnets.  
- Latest Amazon Linux 2023 AMI by default (or a specified AMI).  
- Configurable instance type (default: `t2.micro`).  
- Associates public IP addresses for direct SSH access.  
- Tagged with `Name` and `Role` for identification.

---

## Inputs

| Variable           | Description                                                           |
|-------------------|-----------------------------------------------------------------------|
| `vpc_id`           | ID of the VPC where bastion hosts will be launched                    |
| `my_ip_cidr`       | Public IP in CIDR format allowed to SSH (e.g., 1.2.3.4/32)           |
| `ami`              | Optional AMI ID for bastion host (default uses latest Amazon Linux 2023) |
| `instance_type`    | EC2 instance type (default: `t2.micro`)                               |
| `key_name`         | SSH key name to access bastion hosts                                   |
| `public_subnet_ids`| List of public subnet IDs for multi-AZ deployment                     |

---

## Outputs

| Output                  | Description                             |
|-------------------------|-----------------------------------------|
| `bastion_instance_ids`  | List of EC2 instance IDs                 |
| `bastion_public_ips`    | Public IP addresses of bastion hosts    |
| `bastion_public_dns`    | Public DNS names of bastion hosts       |
| `bastion_sg_id`         | Security group ID for bastion hosts     |

---

## How It Works

### Security Group

- Restricts inbound SSH access to the IP provided in `my_ip_cidr`.  
- Allows all outbound traffic.

### EC2 Instances

- Launches in each public subnet specified for multi-AZ redundancy.  
- Assigns public IP addresses for SSH access.  
- Uses Amazon Linux 2023 by default.  

### Tagging & Identification

- Each instance is tagged as `Name=pyfleet-bastion-<index>` and `Role=bastion`.  
- Security group is tagged as `pyfleet-bastion-sg`.

---

## Usage Notes

- Bastion hosts act as jump boxes to connect to private instances (e.g., ASG EC2s) via SSH.  
- Use the provided public IPs or DNS names to log in.  
- Multi-AZ deployment ensures availability even if one subnet fails.  
- SSH key is the only access method to private EC2s; keep it secure.
