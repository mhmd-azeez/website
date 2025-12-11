---
title: "Claude Code from Your Phone"
date: 2025-12-11
slug: "claude-code-from-phone"
tags: ["ai", "workflow", "tailscale"]
---

I use [Claude Code](https://docs.anthropic.com/en/docs/claude-code) a lot. Sometimes I kick off a task on my machine, then want to check on it from my phone while I'm out (Why let the precious tokens expire, amirite?). Here's my setup for accessing the same Claude Code session from anywhere.

## The stack

- **tmux** - one session, attach from multiple devices at once
- **zsh** - nice autocomplete makes phone typing less painful
- **Tailscale** - VPN to access my machine from anywhere. Huge fan of Tailscale, I also use it for managing my personal servers
- **Termius** - SSH client on iOS/Android with a good keyboard

## tmux config

In `~/.tmux.conf`:

```bash
bind -n F5 detach
set-option -g default-shell /bin/zsh
```

Termius lets you add custom keys to the shortcut bar, so I added F5 there. One tap to detach when I'm done.

## zsh alias

In `~/.zshrc`:

```bash
alias tc='tmux attach -t claude || tmux new -s claude'
```

`tc` attaches to my claude session if it exists, or creates a new one. Same session name everywhere so I always land in the right place.

## The workflow

1. Start Claude Code on my desktop, give it a task
2. SSH in from my phone or laptop, type `tc`
3. I'm looking at the same session - same context, same conversation, live

I can have it open on my desktop and my phone at the same time. Both show the same thing. Type on either one.

From my laptop:

<video src="/assets/videos/tmux/tmux_laptop.webm" controls></video>

From my phone:

<video src="/assets/videos/tmux/tmux_phone.webm" controls></video>
