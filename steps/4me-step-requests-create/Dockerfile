FROM relaysh/core

RUN apk update && apk add ruby ruby-dev ruby-bundler && apk add --virtual build-dependencies build-base
RUN gem install '4me-sdk' json

COPY "./step.rb" "/step.rb"

ENTRYPOINT []
CMD ["ruby", "/step.rb"]

LABEL "org.opencontainers.image.title"="Create 4me request"
LABEL "org.opencontainers.image.description"="This task creates a 4me request."
LABEL "sh.relay.sdk.version"="v1"
