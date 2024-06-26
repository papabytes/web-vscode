FROM gitpod/openvscode-server:1.87.1 as base

# whether to configure golang or not
ARG NODE_MAJOR=20
ARG GO_VERSION=1.22.1

USER root

# GOLANG Section
RUN wget https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz
RUN sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz
RUN echo "export PATH=$PATH:/usr/local/go/bin" > /home/workspace/.profile 
RUN echo "export PATH=$PATH:/usr/local/go/bin" >> /etc/profile
RUN rm go${GO_VERSION}.linux-amd64.tar.gz

# # NODEJS Section
RUN sudo apt-get update && sudo apt-get install -y ca-certificates curl gnupg
RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
RUN echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
RUN sudo apt-get update && sudo apt-get install nodejs -y

# ANGULAR SECTION
RUN npm install -g @angular/cli

# .NET SECTION
RUN sudo apt install dotnet-sdk-8.0 -y

FROM base as secure
ENTRYPOINT [ "/bin/sh", "-c", "exec /home/.openvscode-server/bin/openvscode-server --host 0.0.0.0" ]

FROM base as unsecure