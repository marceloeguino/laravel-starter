# Makefile for Jenkins Master + Agent

# Variables
AGENT_NAME=jenkins-agent-docker
MASTER_NAME=jenkins
MASTER_SCRIPT=./master.sh
AGENT_SCRIPT=./agent.sh

.PHONY: build start start-master start-agent stop logs clean

# Build the Jenkins agent image
build:
	@echo "Building Jenkins agent image..."
	docker build -t $(AGENT_NAME):latest .

# Start Jenkins master
start-master:
	@echo "Starting Jenkins master..."
	$(MASTER_SCRIPT)

# Start Jenkins agent (build first)
start-agent: build
	@echo "Starting Jenkins agent..."
	$(AGENT_SCRIPT)

# Start both master and agent
start: start-master start-agent
	@echo "Jenkins master and agent started."

# Stop both master and agent containers
stop:
	@echo "Stopping Jenkins services..."
	-docker stop $(MASTER_NAME) || true
	-docker rm $(MASTER_NAME) || true
	-docker stop $(AGENT_NAME) || true
	-docker rm $(AGENT_NAME) || true

# Restart both master and agent
restart: stop start
	@echo "Jenkins master and agent restarted."

# Tail logs for both master and agent
logs:
	@echo "Tailing logs for Jenkins master and agent..."
	-@docker logs -f $(MASTER_NAME) &
	-@docker logs -f $(AGENT_NAME)

# Clean up agent image
clean: stop
	@echo "Removing Jenkins agent image..."
	-docker rmi $(AGENT_NAME):latest
