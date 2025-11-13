---
title: "Comparing PlanetScale PostgreSQL with Hetzner Local Postgres"
published: 11/13/2025
tags:
  - postgresql
  - benchmarking
  - planetscale
  - hetzner
---

PlanetScale’s new $5 single-node PostgreSQL tier (PS-5) promises the same observability/maintenance story you get from their Vitess-backed MySQL side. I wanted to see how it feels next to the very boring Postgres instance I already pay for: a Hetzner CPX11 (2 vCPU / 2 GB RAM for €3.85) running in their eu-central region (Nuremberg). This isn’t even LAN vs internet—it’s literally local disk vs a remote region—so the goal is to get a sanity check, not crown a winner.

I pointed the usual pgbench mix at PlanetScale’s x64 PS-5, PS-10, PS-20, PS-40, PS-80, and PS-160 plans. I asked for eu-central-1 to keep everything close to the Hetzner VPS, but PlanetScale split the replicas across eu-central-1 and eu-central-2, so we roll with what they provisioned. Each plan got hit via the direct endpoint and via PgBouncer. The Hetzner box got the same treatment so we can see how much pooling narrows the gap. Everything lives in [mhmd-azeez/hetzner_vs_planetscale](https://github.com/mhmd-azeez/hetzner_vs_planetscale) if you want to re-run or tweak the tests.

## Direct connections

First pass: raw connections, no pooling tricks, single region hops only.

### TPS (transactions/second)

| concurrency | local | ps5 | ps10 | ps20 | ps40 | ps80 | ps160 |
| ----------- | ----- | ---------- | ----------- | ----------- | ----------- | ----------- | ------------ |
| 1 | 406.97 | 29.43 | 24.70 | 24.67 | 23.59 | 28.50 | 24.11 |
| 10 | 2,445.69 | 256.03 | 261.99 | 278.28 | 257.12 | 268.42 | 272.31 |
| 50 | 2,487.99 | - | - | - | - | - | 1,245.58 |

<div class="chart-card chart-card--inline" data-chart="direct-tps">
  <div class="chart-card__title">Direct connection TPS</div>
  <div class="chart-card__subtitle">Higher is better — hover to inspect each plan</div>
  <canvas id="chart-direct-tps" role="img" aria-label="Line chart comparing direct connection TPS across plans"></canvas>
</div>

### Latency (ms)

| concurrency | local | ps5 | ps10 | ps20 | ps40 | ps80 | ps160 |
| ----------- | ----- | ---------- | ----------- | ----------- | ----------- | ----------- | ------------ |
| 1 | 2.46 | 33.98 | 40.49 | 40.53 | 42.38 | 35.09 | 41.48 |
| 10 | 4.09 | 39.06 | 38.17 | 35.93 | 38.89 | 37.26 | 36.72 |
| 50 | 20.10 | - | - | - | - | - | 40.14 |

<div class="chart-card chart-card--inline" data-chart="direct-latency">
  <div class="chart-card__title">Direct connection latency</div>
  <div class="chart-card__subtitle">Lower is better — median latency in milliseconds</div>
  <canvas id="chart-direct-latency" role="img" aria-label="Line chart comparing direct connection latency across plans"></canvas>
</div>

## PgBouncer

Next pass: slap PgBouncer in front of everything and see how far we can push concurrency before the network becomes the wall.

### TPS

| concurrency | local | ps5 | ps10 | ps20 | ps40 | ps80 | ps160 |
| ----------- | --------------- | ------------- | -------------- | -------------- | -------------- | -------------- | --------------- |
| 1 | 275.29 | 23.50 | 26.13 | 22.61 | 24.53 | 27.17 | 21.72 |
| 10 | 1,645.86 | 256.16 | 264.75 | 253.11 | 259.09 | 260.90 | 265.06 |
| 50 | 1,676.38 | 397.54 | 458.44 | 479.10 | 477.70 | 1,204.07 | 1,207.27 |
| 100 | 1,719.79 | 396.29 | 464.93 | 485.40 | 473.24 | 1,200.39 | 2,137.35 |
| 200 | 1,712.10 | 397.50 | 460.53 | 481.65 | 474.73 | 1,196.91 | 2,165.73 |
| 400 | 1,693.84 | 398.24 | 465.79 | 477.23 | 471.96 | - | - |

<div class="chart-card chart-card--inline" data-chart="pgbouncer-tps">
  <div class="chart-card__title">PgBouncer TPS</div>
  <div class="chart-card__subtitle">Higher is better — how pooling scales past 400 concurrent clients</div>
  <canvas id="chart-pgbouncer-tps" role="img" aria-label="Line chart comparing PgBouncer TPS across plans"></canvas>
</div>

### Latency (ms)

| concurrency | local | ps5 | ps10 | ps20 | ps40 | ps80 | ps160 |
| ----------- | --------------- | ------------- | -------------- | -------------- | -------------- | -------------- | --------------- |
| 1 | 3.63 | 42.56 | 38.27 | 44.22 | 40.77 | 36.81 | 46.05 |
| 10 | 6.08 | 39.04 | 37.77 | 39.51 | 38.60 | 38.33 | 37.73 |
| 50 | 29.83 | 125.77 | 109.07 | 104.36 | 104.67 | 41.53 | 41.42 |
| 100 | 58.15 | 252.34 | 215.09 | 206.02 | 211.31 | 83.31 | 46.79 |
| 200 | 116.82 | 503.15 | 434.28 | 415.24 | 421.29 | 167.10 | 92.35 |
| 400 | 236.15 | 1,004.42 | 858.76 | 838.18 | 847.53 | - | - |

<div class="chart-card chart-card--inline" data-chart="pgbouncer-latency">
  <div class="chart-card__title">PgBouncer latency</div>
  <div class="chart-card__subtitle">Lower is better — watch how the network hop compounds the tail</div>
  <canvas id="chart-pgbouncer-latency" role="img" aria-label="Line chart comparing PgBouncer latency across plans"></canvas>
</div>

<script>
  (function () {
    const chartConfigs = {
      'direct-tps': {
        yLabel: 'Transactions per second',
        unit: 'TPS',
        labels: [1, 10, 50],
        data: [
          { label: 'Local (Hetzner CPX11)', points: [406.97, 2445.69, 2487.99] },
          { label: 'PS-5', points: [29.43, 256.03, null] },
          { label: 'PS-10', points: [24.70, 261.99, null] },
          { label: 'PS-20', points: [24.67, 278.28, null] },
          { label: 'PS-40', points: [23.59, 257.12, null] },
          { label: 'PS-80', points: [28.50, 268.42, null] },
          { label: 'PS-160', points: [24.11, 272.31, 1245.58] },
        ],
      },
      'direct-latency': {
        yLabel: 'Latency (ms)',
        unit: 'ms',
        labels: [1, 10, 50],
        data: [
          { label: 'Local (Hetzner CPX11)', points: [2.46, 4.09, 20.10] },
          { label: 'PS-5', points: [33.98, 39.06, null] },
          { label: 'PS-10', points: [40.49, 38.17, null] },
          { label: 'PS-20', points: [40.53, 35.93, null] },
          { label: 'PS-40', points: [42.38, 38.89, null] },
          { label: 'PS-80', points: [35.09, 37.26, null] },
          { label: 'PS-160', points: [41.48, 36.72, 40.14] },
        ],
      },
      'pgbouncer-tps': {
        yLabel: 'Transactions per second',
        unit: 'TPS',
        labels: [1, 10, 50, 100, 200, 400],
        data: [
          { label: 'Local (Hetzner CPX11)', points: [275.29, 1645.86, 1676.38, 1719.79, 1712.10, 1693.84] },
          { label: 'PS-5', points: [23.50, 256.16, 397.54, 396.29, 397.50, 398.24] },
          { label: 'PS-10', points: [26.13, 264.75, 458.44, 464.93, 460.53, 465.79] },
          { label: 'PS-20', points: [22.61, 253.11, 479.10, 485.40, 481.65, 477.23] },
          { label: 'PS-40', points: [24.53, 259.09, 477.70, 473.24, 474.73, 471.96] },
          { label: 'PS-80', points: [27.17, 260.90, 1204.07, 1200.39, 1196.91, null] },
          { label: 'PS-160', points: [21.72, 265.06, 1207.27, 2137.35, 2165.73, null] },
        ],
      },
      'pgbouncer-latency': {
        yLabel: 'Latency (ms)',
        unit: 'ms',
        labels: [1, 10, 50, 100, 200, 400],
        data: [
          { label: 'Local (Hetzner CPX11)', points: [3.63, 6.08, 29.83, 58.15, 116.82, 236.15] },
          { label: 'PS-5', points: [42.56, 39.04, 125.77, 252.34, 503.15, 1004.42] },
          { label: 'PS-10', points: [38.27, 37.77, 109.07, 215.09, 434.28, 858.76] },
          { label: 'PS-20', points: [44.22, 39.51, 104.36, 206.02, 415.24, 838.18] },
          { label: 'PS-40', points: [40.77, 38.60, 104.67, 211.31, 421.29, 847.53] },
          { label: 'PS-80', points: [36.81, 38.33, 41.53, 83.31, 167.10, null] },
          { label: 'PS-160', points: [46.05, 37.73, 41.42, 46.79, 92.35, null] },
        ],
      },
    };

    const palette = [
      '#2563EB', '#D946EF', '#F97316', '#10B981', '#F59E0B', '#9333EA', '#0891B2',
      '#DC2626', '#0EA5E9', '#7C3AED'
    ];
    const mobileQuery = window.matchMedia('(max-width: 600px)');

    const formatValue = (value, unit) => {
      if (value === null || value === undefined || Number.isNaN(value)) {
        return 'N/A';
      }
      return `${Number(value).toLocaleString('en-US', { maximumFractionDigits: 2 })}${unit ? ` ${unit}` : ''}`;
    };

    const initCharts = () => {
      if (typeof window.Chart === 'undefined') {
        window.requestAnimationFrame(initCharts);
        return;
      }

      Object.entries(chartConfigs).forEach(([key, config]) => {
        const container = document.querySelector(`[data-chart="${key}"]`);
        if (!container) {
          return;
        }
        const canvas = container.querySelector('canvas');
        if (!canvas) {
          return;
        }
        canvas.height = mobileQuery.matches ? 240 : 320;

        const datasets = config.data.map((series, index) => ({
          label: series.label,
          data: series.points,
          borderColor: palette[index % palette.length],
          backgroundColor: palette[index % palette.length],
          borderWidth: 2,
          pointRadius: 3,
          pointHoverRadius: 5,
          tension: 0.25,
          spanGaps: true,
        }));

        const context = canvas.getContext('2d', { willReadFrequently: true });
        const chart = new Chart(context, {
          type: 'line',
          data: {
            labels: config.labels,
            datasets,
          },
          options: {
            responsive: true,
            maintainAspectRatio: false,
            interaction: {
              intersect: false,
              mode: 'nearest',
            },
            scales: {
              x: {
                title: {
                  display: true,
                  text: 'Concurrency',
                },
                ticks: {
                  precision: 0,
                },
                grid: {
                  color: 'rgba(148, 163, 184, 0.25)',
                },
              },
              y: {
                title: {
                  display: true,
                  text: config.yLabel,
                },
                grid: {
                  color: 'rgba(148, 163, 184, 0.2)',
                },
              },
            },
            plugins: {
              legend: {
                display: true,
                position: 'bottom',
              },
              tooltip: {
                callbacks: {
                  label: (ctx) => {
                    const value = ctx.parsed.y ?? null;
                    return `${ctx.dataset.label}: ${formatValue(value, config.unit)}`;
                  },
                },
              },
            },
          },
        });

      });
    };

    if (document.readyState === 'loading') {
      document.addEventListener('DOMContentLoaded', initCharts);
    } else {
      initCharts();
    }
  })();
</script>

## Takeaways

- Latency is the tax: even PS-160 stays ~10× slower on single-connection round trips because physics wins.
- Pooling earns its keep: once PgBouncer gets involved, PS-160 eventually outruns the local box at extreme concurrency simply because it can hold more connections open at once.
- Small plans hit ceilings fast: PS-5/10/20 tap out before the 50-connection mark, so plan accordingly if you expect chatty workloads.
- You still pay for the managed bits: backups, maintenance, branches, and observability are the real pitch for PlanetScale; Hetzner only wins if you’re happy being your own DBA.
