Title: Supporting Bi-directional text in Html TextArea
Published: 01/13/2022
Tags:
 - html
 - bidi
---

A `<textarea>` is an HTML element used to capture multiline user input. By default, it's direction is either `right to left` or `left to right`. But what if we want each paragraph to have it's own direction. This is very useful when the text is a mix of multiple languages. For example: Kurdish and English.

I asked the quesiton on Twitter and my good friend [Akam Foad](https://twitter.com/AkamFoad) came to the rescue:

<blockquote class="twitter-tweet"><p lang="en" dir="ltr">have you tested applying `unicode-bidi: plaintext` on textarea?<a href="https://t.co/UC8A0ZKYKj">https://t.co/UC8A0ZKYKj</a></p>&mdash; Akam Foad (@AkamFoad) <a href="https://twitter.com/AkamFoad/status/1481557755248918531?ref_src=twsrc%5Etfw">January 13, 2022</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

It turns out, that you can easily support this by specifying `unicode-bidi: plaintext` in the styles of the `<textarea>`

```html
<textarea style="unicode-bidi:plaintext"></textarea>
```

And this is the result:

<script async src="//jsfiddle.net/mhmd_azeez/egzpcovr/2/embed/html,result/"></script>

Without `unicode-bidi:plaintext`:

<script async src="//jsfiddle.net/mhmd_azeez/hmL9s6a7/embed/html,result/"></script>