Title: Why public google user content images return 403
Published: 01/09/2022
Tags:

 - google
 - oauth
---

When using Google as your OIDC provider you can ask for the `picture` claim which contains the user's profile picture. It's usually a url like this:

```
https://lh3.googleusercontent.com/erjNVzk6nPUaUZuOTg2ObT12EzWWIokbuRdyuTkxRGR1nXQ5vhYk34twIt05FmaBNt7_yB3J
```

I wanted to show the user profile in an `<img>` tag, but Google was responding with 403. I searched around for an answer and I stumbled upon [this stackoverflow answer](https://stackoverflow.com/a/61042200/7003797) which had the solution:

```
<img src="https://lh3.googleusercontent.com/erjNVzk6nPUaUZuOTg2ObT12EzWWIokbuRdyuTkxRGR1nXQ5vhYk34twIt05FmaBNt7_yB3J" referrerpolicy="no-referrer">
```

By setting the [`referrerpolicy`](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/img#attr-referrerpolicy) attribute to `no-referrer`, the browser will not send the `referrer` header and this seems to solve the issue.