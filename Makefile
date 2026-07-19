.PHONY: status health

status:
	@echo "EaaSGrid Website Factory"
	@echo "Project Root: $$(pwd)"
	@echo "Status: initialized"

health:
	@./scripts/dev/day-01-product-initialization.sh
