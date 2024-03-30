This Project will create applications in Private Instances within a VPC and using the Application loadbalancers the loads are evenly distributed across the applications in different servers thus reducing the load in one server!!!!  

Components Used:
A VPC
Two public Subnets for provisioning load balancer
Two private subnets for running applications in each
Two Elastic IPs for the NAT gateways for each Private Subnets
One Internet Gateway
4 Route Tables, 2 for each public subnets and 2 for each private subnet
