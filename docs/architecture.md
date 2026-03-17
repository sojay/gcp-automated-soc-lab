# Architecture Overview

## Components

- **Honeypot VM** (`cowrie-1`, public subnet)
  - Cowrie listens on `22/tcp`
  - Real admin SSH listens on `2022/tcp`
- **Logging VM** (`logging-1`, tools/private subnet)
  - Loki (`3100`)
  - Grafana (`443` in this lab setup)
- **Promtail**
  - Runs on honeypot VM
  - Tails Cowrie JSON logs and pushes to Loki

## Primary Flows

1. Internet scanners attack `cowrie-1:22`
2. Cowrie writes events to JSON logs
3. Promtail enriches/parses and ships logs to `logging-1:3100`
4. Grafana queries Loki and renders attack dashboards
5. Admin reaches `cowrie-1:2022` from allowlisted IP

## Optional External Access

- Cloudflare Tunnel exposes Grafana using your domain:
  - `cloudflared` on `logging-1`
  - Public hostname -> `http://localhost:443`

## Network Guardrails

- `22/tcp` open only for honeypot traffic
- `2022/tcp` restricted to your IP (`/32`)
- Logging VM has no direct public SSH (IAP recommended)
