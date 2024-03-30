This Project will create applications in Private Instances within a VPC and using the Application loadbalancers the loads are evenly distributed across the applications in different servers thus reducing the load in one server!!!!  

Components Used:
A VPC
Two public Subnets for provisioning load balancer
Two private subnets for running applications in each
Two Elastic IPs for the NAT gateways for each Private Subnets
One Internet Gateway
4 Route Tables, 2 for each public subnets and 2 for each private subnet



![image](https://github.com/vijeshnair89/TerraformLoadBalancing/assets/143416086/43e265df-16ca-48aa-8e0d-b8db3c56e7fc)
