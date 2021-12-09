Title: Testing Email Templates in ASP.NET Core
Published: 12/9/2021
Tags:

 - aspnet
 - email
 - testing
---

Many systems require sending emails to notify users. And testing these notifications manually is a pain. So it's one of the best use cases for integration testing. First, let's create strongly typed model for our `Welcome` email:

```cs
public class Welcome
{
    public string FullName { get; set; }
}
```

And we create a Razor template for the email in `EmailTemplates/Welcome.cshtml`:

```html
@model EmailSnapshotTesting.EmailTemplates.Welcome
@{
    Layout = "~/EmailTemplates/_Layout.cshtml";
}

<h1>Welcome @Model.FullName</h1>
<p>Welcome to our wonderful service!</p>
```

And this is how the layout is going to look like in `EmaiTemplates/_Layout.cshtml`:

```html
<!DOCTYPE html>

<html>
<head>
    <meta name="viewport" content="width=device-width" />
</head>
<body>
    <div>
        @RenderBody()
    </div>
</body>
</html>
```

And then we create a service to send emails:

```cs
public class MailerService : IMailerService
{
    private readonly IEmailRenderer _renderer;
    private readonly IMailPostman _postman;

    public MailerService(
        IEmailRenderer renderer,
        IMailPostman postman)
    {
        _renderer = renderer;
        _postman = postman;
    }

    public async Task SendWelcomeEmail(string address, Welcome welcome)
    {
        await SendEmail($"Welcome {welcome.FullName}!", address, welcome);
    }

    public async Task SendEmail<T>(string subject, string address, T model)
    {
        var html = await _renderer.Render(model);

        await _postman.SendEmail(new Message
        {
            Subject = subject,
            Address = address,
            HtmlBody = html
        });
    }
}
```

The `MailerService` needs an `IEmailRenderer` to get HTML content from the strongly typed model and an `IMailPostman` to send the emails.

Here is an implementation of `IEmailRenderer` that renders the Razor template we specified above:

```cs
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Abstractions;
using Microsoft.AspNetCore.Mvc.ModelBinding;
using Microsoft.AspNetCore.Mvc.Razor;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.AspNetCore.Mvc.ViewFeatures;

namespace EmailSnapshotTesting.Services;

// https://stackoverflow.com/a/49275145
// https://ppolyzos.com/2016/09/09/asp-net-core-render-view-to-string/

public class RazorEmailRenderer : IEmailRenderer
{
    private readonly IRazorViewEngine _razorViewEngine;
    private readonly ITempDataProvider _tempDataProvider;
    private readonly IServiceProvider _serviceProvider;

    public RazorEmailRenderer(
        IRazorViewEngine razorViewEngine,
        ITempDataProvider tempDataProvider,
        IServiceProvider serviceProvider)
    {
        _razorViewEngine = razorViewEngine;
        _tempDataProvider = tempDataProvider;
        _serviceProvider = serviceProvider;
    }

    public async Task<string> Render<T>(T model)
    {
        // Note: You can also support multiple languages by separating each locale into a folder
        var viewPath = $"~/EmailTemplates/{typeof(T).Name}.cshtml";
        var result = _razorViewEngine.GetView(null, viewPath, true);

        if (result.Success != true)
        {
            var searchedLocations = string.Join("\n", result.SearchedLocations);
            throw new InvalidOperationException($"Could not find this view: {viewPath}. Searched locations:\n{searchedLocations}");
        }

        var view = result.View;

        var httpContext = new DefaultHttpContext();
        httpContext.RequestServices = _serviceProvider;

        var actionContext = new ActionContext(
                httpContext,
                httpContext.GetRouteData(),
                new ActionDescriptor()
            );

        using (var writer = new StringWriter())
        {
            var viewDataDict = new ViewDataDictionary(
                new EmptyModelMetadataProvider(),
                new ModelStateDictionary());

            viewDataDict.Model = model;

            var viewContext = new ViewContext(
                actionContext,
                view,
                viewDataDict,
                new TempDataDictionary(
                    httpContext.HttpContext,
                    _tempDataProvider
                ),
                writer,
                new HtmlHelperOptions { }
            );

            await view.RenderAsync(viewContext);

            return writer.ToString();
        }
    }
}
```

