FROM alpine:3.4

# libxml2-utils required for xmllintsubl .

#RUN apk add --no-cache wget curl tar bash jq libxml2-utils
RUN apk add --no-cache wget curl tar bash 

COPY jq-linux64 /bin
RUN ln -s /bin/jq-linux64 /bin/jq

ADD assets/ /opt/resource/
ADD test/ /opt/resource-tests/

# Run tests 
RUN /opt/resource-tests/test-check.sh
#RUN /opt/resource-tests/test-in.sh
#RUN /opt/resource-tests/test-out.sh
