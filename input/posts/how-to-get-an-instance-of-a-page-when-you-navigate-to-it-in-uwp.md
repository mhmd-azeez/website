Title: How to get an instance of a page when you navigate to it in UWP
Published: 05/26/2019
Tags:

 - uwp
 - navigation
---

By default when navigating a frame to a page, UWP doesn't give you back a page instance. So the only way of passing parameters is to use the `parameter` parameter. But having an instance to the page can have many other benefits: For example it allows the child page to have custom events and the parent page can subscribe to them.

However `Frame` has an event called `Navigated` that can help us to write an extension method to get a reference to the actual instance:

```csharp
using Windows.UI.Xaml.Media.Animation;
using Windows.UI.Xaml.Navigation;

namespace Windows.UI.Xaml.Controls
{
    public static class FrameExtensions
    {
        /// <summary>
        /// Navigates to a page and returns the instance of the page if it succeeded,
        /// otherwise returns null.
        /// </summary>
        /// <typeparam name="TPage"></typeparam>
        /// <param name="frame"></param>
        /// <param name="transitionInfo">The navigation transition.
        /// Example: <see cref="DrillInNavigationTransitionInfo"/> or
        /// <see cref="SlideNavigationTransitionInfo"/></param>
        /// <returns></returns>
        public static TPage Navigate<TPage>(
            this Frame frame,
            NavigationTransitionInfo transitionInfo = null)
            where TPage : Page
        {
            TPage view = null;
            void OnNavigated(object s, NavigationEventArgs args)
            {
                frame.Navigated -= OnNavigated;
                view = args.Content as TPage;
            }

            frame.Navigated += OnNavigated;

            frame.Navigate(typeof(TPage), null, transitionInfo);
            return view;
        }
    }
}
```

Suppose we have page called `Page1`:
```csharp
public sealed partial class Page1 : Page
{
    public Page1()
    {
        this.InitializeComponent();
    }

    public void Init(string param1, int param2)
    {
        // Initialize the page
    }
}
```

You can navigate to it like so:
```csharp
Page1 page = frame.Navigate<Page1>();
// You can now do stuff with the page
// for example pass in as many parameters as you want
page.Init("Hello World", 42);
```

**Note:** `Page1.Init` will be called after `Page1.OnNavigatedTo` and before `Page1.Loading`.