Now let's create a fake implementation of the `IEmailPostman` for the integration tests:

```cs
public class FakePostman : IMailPostman
{
    public Task SendEmail(Message message)
    {
        LastMessage = message;
        return Task.CompletedTask;
    }

    public Message LastMessage { get; set; }
}
```

Let's now register all of our services:

```cs
builder.Services.AddScoped<IMailerService, MailerService>();
builder.Services.AddScoped<IEmailRenderer, RazorEmailRenderer>();
// In your project, you have to register a real postman in your app
// and swap it our with this fake postman in the integration tests
// by creating a custom WebApplicationFactory. For more info see: 
// https://docs.microsoft.com/en-us/aspnet/core/test/integration-tests?view=aspnetcore-6.0#customize-webapplicationfactory
builder.Services.AddScoped<IMailPostman, FakePostman>();
```

We create a test project called `IntegrationTests` using XUnit and inside the test project we create a folder called `Snapshots` to store the expected html results.

Then we can create our snapshot tests:

```cs
public class EmailTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly IEmailRenderer _renderer;
    private readonly string _folderPath;

    public EmailTests(WebApplicationFactory<Program> factory)
    {
        // Get the path for the snapshots folder
        var environment = factory.Services.GetRequiredService<IWebHostEnvironment>();
        _folderPath = Path.Combine(environment.ContentRootPath, "../IntegrationTests/Snapshots");

        var scope = factory.Services.CreateScope();
        _renderer = scope.ServiceProvider.GetRequiredService<IEmailRenderer>();
    }

    [Fact]
    public async Task CanSendWelcomeEmail()
    {
        var postman = new FakePostman();

        var mailService = new MailerService(_renderer, postman);

        await mailService.SendWelcomeEmail("person@example.com", new Welcome
        {
            FullName = "Example Person"
        });

        Assert.Equal("person@example.com", postman.LastMessage.Address);
        Assert.Equal("Welcome Example Person!", postman.LastMessage.Subject);

        await SaveToFile("Welcome.actual.html", postman.LastMessage.HtmlBody);
        var expectedBody = await File.ReadAllTextAsync(Path.Combine(_folderPath, "Welcome.expected.html"));

        Assert.Equal(Sanitize(postman.LastMessage.HtmlBody), Sanitize(expectedBody));
    }

    private string Sanitize(string text)
    {
        return text
            .Replace("\r\n", "\n")
            .Replace('\r', '\n');
    }

    private async Task SaveToFile(string name, string content)
    {
        var fullPath = Path.Combine(_folderPath, name);
        Directory.CreateDirectory(Path.GetDirectoryName(fullPath));
        await File.WriteAllTextAsync(fullPath, content);
    }
}
```

The first time your run `CanSendWelcomeEmail` it's going to fail because `IntegrationTests/Snapshots/Welcome.expected.html` doesn't exist. But it has created `IntegrationTests/Snapshots/Welcome.actual.html`. So go ahead and take a look at it, it should be something like this:

```html
<!DOCTYPE html>

<html>
<head>
    <meta name="viewport" content="width=device-width" />
</head>
<body>
    <div>
        <h1>Welcome Example Person</h1>
        <p>Welcome to our wonderful service!</p>
    </div>
</body>
</html>
```

You can test out the html using something like [PutsMail](https://putsmail.com/) or [Testi@](https://testi.at/). If you like the result, rename it the file to `IntegrationTests/Snapshots/Welcome.expected.html`.

Because we don't want git to track the actual results, you'll have to add this line to your .gitignore file:
```
*.actual.html
```

Now you have snapshot tests for your email templates, whenever you change them, you can easily see the results without having to manually click through the UI to send the emails. This will make your feedback loop much faster.

You can download the source code on [GitHub](https://github.com/mhmd-azeez/EmailSnapshotTesting).