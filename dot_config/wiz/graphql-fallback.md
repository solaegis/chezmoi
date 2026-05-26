# Wiz GraphQL fallback (no MCP container)

If Docker cannot pull the Wiz MCP image (AWS Marketplace subscription required), use a service account instead:

1. **Settings → Access Management → Service Accounts** → **Custom Integration (GraphQL API)**
2. Scopes: `read:issues`, `read:inventory`, `read:vulnerabilities`, `read:projects`
3. Export issues via [Wiz API](https://docs.wiz.io/wiz-docs/docs/using-the-wiz-api) or UI reports → analyze in Cursor Agent on the files

MCP integration credentials in `mcp.env` are separate from GraphQL service accounts.
