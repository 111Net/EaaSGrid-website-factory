# EaaSGrid Website Factory Portability Rules

1. No hard-coded project paths.
2. No hard-coded IP addresses.
3. No cloud-specific logic in the core engine.
4. Environment configuration must be externalized.
5. Client websites must be independently portable.
6. Deployment must use adapters.
7. Storage must use adapters.
8. Database access must use configuration.
9. Automation scripts must be idempotent wherever possible.
10. Every automated task must validate its result.
11. Every development task must generate a report.
12. Destructive actions require explicit safeguards.
13. Existing work must not be silently overwritten.
14. Temporary test data must be separated from permanent data.
15. The application must be capable of moving to another compatible system.
