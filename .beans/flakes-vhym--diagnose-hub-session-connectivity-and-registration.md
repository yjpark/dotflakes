---
# flakes-vhym
title: Diagnose hub session connectivity and registration
status: in-progress
type: feature
created_at: 2026-11-27T15:41:59Z
updated_at: 2026-11-27T15:41:59Z
---

Add structured, timestamped diagnostics for listener/auth, peer registration freshness, target registration, and callback responsiveness. Use an authenticated DiagnosticsApi and side-effect-free SessionService.ping with unsupported capability handling. Expose the same report through session_probe MCP and kudo-shim doctor. Keep mailbox admission, persistent history, console UI, OpenTelemetry, and automatic remediation out of the first slice. Done when stale peer, unknown session, disconnect, timeout, capability, and redaction tests pass and a live pc/edger probe identifies the failing stage.
