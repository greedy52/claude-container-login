.PHONY: build start stop ssh test help

IMAGE := claude-ssh
CONTAINER := claude-ssh-container

build:
	@echo "Building SSH-enabled Claude Code container..."
	docker build -t $(IMAGE) .
	@echo "✓ Done"

setup-key:
	@if [ ! -f ssh_key ]; then \
		echo "Generating SSH key pair..."; \
		ssh-keygen -t ed25519 -f ssh_key -N "" -C "claude-ssh-poc"; \
		echo "✓ SSH key generated: ssh_key, ssh_key.pub"; \
	else \
		echo "✓ SSH key already exists"; \
	fi

start: setup-key
	@echo "Starting container with SSH daemon..."
	@mkdir -p browser-requests
	@docker run -d --rm \
		--name $(CONTAINER) \
		-p 2222:2222 \
		-v $(shell pwd)/ssh_key.pub:/root/.ssh/authorized_keys:ro \
		-v $(shell pwd)/workspace:/workspace \
		-v $(shell pwd)/browser-requests:/browser-requests \
		-v claude-ssh-config:/root/.claude \
		$(IMAGE)
	@sleep 2
	@echo "✓ Container started"
	@echo ""
	@echo "SSH access: ssh -i ssh_key -p 2222 root@localhost"

stop:
	@echo "Stopping container..."
	@docker stop $(CONTAINER) 2>/dev/null || true
	@echo "✓ Done"

ssh:
	@echo "Starting host listener in background..."
	@./host-listener.sh localhost 2222 root ssh_key > /tmp/host-listener.log 2>&1 & \
	echo $$! > /tmp/host-listener.pid
	@sleep 1
	@echo "✓ Host listener started (PID: $$(cat /tmp/host-listener.pid))"
	@echo "Connecting to container via SSH..."
	@echo ""
	@ssh -i ssh_key -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p 2222 root@localhost; \
	EXIT_CODE=$$?; \
	echo ""; \
	echo "Stopping host listener..."; \
	kill $$(cat /tmp/host-listener.pid) 2>/dev/null || true; \
	rm -f /tmp/host-listener.pid; \
	echo "✓ Host listener stopped"; \
	exit $$EXIT_CODE

test:
	@echo "Testing browser wrapper..."
	@echo ""
	@echo "This will:"
	@echo "1. Send escape sequence from container"
	@echo "2. You manually trigger port forward"
	@echo "3. Browser opens"
	@echo ""
	@ssh -i ssh_key -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p 2222 root@localhost \
		'export BROWSER=/usr/local/bin/browser-wrapper && /usr/local/bin/browser-wrapper "http://localhost:34567/test"'

logs:
	@docker logs -f $(CONTAINER)

clean:
	@echo "Cleaning up..."
	@docker stop $(CONTAINER) 2>/dev/null || true
	@docker volume rm claude-ssh-config 2>/dev/null || true
	@echo "✓ Done"

help:
	@echo "Claude Code SSH POC - OAuth via SSH Port Forwarding"
	@echo ""
	@echo "How it works:"
	@echo "  1. Container runs SSH daemon + Claude Code"
	@echo "  2. Browser wrapper sends escape sequence"
	@echo "  3. Host script creates SSH port forward"
	@echo "  4. Browser opens, OAuth callback works"
	@echo ""
	@echo "Usage:"
	@echo "  make build              - Build container"
	@echo "  make start              - Start container"
	@echo "  make ssh                - SSH into container"
	@echo "  make test               - Test browser wrapper"
	@echo "  make stop               - Stop container"
	@echo ""
	@echo "Full workflow:"
	@echo "  1. make build && make start"
	@echo "  2. make ssh"
	@echo "     Inside: export BROWSER=/usr/local/bin/browser-wrapper"
	@echo "     Inside: claude"
	@echo "  3. When OAuth starts, manually run port forward"
