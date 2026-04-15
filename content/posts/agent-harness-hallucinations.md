---
title: "Agent Harness: How I keep my LLM honest"
date: 2026-04-14
slug: "agent-harness-hallucinations"
tags: ["agents", "ai"]
---

One of the biggest problems my customers kept hitting on [Message24](https://message24.net) was hallucination. A shopper asks about a product that doesn't exist; the LLM invents a price. Someone asks if an item is in stock; the LLM swears it is.

Some LLMs find it really hard to say "I don't know" (or in our case, escalate the conversation). LLMs are golden retrievers; they want to please, even if it costs them their honesty.

I tried the obvious fix first: threatening and begging. Every variation of "do not make things up" in the system prompt. The LLM nodded, agreed, and then made things up anyway. Prompt engineering gets you close, but it's a request, not a rule. For production, you need deterministic guardrails.

Here's what actually worked.

**1. Structured Function Calls (Tools)**

Instead of getting the LLM's response as free-form text, force it through a `reply` tool. This stops the agent from blurting out nonsense (like leaking its internal "thinking" tokens) or cutting its reply mid-sentence.

**2. Citations**

Citations cut our hallucination rate dramatically. For every claim the agent makes, it has to cite a source.

For every price the agent quotes, it has to tell us where the price came from: the Product Catalog or the Knowledge Base. We validate the citations where we can, and block the response if the claims don't check out.

We went one step further: a regex filter catches any price-like numbers that slipped through without a citation, and stops them from reaching the customer.

Here's how we show citations in the UI:
![Message24 shows the citations for each AI response](/assets/images/posts/agent-harness-hallucinations/citations.png)
