.PHONY: build server run run-claude clean help logs

IMAGE := claude-oauth
SOCKET := $(shell pwd)/browser.sock

build:
	@echo "Building image..."
	docker build -t $(IMAGE) .
	@echo "✓ Done"

server:
	@echo "Starting dynamic port forwarding server..."
	@./dynamic-port-server.sh

run:
	@if [ ! -S "$(SOCKET)" ]; then \
		echo "Warning: Start server first in another terminal:"; \
		echo "  make server"; \
		echo ""; \
	fi
	@echo "Starting container..."
	@echo "Socket: $(SOCKET)"
	docker run -it --rm \
		-p 8080:8080 \
		-v $(shell pwd)/workspace:/workspace \
		-v $(SOCKET):/tmp/browser.sock \
		-v claude-oauth-config:/root/.claude \
		$(IMAGE)

run-claude:
	@if [ ! -S "$(SOCKET)" ]; then \
		echo "Warning: Start server first in another terminal:"; \
		echo "  make server"; \
		echo ""; \
	fi
	@echo "Starting Claude Code..."
	@echo "Logs: make logs"
	@echo ""
	docker run -it --rm \
		-p 8080:8080 \
		-v $(shell pwd)/workspace:/workspace \
		-v $(SOCKET):/tmp/browser.sock \
		-v claude-oauth-config:/root/.claude \
		$(IMAGE) \
		bash -c "node /usr/local/bin/oauth-proxy.js & sleep 1 && claude"

logs:
	@echo "OAuth logs:"
	@tail -f workspace/oauth.log workspace/oauth-proxy.log 2>/dev/null || \
		(echo "No logs found yet" && sleep 1 && tail -f workspace/oauth.log workspace/oauth-proxy.log 2>/dev/null)

clean:
	@echo "Cleaning up..."
	@rm -f $(SOCKET)
	@pkill -f "socat.*TCP-LISTEN.*localhost:8080" 2>/dev/null || true
	@docker volume rm claude-oauth-config 2>/dev/null || true
	@echo "✓ Done"

help:
	@echo "Claude Code Docker OAuth POC - Dynamic Port Forwarding"
	@echo ""
	@echo "How it works:"
	@echo "  1. Container detects Claude's OAuth port (e.g., 34567)"
	@echo "  2. Tells host to open that port → forwards to container:8080"
	@echo "  3. Browser opens with original URL (localhost:34567)"
	@echo "  4. Callback works! No port range needed."
	@echo ""
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  build       - Build Docker image"
	@echo "  server      - Start dynamic port server (Terminal 1)"
	@echo "  run         - Run container with bash shell"
	@echo "  run-claude  - Run container with OAuth proxy and claude"
	@echo "  logs        - Watch OAuth logs (workspace/oauth*.log)"
	@echo "  clean       - Clean up sockets, ports, and volumes"
	@echo ""
	@echo "Quick start:"
	@echo "  Terminal 1: make server"
	@echo "  Terminal 2: make run-claude"
	@echo "  Terminal 3: make logs (optional)"
