Title: Why you should read on topics that you might not need right now?
Published: 05/23/2019
Tags:

 - career
---

I was browsing web once when I stumbled upon an article about [SkiaSharp](https://github.com/mono/SkiaSharp). It's a C# wrapper around Google's fast 2D rending engine. I was developing desktop apps in WPF at the time and didn't feel the need to learn a low level library like that.

A few weeks later, I found myself in a project that required building a fast layout designer. First, I tried to write it purely in WPF, and I did. It was super slow, on a decently fast computer, it took a few seconds to load a layout.

Then I remembered SkiaSharp. I headed over to its documentation and it seemed easy enough for me to use it. I rewrote the layout engine in SkiaSharp and It was blazing fast. You could have loaded a layout many times in one second and you still wouldn't feel any delay.

So when you see an article about something interesting, even if it's not directly related to what you work on right now, read it. At least skim it. That way when you do need it, you'll at least have a name to google.

I feel like software engineering is not about memorizing every algorithm and data structure out there, but it's about knowing about the right tools for the right problems.