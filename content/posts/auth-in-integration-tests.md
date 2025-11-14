---
title: "Mocking Authentication and Authorization in ASP.NET Core Integration Tests"
date: 2021-12-12
slug: "auth-in-integration-tests"
tags: ["aspnet", "auth", "testing"]
---
ASP.NET Core makes writing integration tests very easy and even fun. One aspect that might be a bit tough to figure out is authentication and authorization. We might want to run integration tests under different users and different roles.

To get started, let's assume we have an endpoint like this:

```cs
app.MapGet("hi", (HttpContext httpContext) =>
{
    var userId = httpContext.User?.Claims?.FirstOrDefault(c => c.Type == ClaimTypes.NameIdentifier)?.Value;

    return $"Hello #{userId}";
}).RequireAuthorization();
```

It's a very simple endpoint. It gets the currently logged in user's ID and says hello to them.

To make it possible to mock auth, we have to register a custom [`AuthenticationHandler`](https://docs.microsoft.com/en-us/dotnet/api/microsoft.aspnetcore.authentication.authenticationhandler-1?view=aspnetcore-6.0).

Here is a simple implementation of a mock Authentication Handler:

```cs
public class TestAuthHandlerOptions : AuthenticationSchemeOptions
{
    public string DefaultUserId { get; set; } = null!;
}

public class TestAuthHandler : AuthenticationHandler<TestAuthHandlerOptions>
{
    public const string UserId = "UserId";

    public const string AuthenticationScheme = "Test";
    private readonly string _defaultUserId;

    public TestAuthHandler(
        IOptionsMonitor<TestAuthHandlerOptions> options,
        ILoggerFactory logger,
        UrlEncoder encoder,
        ISystemClock clock) : base(options, logger, encoder, clock)
    {
        _defaultUserId = options.CurrentValue.DefaultUserId;
    }

    protected override Task<AuthenticateResult> HandleAuthenticateAsync()
    {
        var claims = new List<Claim> { new Claim(ClaimTypes.Name, "Test user") };

        // Extract User ID from the request headers if it exists,
        // otherwise use the default User ID from the options.
        if (Context.Request.Headers.TryGetValue(UserId, out var userId))
        {
            claims.Add(new Claim(ClaimTypes.NameIdentifier, userId[0]));
        }
        else
        {
            claims.Add(new Claim(ClaimTypes.NameIdentifier, _defaultUserId));
        }

        // TODO: Add as many claims as you need here

        var identity = new ClaimsIdentity(claims, AuthenticationScheme);
        var principal = new ClaimsPrincipal(identity);
        var ticket = new AuthenticationTicket(principal, AuthenticationScheme);

        var result = AuthenticateResult.Success(ticket);

        return Task.FromResult(result);
    }
}
```

The basic idea is this: by default authenticate every request with user id provided in the `TestAuthHandlerOptions`. If a test wants to send a request under on behalf of a different user, they can do so by sending the user ID in the `UserId` header of the HTTP request.

We also need to create a custom WebApplicationFactory that takes advantage of our mock Authentication Handler:

```cs
public class WebAppFactory : WebApplicationFactory<Program>
{
    public string DefaultUserId { get; set; } = "1";

    protected override void ConfigureWebHost(IWebHostBuilder builder)
    {
        builder.ConfigureTestServices(services =>
        {
            services.Configure<TestAuthHandlerOptions>(options => options.DefaultUserId = DefaultUserId);

            services.AddAuthentication(TestAuthHandler.AuthenticationScheme)
                .AddScheme<TestAuthHandlerOptions, TestAuthHandler>(TestAuthHandler.AuthenticationScheme, options => { });
        });
    }
}
```

We have defined a `DefaultUserId` property on the factory so that the individual test fixtures can specify their own default user ID.

And we can use the mock authentication in the test cases like this:

```cs
public class SimpleTest : IClassFixture<WebAppFactory>
{
    private HttpClient _httpClient;

    public SimpleTest(WebAppFactory factory)
    {
        factory.DefaultUserId = "5";

        _httpClient = factory.CreateClient();
        _httpClient.BaseAddress = new Uri("https://localhost/");
        // Use our mock Auth scheme 
        _httpClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Test");
    }

    [Fact]
    public async Task SayHiToNumber5()
    {
        _httpClient.DefaultRequestHeaders.Remove(TestAuthHandler.UserId);

        var response = await _httpClient.GetStringAsync("hi");
        Assert.Equal("Hello #5", response);
    }

    [Fact]
    public async Task SayHiToNumber1()
    {
        _httpClient.DefaultRequestHeaders.Add(TestAuthHandler.UserId, "1");

        var response = await _httpClient.GetStringAsync("hi");
        Assert.Equal("Hello #1", response);
    }

    [Fact]
    public async Task SayHiToNumber3()
    {
        _httpClient.DefaultRequestHeaders.Add(TestAuthHandler.UserId, "3");

        var response = await _httpClient.GetStringAsync("hi");
        Assert.Equal("Hello #3", response);
    }
}
```

And that's it! With a few lines of code, you now have a flexible mock authentication scheme that you can use in your tests. You can also customize it to match your needs.

You can download the source code on [GitHub](https://github.com/mhmd-azeez/IntegrationTestAuth).