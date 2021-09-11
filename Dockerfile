FROM amazonlinux:2

ARG AWS_ACCESS_KEY
ARG AWS_SECRET_ACCESS_KEY
ARG AWS_REGION

RUN mkdir /app

ADD . /app

RUN yum update -y && yum install -y initscripts;
RUN yum install -y awscli
RUN aws configure set profile.personal.aws_access_key_id $AWS_ACCESS_KEY && \
    aws configure set profile.personal.aws_secret_access_key $AWS_SECRET_ACCESS_KEY && \
    aws configure set profile.personal.region $AWS_REGION
RUN yum install -y python3
RUN pip3 install -r app/src/requirements.txt
RUN yum install -y wget && yum -y install unzip
RUN wget https://releases.hashicorp.com/terraform/1.0.6/terraform_1.0.6_linux_amd64.zip && \
    unzip terraform_1.0.6_linux_amd64.zip && \
    mv terraform /usr/local/bin/ && \
    rm -rf terraform_1.0.6_linux_amd64.zip

WORKDIR /app

CMD ["/usr/sbin/init"]