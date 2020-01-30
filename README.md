#Steps for AMI Linux Instance setup
1. Install Docker using
	sudo yum update -y
	apt install docker.io
	sudo service docker start
	sudo usermod -a -G docker ec2-user
2. Pull Docker image : 
	sudo docker pull nikhilsqb/webpagetest:webpagetest
3. Build Docker using following command
	docker build -t webpagetest .
4. sudo modprobe ifb numifbs=1
5. Run docker using following command
	sudo docker run -d -p 4000:99 -e SERVER_URL="http://127.0.0.1:99/work/" -e LOCATION="us-east-1_wptdriver" -e NAME="Docker Test" --cap-add=NET_ADMIN  nikhilsqb/webpagetest:webpagetest
6. Open webpage test using ip 
	http://instance_ip:4000/

# Please refer https://github.com/WPO-Foundation/webpagetest to get details about webpagetest and https://github.com/WPO-Foundation/wptagent for wptagent