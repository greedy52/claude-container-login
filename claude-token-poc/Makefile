.PHONY: build run help setup

IMAGE := claude-token

build:
	@echo "Building image..."
	docker build -t $(IMAGE) .
	@echo "✓ Done"

setup:
	@echo "Getting OAuth token from host..."
	@echo ""
	@echo "Run this command to get your token:"
	@echo "  claude setup-token"
	@echo ""
	@echo "Then copy the token and run:"
	@echo "  export CLAUDE_CODE_OAUTH_TOKEN=<your-token>"
	@echo "  make run"

run:
	@if [ -z "$$CLAUDE_CODE_OAUTH_TOKEN" ]; then \
		echo "Error: CLAUDE_CODE_OAUTH_TOKEN not set"; \
		echo "Run: make setup"; \
		exit 1; \
	fi
	@echo "Starting Claude Code with token auth..."
	@echo ""
	docker run -it --rm \
		-e CLAUDE_CODE_OAUTH_TOKEN=$$CLAUDE_CODE_OAUTH_TOKEN \
		-v $(shell pwd)/workspace:/workspace \
		-v claude-token-config:/root/.claude \
		$(IMAGE) \
		claude

clean:
	@echo "Cleaning up..."
	@docker volume rm claude-token-config 2>/dev/null || true
	@echo "✓ Done"

help:
	@echo "Claude Code Docker - OAuth Token Auth"
	@echo ""
	@echo "This approach uses a pre-generated OAuth token instead of"
	@echo "launching a browser for authentication."
	@echo ""
	@echo "Usage:"
	@echo "  1. make build"
	@echo "  2. make setup     (follow instructions)"
	@echo "  3. make run"
	@echo ""
	@echo "Targets:"
	@echo "  build  - Build Docker image"
	@echo "  setup  - Show how to get your token"
	@echo "  run    - Run Claude Code with token"
	@echo "  clean  - Clean up volumes"
