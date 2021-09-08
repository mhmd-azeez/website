Title: Beware of HTTP Redirects!
Published: 09/08/2021
Tags:
 - http
---

Today, I spent an hour debugging why an http call was getting 401 as a response. I was setting the Authorization header properly and the token was valid. This was the call I was making:

```csharp
var httpClient = new HttpClient();
httpClient.DefaultRequestHeaders.Authorization = 
    new AuthenticationHeaderValue("Bearer", "...");

var response = await httpClient.GetAsync("api/endpoint?parameter=true");
```

When I inspected the `Request` property of the `HttpResponse`, I saw that there was no `Authorization` header. It was the first clue. For some reason, somewhere in the http pipeline, the header was not being forwarded properly.

What made it worse was the fact that I was using a custom HttpMessageHandler to get and renew access tokens. So it made my debugging more difficult because I was thinking that there was a bug in the custom HttpMessageHandler.

After a few searches it lead me to [this stackoverflow answer](https://stackoverflow.com/a/68418735/7003797). It turned out, the API was redirecting the HTTP call. And when an HTTP call gets redirected, the `Authorization` header is removed as [explained by the official docs](https://docs.microsoft.com/en-us/dotnet/api/system.net.http.httpclienthandler.allowautoredirect?view=net-5.0#remarks). This behavior seems to be consistent with [curl](https://curl.se/).

After realizing the issue was because of redirection, I wanted to know where was the call being redirected to. So I disabled automatic redirection on the handler:

```csharp
var handler = new HttpClientHandler
{
    AllowAutoRedirect = false
};

var httpClient = new HttpClient(handler);
```

I inspected the `Location` header and it was redirecting the call to "api/endpoint/?parameter=true". Can you spot the difference with the original URL? Let me make it easier for you:

```
BAD:  api/endpoint?parameter=true
GOOD: api/endpoint/?parameter=true
```

This just makes me appreciate ASP.NET Core's router. It's much more forgiving and has sane defaults.