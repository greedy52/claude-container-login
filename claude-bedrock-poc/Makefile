.PHONY: build assume test run help clean

IMAGE := claude-bedrock
ROLE_ARN := arn:aws:iam::123456789012:role/your-claude-bedrock-role

build:
	@echo "Building image..."
	docker build -t $(IMAGE) .
	@echo "✓ Done"

assume:
	@echo "Assuming role and generating .env file..."
	@aws sts assume-role \
		--role-arn $(ROLE_ARN) \
		--role-session-name claude-bedrock-session \
		--output json > /tmp/creds.json
	@jq -r '.Credentials | "AWS_ACCESS_KEY_ID=\(.AccessKeyId)\nAWS_SECRET_ACCESS_KEY=\(.SecretAccessKey)\nAWS_SESSION_TOKEN=\(.SessionToken)\nAWS_REGION=us-east-1"' /tmp/creds.json > .env
	@rm /tmp/creds.json
	@echo "✓ Credentials saved to .env"
	@echo "✓ Expires at: $$(jq -r '.Credentials.Expiration' /tmp/creds.json 2>/dev/null || echo 'Check AWS console')"
	@echo ""
	@echo "Run: make test"

test:
	@if [ ! -f .env ]; then \
		echo "Error: .env file not found"; \
		echo "Run: make assume"; \
		exit 1; \
	fi
	@echo "Testing AWS credentials..."
	@echo ""
	docker run --rm \
		--env-file .env \
		$(IMAGE) \
		aws sts get-caller-identity

run:
	@if [ ! -f .env ]; then \
		echo "Error: .env file not found"; \
		echo "Run: make assume"; \
		exit 1; \
	fi
	@echo "Starting Claude Code with Bedrock..."
	@echo ""
	docker run -it --rm \
		--env-file .env \
		-e CLAUDE_CODE_USE_BEDROCK=1 \
		-e CLAUDE_CODE_MAX_OUTPUT_TOKENS=4096 \
		-e MAX_THINKING_TOKENS=1024 \
		-v $(shell pwd)/workspace:/workspace \
		-v claude-bedrock-config:/root/.claude \
		$(IMAGE) \
		claude

clean:
	@echo "Cleaning up..."
	@docker volume rm claude-bedrock-config 2>/dev/null || true
	@echo "✓ Done"

help:
	@echo "Claude Code Docker - Amazon Bedrock"
	@echo ""
	@echo "Usage:"
	@echo "  1. make build              - Build image"
	@echo "  2. make assume             - Get role credentials"
	@echo "  3. export AWS_*            - Set credentials"
	@echo "  4. make test               - Test credentials"
	@echo "  5. make run                - Run Claude Code"
	@echo ""
	@echo "Quick workflow:"
	@echo "  make build"
	@echo '  eval "$$(make assume | tail -3 | sed '"'"'s/  //g'"'"')"'
	@echo "  make test"
	@echo "  make run"
