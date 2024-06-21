variable "VPC_CIDR" {
    description = "value of VPC_CIDR"
    type = string
    default = "10.0.0.0/16"
}

variable "availability_zone" {
    description = "value of availability_zone"
    type = list(string)
    default = ["us-east-1a", "us-east-1b"]
}

variable "public_SN_cidr" {
  description = "value of cidr block for public subnets"
  type        = list(any)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}
variable "Public_SN_Tags" {
  description = "value of tags for public subnets" 
  type        = list(any)
  default     = ["Public_SN_1", "Public_SN_2"]
}

variable "Private_SN_cidr" {
  description = "value of cidr block for private subnets"
  type        = list(any)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}
variable "Private_SN_Tags" {
  description = "value of tags for private subnets" 
  type        = list(any)
  default     = ["Private_SN_1", "Private_SN_2"]
  
}

variable "ports" {
  description = "value of ingress"
  type        = list(number)
  default     = [80,443,22]
}

variable "instance_type" {
    description = "value of instance type"
  type        = string
  default     = "t2.micro"
}

variable "ami" {
    description = "value of ami"
  type        = string
  default     = "ami-0e001c9271cf7f3b9"
}

