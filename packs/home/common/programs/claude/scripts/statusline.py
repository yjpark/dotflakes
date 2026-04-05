#!/usr/bin/env python3
import json, sys, subprocess, os

TOKEN_LIMIT = 5_000_000  # Pro plan 5-hour token limit

data = json.load(sys.stdin)
model = data['model']['display_name']
directory = os.path.basename(data['workspace']['current_dir'])
cost = data.get('cost', {}).get('total_cost_usd', 0) or 0
pct = int(data.get('context_window', {}).get('used_percentage', 0) or 0)
duration_ms = data.get('cost', {}).get('total_duration_ms', 0) or 0
ctx = data.get('context_window', {})
total_in = ctx.get('total_input_tokens', 0) or 0
total_out = ctx.get('total_output_tokens', 0) or 0
total_tokens = total_in + total_out

CYAN, GREEN, YELLOW, RED, RESET = '\033[36m', '\033[32m', '\033[33m', '\033[31m', '\033[0m'

bar_color = RED if pct >= 90 else YELLOW if pct >= 70 else GREEN
filled = pct // 10
bar = '█' * filled + '░' * (10 - filled)

token_pct = min(int(total_tokens / TOKEN_LIMIT * 100), 100) if TOKEN_LIMIT else 0
token_color = RED if token_pct >= 90 else YELLOW if token_pct >= 70 else GREEN
token_filled = min(token_pct // 10, 10)
token_bar = '█' * token_filled + '░' * (10 - token_filled)

def fmt_tokens(n):
    if n >= 1_000_000:
        return f"{n / 1_000_000:.1f}M"
    if n >= 1_000:
        return f"{n / 1_000:.0f}K"
    return str(n)

mins, secs = duration_ms // 60000, (duration_ms % 60000) // 1000

try:
    branch = subprocess.check_output(['git', 'branch', '--show-current'], text=True, stderr=subprocess.DEVNULL).strip()
    branch = f" | 🌿 {branch}" if branch else ""
except:
    branch = ""

print(f"{CYAN}[{model}]{RESET} 📁 {directory}{branch}")
print(f"{bar_color}{bar}{RESET} {pct}% | {token_color}{token_bar}{RESET} {fmt_tokens(total_tokens)}/{fmt_tokens(TOKEN_LIMIT)} | {YELLOW}${cost:.2f}{RESET} | ⏱️ {mins}m {secs}s")
